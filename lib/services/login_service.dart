import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/result_model.dart';
import 'package:teragate_test/utils/toast_util.dart';
 
Map<String, String> headers = {};

// 로그인체크
loginCheck(loginId, password) async {
  const flutterSecureStorage = FlutterSecureStorage();
  /*
  Map<String, String> param = {
    "loginId": loginId,
    "password": password,
  }; 
  */

  var data = {"loginId": loginId, "password": password};
  var body = json.encode(data);

  String id = loginId;
  String pw = password;

  var response = await http.post(Uri.parse(Env.serverLoginURL), headers: {"Content-Type": "application/json"}, body: body);
  if (response.statusCode == 200) {
    flutterSecureStorage.deleteAll();
    flutterSecureStorage.write(key: id, value: pw);
    flutterSecureStorage.write(key: LOGIN_ID, value: id);
    flutterSecureStorage.write(key: LOGIN_PW, value: pw);
    flutterSecureStorage.write(key: '${id}_$pw', value: USER_NICK_NAME);
    flutterSecureStorage.write(key: USER_NICK_NAME, value: STATUS_LOGIN);

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

    flutterSecureStorage.write(key: 'user_id', value: '${loginInfo.data['userId']}');
    flutterSecureStorage.write(key: 'kr_name', value: '${loginInfo.data['krName']}');
    return LoginInfo.fromJson(json.decode(response.body));

  } else {
    throw Exception('Failed to load album');
  }
}
