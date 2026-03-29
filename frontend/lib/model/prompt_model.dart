class DailyPrompt {
  final String id;
  final String chatId;
  final String questionText;
  final String date;
  final int answeredCount;
  bool hasAnswered;

  DailyPrompt({
    required this.id,
    required this.chatId,
    required this.questionText,
    required this.date,
    required this.answeredCount,
    this.hasAnswered = false,
  });

  factory DailyPrompt.fromJson(Map<String, dynamic> json) {
    return DailyPrompt(
      id: json['dailyQuestionId'] as String,
      chatId: '', // not returned by backend
      questionText: json['question'] as String,
      date: json['date'] as String,
      answeredCount: json['answeredCount'] ?? 0,
      hasAnswered: json['hasAnswered'] ?? false,
    );
  }
}

class PromptResponse {
  final String id;
  final String dailyQuestionId;
  final String userId;
  final String username;
  final int? pigeonId;
  final String answerText;
  final DateTime answeredAt;
  final bool isSentByCurrentUser;

  PromptResponse({
    required this.id,
    required this.dailyQuestionId,
    required this.userId,
    required this.username,
    this.pigeonId,
    required this.answerText,
    required this.answeredAt,
    required this.isSentByCurrentUser,
  });

  factory PromptResponse.fromJson(Map<String, dynamic> json, String currentUserId) {
    return PromptResponse(
      id: json['id'],
      dailyQuestionId: json['dailyQuestionId'],
      userId: json['userId'],
      username: json['username'] ?? 'Unknown',
      pigeonId: json['pigeonId'],
      answerText: json['answerText'] ?? '',
      answeredAt: DateTime.parse(json['answeredAt']),
      isSentByCurrentUser: json['userId'] == currentUserId,
    );
  }
}

class DailyPromptModel {
  bool isLoading = false;
  String? loadError;
  bool isSubmitting = false;
  String? submitError;
}