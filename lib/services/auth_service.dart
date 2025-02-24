import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static User? _currentUser;

  // Get current logged in user
  static User? get currentUser => _currentUser;

  // Initialize the auth service
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      _currentUser = User.fromJson(jsonDecode(userData));
    }
  }

  // Register a new user
  static const String _doctorAuthCode = 'ifpi@12345';

  // Check if email is already registered
  static Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final existingUser = User.fromJson(jsonDecode(userData));
      return existingUser.email == email;
    }
    return false;
  }

  // Validate doctor authentication code
  static bool validateDoctorAuthCode(String code) {
    return code == _doctorAuthCode;
  }

  static Future<User> register({
    required String email,
    required String password,
    required String name,
    required bool isDoctor,
    String? specialization,
    required DateTime birthDate,
    required String phoneNumber,
    String? doctorAuthCode,
  }) async {
    // Check if email is already registered
    if (await isEmailRegistered(email)) {
      throw Exception('Email already registered');
    }

    // Validate doctor authentication code
    if (isDoctor) {
      if (doctorAuthCode == null || !validateDoctorAuthCode(doctorAuthCode)) {
        throw Exception('Invalid doctor authentication code');
      }
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      isDoctor: isDoctor,
      specialization: specialization,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
    );

    // Save user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    _currentUser = user;

    return user;
  }

  // Login user
  static Future<User> login(String email, String password) async {
    // In a real app, this would verify credentials against an API
    // For now, we'll just check if the user exists locally
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      final user = User.fromJson(jsonDecode(userData));
      if (user.email == email) {
        _currentUser = user;
        return user;
      }
    }
    
    throw Exception('Invalid credentials');
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }
}