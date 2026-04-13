import 'package:frontend/model/profile_model.dart';

class Journal {
  final User subject; //the user the journal is about
  final User author; //who writes the journal entries/ is journal owner

  Journal({required this.subject, required this.author});

  factory Journal.fromJson(Map<String, dynamic> json) {
    if (json['SubjectProfile'] == null) {
      throw Exception("Missing SubjectProfile in Journal JSON");
    }

    return Journal(
      // Ensure these keys match what your backend returns (e.g., 'SubjectProfile' and 'AuthorProfile')
      subject: User.fromJson(json['SubjectProfile']),
      //author: User.fromJson(json['AuthorProfile']),
      author: json['AuthorProfile'] != null
          ? User.fromJson(json['AuthorProfile'])
          : User(
              uid: json['ownerId'] ?? '',
              username: 'Me',
              email: '',
              pigeonId: 0,
            ), // Fallback to a default User if AuthorProfile is missing
    );
  }
}
