import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/view/mail_screen.dart';

class MailController {
  MailScreenState state;
  MailController(this.state);

  //TODO: load chatrooms

  //onTap chat --> navigate to corresponding chat room

  //long tap on chat --> pin
  void onLongPressChat(BuildContext context, Chatroom chat) {
    print('long tap chat called');
    //update selected chat room
    state.callSetState(() {
      state.model.selectedChatroom = chat;
    });
    
    state.showPinModal(context); //show the pin chat dialog
  }

  //on tap pin icon --> unpin

  //click floating action button
}