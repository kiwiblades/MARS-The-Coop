class ChatModel {
  bool isLoading = false;
  String? loadError;
  bool isTyping = false;
  bool showFullGroupName = false;
}

class Message {
  final String id;
  final String content;
  final String senderUsername;
  final String senderId;
  final DateTime timestamp;
  final bool isSentByCurrentUser;
  final int? senderPigeonId;

  Message({
    required this.id,
    required this.content,
    required this.senderUsername,
    required this.senderId,
    required this.timestamp,
    required this.isSentByCurrentUser,
    this.senderPigeonId,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      senderUsername: (json['sender'] as Map<String, dynamic>?)?['username'] as String? ?? '',
      senderId: json['sender_id'] as String,
      timestamp: DateTime.parse(json['createdAt'] as String),
      isSentByCurrentUser: json['sender_id'] == currentUserId,
      senderPigeonId: null, // TODO: need in response
    );
  }
}

class ChatGroup {
  final dynamic id;
  final String name;
  final int memberCount;
  final List<String> memberAvatars;
  final List<String>? memberNames;

  ChatGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.memberAvatars,
    this.memberNames,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Group',
      memberCount: json['memberCount'] ?? 0,
      memberAvatars: List<String>.from(json['memberAvatars'] ?? []),
      memberNames: json['memberNames'] != null   
        ? List<String>.from(json['memberNames'])
        : null,
    );
  }
}