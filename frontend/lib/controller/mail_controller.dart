import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/view/chat_page.dart';
import 'package:frontend/view/mail_screen.dart';

class MailController {
  MailScreenState state;
  final ChatroomService chatroomService;
  final UserService userService;
  MailController(this.state, {required this.chatroomService, required this.userService});

  Future<void> loadChatrooms() async {
    try {
      // fetch both chatrooms and current user at the same time
      final results = await Future.wait([
        chatroomService.getChatrooms(),
        userService.getProfile(),
      ]);
      final chatrooms = results[0] as List<Chatroom>;
      final user = results[1] as User;
      state.callSetState(() {
        state.model.chatroomList = chatrooms;
        state.model.currentUser = user;
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
  void onTapChat(BuildContext context, Chatroom chat) async {
    print('on tap chat called');
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(
      // pass chat info values
      chatId: chat.id,
      chatName: chat.name,
      participants: chat.participants,
      membership: chat.membership,
    )));
    loadChatrooms(); // reload chatrooms on return to display the newest message + sort properly
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

  // format the most recent msg timestamp
  String formatChatTimestamp(String isoString) {
    if (isoString.isEmpty) return '';
    final date = DateTime.tryParse(isoString)?.toLocal();
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    // choose based on how long ago the msg was
    if (msgDay == today) { // within the day, show direct time
      // format like 3:30 PM
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (msgDay == yesterday) { // show yesterday directly
      return 'Yesterday';
    } else if (today.difference(msgDay).inDays < 7) { // if within the week, show weekday
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday-1];
    } else { // otherwise, give direct date
      return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
    }
  }
}