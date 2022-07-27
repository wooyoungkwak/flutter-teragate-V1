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

    String result = utf8.decode(response.bodyBytes);
    Map<String, dynamic> resultMap = jsonDecode(result);
    
    LoginInfo loginInfo;

    if (resultMap.values.first) {
      //로그인 성공 실패 체크해서 Model 다르게 설정
      loginInfo = LoginInfo.fromJson(resultMap);

      secureStorage.getFlutterSecureStorage().deleteAll();
      // secureStorage.write(id, pw);
      secureStorage.write(Env.LOGIN_ID, id);
      secureStorage.write(Env.LOGIN_PW, pw);

      secureStorage.write('krName', '${loginInfo.data['krName']}');
      secureStorage.write('accessToken', '${loginInfo.tokenInfo?.getAccessToken()}');
      secureStorage.write('refreshToken', '${loginInfo.tokenInfo?.getRefreshToken()}');
      if(Env.isDebug) debugPrint(loginInfo.tokenInfo?.getAccessToken());
    } else {
      loginInfo = LoginInfo.fromJsonByFail(resultMap);
      if(Env.isDebug) debugPrint(loginInfo.message);
    }

    return loginInfo;
  } else {
    throw Exception('로그인 서버 오류');
  }
}

// 출근
Future<LoginInfo> getIn(ip) async {
  var url = Uri.parse(Env.SERVER_GET_IN_URL);
  var data = {"attIpIn": ip};
  var body = json.encode(data);
  var response = await http.post(url, headers: {"Content-Type": "application/json"}, body: body);

  if (response.statusCode == 200) {
    return LoginInfo.fromJson(json.decode(response.body));
  } else {
    LoginInfo loginInfo = LoginInfo.fromJson(json.decode(response.body));
    debugPrint(loginInfo.message);
    throw Exception(loginInfo.message);
  }
}

// 퇴근
Future<LoginInfo> getOut(ip) async {
  var url = Uri.parse(Env.SERVER_GET_OUT_URL);
  var data = {"attIpIn": ip};
  var body = json.encode(data);
  final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: body);
  
  if (response.statusCode == 200) {
    return LoginInfo.fromJson(json.decode(response.body));
  } else {
    LoginInfo loginInfo = LoginInfo.fromJson(json.decode(response.body));
    debugPrint(loginInfo.message);
    throw Exception(loginInfo.message);
  }
}

