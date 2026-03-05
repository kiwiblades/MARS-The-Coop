import 'package:frontend/model/profile_model.dart';

class Chatroom {
  final int id;
  final String name;
  // final List<User> participants;
  final List<String> participants; //test
  final bool pinned;
  final String membership;

  Chatroom({
    required this.id,
    required this.name,
    required this.participants,
    required this.pinned,
    required this.membership,
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
    ),
    Chatroom(
      id: 1, 
      name: 'Test chat 2 (GC, P)', 
      participants: ['bill', 'bob'], 
      pinned: true, 
      membership: 'participant'
    ),
    Chatroom(
      id: 2, 
      name: 'Test chat 3 (!GC, !P)', 
      participants: ['june'], 
      pinned: false, 
      membership: 'owner'
    ),
    Chatroom(
      id: 3, 
      name: 'Test chat 4 (!GC, P)', 
      participants: ['kyly'], 
      pinned: true, 
      membership: 'participant'
    ),
    Chatroom(
      id: 4, 
      name: 'Test chat 5 (New chat, !P)', 
      participants: [], 
      pinned: false, 
      membership: 'owner'
    ),
  ];