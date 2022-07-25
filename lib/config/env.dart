class Env {
  static const String TEST_SERVER = "192.168.0.164";
  static const String REAL_SERVER = "teraenergy.iptime.org";
  static const String SERVER_URL = 'http://$TEST_SERVER:10032';
  static const String SERVER_LOGIN_URL = 'http://$TEST_SERVER:3000/login';
  static const String SERVER_WEB_URL = 'http://$TEST_SERVER:8080/signInapp';
  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String STATUS_LOGIN = 'STATUS_LOGIN';
  static const String STATUS_LOGOUT = 'STATUS_LOGOUT';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String DIALOG_TITLE = "알림";
  static const String BEACON_NOTIFICATION_TITLE = "Beacons Set";
  static var isDebug = true;
}
