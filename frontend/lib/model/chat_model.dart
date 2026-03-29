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
      senderPigeonId: (json['sender'] as Map<String, dynamic>?)?['pigeonId'] as int?,
    );
  }
}

class PromptQASection {
  final String questionId;
  final String questionText;
  final DateTime askedAt;
  final List<String> answerMessageIds; // IDs of messages that are answers

  PromptQASection({
    required this.questionId,
    required this.questionText,
    required this.askedAt,
    required this.answerMessageIds,
  });
}