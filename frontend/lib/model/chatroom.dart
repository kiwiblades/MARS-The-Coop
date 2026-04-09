import 'package:frontend/model/profile_model.dart';

//enum for possible relationship types a chat can fall under
enum RelationshipType { acquaintances, family, friends, romantic }

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
  String lastSentMessage;
  String lastSentTime;
  final RelationshipType relationshipType;
  final bool fineGrainControl;
  final Set<QuestionTopic> allowedTopics;
  final Set<QuestionType> allowedTypes;
  int unreadCount;
  bool hasPendingQuestion;

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
    required this.unreadCount,
    required this.hasPendingQuestion,
  });

  factory Chatroom.fromJson(Map<String, dynamic> json) {
    final chatroom = json['chatroom'] as Map<String, dynamic>? ?? json;
    final membership = json['membership'] as Map<String, dynamic>? ?? {};
    final participants = (json['participants'] as List<dynamic>? ?? [])
      .map((p) => User.fromJson(p as Map<String, dynamic>))
      .toList();
    final settings = json['settings'] as Map<String, dynamic>? ?? {};
    final allowedTopics = (settings['allowedTopics'] as List<dynamic>? ?? [])
      .map((t) => t as String).toList();
    final allowedTypes = (settings['allowedTypes'] as List<dynamic>? ?? [])
      .map((t) => t as String).toList();

    return Chatroom(
      id: chatroom['id'] as String,
      name: chatroom['name'] as String,
      inviteCode: chatroom['inviteCode'] as String? ?? '',
      participants: participants,
      pinned: membership['pinned'] as bool? ?? false,
      membership: membership['role'] as String? ?? 'member',
      lastSentMessage: json['lastSentMessage'] as String? ?? '',
      lastSentTime: json['lastSentTime'] as String? ?? '',
      relationshipType: RelationshipType.values.firstWhere(
        (e) => e.name.toLowerCase() == (settings['relationshipType'] as String? ?? 'friends').toLowerCase(),
        orElse: () => RelationshipType.friends,
      ),
      fineGrainControl: allowedTypes.isNotEmpty || allowedTypes.isNotEmpty,
      allowedTypes: allowedTypes.map((t) => QuestionType.values.firstWhere(
        (q) => q.name.toLowerCase() == t.toLowerCase(),
        orElse: () => QuestionType.favorite,
      )).toSet(),
      allowedTopics: allowedTopics.map((t) => QuestionTopic.values.firstWhere(
        (q) => q.name.toLowerCase() == t.toLowerCase(),
        orElse: () => QuestionTopic.personal,
      )).toSet(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      hasPendingQuestion: json['hasPendingQuestion'] as bool? ?? false,
    );
  }
}
