import 'package:flutter/material.dart';
import 'package:frontend/controller/resetPassword_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/resetPasswordScreen';
  const ResetPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ResetPasswordScreenState();
  }
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final ResetPasswordController controller;
  //model attach
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = ResetPasswordController(this);
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD1A681),
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xFFD1A681),
          title: const Text('Reset Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Password',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                    // validator: controller.newPasswordValidator,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'New Password',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.newPasswordValidator,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Confirm New Password',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.confirmPasswordValidator,
                    // onSaved: controller.onSave,
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.onPressedSave,
                          child: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
