import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  //单利模式
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();
  static Preferences get instance => _instance;

  late SharedPreferences _store;
  Future<void> init() async {
    _store = await SharedPreferences.getInstance();
  }

  Future<bool> setString(key, value) {
    return _store.setString(key, value);
  }

  String? getString(key) {
    return _store.getString(key);
  }

  Future<bool> remove(key) {
    return _store.remove(key);
  }

  Future<bool> clear() {
    return _store.clear();
  }

  bool getBool(key) {
    return _store.getBool(key) ?? false;
  }

  double getDouble(key) {
    return _store.getDouble(key) ?? 0.0;
  }

  int getInt(key) {
    return _store.getInt(key) ?? 0;
  }

  Map<String, dynamic> getMap(key) {
    return json.decode(_store.getString(key) ?? '{}');
  }

  List<String> getStringList(key) {
    return _store.getStringList(key) ?? [];
  }

  Future<bool> setBool(key, value) {
    return _store.setBool(key, value);
  }

  Future<bool> setDouble(key, value) {
    return _store.setDouble(key, value);
  }

  Future<bool> setInt(key, value) {
    return _store.setInt(key, value);
  }

  Future<bool> setMap(key, value) {
    return _store.setString(key, json.encode(value));
  }

  Future<bool> setStringList(key, value) {
    return _store.setStringList(key, value);
  }
}
