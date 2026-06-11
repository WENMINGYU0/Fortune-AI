import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 用户信息
  static const _keyProfile = 'user_profile';

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs?.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  UserProfile? getProfile() {
    final json = _prefs?.getString(_keyProfile);
    if (json == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  bool get hasProfile => getProfile() != null;

  // 通用存取
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) => _prefs?.getString(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool getBool(String key) => _prefs?.getBool(key) ?? false;

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int getInt(String key) => _prefs?.getInt(key) ?? 0;
}
