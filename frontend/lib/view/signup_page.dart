import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/token_manager.dart';
import '../constants.dart';
import 'signin_page.dart';
import '../controller/auth_controller.dart';

class SignupPage extends StatefulWidget {
  static const String routeName = '/signupScreen';
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  late final AuthController _authController;

  bool _obscurePassword = true;
  bool _obscureVerifyPassword = true;

  @override
  void initState() {
    super.initState();
    final authService = AuthService(
      tokenManager: TokenManager.instance,
    );

    _authController = AuthController(auth: authService);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (_formKey.currentState!.validate()) {
      final result = await _authController.signup(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (result['success']) {
              Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created! Please sign in.')),
      );
      } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${result['error']}')),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/woodGrainTexture.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 90,
                      height: 90,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'The Coop',
                      style: AppTextStyles.heading.copyWith(fontSize: 40),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Find Your Flock',
                            style: AppTextStyles.heading.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.lg),

                          // username field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: AppTextStyles.label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3 || value.length > 20) {
                                return 'Username must be 3-20 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return 'Only letters, numbers, and underscores allowed';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.md),

                          // email field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: AppTextStyles.label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.md),

                          // password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: AppTextStyles.label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }

                              bool hasUpper = RegExp(r'[A-Z]').hasMatch(value);
                              bool hasLower = RegExp(r'[a-z]').hasMatch(value);
                              bool hasDigit = RegExp(r'[0-9]').hasMatch(value);
                              bool hasSpecial = RegExp(
                                r'[@$!%*?&]',
                              ).hasMatch(value);

                              if (!hasUpper ||
                                  !hasLower ||
                                  !hasDigit ||
                                  !hasSpecial) {
                                return 'Must contain: A-Z, a-z, 0-9, @\$!%*?&';
                              }

                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.md),

                          // verify password field
                          TextFormField(
                            controller: _verifyPasswordController,
                            obscureText: _obscureVerifyPassword,
                            decoration: InputDecoration(
                              labelText: 'Verify Password',
                              labelStyle: AppTextStyles.label,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureVerifyPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureVerifyPassword =
                                        !_obscureVerifyPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please verify your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),

                          // signup button
                          ElevatedButton(
                            onPressed: _onSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                              ),
                            ),
                            child: Text('Sign Up', style: AppTextStyles.button),
                          ),

                          SizedBox(height: AppSpacing.md),

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppTextStyles.body,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SigninPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign In',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
