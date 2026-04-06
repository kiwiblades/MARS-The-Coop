import 'package:flutter/material.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/view/chat_page.dart';
import 'package:frontend/view/createChat_screen.dart';
import 'package:frontend/view/mail_screen.dart';

class CreateChatController {
  CreateChatScreenState state;
  final ChatroomService chatroomService;
  final UserService userService;
  CreateChatController(this.state, {
    required this.chatroomService,
    required this.userService
  });

  //name validator
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

  //create button
  void onPressCreate() async {
    final form = state.formKey.currentState;

    bool isValid = form != null && form.validate(); //used to fam

    // dropdown must be manually validated because it does not have the validator option
    if (state.selectedRelationship == null) {
      state.callSetState(() {
        state.relationshipError = 'Please select a relationship type';
      });
      isValid = false;
    } else { //reset to null if it validates
      state.callSetState(() {
        state.relationshipError = null;
      });
    }

    if (!isValid) return;

      print('validation passed');
      try {
        //TODO: edit createChatroom to take: name(state.chatroomNameController), 
        //relationship type(state.selectedRelationship), 
        //fine-grain control one/off(state.fineGrainControlSwitch), 
        //and question preferences (state.selectedQuestionTypes and selectedQuestionTopics) all relevant values are in "form controllers/values" section
        final chatroom = await chatroomService.createChatroom(
          name: state.chatroomNameController.text,
          creator: await userService.getProfile(),
          relationshipType: state.selectedRelationship!.name,
          allowedTopics: state.fineGrainControlSwitch
            ? state.selectedQuestionTopics.map((t) => t.name).toList()
            : [],
          allowedTypes: state.fineGrainControlSwitch
            ? state.selectedQuestionTypes.map((t) => t.name).toList()
            : [],
        );
        Navigator.of(state.context)
          ..pop() // pop createchatscreen
          ..pop() // pop add chat screen
          ..push(
            MaterialPageRoute(
              builder: (_) => ChatPage( // jump to the new chat page
                chatId: chatroom.id,
                chatName: chatroom.name,
                participants: const [],
                membership: 'owner',
                chatroomService: chatroomService,
                chatroom: chatroom,
              ),
            ),
          );

        // delay invite code popup so there's time to navigate to the chatroom
        Future.delayed(const Duration(milliseconds: 100), () {
          showCodePopup(state.context, chatroom.inviteCode);
        });
      } catch (e) {
        print('failed to create chatroom: $e');
        // TODO: dispaly error
      }

    print('create pressed');
  }
}
