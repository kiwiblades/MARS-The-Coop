import 'package:frontend/model/chatroom.dart';

class MailModel {
  List<Chatroom>? chatroomList = [...testChats, ...testChats, ...testChats]; //chatroomList should equal all the chatrooms the user is in
  Chatroom? selectedChatroom;
}