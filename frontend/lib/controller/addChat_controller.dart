import 'package:flutter/material.dart';
import 'package:frontend/view/addChat_screen.dart';

class AddChatController {
  AddChatScreenState state;
  AddChatController(this.state);

  //code validator
  String? chatCodeValidator(String? value) {
    if(value == null || value.isEmpty) {
      return 'Please enter code to join';
    }
    return null;
  }

  //join button
  void onPressJoin() {
    final form = state.formKey.currentState;

    if(form != null && form.validate()) {
      print('validation passed');
      //TODO: joining a chat 
      //handle error of not being a correct code
      //navigate back to mail page once joined, make sure the view updates to show new chat
    }

    print('join pressed');
  }

  //create new button
  void onPressCreateNew() {
    print('on press create new');
    //navigate to create new page
    Navigator.pushNamed(state.context, '/createChatScreen');
  }
}