import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static final SecureStorage _secureStorage = SecureStorage._interal();

  late FlutterSecureStorage flutterSecureStorage;

  factory SecureStorage() {
    return _secureStorage;
  }

  // 초기화
  SecureStorage._interal() {
    _create();
  }

  //
  void _create() async {
    flutterSecureStorage = const FlutterSecureStorage();
  }

  Future<String?> read(String key) async {
    return await flutterSecureStorage.read(key: key);
  }

  void write(String key, String value) {
    flutterSecureStorage.write(key: key, value: value);
  }

  void delete(String key) {
    flutterSecureStorage.delete(key: key);
  }

  void deleteAll() {
    flutterSecureStorage.deleteAll();
  }

  FlutterSecureStorage getFlutterSecureStorage() {
    return flutterSecureStorage;
  }
}

class SharedStorage {

  SharedPreferences? sharedPreferences;

  // 초기화
  SharedStorage(this.sharedPreferences);

  void write(String key, var values) {
    switch (values.runtimeType.toString()) {
      case "int":
        sharedPreferences?.setInt(key, values);
        break;
      case "String":
        sharedPreferences?.setString(key, values);
        break;
      case "double":
        sharedPreferences?.setDouble(key, values);
        break;
      case "Bool":
        sharedPreferences?.setBool(key, values);
        break;
      case "List":
        sharedPreferences?.setStringList(key, values);
        break;
    }
  }

  int? readToInt(String key) {
    return sharedPreferences?.getInt(key);
  }

  String? readToString(String key) {
    return sharedPreferences?.getString(key);
  }

  double? readToDouble(String key) {
    return sharedPreferences?.getDouble(key);
  }

  bool? readToBool(String key) {
    return sharedPreferences?.getBool(key);
  }

  List<String>? readList(String key) {
    return sharedPreferences?.getStringList(key);
  }

  void delete(String key) {
    sharedPreferences?.remove(key);
  }

  void deleteAll() {
    sharedPreferences?.clear();
  }
}
