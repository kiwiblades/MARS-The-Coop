import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/view/resetPassword_screen.dart';
import 'package:frontend/view/signin_page.dart';

class ResetPasswordController {
  ResetPasswordScreenState state;
  final AuthService auth;
  ResetPasswordController(this.state, {required this.auth});

  //new password validator
  String? newPasswordValidator(String? value) {
    //password cannot be empty
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    //password must have at least 8 characters
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    bool hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    bool hasLower = RegExp(r'[a-z]').hasMatch(value);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(value);
    bool hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(value);

    //password must have an uppercase, lowercase, number and special character
    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'Must contain an uppercase letter, lowercase letter, number and special character(@\$!%*?&).';
    }

    return null;
  }

  String? confirmPasswordValidator(String? value) {
    //password cannot be empty
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value != state.newPasswordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  // internal fcn to show errors
  void _showError(String msg) {
    ScaffoldMessenger.of(state.context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void onPressedSave() async {
    final form = state.formKey.currentState;

    if (form != null && form.validate()) {
      print('Validation passed'); //validation only for new password
      final currentPassword = state.currentPasswordController.text;
      final newPassword = state.newPasswordController.text;
      
      try {
        await auth.changePassword(currentPassword: currentPassword, newPassword: newPassword);
        print('Password changed successfully');
        await auth.logout();
        Navigator.of(state.context).pushNamedAndRemoveUntil(
          SigninPage.routeName,
          (route) => false,
        );
      } catch(e) {
        print('Error changing password: $e');
        _showError('Failed to update password');
      }
      //sign out and direct to sign in page
    }

    print('password save clicked'); //test print out
  }
}
