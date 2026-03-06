import 'package:flutter/material.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/view/profilePicSelection_screen.dart';
import 'package:frontend/view/profile_screen.dart';

class ProfileController {
  ProfileScreenState state;
  final UserService users;
  ProfileController(this.state, {required this.users});

  Future<void> loadUser() async {
    state.callSetState(() {
      state.isLoading = true;
      state.loadError = null;
    });

    try {
      final user = await users.getProfile();
      state.callSetState(() {
        state.currentUser = user;
        state.isLoading = false;
      });
    } catch (e) {
      state.callSetState(() {
        state.loadError = 'Failed to load profile';
        state.isLoading = false;
      });
    }
  }

  // internal fcn to show errors
  void _showError(String msg) {
    ScaffoldMessenger.of(
      state.context,
    ).showSnackBar(SnackBar(content: Text(msg)));
  }

  //profile pic edit click
  Future<void> onPressedProfilePicEdit() async {
    final result = await Navigator.pushNamed(
      state.context,
      ProfilePicSelectionScreen.routeName,
    );

    if (result is int) {
      state.callSetState(() {
        // update local cached user
        state.currentUser!.pigeonId = result;
      });
    } else {
      // do nothing if no change
    }
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

    if (form != null && form.validate()) {
      form.save();
    }
    print('email save clicked');
  }

  Future<void> onSaveEmail(String? value) async {
    final newEmail = value?.trim().toLowerCase();
    if (newEmail == null || newEmail.isEmpty) return;

    try {
      final updated = await users.updateProfile(email: newEmail);

      state.callSetState(() {
        state.currentUser = updated;
        state.model.isEditingEmail = false;
      });
    } catch (e) {
      _showError('Failed to update email');
    }

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

    if (form != null && form.validate()) {
      form.save();
    }
    print('username save clicked');
  }

  Future<void> onSaveUsername(String? value) async {
    final newUsername = value?.trim();
    if (newUsername == null || newUsername.isEmpty) return;

    try {
      final updated = await users.updateProfile(username: newUsername);

      state.callSetState(() {
        state.currentUser = updated;
        state.model.isEditingUsername = false;
      });
    } catch (e) {
      _showError('Failed to update username');
    }
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
    Navigator.pushNamed(state.context, '/resetPasswordScreen');
  }

  //info click
  void onPressedInfo() {
    print('info clicked');
    //navigate to info page
  }

  void onPressedSignOutButton() async { // The 'async' keyword marks this as a background-compatible function
    print('sign out button pressed');
    //sign out logic
    // Navigator.pushNamed(state.context, '/signinScreen'); //navigate to sign in page

      try {
        // Call backend to invalidate the session/token
        await users.logout();

        // Confirm status and redirect
        // Using pushNamedAndRemoveUntil ensures the user cannot hit 'back' to return to the profile
        Navigator.pushNamedAndRemoveUntil(
          state.context, 
          '/signinScreen', // Assuming this is your route name for login
          (route) => false, 
        );
        
        _showSuccess('Successfully signed out');
      } catch (e) {
        // Even if the network call fails, we usually clear local storage and redirect
        print('Logout error: $e');
        _showError('Sign out failed. Please try again.');
      }
    }

    // Helper for success messages 
    void _showSuccess(String msg) {
    ScaffoldMessenger.of(state.context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
    );
  }

