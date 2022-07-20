// ignore: camel_case_types
class AttendUser {
  int userId;
  String krName;

  AttendUser(this.userId, this.krName);

  AttendUser.fromJson(Map<String, dynamic> json) : 
  userId = json['user_id'],
  krName = json['kr_name']
  ;
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'kr_name': krName,
      };
}
