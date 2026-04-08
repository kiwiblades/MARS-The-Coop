import 'package:frontend/model/profile_model.dart';

class Journal {
  final User subject; //the user the journal is about
  final User author; //who writes the journal entries/ is journal owner

  Journal({
    required this.subject,
    required this.author,
  });
}