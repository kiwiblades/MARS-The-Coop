import 'package:frontend/model/journal.dart';
import 'package:frontend/model/profile_model.dart';

class MyCoopModel {
  List<Journal>? journalList;
  User? currentUser;
  List<User>?
  friendList; //list of user's the current user shares a chat with, should exclude journals they already have
}
