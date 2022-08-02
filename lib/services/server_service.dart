import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/result_model.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/utils/time_util.dart';
import 'package:teragate_test/utils/debug_util.dart';

Map<String, String> headers = {};

// 로그인
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
  var response = await http.post(Uri.parse(Env.SERVER_GET_IN_URL), headers: {"Content-Type": "application/json", "Authorization": accessToken}, body: body);

Log.debug(accessToken);
Log.debug(Env.SERVER_GET_IN_URL);
Log.debug(response.body);

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
  final response = await http.post(Uri.parse(Env.SERVER_GET_OUT_URL), headers: {"Content-Type": "application/json", "Authorization": accessToken}, body: body);

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
    if ( data[Env.KEY_SUCCESS] ) {
      return TokenInfo(accessToken: data[Env.KEY_ACCESS_TOKEN], refreshToken: data[Env.KEY_REFRESH_TOKEN], isUpdated: true);
    } else {
      return TokenInfo(accessToken: "", refreshToken: "", message: data[Env.KEY_SUCCESS],  isUpdated: false);
    }
  } else {
    throw Exception(response.body);
  }
}

// 출근 요청 처리
Future<WorkInfo> processGetIn(String accessToken, String refreshToken, String ip, SecureStorage secureStorage, int repeat) async {
  String? isGetInCheck = await secureStorage.read(Env.KEY_GET_IN_CHECK);
  TokenInfo tokenInfo;
  WorkInfo workInfo;

  if (isGetInCheck != null && isGetInCheck == getDateToStringForYYYYMMDDInNow()) {
    // 출근 처리 가 이미 된 경우
    workInfo = WorkInfo(success: false, message: Env.MSG_GET_IN_EXIST);
  } else {
    workInfo = await getIn(ip, accessToken);
    if (workInfo.success) {
      // 정상 등록 된 경우
      tokenInfo = TokenInfo(accessToken: accessToken, refreshToken: refreshToken, isUpdated: false);
      secureStorage.write(Env.KEY_GET_IN_CHECK, getDateToStringForYYYYMMDDInNow());
      workInfo.message = Env.MSG_GET_OUT_SUCCESS;
    } else {
      if (workInfo.message == "expired") {

        try {
          // 만료 인 경우 재 요청 경우
          tokenInfo = await getTokenByRefreshToken(refreshToken);

          // Token 저장
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getAccessToken());
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getRefreshToken());

          repeat++;
          if (repeat < 2) {
            return await processGetIn(tokenInfo.getAccessToken(), tokenInfo.getRefreshToken(), ip, secureStorage, repeat);
          } else {
            return WorkInfo(success: false, message: Env.MSG_GET_IN_FAIL);
          }
        } catch (err) {
          Log.log(" processGetIn Exception : ${err.toString()}");
          return WorkInfo(success: false, message: Env.MSG_GET_IN_FAIL);
        }

      }
    }
  }

  return workInfo;
}

// 퇴근 요청 처리
Future<WorkInfo> processGetOut(String accessToken, String refreshToken, String ip, SecureStorage secureStorage, int repeat) async {
  WorkInfo workInfo = await getOut(ip, accessToken);
  TokenInfo tokenInfo;
  
  if (workInfo.success) {
    tokenInfo = TokenInfo(accessToken: accessToken, refreshToken: refreshToken, isUpdated: false);
    secureStorage.write(Env.KEY_GET_OUT_CHECK, getDateToStringForAllInNow());
    workInfo.message = Env.MSG_GET_OUT_SUCCESS;
  } else {
    if (workInfo.message == "expired") {
      try {
        // 만료 인 경우 재 요청 경우
        tokenInfo = await getTokenByRefreshToken(refreshToken);

        if ( tokenInfo.isUpdated == true) {
          // Token 저장
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getAccessToken());
          secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getRefreshToken());
        
          repeat++;
          if (repeat < 2) {
            return await processGetOut(tokenInfo.getAccessToken(), tokenInfo.getRefreshToken(), ip, secureStorage, repeat);
          } else {
            return WorkInfo(success: false, message: Env.MSG_GET_OUT_FAIL);
          }
        }
      } catch (err) {
        Log.log(" 퇴근 요청 처리 오류 : ${err.toString()}");
        return WorkInfo(success: false, message: Env.MSG_GET_OUT_FAIL);
      }
    } 
  }

  return workInfo;
}
