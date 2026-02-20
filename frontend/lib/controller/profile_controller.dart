import 'package:flutter/material.dart';
import 'package:frontend/view/profilepicselection_screen.dart';
import 'package:frontend/view/profile_screen.dart';

class ProfileController {
  ProfileScreenState state;
  ProfileController(this.state);

  //profile pic edit click
  void onPressedProfilePicEdit() {
    Navigator.pushNamed(state.context, ProfilePicSelectionScreen.routeName);
  }

  //EMAIL:
  //email edit click
  void onPressedEditEmail() {
    print('edit email clicked');
    state.callSetState(() {
      state.model.isEditingEmail = true;
    });
    print(state.model.isEditingEmail);
  }

  //save email edit
  void onPressedEditEmailSave() {
    final form = state.formKeyEmail.currentState;

    if (form!= null && form.validate()) {
      form.save();
    }
    print('email save clicked');
  }

  void onSaveEmail(String? value) {
    //TODO: logic for updating email in db

    state.callSetState(() {
      state.model.isEditingEmail = false;
    });

    print(value);
    print('FORM: email save clicked');
  }

  void onPressedEditEmailCancel() {
    print('email cancel clicked');
    state.callSetState(() {
      state.model.isEditingEmail = false;
    });
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  //USERNAME:
  //username edit click
  void onPressedEditUsername() {
    state.callSetState(() {
      state.model.isEditingUsername = true;
    });
    print('edit username clicked');
  }

  void onPressedEditUsernameSave() {
    final form = state.formKeyUsername.currentState;

    if (form!= null && form.validate()) {
      form.save();
    }
    print('username save clicked');
  }

  void onSaveUsername(String? value) {
    //TODO: logic for updating username in db

    state.callSetState(() {
      state.model.isEditingUsername = false;
    });
    print(value);
    print('FORM: username save clicked');
  }

  void onPressedEditUsernameCancel() {
    print('username cancel clicked');
    state.callSetState(() {
      state.model.isEditingUsername = false;
    });
  }

  String? usernameValidator(String? value) {
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
  }

  //password reset click
  void onPressedPasswordReset() {
    print('password reset clicked');
    //navigate to password reset page
  }

  //info click
  void onPressedInfo() {
    print('info clicked');
    //navigate to info page
  }
}
