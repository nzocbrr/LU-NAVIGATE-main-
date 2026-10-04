import 'package:flutter/material.dart';

/// Holds the currently logged-in user's data.
class AppUser {
  const AppUser({
    required this.name,
    required this.studentId,
    required this.email,
    required this.program,
  });

  final String name;
  final String studentId;
  final String email;
  final String program;

  /// Initials from the full name (up to 2 letters).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class AuthProvider extends ValueNotifier<AppUser?> {
  AuthProvider() : super(null);

  bool get isLoggedIn => value != null;

  /// Simple in-memory "register & login" – stores one user at a time.
  final Map<String, _StoredUser> _users = {};

  /// Returns an error message on failure, null on success.
  String? register({
    required String name,
    required String studentId,
    required String email,
    required String program,
    required String password,
  }) {
    final key = email.toLowerCase().trim();
    if (name.trim().isEmpty) return 'Name is required.';
    if (studentId.trim().isEmpty) return 'Student ID is required.';
    if (program.trim().isEmpty) return 'Program is required.';
    if (key.isEmpty) return 'Email is required.';
    final normalizedStudentId = studentId.trim().toLowerCase();
    if (_users.values.any(
      (stored) =>
          stored.user.studentId.trim().toLowerCase() == normalizedStudentId,
    )) {
      return 'An account with this student ID already exists.';
    }
    if (_users.containsKey(key)) {
      return 'An account with this email already exists.';
    }
    if (password.length < 6) return 'Password must be at least 6 characters.';
    _users[key] = _StoredUser(
      user: AppUser(
          name: name, studentId: studentId, email: email, program: program),
      password: password,
    );
    value = _users[key]!.user;
    return null;
  }

  /// Returns an error message on failure, null on success.
  String? login({required String studentId, required String password}) {
    final normalizedStudentId = studentId.trim().toLowerCase();
    _StoredUser? stored;
    for (final account in _users.values) {
      if (account.user.studentId.trim().toLowerCase() == normalizedStudentId) {
        stored = account;
        break;
      }
    }
    if (stored == null) return 'No account found with this student ID.';
    if (stored.password != password) return 'Incorrect password.';
    value = stored.user;
    return null;
  }

  void logout() => value = null;
}

class _StoredUser {
  const _StoredUser({required this.user, required this.password});
  final AppUser user;
  final String password;
}

final authProvider = AuthProvider();
