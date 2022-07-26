class Env {
  static const String TEST_SERVER = "http://192.168.0.164";
  static const String TEST_GROUPWARE_SERVER = "$TEST_SERVER:8080";

  static const String REAL_SERVER = "http://teraenergy.iptime.org";
  static const String REAL_GROUPWARE_SERVER = "http://teragroupware.duckdns.org";

  static const String SERVER_GROUPWARE_URL = '$TEST_GROUPWARE_SERVER/signInapp';
  static const String SERVER_LOGIN_URL = '$TEST_SERVER:3000/login';
  static const String SERVER_GET_IN_URL = '$TEST_SERVER:3000/teragate/goToWork';
  static const String SERVER_GET_OUT_URL = '$TEST_SERVER:3000/teragate/leaveWork';
  static const String SERVER_REFRESH_TOKEN_URL = '$TEST_SERVER:3000/teragate/refreshToken';

  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String STATUS_LOGIN = 'STATUS_LOGIN';
  static const String STATUS_LOGOUT = 'STATUS_LOGOUT';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String TITLE_DIALOG = "알림";
  static const String TITLE_BEACON_NOTIFICATION = "Beacons Set";
  
  static var isDebug = true;
}
