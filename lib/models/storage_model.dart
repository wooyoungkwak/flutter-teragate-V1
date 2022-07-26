import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  
  var flutterSecureStorage = const FlutterSecureStorage();

  Future<String?> read(String key) async {
    return await flutterSecureStorage.read(key: key);
  }

  void write(String key, String value) {
    flutterSecureStorage.write(key: key, value: value);
  }

  FlutterSecureStorage getFlutterSecureStorage() {
    return flutterSecureStorage;
  }

}

class SharedStorage {

  late SharedPreferences sharedPreferences;
  
  SharedStorage() {
    create();
  }

  void create() async{
     sharedPreferences = await SharedPreferences.getInstance();
  }

  void write(String key, var values) {
    switch(values.runtimeType.toString()) {
      case "int":
        sharedPreferences.setInt(key, values);
        break;
      case "String":
        sharedPreferences.setString(key, values);
        break;
      case "double":
        sharedPreferences.setDouble(key, values);
        break;
      case "Bool":
        sharedPreferences.setBool(key, values);
        break;
      case "List":
        sharedPreferences.setStringList(key, values);
        break;
    }

  }

  int? readToInt(String key) {
    return sharedPreferences.getInt(key);
  }

  String? readToString(String key) {
    return sharedPreferences.getString(key);
  }

  double? readToDouble(String key) {
    return sharedPreferences.getDouble(key);
  }

  bool? readToBool(String key) {
    return sharedPreferences.getBool(key);
  }

  List<String>? readList(String key) {
    return sharedPreferences.getStringList(key);
  }
}
