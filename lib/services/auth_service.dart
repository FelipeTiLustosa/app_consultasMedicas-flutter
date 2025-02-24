import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'current_user';
  static User? _currentUser;

  // Get current logged in user
  static User? get currentUser => _currentUser;

  // Initialize the auth service
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserData = prefs.getString(_currentUserKey);
    if (currentUserData != null) {
      _currentUser = User.fromJson(jsonDecode(currentUserData));
    }
  }

  // Register a new user
  static const String _doctorAuthCode = 'ifpi@12345';

  // Check if email is already registered
  static Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getStringList(_usersKey) ?? [];
    return usersData.any((userData) {
      final user = User.fromJson(jsonDecode(userData));
      return user.email == email;
    });
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
    final usersData = prefs.getStringList(_usersKey) ?? [];
    usersData.add(jsonEncode(user.toJson()));
    await prefs.setStringList(_usersKey, usersData);
    
    // Set as current user
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    _currentUser = user;

    return user;
  }

  // Login user
  static Future<User> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getStringList(_usersKey) ?? [];
    
    for (var userData in usersData) {
      final user = User.fromJson(jsonDecode(userData));
      if (user.email == email) {
        // Save current user
        await prefs.setString(_currentUserKey, userData);
        _currentUser = user;
        return user;
      }
    }
    
    throw Exception('Invalid credentials');
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    _currentUser = null;
  }
}