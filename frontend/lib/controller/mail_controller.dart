import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/view/chat_page.dart';
import 'package:frontend/view/mail_screen.dart';

class MailController {
  MailScreenState state;
  final ChatroomService chatroomService;
  MailController(this.state, {required this.chatroomService});

  Future<void> loadChatrooms() async {
    try {
      final chatrooms = await chatroomService.getChatrooms();
      state.callSetState(() {
        state.model.chatroomList = chatrooms;
      });
    } catch (e) {
      if (e.toString().contains('404')) {
        print('no chatrooms currently');
        state.callSetState(() {
          state.model.chatroomList = [];
        });
        
      } else {
        print('failed to load chatrooms: $e');
      }
      
      // TODO: display error
    }
  }

  //onTap chat --> navigate to corresponding chat room
  void onTapChat(BuildContext context, Chatroom chat) {
    print('on tap chat called');
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(
      chatId: chat.id,
    )));
  }

  //long tap on chat --> pin
  void onLongPressChat(BuildContext context, Chatroom chat) {
    print('long tap chat called');
    //update selected chat room
    state.callSetState(() {
      state.model.selectedChatroom = chat;
    });

    state.showPinModal(context); //show the pin chat dialog
  }

  void onPressPin(BuildContext context) async {
    print('pin tapped');
    final chatroom = state.model.selectedChatroom!;
    try {
      await chatroomService.togglePin(chatroom.id);
      state.callSetState(() {
        chatroom.pinned = !chatroom.pinned; // reflect the change locally
      });
    } catch (e) {
      print('Failed to toggle pin: $e');
      // TODO: display error
    }
    print(state.model.selectedChatroom!.pinned);
    Navigator.pop(context);
  }

  //click floating action button
  void onPressAddChatButton() async {
    print('on press add chat button pressed');
    await Navigator.pushNamed(state.context, '/addChatScreen');
    loadChatrooms(); // refresh list when returning from create screen
  }
}