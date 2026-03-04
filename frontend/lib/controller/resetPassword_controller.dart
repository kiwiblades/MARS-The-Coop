import 'package:frontend/view/resetPassword_screen.dart';

class ResetPasswordController {
  ResetPasswordScreenState state;
  ResetPasswordController(this.state);

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

  void onPressedSave() {
    final form = state.formKey.currentState;

    if (form != null && form.validate()) {
      print('Validation passed'); //validation only for new password
      //TODO: add password reset backend functionality
    }

    print('password save clicked'); //test print out
  }
}
