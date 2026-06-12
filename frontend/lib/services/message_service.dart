/*
  Handles real-time message delivery w/ Socket.io
  Uses SocketClient for connection
*/

import '../model/chat_model.dart';
import 'api_client.dart';
import 'socket_client.dart';

class MessageService {
  final SocketClient socket;
  final ApiClient api;
  final String currentUserId;

  MessageService({required this.socket, required this.api, required this.currentUserId});

  // send a message to a room via socket
  void sendMessage({
    required String chatId,
    required String content,
    required String senderId,
  }) {
    try {
      socket.emit('send_message', {
        'chat_id': chatId,
        'content': content,
        'sender_id': senderId,
      });
    } catch(e) {
      // fall back to HTTP if socket fails
      print('[MessageService] socket emit failed, falling back to HTTP: $e');
      _sendMessageHttp(chatId: chatId, content: content)
        .catchError((e) {
          print('[MessageService] HTTP fallback failed for sending message: $e');
        });
    }
  }

  // stream of incoming messages for the currently joined room, listen in chat screen
  Stream<Message> onReceiveMessage() {
    return socket.on('receive_message').map((data) => Message.fromJson(data, currentUserId));
  }

  Future<List<Message>> getChatHistory(String chatId) async {
    final data = await api.getJson('/chat/$chatId/messages');
    final messages = data['messages'] as List<dynamic>;
    return messages
      .map((m) => Message.fromJson(m as Map<String, dynamic>, currentUserId))
      .toList()
      .reversed.toList(); // show oldest first for display (top down)
  }

  Future<void> _sendMessageHttp({
    required String chatId,
    required String content,
  }) async {
    await api.postJson('/chat/$chatId/messages', {'content': content});
  }
}