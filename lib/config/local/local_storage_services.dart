import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageServices {
  static SharedPreferences? _preferences;

  static Future<SharedPreferences> get instance async => _preferences ??= await SharedPreferences.getInstance();

  static String? getToken() => getData<String>(LocalStorageKeys.authToken.name);

  static String? getRefreshToken() => getData<String>(LocalStorageKeys.refreshToken.name);

  static Future<bool> setTokens({required String accessToken, required String refreshToken}) async {
    final savedAccess = await saveData(LocalStorageKeys.authToken.name, accessToken);
    final savedRefresh = await saveData(LocalStorageKeys.refreshToken.name, refreshToken);
    return savedAccess && savedRefresh;
  }

  static Future<void> clearTokens() async {
    await deleteData(LocalStorageKeys.authToken.name);
    await deleteData(LocalStorageKeys.refreshToken.name);
  }

  static String? getLanguageCode() => getData<String>(LocalStorageKeys.selectedLanguage.name);

  static Future<bool> saveLanguageCode(String code) => saveData(LocalStorageKeys.selectedLanguage.name, code);

  static Future<bool> saveData<T>(String key, T value) async {
    if (_preferences?.containsKey(key.toString()) ?? false) {
      await deleteData(key);
    }
    if (T == String) {
      return await _preferences?.setString(key.toString(), value as String) ?? false;
    } else if (T == int) {
      return await _preferences?.setInt(key.toString(), value as int) ?? false;
    } else if (T == bool) {
      return await _preferences?.setBool(key.toString(), value as bool) ?? false;
    } else {
      return await _preferences?.setString(key.toString(), jsonEncode(value).toString()) ?? false;
    }
  }

  static T? getData<T>(String key) {
    if (T == String) {
      return _preferences?.getString(key.toString()) as T?;
    } else if (T == int) {
      return _preferences?.getInt(key.toString()) as T?;
    } else if (T == bool) {
      return _preferences?.getBool(key.toString()) as T?;
    } else {
      final jsonString = _preferences?.getString(key.toString());
      if (jsonString != null) return jsonDecode(jsonString) as T?;
    }
    return null;
  }

  static List<T> getListData<T>(String key, {required T? Function(Map<String, dynamic> json) fromJson}) {
    final jsonString = _preferences?.getString(key.toString());
    if (jsonString != null) {
      return List<T>.from(jsonDecode(jsonString).map((e) => fromJson(e)).toList());
    }
    return [];
  }

  static Future<bool> clearAll() async => await _preferences?.clear() ?? false;

  static Future<bool> deleteData(String key) async {
    if (_preferences?.containsKey(key.toString()) ?? false) {
      return await _preferences?.remove(key.toString()) ?? false;
    }
    return false;
  }
}

enum LocalStorageKeys { authToken, refreshToken, selectedLanguage }
