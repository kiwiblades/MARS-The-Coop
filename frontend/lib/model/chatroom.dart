import 'package:frontend/model/profile_model.dart';

class Chatroom {
  final String id;
  final String name;
  final String inviteCode;
  final List<User> participants;
  bool pinned;
  final String membership;
  final String lastSentMessage;
  final String lastSentTime;

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