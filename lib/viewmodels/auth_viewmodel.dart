import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initAuth() async {
    await AuthService.init();
    _currentUser = AuthService.currentUser;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required bool isDoctor,
    String? specialization,
    required DateTime birthDate,
    required String phoneNumber,
    String? doctorAuthCode,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      _currentUser = await AuthService.register(
        email: email,
        password: password,
        name: name,
        isDoctor: isDoctor,
        specialization: specialization,
        birthDate: birthDate,
        phoneNumber: phoneNumber,
        doctorAuthCode: doctorAuthCode,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      _currentUser = await AuthService.login(email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await AuthService.logout();
      _currentUser = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}