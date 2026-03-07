import 'package:frontend/view/createChat_screen.dart';

class CreateChatController {
  CreateChatScreenState state;
  CreateChatController(this.state);

  //name validator
  String? chatNameValidator(String? value) {
    final RegExp validInput = RegExp(r'^[a-zA-Z0-9@$!%*?&]+$');
    if(value == null || value.isEmpty) {
      return 'Please enter name';
    }
    if(value.length > 20) {
      return 'Chat name cannot be greater than 20 characters';
    }
    if(!validInput.hasMatch(value)) {
      return 'Only letters, numbers, and @\$!%*?& allowed';
    }

    return null;
  }

  //create button
  void onPressCreate() {
    final form = state.formKey.currentState;

    if(form != null && form.validate()) {
      print('validation passed');
      //TODO: creating chat 
      //navigate back to mail page once crated, make sure the view updates to show new chat
    }

    print('create pressed');
  }

}