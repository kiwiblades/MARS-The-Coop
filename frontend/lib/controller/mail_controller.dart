import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/view/mail_screen.dart';

class MailController {
  MailScreenState state;
  MailController(this.state);

  //TODO: load chatrooms

  //onTap chat --> navigate to corresponding chat room
  void onTapChat(BuildContext context, Chatroom chat) {
    print('on tap chat called');
    //TODO: navigate to the chatroom that was clicked on
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

  void onPressPin(BuildContext context) {
    print('pin tapped');
    print(state.model.selectedChatroom!.pinned); //testing
    state.callSetState(() {
      //TODO: logic to pin/unpin chat in database
      state.model.selectedChatroom!.pinned = !state.model.selectedChatroom!.pinned; //reverse pin bool
    });
    print(state.model.selectedChatroom!.pinned);
    Navigator.pop(context);
  }

  //click floating action button
  void onPressAddChatButton() {
    print('on press add chat button pressed');
    Navigator.pushNamed(state.context, '/addChatScreen');
  }
}