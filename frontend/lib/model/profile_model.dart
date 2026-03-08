class User {
  String uid;
  String email;
  // String password;
  String username;
  int pigeonId; //corresponding id to pigeon

  // email verification (can be ignored for now)
  final bool? emailVerified;
  final DateTime? emailVerifiedAt;

  User({
    required this.uid,
    required this.email,
    // required this.password,
    required this.username,
    required this.pigeonId,
    this.emailVerified,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      pigeonId: (json['pigeonId'] as num?)?.toInt() ?? 0,
      emailVerified: json['emailVerified'] as bool?,
      emailVerifiedAt: json['emailVerifiedAt'] == null 
        ? null : DateTime.tryParse(json['emailVerifiedAt'] as String),
    );
  }
}

class ProfileModel {
  bool isEditingUsername = false;
  bool isEditingEmail= false;
}