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
      final settings = entry['settings'] as Map<String, dynamic>? ?? {};
      final allowedTopics = (settings['allowedTopics'] as List<dynamic>? ?? [])
        .map((t) => t as String)
        .toList();
      final allowedTypes = (settings['allowedTypes'] as List<dynamic>? ?? [])
        .map((t) => t as String)
        .toList();

      return Chatroom(
        id: chatroom['id'] as String,
        name: chatroom['name'] as String,
        inviteCode: chatroom['inviteCode'] as String,
        participants: participants,
        pinned: membership['pinned'] as bool,
        membership: membership['role'] as String,
        lastSentMessage: entry['lastSentMessage'] as String? ?? '',
        lastSentTime: entry['lastSentTime'] as String? ?? '',
        relationshipType: RelationshipType.values.firstWhere(
          (e) => e.name.toLowerCase() == (settings['relationshipType'] as String? ?? 'friends').toLowerCase(),
          orElse: () => RelationshipType.friends,
        ),
        fineGrainControl: allowedTopics.isNotEmpty || allowedTypes.isNotEmpty,
        allowedTypes: allowedTypes.map((t) => 
          QuestionType.values.firstWhere(
            (q) => q.name.toLowerCase() == t.toLowerCase(),
            orElse: () => QuestionType.favorite,
          )
        ).toSet(),
        allowedTopics: allowedTopics.map((t) =>
          QuestionTopic.values.firstWhere(
            (q) => q.name.toLowerCase() == t.toLowerCase(),
            orElse: () => QuestionTopic.personal,
          )
        ).toSet(),
      );
    }).toList();
  }

  // post /chatroom/create
  // returns the new chatroom row, but it doesn't really need to be displayed immediately
  // the invite code is immediately provided with the new chatroom, though
  Future<Chatroom> createChatroom(String name) async {
    final data = await api.postJson('/chatroom/create', {'name': name});
    return Chatroom(
      id: data['id'] as String,
      name: data['name'] as String,
      inviteCode: data['inviteCode'] as String,
      // the values from here aren't really important, they'll be fetched when needed later
      participants: [],
      pinned: false,
      membership: 'owner',
      lastSentMessage: '',
      lastSentTime: '',
      relationshipType: RelationshipType.friends,
      fineGrainControl: false,
      allowedTypes: const {},
      allowedTopics: const {},
    );
  }

  // post /chatroom/join
  Future<void> joinChatroom(String inviteCode) async {
    await api.postJson('/chatroom/join', {'inviteCode': inviteCode});
  }

  // delete /chatroom/leave
  Future<void> leaveChatroom(String chatroomId) async {
    await api.deleteJson('/chatroom/leave', {'chatroomId': chatroomId});
  }

  // delete /chatroom/delete
  Future<void> deleteChatroom(String chatroomId) async {
    //await api.deleteJson('/chatroom/delete', {'chatroomId': chatroomId});
    await api.deleteJson('/chatroom/$chatroomId', {});
  }

  Future<void> updateSettings({
    required String chatroomId,
    String? name,
    String? relationshipType,
    List<String>? allowedTopics,
    List<String>? allowedTypes,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (relationshipType != null) 'relationshipType': relationshipType,
      if (allowedTopics != null) 'allowedTopics': allowedTopics,
      if (allowedTypes != null) 'allowedTypes': allowedTypes,
    };

    await api.patchJson('/chatroom/$chatroomId/settings', body);
  }

  // patch /chatroom/pin
  Future<void> togglePin(String chatroomId) async {
    await api.patchJson('/chatroom/pin', {'chatroomId': chatroomId});
  }
}
