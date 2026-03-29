import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/view/chatDetail_screen.dart';
import 'package:frontend/services/chatroom_service.dart';

class ChatDetailController {
  ChatDetailScreenState state;
  final ChatroomService chatroomService;
  ChatDetailController(this.state, {required this.chatroomService});

  //TODO: chat needs to be fetched for currentChat in view and also to set all the model editing values to what they are already
  // Helper to get current chat ID
  String get _chatId => state.model.currentChatroom!.id;

  // INITIALIZATION: Called from the View's initState to sync model with existing data
  void init(Chatroom chatroom) {
    state.model.currentChatroom = chatroom;
    state.callSetState(() {
      // Set initial values for the relationship dropdown
      state.model.selectedRelationshipType = RelationshipType.values.firstWhere(
        (e) => e.name.toLowerCase() == chatroom.relationshipType.toLowerCase(),
        orElse: () => RelationshipType.friends,
      );
      // Sync fine grain control state
      state.model.fineGrainControlEdit = chatroom.allowedTopics.isNotEmpty;
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
    }
    print('chat name save clicked');
  }

  //chat name save
  Future<void> onSaveChatName(String? value) async {
    final newChatName = value?.trim();
    if (newChatName == null || newChatName.isEmpty) return;

    //TODO (rye): try catch for editing the chat's name
    try {
      await chatroomService.updateSettings(chatId, newChatName);
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
    //TODO (rye): try catch for editing the relationship type
    try {
      await chatroomService.updateSettings(chatId, newRelationshipType);
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

    //TODO (rye): copy over all current values that were fetched from db into edit variables in model

    state.callSetState(() {
      state.model.isEditingQuestionPreferences = true;

      // SYNC: Copy current topics from the chatroom object into the "Edits" buffer
      state.model.questionTopicPreferenceEdits.clear();
      for (var topicName in state.model.currentChatroom!.allowedTopics) {
        final topic = QuestionTopic.values.firstWhere(
          (t) => t.name.toLowerCase() == topicName.toLowerCase(),
          orElse: () => QuestionTopic.personal,
        );
        state.model.questionTopicPreferenceEdits.add(topic);
      }
    });

    //Test Data
    state.model.questionTopicPreferenceEdits.add(QuestionTopic.intimacy);
    state.model.questionTypePreferenceEdits.add(QuestionType.favorite);
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
    //TODO (rye): call the fine grain control save for backend
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
    //TODO (rye): try catch to update fine grain control on or off and the preferences accordingly
    try {
      await chatroomService.updateSettings(
        chatId,
        null, // No change to chat name
        fineGrainControl: fineGrainControl,
        questionTypePreference: types,
        questionTopicPreference: topics,
      );
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
    //TODO (rye): delete chat functionality
    try {
      await chatroomService.deleteChatroom(_chatId);
      // Navigate back to mail screen
      Navigator.of(state.context).popUntil((route) => route.isFirst);
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
    //TODO (rye): BUGFIX leave implementation
    try {
      await chatroomService.leaveChatroom(_chatId);
      // Pop twice (back to main mail screen)
      Navigator.of(state.context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Leave chat failed: $e');
    }
  }
  //   if (_currentUser == null) return;

  //   final result = await _chatController.leaveChat();

  //   if (result['success']) {
  //     Navigator.pop(state.context);
  //     ScaffoldMessenger.of(
  //       state.context,
  //     ).showSnackBar(SnackBar(content: Text('Left chat successfully')));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to leave chat: ${result['error']}')),
  //     );
  //   }
  // }

  // @override
  // void dispose() {
  //   _messageController.dispose();
  //   _scrollController.dispose();
  //   super.dispose();
}
