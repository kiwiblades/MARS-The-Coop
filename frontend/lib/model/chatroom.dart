import 'package:frontend/model/profile_model.dart';

class Chatroom {
  final int id;
  final String name;
  // final List<User> participants;
  final List<String> participants; //test
  bool pinned;
  final String membership;
  final String lastSentMessage;
  final String lastSentTime;

  Chatroom({
    required this.id,
    required this.name,
    required this.participants,
    required this.pinned,
    required this.membership,
    required this.lastSentMessage,
    required this.lastSentTime,
  });
}
//test list
  List<Chatroom> testChats = [
    Chatroom(
      id: 0, 
      name: 'Test chat 1 (GC, !P)', 
      participants: ['bill','gene', 'mai'], 
      pinned: false, 
      membership: 'owner',
      lastSentMessage: 'long long long long long I was following the pack all swallowed in the coats with scarves of red tied rought their throats Last message sent',
      lastSentTime: '11:20p'
    ),
    Chatroom(
      id: 1, 
      name: 'Test chat 2 (GC, P)', 
      participants: ['bill', 'bob'], 
      pinned: true, 
      membership: 'participant',
      lastSentMessage: 'Last message sent',
      lastSentTime: 'Feb 28th'
    ),
    Chatroom(
      id: 2, 
      name: 'Test chat 3 (!GC, !P)', 
      participants: ['june'], 
      pinned: false, 
      membership: 'owner',
      lastSentMessage: 'Last message sent',
      lastSentTime: '11:20a'
    ),
    Chatroom(
      id: 3, 
      name: 'Test chat 4 (!GC, P)', 
      participants: ['kyly'], 
      pinned: true, 
      membership: 'participant',
      lastSentMessage: 'Last message sent',
      lastSentTime: 'Dec 11 2025'
    ),
    Chatroom(
      id: 4, 
      name: 'Test chat 5 (New chat, !P)', 
      participants: [], 
      pinned: false, 
      membership: 'owner',
      lastSentMessage: 'Last message sent',
      lastSentTime: '11:20p'
    ),
  ];