import 'package:frontend/model/profile_model.dart';

enum RelationshipType {
  acquaintance, 
  family,
  friends, 
  romantic
}

class Chatroom {
  final String id;
  final String name;
  final String inviteCode;
  final List<User> participants;
  bool pinned;
  final String membership;
  final String lastSentMessage;
  final String lastSentTime;
  //relationshiptype
  //fine grain control bool
  //question type preference list
  //question topic preference list

  Chatroom({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.participants,
    required this.pinned,
    required this.membership,
    required this.lastSentMessage,
    required this.lastSentTime,
  });
}