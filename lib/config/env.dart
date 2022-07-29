class Env {
  static const String TEST_SERVER = "http://192.168.0.164";
  static const String REAL_SERVER = "http://teraenergy.iptime.org";

  static const String SERVER_LOGIN_URL = '$TEST_SERVER:3000/login';
  static const String SERVER_GET_IN_URL = '$TEST_SERVER:3000/teragate/goToWork';
  static const String SERVER_GET_OUT_URL = '$TEST_SERVER:3000/teragate/leaveWork';
  static const String SERVER_REFRESH_TOKEN_URL = '$TEST_SERVER:3000/teragate/refreshToken';

  static const String INITIAL_UUID = '74278bdb-b644-4520-8f0c-720eeaffffff';

  static const String SERVER_GROUPWARE_TEST = "$TEST_SERVER:8080";
  static const String SERVER_GROUPWARE_REAL = "http://teragroupware.duckdns.org";
  static const String SERVER_GROUPWARE_URL = '$SERVER_GROUPWARE_TEST/signInapp';

  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String KEY_ID_CHECK = 'KEY_ID_CHECK';
  static const String KEY_SUCCESS = "sucess";
  static const String KEY_MESSAGE = "message";
  static const String KEY_ACCESS_TOKEN = "accessToken";
  static const String KEY_REFRESH_TOKEN = "refreshToken";
  static const String KEY_GET_IN_CHECK = "getInCheck";
  static const String KEY_GET_OUT_CHECK = "getOutCheck";
  static const String KEY_UUID = "uuid";
  static const String KEY_LOGIN_STATE = "loginState";

  static const String KEY_SETTING_MON_GI = "MondayGi";
  static const String KEY_SETTING_TUE_GI = "TuesdayGi";
  static const String KEY_SETTING_WED_GI = "WednesdayGi";
  static const String KEY_SETTING_THU_GI = "ThursdayGi";
  static const String KEY_SETTING_FRI_GI = "FridayGi";
  static const String KEY_SETTING_SAT_GI = "SaturdayGi";
  static const String KEY_SETTING_SUN_GI = "SundayGi";

  static const String KEY_SETTING_MON_GO = "MondayGO";
  static const String KEY_SETTING_TUE_GO = "TuesdayGO";
  static const String KEY_SETTING_WED_GO = "WednesdayGO";
  static const String KEY_SETTING_THU_GO = "ThursdayGO";
  static const String KEY_SETTING_FRI_GO = "FridayGO";
  static const String KEY_SETTING_SAT_GO = "SaturdayGO";
  static const String KEY_SETTING_SUN_GO = "SundayGO";

  static const String KEY_SETTING_MON_GI_TIME = "MondayTimeGetIn";
  static const String KEY_SETTING_TUE_GI_TIME = "TuesdayTimeGetIn";
  static const String KEY_SETTING_WED_GI_TIME = "WednesdayTimeGetIn";
  static const String KEY_SETTING_THU_GI_TIME = "ThursdayTimeGetIn";
  static const String KEY_SETTING_FRI_GI_TIME = "FridayTimeGetIn";
  static const String KEY_SETTING_SAT_GI_TIME = "SaturdayTimeGetIn";
  static const String KEY_SETTING_SUN_GI_TIME = "SundayTimeGetIn";

  static const String KEY_SETTING_MON_GO_TIME = "MondayTimeGetOut";
  static const String KEY_SETTING_TUE_GO_TIME = "TuesdayTimeGetOut";
  static const String KEY_SETTING_WED_GO_TIME = "WednesdayTimeGetOut";
  static const String KEY_SETTING_THU_GO_TIME = "ThursdayTimeGetOut";
  static const String KEY_SETTING_FRI_GO_TIME = "FridayTimeGetOut";
  static const String KEY_SETTING_SAT_GO_TIME = "SaturdayTimeGetOut";
  static const String KEY_SETTING_SUN_GO_TIME = "SundayTimeGetOut";

  static const String KEY_SETTING_VIBRATE = "VIBRATE";
  static const String KEY_SETTING_ALARM = "ALARM";

  static const String KEY_SETTING_GI_ON_OFF = "GIONOFF";
  static const String KEY_SETTING_GO_ON_OFF = "GOONOFF";

  static const String KEY_BEACON_COMPLETE_STATE = "false";

  static const String MSG_GET_IN_EXIST = "exist";
  static const String MSG_GET_IN_SUCCESS = "출근 등록 되었습니다.";
  static const String MSG_GET_OUT_SUCCESS = "퇴근 등록 되었습니다.";
  static const String MSG_GET_IN_FAIL = "출근 등록을 실패 하였습니다.";
  static const String MSG_GET_OUT_FAIL = "퇴근 등록을 실패 하였습니다.";
  static const String MSG_MINOR_FAIL = "비콘이 존재 하지 않습니다. 수동으로 등록 해주세요.";

  static const String TITLE_DIALOG = "알림";
  static const String TITLE_BEACON_NOTIFICATION = "Beacons Set";
  
  static var isDebug = true;
}
