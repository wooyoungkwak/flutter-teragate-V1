import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/result_model.dart';

Map<String, String> headers = {};

// 로그인체크
Future<LoginInfo> login(String id, String pw) async {

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
    } else {
      loginInfo = LoginInfo.fromJsonByFail(resultMap);
    }

    return loginInfo;
  } else {
    throw Exception('로그인 서버 오류');
  }
}

// 출근
Future<WorkInfo> getIn(String ip, String accessToken) async {
  var data = {"attIpIn": ip};
  var body = json.encode(data);
  var response = await http.post(
    Uri.parse(Env.SERVER_GET_IN_URL), 
    headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    }, 
    body: body
  );
  
  debugPrint("response body =================");
  debugPrint(response.body);

  if (response.statusCode == 200) {
    return WorkInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception(response.body);
  }
}

// 퇴근
Future<WorkInfo> getOut(String ip, String accessToken) async {
  var data = {"attIpIn": ip};
  var body = json.encode(data);
  final response = await http.post(
    Uri.parse(Env.SERVER_GET_OUT_URL), 
    headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    }, 
    body: body
  );

  if (response.statusCode == 200) {
    return WorkInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception(response.body);
  }
}

// 토큰 재요청
Future<TokenInfo> getTokenByRefreshToken(String refreshToken) async {
  var data = {"refreshToken": refreshToken};
  var body = json.encode(data);
  var response = await http.post(Uri.parse(Env.SERVER_REFRESH_TOKEN_URL), headers: {"Content-Type": "application/json"}, body: body);

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    TokenInfo tokenInfo = TokenInfo(accessToken: data[Env.KEY_ACCESS_TOKEN], refreshToken: data[Env.KEY_REFRESH_TOKEN]);
    return tokenInfo;
  } else {
    throw Exception(response.body);
  }
}

// String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
// getIn(deviceip!, accessToken!).then((workInfo) => debugPrint(workInfo.success.toString()));

// String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
// getOut(deviceip!, accessToken!).then((workInfo) => debugPrint(workInfo.success.toString()));