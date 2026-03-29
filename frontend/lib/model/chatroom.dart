import 'package:frontend/model/profile_model.dart';

//enum for possible relationship types a chat can fall under
enum RelationshipType { acquaintance, family, friends, romantic }

enum QuestionType {
  favorite,
  wouldYouRather,
  ranking,
  ifYouCould,
  ifYouWere,
  whatTypeAreYou,
  prompt,
  riddle,
  whatsYourOpinion,
  firsts,
  kissMarryKill,
  memory,
}

enum QuestionTopic { personal, politics, religion, intimacy, romance, death }

class Chatroom {
  final String id;
  final String name;
  final String inviteCode;
  final List<User> participants;
  bool pinned;
  final String membership;
  final String lastSentMessage;
  final String lastSentTime;
  final RelationshipType relationshipType;
  final bool fineGrainControl;
  final Set<QuestionTopic> allowedTopics;
  final Set<QuestionType> allowedTypes;

  Chatroom({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.participants,
    required this.pinned,
    required this.membership,
    required this.lastSentMessage,
    required this.lastSentTime,
    required this.relationshipType,
    required this.fineGrainControl,
    required this.allowedTopics,
    required this.allowedTypes,
  });
}
