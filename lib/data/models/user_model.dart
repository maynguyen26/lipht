class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final bool privateMode;
  final bool enableAiMealAnalysis;
  final List<String> blockedUsers;
  final String createdAt;
  final String lastLogin;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.privateMode = false,
    this.enableAiMealAnalysis = true,
    this.blockedUsers = const [],
    required this.createdAt,
    required this.lastLogin,
  });

  // Factory constructor for creating a default user
  factory UserModel.createDefault({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) {
    final username = email.split('@')[0];
    return UserModel(
      id: userId,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      photoUrl: photoUrl,
      privateMode: false,
      enableAiMealAnalysis: true,
      blockedUsers: const [],
      createdAt: DateTime.now().toIso8601String(),
      lastLogin: DateTime.now().toIso8601String(),
    );
  }

  // Factory constructor to create a UserModel from a Map (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      privateMode: json['privateMode'] ?? false,
      enableAiMealAnalysis: json['enableAiMealAnalysis'] ?? true,
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      createdAt: json['createdAt'],
      lastLogin: json['lastLogin'],
    );
  }

  // Convert a UserModel to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'photoUrl': photoUrl,
      'privateMode': privateMode,
      'enableAiMealAnalysis': enableAiMealAnalysis,
      'blockedUsers': blockedUsers,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  // Create a copy of UserModel with some field changes
  UserModel copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    bool? privateMode,
    bool? enableAiMealAnalysis,
    List<String>? blockedUsers,
    String? createdAt,
    String? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      privateMode: privateMode ?? this.privateMode,
      enableAiMealAnalysis: enableAiMealAnalysis ?? this.enableAiMealAnalysis,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}