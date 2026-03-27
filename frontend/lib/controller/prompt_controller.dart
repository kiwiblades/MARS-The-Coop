import '../services/api_client.dart';
import '../model/prompt_model.dart';

class DailyPromptController {
  final ApiClient _apiClient;
  final String chatId;
  final String currentUserId;

  DailyPromptController(this._apiClient, this.chatId, this.currentUserId);

  // get prompt
  Future<Map<String, dynamic>> getTodaysPrompt() async {
    try {
      // TODO: Backend needs GET /chat/:chatId/daily-prompt endpoint
      final response = await _apiClient.getJson('/chat/$chatId/daily-prompt');
      
      final prompt = DailyPrompt.fromJson(response);
      
      return {
        'success': true,
        'prompt': prompt,
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
      // TODO: connect backend
      final response = await _apiClient.postJson(
        '/chat/$chatId/daily-prompt/answer',
        {'answerText': answerText},
      );
      
      return {
        'success': true,
        'response': response,
      };
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
      // TODO: connect backend
      final response = await _apiClient.getJson('/chat/$chatId/daily-prompt/responses');
      
      final responses = (response['responses'] as List)
          .map((r) => PromptResponse.fromJson(r, currentUserId))
          .toList();
      
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