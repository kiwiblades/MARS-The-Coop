import 'package:flutter/material.dart';
import 'package:frontend/model/journal.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/services/journalentry_service.dart';
import 'package:frontend/view/myCoop_screen.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/view/journalentry_page.dart';

class MyCoopController {
  MyCoopScreenState state;
  late final JournalService journalService;

  MyCoopController(this.state) {
    journalService = JournalService(api: ApiClient());
  }

  //Function to fetch/load journals into the journalList of the state.model
  Future<void> loadJournalSubjects() async {
    try {
      final response = await journalService.getJournalSubjects();
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
      final response = await journalService.getEligibleSubjects();
      state.setState(() {
        state.model.friendList = response
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
          subjectId: journal.subject.uid,
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
      await journalService.createEntry(
        subjectId: selectedUser.uid,
        content: 'Started a new journal.',
      );
      await loadJournalSubjects(); // refresh list after creating
      await loadEligibleFriends(); // refresh to remove user from eligible list
      print("Selected: ${selectedUser.username}");
    }
  }
}
