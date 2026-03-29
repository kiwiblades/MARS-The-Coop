import 'package:flutter/material.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/view/addChat_screen.dart';
import 'package:frontend/view/chat_page.dart';

class AddChatController {
  AddChatScreenState state;
  final ChatroomService chatroomService;
  AddChatController(this.state, {required this.chatroomService});

  //code validator
  String? chatCodeValidator(String? value) {
    if(value == null || value.isEmpty) {
      return 'Please enter code to join';
    }
    return null;
  }

  //join button
  void onPressJoin() async {
    final form = state.formKey.currentState;

    if(form != null && form.validate()) {
      print('validation passed');
      try {
        await chatroomService.joinChatroom(state.chatroomCodeController.text);

        // fetch updated chatroom list to find newly joined room
        final chatrooms = await chatroomService.getChatrooms();
        final joined = chatrooms.firstWhere(
          (c) => c.inviteCode.toUpperCase() == state.chatroomCodeController.text.trim().toUpperCase(),
        );

        Navigator.of(state.context).pop(); // return to mail screen
        Navigator.of(state.context).push( // push the newly joined chay
          MaterialPageRoute(
            builder: (_) => ChatPage(
              chatId: joined.id,
              chatName: joined.name,
              participants: joined.participants,
              membership: joined.membership,
              chatroomService: chatroomService,
              chatroom: joined,
            ),
          ),
        );
      } catch (e) {
        print('failed to join chatroom: $e');
        if (e.toString().contains('404')) {
          // chat doesn't exist
          // TODO: display error
        } else if (e.toString().contains('409')) {
          // already a member of the chat
          // TODO: display error
        }
      }
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