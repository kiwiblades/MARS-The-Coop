import 'package:flutter/material.dart';
import 'package:frontend/view/profilepicselection_screen.dart';

class ProfilePicSelectionController {
  final ProfilePicSelectionScreenState state;
  ProfilePicSelectionController(this.state);

  void onTapPigeon(int index) {
    state.callSetState(() {
      state.model.selectedPigeonIndex = index;
    });
    // print(index);
  }

  void onPressedSave() {
    //TODO: update user to have the pigeonId that is the selected Pigeon Index
    //state.model.selectedPigeonIndex corresponds to the pigeonId
    Navigator.pushNamed(state.context, '/profileScreen');
  }
}
