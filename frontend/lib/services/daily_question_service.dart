/*
  Handles daily question delivery and answer submission.
  SocketClient for real-time events and ApiClient for REST API
*/

import 'api_client.dart';
import 'socket_client.dart';

// organized daily question info
class DailyQuestionData {
  final String dailyQuestionId;
  final String question;
  final String date;
  final int answeredCount;
  final bool hasAnswered;
  final String? answerText;

  DailyQuestionData({
    required this.dailyQuestionId,
    required this.question,
    required this.date,
    required this.answeredCount,
    required this.hasAnswered,
    this.answerText,
  });

  factory DailyQuestionData.fromJson(Map<String, dynamic> json) {
    return DailyQuestionData(
      dailyQuestionId: json['dailyQuestionId'] as String,
      question: json['question'] as String,
      date: json['date'] as String,
      answeredCount: (json['answeredCount'] as int?) ?? 0,
      hasAnswered: (json['hasAnswered'] as bool?) ?? false,
      answerText: json['answerText'] as String?,
    );
  }
}

class DailyQuestionService {
  final SocketClient socket;
  final ApiClient api;

  DailyQuestionService({required this.socket, required this.api});

  // --- rest endpoints

  // fetch today's question for a room on load, returns null if none dispatched today yet
  // also returns hasAnswered so UI can determine whether to show prompt modal
  Future<DailyQuestionData?> getTodaysQuestion(String chatId) async {
    try {
      final data = await api.getJson('/daily-question/$chatId');
      return DailyQuestionData.fromJson(data);
    } catch(e) {
      if (e.toString().contains('404')) return null; // no question yet
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAnswers(String chatId) async {
    final data = await api.getJsonList('/daily-question/$chatId/answers');
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  // --- socket

  // stream of incoming daily questions pushed by server, listen so live users get the question the moment it's sent
  Stream<DailyQuestionData> onDailyQuestion() {
    return socket.on('daily_question').map(DailyQuestionData.fromJson);
  }

  // submit user's answer to the daily question, listen to onAnswerAccepted() to know when it succeeded
  void submitAnswer({
    required String dailyQuestionId,
    required String userId,
    required String answerText,
    required String chatId,
  }) {
    socket.emit('submit_daily_answer', {
      'dailyQuestionId': dailyQuestionId,
      'userId': userId,
      'answerText': answerText,
      'chatId': chatId,
    });
  }

  // fires when server confirms answer was saved, use to unlock chat view for answering user
  Stream<Map<String, dynamic>> onAnswerAccepted() {
    return socket.on('daily_answer_accepted');
  }

  // fires when any member of the room answers
  Stream<Map<String, dynamic>> onAnswerUpdate() {
    return socket.on('daily_answer_update');
  }

  // fires on any socket-level error from daily question handler
  Stream<String> onError() {
    return socket.on('daily_question_error').map((data) => data['message'] as String);
  }
}