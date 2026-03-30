import 'package:frontend/services/daily_question_service.dart';
import '../model/prompt_model.dart';

class DailyPromptController {
  final DailyQuestionService _dqService;
  final String chatId;
  final String currentUserId;
  String? _dailyQuestionId;

  DailyPromptController(this._dqService, this.chatId, this.currentUserId);

  // get prompt
  Future<Map<String, dynamic>> getTodaysPrompt() async {
    try {
      final response = await _dqService.getTodaysQuestion(chatId);
      if (response == null) {
        return { 
          'success': false, 
          'error': 'No prompt today' 
        };
      }
      _dailyQuestionId = response.dailyQuestionId; // store for submit answer
      final prompt = DailyPrompt(
        id: response.dailyQuestionId,
        chatId: '',
        questionText: response.question,
        date: response.date,
        answeredCount: response.answeredCount,
        hasAnswered: response.hasAnswered,
      );
      return { 
        'success': true, 
        'prompt': prompt 
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // submit answer 
  Future<Map<String, dynamic>> submitAnswer(String answerText) async {
    try {
      if (_dailyQuestionId == null) {
        return {
        'success': false,
        'error': 'No active prompt',
        };
      }
      _dqService.submitAnswer(
        dailyQuestionId: _dailyQuestionId!, 
        userId: currentUserId, 
        answerText: answerText, 
        chatId: chatId
      );
      // response comes back through onAnswerAccepted stream
      return { 'success': true };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // get all responses 
  Future<Map<String, dynamic>> getTodaysResponses() async {
    try {
      final data = await _dqService.getAnswers(chatId);
      final responses = data.map((r) => PromptResponse.fromJson(r, currentUserId)).toList();
      
      return {
        'success': true,
        'responses': responses,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}