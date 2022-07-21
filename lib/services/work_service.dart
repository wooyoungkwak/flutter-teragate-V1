import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/result_model.dart';

// key DB 가져오기
keyCheck() async {
  var url = Uri.parse("${Env.SERVER_URL}/keyCheck");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final result = utf8.decode(response.bodyBytes);
    Map<String, dynamic> keyMap = jsonDecode(result);
    var checkKey = KeyInfo.fromJson(keyMap);

    return '${checkKey.commuteKey}';
  } else {
    throw Exception('Failed to load album');
  }
}

// 출근
getIn(id, ip) async {
  if(Env.isDebug) debugPrint("#################출근##################");
  Map<String, String> param = {"user_id": id, "att_ip_in": ip};
  if(Env.isDebug) debugPrint(param.toString());
  var url =
      Uri.parse("http://192.168.0.164:3000/groupware/ajax_attend_user_v3");
  var data = {"userId": id, "attIpIn": ip};
  var body = json.encode(data);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);

  if(Env.isDebug) debugPrint(response.body);
  if (response.statusCode == 200) {
    return "TEST";
  } else {
    throw Exception('Failed to load album');
  }
}

//user_id 가져오기
/* attendidCheck() async {
  if(Env.isDebug) debugPrint("############유저id#############");
  const flutterSecureStorage = FlutterSecureStorage();
  debugPrint('autulogin :${await flutterSecureStorage.readAll()}');
  Map<String, String> allStorage = await flutterSecureStorage.readAll();
  String statusUser = '';
  String loginId = '';
  String loginPw = '';
  if (allStorage.isNotEmpty) {
    allStorage.forEach((k, v) {
      debugPrint('k : $k, v : $v');
      if (v == STATUS_LOGIN) statusUser = k;

      if (k == 'LOGIN_ID') loginId = v;
      if (k == 'LOGIN_PW') loginPw = v;
    });
  }

  Map<String, String> param = {
    "loginId": loginId,
    "password": loginPw,
  };

  var url =
      Uri.parse("${Env.SERVER_URL}/attendid").replace(queryParameters: param);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    if(Env.isDebug) debugPrint("#########################RESPONSE");
    debugPrint("body:" + response.body);

    return response;
  } else {
    throw Exception('Failed to load album');
  }
}
 */

//출근 중복체크
checkOverlapForGetIn(id) async {
  if(Env.isDebug) debugPrint("#################출근중복체크##################");
  Map<String, String> param = {"user_id": id};
  var url =
      //Uri.parse("${Env.SERVER_URL}/groupware/ajax_get_today_my_attend_data_v3")
      Uri.parse("http://http://192.168.0.164:3000/getTdyMyAtndData")
          .replace(queryParameters: param);
  var response = await http.get(url);
  if (response.statusCode == 200) {
    if(Env.isDebug) debugPrint(response.body);
    return LoginInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}


// 퇴근
getOut(id,ip) async {
  if(Env.isDebug) debugPrint("#################퇴근##################");
  Map<String, String> param = {"user_id": id,"att_ip_out":ip};

  var url = Uri.parse("${Env.SERVER_URL}/leave").replace(queryParameters: param);
  final response = await http.get(url);
  
  if(Env.isDebug) debugPrint("###########################");
  if(Env.isDebug) debugPrint(response.body);

  if (response.statusCode == 200) {
    return LoginInfo.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}
