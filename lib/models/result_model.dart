import 'dart:convert';

LoginInfo resultInfoFromJson(String str) => LoginInfo.fromJson(json.decode(str));

String resultInfoToJson(LoginInfo data) => json.encode(data.toJson());

class LoginInfo {
  LoginInfo(
    {
      required this.success, 
      required this.data, 
      required this.message
    }
  );

  bool success;
  String message;
  Map<String, dynamic> data = {};

  factory LoginInfo.fromJson(Map<String, dynamic> json) => 
    LoginInfo(
        success: json["success"], 
        data: json["data"],
        message: ""
    ); 

  factory LoginInfo.fromJsonByFail(Map<String, dynamic> json) => 
    LoginInfo(
        success: json["success"], 
        data: {},
        message: ""
    ); 

  Map<String, dynamic> toJson() => 
    {
        "success": success,
        "data": data
    };
}

class KeyInfo  {
  final int commuteKey;

  KeyInfo (this.commuteKey);

  KeyInfo.fromJson(Map<String, dynamic> json)
      : commuteKey = json['commute_key'];
  Map<String, dynamic> toJson() => {
      'commute_key': commuteKey,
    };
}

