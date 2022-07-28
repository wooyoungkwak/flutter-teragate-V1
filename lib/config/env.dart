class Env {
  static const String TEST_SERVER = "http://192.168.0.164";
  static const String REAL_SERVER = "http://teraenergy.iptime.org";

  static const String SERVER_LOGIN_URL = '$TEST_SERVER:3000/login';
  static const String SERVER_GET_IN_URL = '$TEST_SERVER:3000/teragate/goToWork';
  static const String SERVER_GET_OUT_URL = '$TEST_SERVER:3000/teragate/leaveWork';
  static const String SERVER_REFRESH_TOKEN_URL = '$TEST_SERVER:3000/teragate/refreshToken';

  static const String SERVER_GROUPWARE_TEST = "$TEST_SERVER:8080";
  static const String SERVER_GROUPWARE_REAL = "http://teragroupware.duckdns.org";
  static const String SERVER_GROUPWARE_URL = '$SERVER_GROUPWARE_TEST/signInapp';

  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String ID_CHECK = 'ID_CHECK';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String KEY_ACCESS_TOKEN = "accessToken";
  static const String KEY_REFRESH_TOKEN = "refreshToken";
  static const String KEY_GET_IN_CHECK = "getInCheck";
  static const String KEY_GET_OUT_CHECK = "getOutCheck";


  static const String TITLE_DIALOG = "알림";
  static const String TITLE_BEACON_NOTIFICATION = "Beacons Set";
  
  static var isDebug = true;
}
