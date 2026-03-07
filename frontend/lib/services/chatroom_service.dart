/*
  Calls backend /chatroom endpoints.
*/

import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/services/api_client.dart';

class ChatroomService {
  final ApiClient api;
  ChatroomService({required this.api});

  // get /chatroom
  Future<List<Chatroom>> getChatrooms() async {
    final data = await api.getJsonList('/chatroom');
    
    // map the returned response into the expected chatroom model form
    return data.map((entry) {
      final chatroom = entry['chatroom'] as Map<String, dynamic>;
      final membership = entry['membership'] as Map<String, dynamic>;
      final participants = (entry['participants'] as List<dynamic>? ?? [])
        .map((p) => User.fromJson(p as Map<String, dynamic>))
        .toList();
      
      return Chatroom(
        id: chatroom['id'] as String,
        name: chatroom['name'] as String,
        participants: participants,
        pinned: membership['pinned'] as bool,
        membership: membership['role'] as String,
        lastSentMessage: '', // TODO: add these values in the endpoint
        lastSentTime: '',
      );
    }).toList();
  }

  // post /chatroom/create
  // returns the new chatroom row, but it doesn't really need to be displayed immediately
  Future<void> createChatroom(String name) async {
    await api.postJson('/chatroom/create', {'name': name});
  }

  // post /chatroom/join
  Future<void> joinChatroom(String inviteCode) async {
    await api.postJson('/chatroom/join', {'inviteCode': inviteCode});
  }

  // delete /chatroom/leave
  Future<void> leaveChatroom(int chatroomId) async {
    await api.deleteJson('/chatroom/leave', {'chatroomId': chatroomId});
  }

  // delete /chatroom/delete
  Future<void> deleteChatroom(int chatroomId) async {
    await api.deleteJson('/chatroom/delete', {'chatroomId': chatroomId});
  }

  // patch /chatroom/pin
  Future<void> togglePin(String chatroomId) async {
    await api.patchJson('/chatroom/pin', {'chatroomId': chatroomId});
  }
}