class AgentModel {
  final int? id;
  final String name;
  final String? email;
  final String? activationCode;
  final String? token;
  final DateTime? createdAt;
  final String? fcmToken;

  AgentModel({
    this.id,
    required this.name,
    this.email,
    this.activationCode,
    this.token,
    this.createdAt,
    this.fcmToken,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      email: json['email'],
      activationCode: json['activation_code'],
      token: json['token'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      fcmToken: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'activation_code': activationCode,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'fcm_token': fcmToken,
    };
  }
}