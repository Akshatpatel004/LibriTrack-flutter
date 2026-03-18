class UserModel {
  String email;
  String password;

  UserModel({
    required this.email,
    required this.password,
  });

  /// Convert Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }

  /// Convert JSON -> Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json["email"] ?? "",
      password: json["password"] ?? "",
    );
  }
}
