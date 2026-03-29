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
  final RelationshipType
  relationshipType; //TODO: this is the storage for whether the user has on
  //fine grain question control, it cannot be uncommented
  //until the service is updated (but idk how that works)
  final bool fineGrainControl;
  final Set<QuestionType> questionTypePreference; //TODO: similar to above
  final Set<QuestionTopic> questionTopicPreference; //TODO: similar to above

  Chatroom({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.participants,
    required this.pinned,
    required this.membership,
    required this.lastSentMessage,
    required this.lastSentTime,
    required this.relationshipType, //TODO
    required this.fineGrainControl, //TODO
    required this.questionTypePreference, //TODO
    required this.questionTopicPreference, //TODO
  });
}
