import 'package:flutter/material.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/view/createChat_screen.dart';

class CreateChatController {
  CreateChatScreenState state;
  final ChatroomService chatroomService;
  CreateChatController(this.state, {required this.chatroomService});

  //name validator
  String? chatNameValidator(String? value) {
    final RegExp validInput = RegExp(r'^[a-zA-Z0-9@$!%*?&]+$');
    if(value == null || value.isEmpty) {
      return 'Please enter name';
    }
    if(value.length > 20) {
      return 'Chat name cannot be greater than 20 characters';
    }
    if(!validInput.hasMatch(value)) {
      return 'Only letters, numbers, and @\$!%*?& allowed';
    }

    return null;
  }

  //create button
  void onPressCreate() async {
    final form = state.formKey.currentState;

    if(form != null && form.validate()) {
      print('validation passed');
      try {
        await chatroomService.createChatroom(state.chatroomNameController.text);
        Navigator.pop(state.context); // back to invite screen
        Navigator.pop(state.context); // back to mail screen
      } catch (e) {
        print('failed to create chatroom: $e');
        // TODO: dispaly error
      }
    }

    print('create pressed');
  }

}