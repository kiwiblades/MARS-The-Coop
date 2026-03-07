// frontend/lib/controller/chat_controller.dart

import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../model/chat_model.dart';

class ChatController {
  final ApiClient _apiClient;
  final String chatId;
  final String currentUserId;

  ChatController(this._apiClient, this.chatId, this.currentUserId);

  // load chat messages
  Future<Map<String, dynamic>> loadMessages({int offset = 0, int limit = 50}) async {
    try {
      final response = await _apiClient.getJson('/chat/$chatId/messages?offset=$offset&limit=$limit');
      
      final messages = (response['messages'] as List)
          .map((msg) => Message.fromJson(msg, currentUserId))
          .toList();
      
      return {
        'success': true,
        'messages': messages,
        'hasMore': response['hasMore'] ?? false,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // load chat group info
  Future<Map<String, dynamic>> loadChatInfo() async {
    try {
      final response = await _apiClient.getJson('/chat/$chatId');
      final chatGroup = ChatGroup.fromJson(response);
      
      return {
        'success': true,
        'chatGroup': chatGroup,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // send a message
  Future<Map<String, dynamic>> sendMessage(String content) async {
    try {

      final response = await _apiClient.postJson('/chat/$chatId/messages', {
        'content': content,
      });
      
      final message = Message.fromJson(response, currentUserId);
      
      return {
        'success': true,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // leave chat
  Future<Map<String, dynamic>> leaveChat() async {
    try {
      await _apiClient.postJson('/chat/$chatId/leave', {});
      
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // typing indicator
  Future<void> sendTypingIndicator(bool isTyping) async {
    try {
      await _apiClient.postJson('/chat/$chatId/typing', {
        'isTyping': isTyping,
      });
    } catch (e) {
    }
  }
}