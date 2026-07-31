import '../models/user_model.dart';
import '../services/auth_local_service.dart';

class AuthRepository {
  AuthRepository(this._service);

  final AuthLocalService _service;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _service.signUp(name: name, email: email, password: password);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) {
    return _service.login(email: email, password: password);
  }

  Future<void> logout() => _service.logout();

  UserModel? get currentUser => _service.getCurrentUser();

  bool get isLoggedIn => _service.isLoggedIn;
}
