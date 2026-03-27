import 'package:flutter/material.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/view/chatDetail_screen.dart';

class ChatDetailController {
  ChatDetailScreenState state;
  ChatDetailController(this.state);

  //TODO: i think the chat needs to be fetched for currentChat in view and also to set all the model editing values to what they are already

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

    //TODO: try catch for editing the chat's name
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
    //TODO: try catch for editing the relationship type
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
    state.callSetState(() {
      state.model.isEditingQuestionPreferences = true;
    });

    //TODO: copy over all current values that were fetched from db into edit variables in model
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
    //TODO: call the fine grain control save for backend
  }

  //fine grain control save
  // Future<void> onSaveFineGrainControl(bool fineGrainControl, List<QuestionType> types, List<QuestionTopic> topics) {
  //   //TODO: try catch to update fine grain control on or off and the preferences accordingly
  // }

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
    //TODO: delete chat funcitonality
  }

  //LEAVE
  void onPressedLeaveChat() async {
    print('pressed leave chat');

    final confirmed = await showLeaveConfirmationPopUp(
      state.context,
      1, // TODO: real participant count
    );

    if (confirmed == true) {
      await leaveChat();
    }
  }

  Future<void> leaveChat() async {
    print('leave chat called');
    //TODO: BUGFIX leave implementation
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
}
