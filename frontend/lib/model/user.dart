class User {
  final String username;
  final String email;
  
  User({required this.username, required this.email});
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    username: json['username'],
    email: json['email'],
  );
}