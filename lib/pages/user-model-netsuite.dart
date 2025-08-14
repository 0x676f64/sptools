class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final Map<String, dynamic>? netsuiteData;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.dateOfBirth,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.netsuiteData,
  });

  // Create User from JSON (NetSuite response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Individual User',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      isActive: json['isActive'] ?? true,
      netsuiteData: json['netsuiteData'],
    );
  }

  // Convert User to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'netsuiteData': netsuiteData,
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    Map<String, dynamic>? netsuiteData,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      netsuiteData: netsuiteData ?? this.netsuiteData,
    );
  }

  // Get user's age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Check if user is a garage owner
  bool get isGarageOwner => role == 'Garage Owner';

  // Check if user is an individual user
  bool get isIndividualUser => role == 'Individual User';

  // Get formatted date of birth
  String get formattedDateOfBirth {
    return '${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}';
  }

  // Get user initials for profile avatar
  String get initials {
    final names = username.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

// Registration request model
class RegistrationRequest {
  final String username;
  final String email;
  final String password;
  final String role;
  final DateTime dateOfBirth;

  RegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }
}

// Login request model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Authentication response model
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}