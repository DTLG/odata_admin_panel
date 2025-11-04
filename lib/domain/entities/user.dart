import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final bool isAdmin;
  final String? schemaName;
  final DateTime? createdAt;
  final String? login;
  final String? originalName;

  const User({
    required this.id,
    required this.email,
    required this.isAdmin,
    this.schemaName,
    this.createdAt,
    this.login,
    this.originalName,
  });

  String get displayName => originalName ?? login ?? email;

  @override
  List<Object?> get props => [
    id,
    email,
    isAdmin,
    schemaName,
    createdAt,
    login,
    originalName,
  ];
}
