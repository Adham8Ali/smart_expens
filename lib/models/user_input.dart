class UserInput {
  final String fullName;
  final String email;
  final String password;

  UserInput({
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'email': email};
  }

  // Factory constructor from JSON
  factory UserInput.fromJson(Map<String, dynamic> json) {
    return UserInput(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: '',
    );
  }
}
