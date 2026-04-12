import 'package:frontend/model/journal.dart';
import 'package:frontend/model/profile_model.dart';

class MyCoopModel {
  List<Journal>? journalList;
  User? currentUser;
  List<User>?
  friendList; //list of user's the current user shares a chat with, should exclude journals they already have

  // //TEST VALUES: TODO Delete
  // // --- Test Users ---
  // final User user1 = User(
  //   uid: 'u1',
  //   email: 'alice@example.com',
  //   username: 'AliceAliceAliceAlice',
  //   pigeonId: 1,
  // );

  // final User user2 = User(
  //   uid: 'u2',
  //   email: 'bob@example.com',
  //   username: 'Bob',
  //   pigeonId: 2,
  // );

  // final User user3 = User(
  //   uid: 'u3',
  //   email: 'charlie@example.com',
  //   username: 'Charlie',
  //   pigeonId: 3,
  // );

  // // --- Test Journals ---
  // late final Journal testJournal1 = Journal(
  //   subject: user1,
  //   author: user2,
  // );

  // late final Journal testJournal2 = Journal(
  //   subject: user2,
  //   author: user3,
  // );

  // late final Journal testJournal3 = Journal(
  //   subject: user3,
  //   author: user1,
  // );

  // // --- Journal List ---
  // MyCoopModel() {
  //   journalList = [
  //     testJournal1,
  //     testJournal2,
  //     testJournal2,
  //     testJournal3,
  //     testJournal3,
  //   ];
  //   friendList = [user1, user2, user3,];

  //   currentUser = user1; // optional default
  // }
}
