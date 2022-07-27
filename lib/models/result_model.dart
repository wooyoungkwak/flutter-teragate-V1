import 'dart:convert';

LoginInfo resultInfoFromJson(String str) => LoginInfo.fromJson(json.decode(str));

String resultInfoToJson(LoginInfo loginInfo) => json.encode(loginInfo.toJson());

class LoginInfo {
  LoginInfo(
      this.success, 
      this.data, 
      this.message,
      this.tokenInfo
  );

  bool? success;
  String? message;
  Map<String, dynamic>? data = {};
  TokenInfo? tokenInfo;

  static LoginInfo fromJson(Map<String, dynamic> json) {
    TokenInfo tokenInfo = TokenInfo(accessToken: json["accessToken"], refreshToken: json["refreshToken"]);
    return LoginInfo( json["success"], json["data"], "", tokenInfo ); 
  }

  static LoginInfo fromJsonByFail(Map<String, dynamic> json) => LoginInfo(json["success"], {}, "", null); 

  Map<String, dynamic> toJson() => 
    {
        "success": success,
        "data": data
    };
}

class WorkInfo {
  bool success;
  String message;

  WorkInfo({
      required this.success, 
      required this.message
  });

  static WorkInfo fromJson(Map<String, dynamic> json) {
    return WorkInfo(
        success: json["success"], 
        message: ""
    ); 
  }

  static WorkInfo fromJsonByFail(Map<String, dynamic> json) {
    return WorkInfo(
        success: json["success"], 
        message: json["message"]
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

