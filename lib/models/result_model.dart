import 'dart:convert';

LoginInfo resultInfoFromJson(String str) => LoginInfo.fromJson(json.decode(str));

String resultInfoToJson(LoginInfo loginInfo) => json.encode(loginInfo.toJson());

class LoginInfo {
  LoginInfo(
    {
      required this.success, 
      required this.data, 
      required this.message,
      this.tokenInfo
    }
  );

  bool success;
  String message;
  Map<String, dynamic> data = {};
  TokenInfo? tokenInfo;

  static LoginInfo fromJson(Map<String, dynamic> json) {
    TokenInfo tokenInfo = TokenInfo(accessToken: json["accessToken"], refreshToken: json["refreshToken"]);
    return LoginInfo(
        success: json["success"], 
        data: json["data"],
        message: "",
        tokenInfo: tokenInfo
    ); 
  }

  static LoginInfo fromJsonByFail(Map<String, dynamic> json) =>
    LoginInfo(
      success: json["success"], 
      data: {},
      message: "",
      tokenInfo: null
    ); 

  Map<String, dynamic> toJson() => 
    {
        "success": success,
        "data": data
    };
}

class WorkInfo {
  bool success;
  String message;

  WorkInfo(
    {
      required this.success, 
      required this.message
    }
  );

  static fromJson(Map<String, dynamic> json) {
    WorkInfo(
        success: json["success"], 
        message: ""
    ); 
  }

  Map<String, dynamic> toJson() => 
  {
      "success": success
  };
}

class TokenInfo {
  String accessToken;
  String refreshToken;
  
  TokenInfo({
      required this.accessToken, 
      required this.refreshToken
  });

  String getAccessToken() {
    return accessToken;
  }

  String getRefreshToken() {
    return refreshToken;
  }
 
  void setAccessToken(String accessToken){
    this.accessToken = accessToken;
  }

  void setRefreshToken(String refreshToken){
    this.refreshToken = refreshToken;
  }

}

