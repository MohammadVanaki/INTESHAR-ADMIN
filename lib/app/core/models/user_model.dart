class UserModel {
  final String? id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? createdAt;
  final String? fcmToken;
  final String? token; // JWT token

  UserModel({
    this.id,
    required this.email,
    this.name,
    this.phone,
    this.createdAt,
    this.fcmToken,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      fcmToken: json['fcm_token'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'fcm_token': fcmToken,
      'token': token,
    };
  }
}