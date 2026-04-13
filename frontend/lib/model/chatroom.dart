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
  final List<User> bannedUsers;
  final User owner;
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
    required this.bannedUsers,
    required this.owner,
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
    final bannedUsers = (json['bannedUsers'] as List<dynamic>? ?? [])
      .map((p) => User.fromJson(p as Map<String, dynamic>))
      .toList();
    final owner = User.fromJson(json['owner'] as Map<String, dynamic>);
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
      bannedUsers: bannedUsers,
      owner: owner,
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

  Chatroom copyWith({
    String? id,
    String? name,
    String? inviteCode,
    List<User>? participants,
    List<User>? bannedUsers,
    User? owner,
    bool? pinned,
    String? membership,
    String? lastSentMessage,
    String? lastSentTime,
    RelationshipType? relationshipType,
    bool? fineGrainControl,
    Set<QuestionTopic>? allowedTopics,
    Set<QuestionType>? allowedTypes,
    int? unreadCount,
    bool? hasPendingQuestion,
  }) {
    return Chatroom(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      participants: participants ?? this.participants,
      bannedUsers: bannedUsers ?? this.bannedUsers,
      owner: owner ?? this.owner,
      pinned: pinned ?? this.pinned,
      membership: membership ?? this.membership,
      lastSentMessage: lastSentMessage ?? this.lastSentMessage,
      lastSentTime: lastSentTime ?? this.lastSentTime,
      relationshipType: relationshipType ?? this.relationshipType,
      fineGrainControl: fineGrainControl ?? this.fineGrainControl,
      allowedTopics: allowedTopics ?? this.allowedTopics,
      allowedTypes: allowedTypes ?? this.allowedTypes,
      unreadCount: unreadCount ?? this.unreadCount,
      hasPendingQuestion: hasPendingQuestion ?? this.hasPendingQuestion
    );
  }
}

