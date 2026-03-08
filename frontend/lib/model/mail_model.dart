import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/profile_model.dart';

class MailModel {
  List<Chatroom>? chatroomList; //chatroomList should equal all the chatrooms the user is in
  Chatroom? selectedChatroom;
  User? currentUser; //for grabbing pigeonid when user is alone in a chatroom
}