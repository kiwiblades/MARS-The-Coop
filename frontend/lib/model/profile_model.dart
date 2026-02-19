class User {
  String email;
  String password;
  String username;
  int pigeonId; //corresponding id to pigeon

  User({
    required this.email,
    required this.password,
    required this.username,
    required this.pigeonId,
  });
}