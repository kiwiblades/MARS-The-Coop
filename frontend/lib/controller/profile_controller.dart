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

  //email edit click
  void onPressedEditEmail() {
    print('edit email clicked');
    //navigate to edit email page
  }
  
  //username edit click
  void onPressedEditUsername() {
    print('edit username clicked');
    //navigate to edit username page
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
