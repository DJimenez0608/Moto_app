import 'dart:convert';

List<User> usersModelFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String usersModelToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
  });

  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'username': username,
      'password': password,
    };
  }
}
