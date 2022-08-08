// ignore_for_file: constant_identifier_names

class Env {
  static const String TEST_SERVER = "http://192.168.0.164";
  static const String REAL_SERVER = "http://teraenergy.iptime.org";

  static const String SERVER_LOGIN_URL = '$REAL_SERVER:3000/login';
  static const String SERVER_GET_IN_URL = '$REAL_SERVER:3000/teragate/goToWork';
  static const String SERVER_GET_OUT_URL = '$REAL_SERVER:3000/teragate/leaveWork';
  static const String SERVER_REFRESH_TOKEN_URL = '$REAL_SERVER:3000/teragate/refreshToken';

  static const String INITIAL_UUID = '74278bdb-b644-4520-8f0c-720eeaffffff';

  static const String SERVER_GROUPWARE_TEST = "$REAL_SERVER:8080";
  static const String SERVER_GROUPWARE_REAL = "http://teragroupware.duckdns.org";
  static const String SERVER_GROUPWARE_URL = '$SERVER_GROUPWARE_TEST/signInapp';

  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String WORK_GET_IN = "getin";
  static const String WORK_GET_OUT = "getout";

  static const String KEY_ID_CHECK = 'KEY_ID_CHECK';
  static const String KEY_SUCCESS = "sucess";
  static const String KEY_MESSAGE = "message";
  static const String KEY_ACCESS_TOKEN = "accessToken";
  static const String KEY_REFRESH_TOKEN = "refreshToken";
  static const String KEY_GET_IN_CHECK = "getInCheck";
  static const String KEY_GET_OUT_CHECK = "getOutCheck";
  static const String KEY_LOGIN_STATE = "loginState";
  static const String KEY_SETTING_WEEK_GI_SWITCH =  "WeekSwitchGi";
  static const String KEY_SETTING_MON_GI_SWITCH =   "MondaySwitchGi";
  static const String KEY_SETTING_TUE_GI_SWITCH =   "TuesdaySwitchGi";
  static const String KEY_SETTING_WED_GI_SWITCH =   "WednesdaySwitchGi";
  static const String KEY_SETTING_THU_GI_SWITCH =   "ThursdaySwitchGi";
  static const String KEY_SETTING_FRI_GI_SWITCH =   "FridaySwitchGi";
  static const String KEY_SETTING_SAT_GI_SWITCH =   "SaturdaySwitchGi";
  static const String KEY_SETTING_SUN_GI_SWITCH =   "SundaySwitchGi";
  static const String KEY_SETTING_WEEK_GO_SWITCH =  "WeekSwitchGO";
  static const String KEY_SETTING_MON_GO_SWITCH =   "MondaySwitchGO";
  static const String KEY_SETTING_TUE_GO_SWITCH =   "TuesdaySwitchGO";
  static const String KEY_SETTING_WED_GO_SWITCH =   "WednesdaySwitchGO";
  static const String KEY_SETTING_THU_GO_SWITCH =   "ThursdaySwitchGO";
  static const String KEY_SETTING_FRI_GO_SWITCH =   "FridaySwitchGO";
  static const String KEY_SETTING_SAT_GO_SWITCH =   "SaturdaySwitchGO";
  static const String KEY_SETTING_SUN_GO_SWITCH =   "SundaySwitchGO";
  static const String KEY_SETTING_WEEK_GI_TIME =    "WeekTimeGetIn";
  static const String KEY_SETTING_MON_GI_TIME =     "MondayTimeGetIn";
  static const String KEY_SETTING_TUE_GI_TIME =     "TuesdayTimeGetIn";
  static const String KEY_SETTING_WED_GI_TIME =     "WednesdayTimeGetIn";
  static const String KEY_SETTING_THU_GI_TIME =     "ThursdayTimeGetIn";
  static const String KEY_SETTING_FRI_GI_TIME =     "FridayTimeGetIn";
  static const String KEY_SETTING_SAT_GI_TIME =     "SaturdayTimeGetIn";
  static const String KEY_SETTING_SUN_GI_TIME =     "SundayTimeGetIn";
  static const String KEY_SETTING_WEEK_GO_TIME =    "WeekTimeGetOut";
  static const String KEY_SETTING_MON_GO_TIME =     "MondayTimeGetOut";
  static const String KEY_SETTING_TUE_GO_TIME =     "TuesdayTimeGetOut";
  static const String KEY_SETTING_WED_GO_TIME =     "WednesdayTimeGetOut";
  static const String KEY_SETTING_THU_GO_TIME =     "ThursdayTimeGetOut";
  static const String KEY_SETTING_FRI_GO_TIME =     "FridayTimeGetOut";
  static const String KEY_SETTING_SAT_GO_TIME =     "SaturdayTimeGetOut";
  static const String KEY_SETTING_SUN_GO_TIME =     "SundayTimeGetOut";
  static const String KEY_SETTING_UUID = "uuid";
  static const String KEY_SETTING_VIBRATE = "VIBRATE";
  static const String KEY_SETTING_SOUND = "SOUND";
  static const String KEY_SETTING_ALARM = "ALARM";
  static const String KEY_SETTING_GI_ON_OFF = "GIONOFF";
  static const String KEY_SETTING_GO_ON_OFF = "GOONOFF";

  static const String MSG_NOT_TOKEN = "로그 아웃 후에 다시 로그인 해주세요.";
  static const String MSG_GET_IN_EXIST = "이미 출근 등록이 완료 되었습니다.";
  static const String MSG_GET_IN_SUCCESS = "출근 등록이 완료 되었습니다.";
  static const String MSG_GET_OUT_SUCCESS = "퇴근 등록이 완료 되었습니다.";
  static const String MSG_GET_IN_FAIL = "출근 등록이 실패 하였습니다.";
  static const String MSG_GET_OUT_FAIL = "퇴근 등록이 실패 하였습니다.";
  static const String MSG_MINOR_FAIL = "비콘이 존재 하지 않습니다. 등록을 실패하였습니다.";
  static const String MSG_LODING = "등록중입니다 ....";
  static const String MSG_PERMISSON_LOCATION = "위치 권한을 항상 허용으로 변경해 주세요.";

  static const String TITLE_PERMISSION = "권한 허용";
  static const String TITLE_DIALOG = "알림";
  static const String TITLE_BEACON_NOTIFICATION = "비콘 설정";
  
  static const String UUID_DEFAULT = "74278BDB-B644-4520-8F0C-720EEAFFFFFF";

  static const String NOTIFICATION_CHANNEL_ID = "channelID";
  static const String NOTIFICATION_CHANNEL_NAME = "channelName";

  static bool isDebug = true;
}
