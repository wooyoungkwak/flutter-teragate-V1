import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/result_model.dart';
 import 'package:teragate_test/models/storage_model.dart';

Map<String, String> headers = {};

// 로그인체크
Future<LoginInfo> login(String id, String pw) async {
  SecureStorage secureStorage = SecureStorage();

  var data = {"loginId": id, "password": pw};
  var body = json.encode(data);

  var response = await http.post(Uri.parse(Env.SERVER_LOGIN_URL), headers: {"Content-Type": "application/json"}, body: body);
  if (response.statusCode == 200) {
    secureStorage.getFlutterSecureStorage().deleteAll();
    secureStorage.write(id, pw);
    secureStorage.write(Env.LOGIN_ID, id);
    secureStorage.write(Env.LOGIN_PW, pw);
    secureStorage.write('${id}_$pw', Env.USER_NICK_NAME);
    secureStorage.write(Env.USER_NICK_NAME, Env.STATUS_LOGIN);

    var result = utf8.decode(response.bodyBytes);
    Map<String, dynamic> keyMap = jsonDecode(result);

    LoginInfo loginInfo;

    if (keyMap.values.first) {
      //로그인 성공 실패 체크해서 Model 다르게 설정
       loginInfo = LoginInfo.fromJson(keyMap);
       if(Env.isDebug) debugPrint(loginInfo.data.toString());
    } else {
       loginInfo = LoginInfo.fromJsonByFail(keyMap);
       if(Env.isDebug) debugPrint(loginInfo.message);
    }

    secureStorage.write('user_id', '${loginInfo.data['userId']}');
    secureStorage.write('kr_name', '${loginInfo.data['krName']}');
    return LoginInfo.fromJson(json.decode(response.body));

  } else {
    throw Exception('Failed to load album');
  }
}
