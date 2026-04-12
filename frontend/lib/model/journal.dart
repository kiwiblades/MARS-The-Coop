import 'package:frontend/model/profile_model.dart';

class Journal {
  final User subject; //the user the journal is about
  final User author; //who writes the journal entries/ is journal owner

  Journal({
    required this.subject,
    required this.author,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      // Ensure these keys match what your backend returns (e.g., 'SubjectProfile' and 'AuthorProfile')
      subject: User.fromJson(json['SubjectProfile']), 
      author: User.fromJson(json['AuthorProfile']),
    );
  }
}