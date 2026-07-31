import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Local-only authentication backed by SharedPreferences.
class AuthLocalService {
  AuthLocalService(this._prefs);

  final SharedPreferences _prefs;

  List<UserModel> getUsers() {
    final raw = _prefs.getString(AppConstants.keyUsers);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveUsers(List<UserModel> users) async {
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await _prefs.setString(AppConstants.keyUsers, encoded);
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final users = getUsers();

    if (users.any((u) => u.email == normalized)) {
      throw const AuthException('An account with this email already exists.');
    }

    final user = UserModel(
      name: name.trim(),
      email: normalized,
      password: password,
    );
    users.add(user);
    await _saveUsers(users);
    await _prefs.setString(AppConstants.keyLoggedInEmail, normalized);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final users = getUsers();
    UserModel? match;
    for (final u in users) {
      if (u.email == normalized) {
        match = u;
        break;
      }
    }

    if (match == null) {
      throw const AuthException('No account found with this email.');
    }
    if (match.password != password) {
      throw const AuthException('Incorrect password.');
    }

    await _prefs.setString(AppConstants.keyLoggedInEmail, normalized);
    return match;
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.keyLoggedInEmail);
  }

  UserModel? getCurrentUser() {
    final email = _prefs.getString(AppConstants.keyLoggedInEmail);
    if (email == null) return null;
    final users = getUsers();
    for (final u in users) {
      if (u.email == email) return u;
    }
    return null;
  }

  bool get isLoggedIn => getCurrentUser() != null;
}
