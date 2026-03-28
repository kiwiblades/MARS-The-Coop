import 'package:flutter/material.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/view/chat_page.dart';
import 'package:frontend/view/createChat_screen.dart';

class CreateChatController {
  CreateChatScreenState state;
  final ChatroomService chatroomService;
  CreateChatController(this.state, {required this.chatroomService});

  //name validator
  String? chatNameValidator(String? value) {
    final RegExp validInput = RegExp(r'^[ a-zA-Z0-9@$!%*?&]+$');
    if(value == null || value.isEmpty) {
      return 'Please enter name';
    }
    if(value.length > 20) {
      return 'Chat name cannot be greater than 20 characters';
    }
    if(!validInput.hasMatch(value)) {
      return 'Only letters, numbers, spaces, and @\$!%*?& allowed';
    }

    return null;
  }

  //create button
  void onPressCreate() async {
    final form = state.formKey.currentState;

    if(form != null && form.validate()) {
      print('validation passed');
      try {
        final chatroom = await chatroomService.createChatroom(state.chatroomNameController.text);
        Navigator.pushAndRemoveUntil( // remove the create chat and join chat pages from the stack
          state.context,
          MaterialPageRoute(
            builder: (_) => ChatPage( // jump to the new chat page
              chatId: chatroom.id,
              chatName: chatroom.name,
              participants: const [],
              membership: 'owner',
              chatroomService: chatroomService,
            ),
          ),
          (route) => route.settings.name == '/mailScreen', // keep mail screen on the stack
        );

        // delay invite code popup so there's time to navigate to the chatroom
        Future.delayed(const Duration(milliseconds: 100), () {
          showCodePopup(state.context, chatroom.inviteCode);
        });
      } catch (e) {
        print('failed to create chatroom: $e');
        // TODO: dispaly error
      }
    }

    print('create pressed');
  }

}