import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/services/message_service.dart';
import '../model/chat_model.dart';

class ChatController {
  final MessageService _messageService;
  final ChatroomService chatroomService;
  final String chatId;
  final String currentUserId;

  ChatController(
    this._messageService, 
    this.chatId, 
    this.currentUserId, 
    {required this.chatroomService}
  );

  // join socket room for the chat, call when chat screen opens
  Future<void> joinRoom() async {
    print('[ChatController] joinRoom called, isConnected: ${_messageService.socket.isConnected}');
    if (!_messageService.socket.isConnected) {
      print('[ChatController] socket not ready, waiting...');
      await _messageService.socket.waitUntilConnected();
    }
    _messageService.socket.joinRoom(chatId);
  }

  // leave socket room for the chat when navigating away
  void leaveRoom() {
    _messageService.socket.leaveRoom(chatId);
  }

  // load chat messages
  Future<Map<String, dynamic>> loadMessages({int offset = 0, int limit = 50}) async {
    try {
      print('[ChatController] loading messages for chat: $chatId');
      final messages = await _messageService.getChatHistory(chatId);

      return {
        'success': true,
        'messages': messages,
        'hasMore': messages.length == limit,
      };
    } catch (e) {
      print('[ChatController] loadMessages error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // send a message via socket with http as fallback, doesn't return the message, rather receives through broadcast
  // so onReceiveMessages() must be used to listen to the broadcast
  void sendMessage(String content) {
    _messageService.sendMessage(
      chatId: chatId,
      content: content,
      senderId: currentUserId,
    );
  }

  // stream of incoming messages, subscribe to receive incoming messages
  Stream<Message> onReceiveMessage() {
    return _messageService.onReceiveMessage();
  }

  Stream<String> onMessageError() {
    return _messageService.socket.on('message_error')
      .map((data) => data['message'] as String);
  }

  // leave chat, removes user from the chatroom entirely
  Future<Map<String, dynamic>> leaveChat() async {
    try {
      await chatroomService.leaveChatroom(chatId);
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
Stream<Map<String, dynamic>> onUserTyping() {
  return _messageService.socket.on('user_typing');
}

void sendTypingIndicator(bool isTyping) {
  _messageService.socket.emit('typing_indicator', {
    'chatId': chatId,
    'userId': currentUserId,
    'isTyping': isTyping,
  });
}
}