import 'package:odata_admin_panel/domain/entities/user.dart' as domain;

class UserModel {
  final String id;
  final String email;
  final bool isAdmin;
  final String? schemaName;
  final DateTime? createdAt;
  final String? login;
  final String? originalName;

  const UserModel({
    required this.id,
    required this.email,
    required this.isAdmin,
    this.schemaName,
    this.createdAt,
    this.login,
    this.originalName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['user_id']) as String;
    final email = json['email'] as String;
    final isAdmin = (json['is_admin'] as bool?) ?? false;
    final schemaName = json['schema_name'] as String?;
    final createdAtRaw = json['created_at'] as String?;
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw)
        : null;
    final login = json['login'] as String?;
    final originalName = json['original_name'] as String?;
    return UserModel(
      id: id,
      email: email,
      isAdmin: isAdmin,
      schemaName: schemaName,
      createdAt: createdAt,
      login: login,
      originalName: originalName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'is_admin': isAdmin,
    if (schemaName != null) 'schema_name': schemaName,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (login != null) 'login': login,
    if (originalName != null) 'original_name': originalName,
  };

  domain.User toDomain() => domain.User(
    id: id,
    email: email,
    isAdmin: isAdmin,
    schemaName: schemaName,
    createdAt: createdAt,
    login: login,
    originalName: originalName,
  );
}
