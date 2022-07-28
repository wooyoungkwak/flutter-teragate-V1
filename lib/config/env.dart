class Env {
  static const String TEST_SERVER = "http://192.168.0.247";
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

  static const String KEY_SUCCESS = "sucess";
  static const String KEY_MESSAGE = "message";
  static const String KEY_ACCESS_TOKEN = "accessToken";
  static const String KEY_REFRESH_TOKEN = "refreshToken";
  static const String KEY_GET_IN_CHECK = "getInCheck";
  static const String KEY_GET_OUT_CHECK = "getOutCheck";

  static const String MSG_GET_IN_EXIST = "exist";
  static const String MSG_GET_IN_SUCCESS = "출근 등록 되었습니다.";
  static const String MSG_GET_OUT_SUCCESS = "퇴근 등록 되었습니다.";
  static const String MSG_GET_IN_FAIL = "출근 등록을 실패 하였습니다.";
  static const String MSG_GET_OUT_FAIL = "퇴근 등록을 실패 하였습니다.";


  static const String TITLE_DIALOG = "알림";
  static const String TITLE_BEACON_NOTIFICATION = "Beacons Set";
  
  static var isDebug = true;
}
