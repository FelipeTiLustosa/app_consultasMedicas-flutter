import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const String _usersKey = 'users_data';
  static List<User> _users = [];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getStringList(_usersKey) ?? [];
    _users = usersData.map((data) => User.fromJson(jsonDecode(data))).toList();
  }

  static Future<User?> getUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getStringList(_usersKey) ?? [];
    
    try {
      return usersData
          .map((data) => User.fromJson(jsonDecode(data)))
          .firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getStringList(_usersKey) ?? [];
    
    // Remove existing user data if present
    usersData.removeWhere((data) {
      final userData = User.fromJson(jsonDecode(data));
      return userData.id == user.id;
    });
    
    // Add new user data
    usersData.add(jsonEncode(user.toJson()));
    
    await prefs.setStringList(_usersKey, usersData);
  }
}