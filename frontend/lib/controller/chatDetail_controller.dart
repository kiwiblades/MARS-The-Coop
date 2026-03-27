import 'package:frontend/model/chatroom.dart';
import 'package:frontend/view/chatDetail_screen.dart';

class ChatDetailController {
  ChatDetailScreenState state;
  ChatDetailController(this.state);

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
}
