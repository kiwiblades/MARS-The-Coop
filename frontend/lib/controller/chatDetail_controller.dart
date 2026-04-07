import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/view/chatDetail_screen.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/view/mail_screen.dart';

class ChatDetailController {
  ChatDetailScreenState state;
  final ChatroomService chatroomService;
  final UserService userService;
  ChatDetailController(
    this.state, {
    required this.chatroomService,
    required this.userService,
  });

  // Helper to get current chat ID
  String get _chatId => state.model.currentChatroom!.id;

  // INITIALIZATION: Called from the View's initState to sync model with existing data
  void init(Chatroom chatroom) {
    state.model.currentChatroom = chatroom;
    state.callSetState(() {
      // Set initial values for the relationship dropdown
      state.model.selectedRelationshipType = RelationshipType.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            chatroom.relationshipType.name.toLowerCase(),
        orElse: () => RelationshipType.friends,
      );
      // Sync fine grain control state
      state.model.fineGrainControlEdit =
          chatroom.allowedTopics.isNotEmpty || chatroom.allowedTypes.isNotEmpty;
    });
  }

  //CHAT NAME:
  //chat name edit click
  void onPressedEditChatName() {
    print('edit chat name clicked');
    state.callSetState(() {
      state.model.isEditingChatName = true;
    });
    print(state.model.isEditingChatName);
  }

  //chat name save edit
  void onPressedEditChatNameSave() {
    final form = state.formKeyChatName.currentState;

    if (form != null && form.validate()) {
      form.save();
      state.callSetState(() {
        state.model.isEditingChatName = false; // close the form once finished
      });
    }
    print('chat name save clicked');
  }

  //chat name save
  Future<void> onSaveChatName(String? value) async {
    final newChatName = value?.trim();
    if (newChatName == null || newChatName.isEmpty) return;

    // immediately update local model to reflect changes
    // TODO: there's probably a better way to do this, fix later

    final updated = Chatroom(
      id: state.model.currentChatroom!.id,
      name: newChatName,
      inviteCode: state.model.currentChatroom!.inviteCode,
      participants: state.model.currentChatroom!.participants,
      owner: state.model.currentChatroom!.owner,
      pinned: state.model.currentChatroom!.pinned,
      membership: state.model.currentChatroom!.membership,
      lastSentMessage: state.model.currentChatroom!.lastSentMessage,
      lastSentTime: state.model.currentChatroom!.lastSentTime,
      relationshipType: state.model.currentChatroom!.relationshipType,
      fineGrainControl: state.model.currentChatroom!.fineGrainControl,
      allowedTypes: state.model.currentChatroom!.allowedTypes,
      allowedTopics: state.model.currentChatroom!.allowedTopics,
    );
    state.callSetState(() {
      state.model.currentChatroom = updated;
    });

    try {
      await chatroomService.updateSettings(
        chatroomId: _chatId,
        name: newChatName,
      );
      // notify parent of the change
      state.widget.onSettingsChanged?.call(updated);
    } catch (error) {
      print('Error updating chat name: $error');
    }
  }

  //chat name cancel edit
  void onPressedEditChatNameCancel() {
    print('chat name cancel clicked');
    state.callSetState(() {
      state.model.isEditingChatName = false;
    });
  }

  //chat name validator
  String? chatNameValidator(String? value) {
    final RegExp validInput = RegExp(r'^[ a-zA-Z0-9@$!%*?&]+$');
    if (value == null || value.isEmpty) {
      return 'Please enter name';
    }
    if (value.length > 20) {
      return 'Chat name cannot be greater than 20 characters';
    }
    if (!validInput.hasMatch(value)) {
      return 'Only letters, numbers, spaces, and @\$!%*?& allowed';
    }

    return null;
  }

  //RELATIONSHIP TYPE:
  //relationship type edit click
  void onPressedEditRelationshipType() {
    print('edit relationship type clicked');
    state.callSetState(() {
      state.model.isEditingRelationshipType = true;
    });
  }

  //relationship type select relationship
  void onSelectRelationshipType(RelationshipType? value) {
    state.callSetState(() {
      state.model.selectedRelationshipType = value;
      state.model.relationshipError = null;
    });
  }

  //relationship type save edit
  void onPressedEditRelationshipTypeSave() {
    final error = relationshipTypeValidator(
      state.model.selectedRelationshipType,
    );

    if (error != null) {
      state.callSetState(() {
        state.model.relationshipError = error;
      });
      return;
    }

    onSaveRelationshipType(state.model.selectedRelationshipType);

    print('relationship type save clicked');
  }

  //relationship type save
  Future<void> onSaveRelationshipType(RelationshipType? value) async {
    final newRelationshipType = value;
    if (newRelationshipType == null) return;

    final updated = Chatroom(
      id: state.model.currentChatroom!.id,
      name: state.model.currentChatroom!.name,
      inviteCode: state.model.currentChatroom!.inviteCode,
      participants: state.model.currentChatroom!.participants,
      owner: state.model.currentChatroom!.owner,
      pinned: state.model.currentChatroom!.pinned,
      membership: state.model.currentChatroom!.membership,
      lastSentMessage: state.model.currentChatroom!.lastSentMessage,
      lastSentTime: state.model.currentChatroom!.lastSentTime,
      relationshipType: newRelationshipType, // updated
      fineGrainControl: state.model.currentChatroom!.fineGrainControl,
      allowedTypes: state.model.currentChatroom!.allowedTypes,
      allowedTopics: state.model.currentChatroom!.allowedTopics,
    );

    state.callSetState(() {
      state.model.currentChatroom = updated;
      state.model.isEditingRelationshipType = false;
    });

    try {
      await chatroomService.updateSettings(
        chatroomId: _chatId,
        relationshipType: newRelationshipType.name,
      );
    } catch (error) {
      print('Error updating relationship type: $error');
    }
  }

  //relationship type cancel edit
  void onPressedEditRelationshipTypeCancel() {
    print('cancel relationship type clicked');
    state.callSetState(() {
      state.model.isEditingRelationshipType = false;
      state.model.relationshipError = null;
    });
  }

  //relationship type validator
  String? relationshipTypeValidator(RelationshipType? value) {
    if (value == null) {
      return 'Please select a relationship type';
    }
    return null;
  }

  //QUESTION PREFERENCES
  //fine-grain question control edit click
  void onPressedEditFineGrainControl() {
    print('edit fine-grain question control clicked');

    print(
      '[FineGrain] allowedTopics: ${state.model.currentChatroom!.allowedTopics}',
    );
    print(
      '[FineGrain] allowedTypes: ${state.model.currentChatroom!.allowedTypes}',
    );

    state.callSetState(() {
      state.model.isEditingQuestionPreferences = true;

      // resync finegraincontroledit
      state.model.fineGrainControlEdit =
          state.model.currentChatroom!.allowedTopics.isNotEmpty ||
          state.model.currentChatroom!.allowedTypes.isNotEmpty;

      // SYNC: Copy current topics from the chatroom object into the "Edits" buffer
      state.model.questionTopicPreferenceEdits
        ..clear()
        ..addAll(state.model.currentChatroom!.allowedTopics);

      state.model.questionTypePreferenceEdits
        ..clear()
        ..addAll(state.model.currentChatroom!.allowedTypes);
    });
  }

  //fine grain control toggle
  void onToggleFineGrainControl(bool value) {
    print('on toggle fine grain control clicked');
    state.callSetState(() {
      state.model.fineGrainControlEdit = value;
    });

    if (!value) {
      state.model.questionTypePreferenceEdits.clear();
      state.model.questionTopicPreferenceEdits.clear();

      // clear the allowed types/topics on backend + local
      final updated = Chatroom(
        id: state.model.currentChatroom!.id,
        name: state.model.currentChatroom!.name,
        inviteCode: state.model.currentChatroom!.inviteCode,
        participants: state.model.currentChatroom!.participants,
        owner: state.model.currentChatroom!.owner,
        pinned: state.model.currentChatroom!.pinned,
        membership: state.model.currentChatroom!.membership,
        lastSentMessage: state.model.currentChatroom!.lastSentMessage,
        lastSentTime: state.model.currentChatroom!.lastSentTime,
        relationshipType: state.model.currentChatroom!.relationshipType,
        fineGrainControl: false,
        allowedTypes: const {},
        allowedTopics: const {},
      );

      state.callSetState(() {
        state.model.currentChatroom = updated;
      });

      chatroomService
          .updateSettings(
            chatroomId: _chatId,
            allowedTypes: [],
            allowedTopics: [],
          )
          .then((_) {
            state.widget.onSettingsChanged?.call(updated);
          })
          .catchError((e) {
            print('Error clearing fine grain control: $e');
          });
    }
  }

  //fine grain question control check mark listeners
  void onToggleQuestionType(QuestionType type, bool? value) {
    state.callSetState(() {
      if (value == true) {
        state.model.questionTypePreferenceEdits.add(type);
      } else {
        state.model.questionTypePreferenceEdits.remove(type);
      }
    });
  }

  void onToggleQuestionTopic(QuestionTopic topic, bool? value) {
    state.callSetState(() {
      if (value == true) {
        state.model.questionTopicPreferenceEdits.add(topic);
      } else {
        state.model.questionTopicPreferenceEdits.remove(topic);
      }
    });
  }

  //fine grain question control save edit
  void onPressedEditFineGrainControlSave() {
    print('question preference edit save pressed');
    state.callSetState(() {
      state.model.isEditingQuestionPreferences = false;
    });

    try {
      fineGrainControlEdit(
        state.model.fineGrainControlEdit,
        state.model.questionTypePreferenceEdits.toList(),
        state.model.questionTopicPreferenceEdits.toList(),
      );
    } catch (error) {
      print('Error updating fine grain control: $error');
    }
  }

  ///fine grain control save
  Future<void> fineGrainControlEdit(
    bool fineGrainControl,
    List<QuestionType> types,
    List<QuestionTopic> topics,
  ) async {
    final updated = Chatroom(
      id: state.model.currentChatroom!.id,
      name: state.model.currentChatroom!.name,
      inviteCode: state.model.currentChatroom!.inviteCode,
      participants: state.model.currentChatroom!.participants,
      owner: state.model.currentChatroom!.owner,
      pinned: state.model.currentChatroom!.pinned,
      membership: state.model.currentChatroom!.membership,
      lastSentMessage: state.model.currentChatroom!.lastSentMessage,
      lastSentTime: state.model.currentChatroom!.lastSentTime,
      relationshipType: state.model.currentChatroom!.relationshipType,
      fineGrainControl: fineGrainControl,
      allowedTypes: types.toSet(),
      allowedTopics: topics.toSet(),
    );

    state.callSetState(() {
      state.model.currentChatroom = updated;
    });

    try {
      await chatroomService.updateSettings(
        chatroomId: _chatId,
        allowedTypes: types.map((t) => t.name).toList(),
        allowedTopics: topics.map((t) => t.name).toList(),
      );
      state.widget.onSettingsChanged?.call(updated);
    } catch (error) {
      print('Error updating fine grain control: $error');
    }
  }

  //fine grain control cancel edit
  void onPressedEditFineGrainControlCancel() {
    print('fine grain control cancel clicked');
    state.callSetState(() {
      state.model.isEditingQuestionPreferences = false;
    });
  }

  //MEMBER LIST
  void onMemberMoreActions(String action, User user) async {
    switch (action) {
      case 'ban':
        print('Ban ${user.username}');
        // TODO: backend integration
        // The chatroom should be updated, but bannedUsers attribute should be updated to be accurate (add user)
        // the state.model also needs to be updated so the view is correct (should happen within a state.callSetState function call)
        break;

      case 'promote':
        final confirmed = await showPromoteConfirmationPopUp(state.context);

        if (confirmed == true) {
          print('Promote ${user.username} to owner');
          // TODO: backend integration
          // Chatroom should be updated, owner attribute should be changed from the previous user to the selected user (passed to this function)
          // state.model also needs to be updated (same reasons as above)
        }

        break;
    }
  }

  //BANNED USERS list
  void onBannedUserMoreActions(String action, User user) async {
    switch (action) { //for possible later expansion
      case 'unban':
        print('unban ${user.username}');
        // TODO: backend integration
        // The chatroom should be updated, but bannedUsers attribute should be updated to be accurate (add user)
        // the state.model also needs to be updated so the view is correct (should happen within a state.callSetState function call)
        break;
    }
  }

  //DELETE
  void onPressedDeleteChat() async {
    print('pressed delete chat');

    final confirmed = await showDeleteConfirmationPopUp(state.context);

    if (confirmed == true) {
      await deleteChat();
    }
  }

  Future<void> deleteChat() async {
    print('delete chat called');
    try {
      await chatroomService.deleteChatroom(_chatId);
      // Navigate back to mail screen
      Navigator.of(state.context).pushNamedAndRemoveUntil(
        MailScreen.routeName,
        (route) => false, // remove everything below too
      );
    } catch (e) {
      print('Delete chat failed: $e');
    }
  }

  //LEAVE
  void onPressedLeaveChat() async {
    print('pressed leave chat');
    // Calculate real participant count (others + current user)
    final count = (state.model.currentChatroom?.participants.length ?? 0) + 1;

    final confirmed = await showLeaveConfirmationPopUp(
      state.context,
      count, // Pass the participant count to the confirmation popup
    );

    if (confirmed == true) {
      await leaveChat();
    }
  }

  Future<void> leaveChat() async {
    print('leave chat called');
    try {
      await chatroomService.leaveChatroom(_chatId);
      // Pop twice (back to main mail screen)
      Navigator.of(
        state.context,
      ).pushNamedAndRemoveUntil(MailScreen.routeName, (route) => false);
    } catch (e) {
      print('Leave chat failed: $e');
    }
  }
}
