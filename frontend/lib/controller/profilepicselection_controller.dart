import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../view/profilePicSelection_screen.dart';

class ProfilePicSelectionController {
  final ProfilePicSelectionScreenState state;
  final UserService users;
  ProfilePicSelectionController(this.state, {required this.users});

  // internal fcn to show errors
  void _showError(String msg) {
    ScaffoldMessenger.of(state.context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void onTapPigeon(int index) {
    state.callSetState(() {
      state.model.selectedPigeonIndex = index;
    });
    // print(index);
  }

  Future<void> onPressedSave() async {
    final pigeonId = state.model.selectedPigeonIndex;

    try {
      await users.updateProfile(pigeonId: pigeonId);
      if (!state.mounted) return;
      Navigator.pushNamed(state.context, '/profileScreen');
    } catch(e) {
      _showError('Failed to update profile picture. Please make sure a pigeon is selected.');
    }
  }
}