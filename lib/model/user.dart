class User {
  final String email;
  final String password;

  User({
    required this.email,
    required this.password,
  });

  // json으로 받은 정보로 객체화시킴
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '', // email이 없으면 공백 저장
      password: json['password'] ?? '',
    );
  }
}
