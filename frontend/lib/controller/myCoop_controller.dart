import 'package:flutter/material.dart';
import 'package:frontend/model/journal.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/view/myCoop_screen.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/view/journalentry_page.dart';

class MyCoopController {
  MyCoopScreenState state;
  MyCoopController(this.state);
  final ApiClient api = ApiClient();

  //Function to fetch/load journals into the journalList of the state.model
  Future<void> loadJournalSubjects() async {
    try {
      final response = await api.getJsonList('/api/journals/subjects');
      state.setState(() {
        state.model.journalList = response
            .map((data) => Journal.fromJson(data))
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading Coop: $e");
    }
  }

  //Function to fetch/load the "friends" into the friendList of state.model
  Future<void> loadEligibleFriends() async {
    try {
      final response = await api.getJsonList('/api/journals/eligible-subjects');

      state.setState(() {
        state.model.friendList = (response as List)
            .map((data) => User.fromJson(data))
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading eligible friends: $e");
    }
  }

  //onTap jounral --> navigate to corresponding page of journal entries
  void onTapPigeon(BuildContext context, Journal journal) {
    print('on tap pigeon/journal called');
    //navigate to the journal page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalPage(
          // Pass the subject's UID as the journalId for fetching entries
          journalId: journal.subject.uid,
          userName: journal.subject.username,
          pigeonId: journal.subject.pigeonId,
        ),
      ),
    );
  }

  //onClick add --> load options etc.
  Future<void> onTapAddNew() async {
    final selectedUser = await showDialog<User>(
      //show friend list
      context: state.context,
      builder: (context) =>
          FriendSelectionDialog(friends: state.model.friendList ?? []),
    );

    if (selectedUser != null) {
      //user has to be selected
      // create journal with selectedUser
      //make sure the journalList is updated in a setState call so that the view updates
      final response = await api.postJson('/api/journals', {
        'subjectId': selectedUser.uid,
        'content': 'Started a new journal.',
      });
      print("Selected: ${selectedUser.username}");
    }
  }
}
