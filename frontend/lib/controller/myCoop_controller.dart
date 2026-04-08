import 'package:flutter/material.dart';
import 'package:frontend/model/journal.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/view/myCoop_screen.dart';

class MyCoopController {
  MyCoopScreenState state;
  MyCoopController(this.state);

  //TODO: Function to fetch/load journals into the journalList of the state.model

  //TODO: function to fetch/load the "friends" into the friendList of state.model

  //onTap jounral --> navigate to corresponding page of journal entries
  void onTapPigeon(BuildContext context, Journal journal) {
    print('on tap pigeon/journal called');
    //TODO: navigate to the journal page
  }

  //onClick add --> load options etc.
  Future<void> onTapAddNew() async {
    final selectedUser = await showDialog<User>( //show friend list
      context: state.context,
      builder: (context) =>
          FriendSelectionDialog(friends: state.model.friendList ?? []),
    );

    if (selectedUser != null) { //user has to be selected
      // TODO: create journal with selectedUser 
      //make sure the journalList is updated in a setState call so that the view updates
      print("Selected: ${selectedUser.username}");
    }
  }
}
