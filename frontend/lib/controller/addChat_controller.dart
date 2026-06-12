import 'package:flutter/material.dart';
import '../services/chatroom_service.dart';
import '../view/addChat_screen.dart';
import '../view/chat_page.dart';

class AddChatController {
  AddChatScreenState state;
  final ChatroomService chatroomService;
  AddChatController(this.state, {required this.chatroomService});

  // internal fcn to show errors
  void _showError(String msg) {
    ScaffoldMessenger.of(state.context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

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
          _showError('A chatroom does not exist with the entered code.');
        } else if (e.toString().contains('409')) {
          // already a member of the chat
          _showError('You are already a member of this chat.');
        } else if (e.toString().contains('403')) {
          _showError('You are banned from joining this chat.');
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