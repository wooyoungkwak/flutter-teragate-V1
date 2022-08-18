// ignore_for_file: constant_identifier_names, non_constant_identifier_names
class Env {
  // static const String TEST_SERVER = "http://192.168.0.247";  // local 테스트 서버
  static const String TEST_SERVER = "http://teraenergy.iptime.org"; // 개발 테스트 서버
  static const String REAL_SERVER = "http://teragroupware.duckdns.org";

  static const String SERVER_URL = TEST_SERVER;

  static const String SERVER_LOGIN_URL = '$SERVER_URL:3000/login';
  static const String SERVER_GET_IN_URL = '$SERVER_URL:3000/teragate/goToWork';
  static const String SERVER_GET_OUT_URL = '$SERVER_URL:3000/teragate/leaveWork';
  static const String SERVER_REFRESH_TOKEN_URL = '$SERVER_URL:3000/teragate/refreshToken';

  static const String INITIAL_UUID = '74278bdb-b644-4520-8f0c-720eeaffffff';

  static const String SERVER_GROUPWARE_TEST = "$SERVER_URL:8060/pageLnk/Home";
  static const String SERVER_GROUPWARE_REAL = "$SERVER_URL/signIn";

  static const String SERVER_GROUPWARE_URL = SERVER_GROUPWARE_TEST;

  static const String USER_NICK_NAME = 'USER_NICK_NAME';
  static const String LOGIN_ID = 'LOGIN_ID';
  static const String LOGIN_PW = 'LOGIN_PW';

  static const String WORK_GET_IN = "getin";
  static const String WORK_GET_OUT = "getout";

  static const String KEY_ID_CHECK = 'KEY_ID_CHECK';
  static const String KEY_LOGIN_SUCCESS = "success";
  static const String KEY_ACCESS_TOKEN = "accessToken";
  static const String KEY_REFRESH_TOKEN = "refreshToken";
  static const String KEY_GET_IN_CHECK = "getInCheck";
  static const String KEY_GET_OUT_CHECK = "getOutCheck";
  static const String KEY_LOGIN_STATE = "loginState";
  static const String KEY_LOGIN_RETURN_ID = "loginReturnID";
  static const String KEY_SETTING_WEEK_GI_SWITCH = "WeekSwitchGi";
  static const String KEY_SETTING_MON_GI_SWITCH = "MondaySwitchGi";
  static const String KEY_SETTING_TUE_GI_SWITCH = "TuesdaySwitchGi";
  static const String KEY_SETTING_WED_GI_SWITCH = "WednesdaySwitchGi";
  static const String KEY_SETTING_THU_GI_SWITCH = "ThursdaySwitchGi";
  static const String KEY_SETTING_FRI_GI_SWITCH = "FridaySwitchGi";
  static const String KEY_SETTING_SAT_GI_SWITCH = "SaturdaySwitchGi";
  static const String KEY_SETTING_SUN_GI_SWITCH = "SundaySwitchGi";
  static const String KEY_SETTING_WEEK_GO_SWITCH = "WeekSwitchGO";
  static const String KEY_SETTING_MON_GO_SWITCH = "MondaySwitchGO";
  static const String KEY_SETTING_TUE_GO_SWITCH = "TuesdaySwitchGO";
  static const String KEY_SETTING_WED_GO_SWITCH = "WednesdaySwitchGO";
  static const String KEY_SETTING_THU_GO_SWITCH = "ThursdaySwitchGO";
  static const String KEY_SETTING_FRI_GO_SWITCH = "FridaySwitchGO";
  static const String KEY_SETTING_SAT_GO_SWITCH = "SaturdaySwitchGO";
  static const String KEY_SETTING_SUN_GO_SWITCH = "SundaySwitchGO";
  static const String KEY_SETTING_WEEK_GI_TIME = "WeekTimeGetIn";
  static const String KEY_SETTING_MON_GI_TIME = "MondayTimeGetIn";
  static const String KEY_SETTING_TUE_GI_TIME = "TuesdayTimeGetIn";
  static const String KEY_SETTING_WED_GI_TIME = "WednesdayTimeGetIn";
  static const String KEY_SETTING_THU_GI_TIME = "ThursdayTimeGetIn";
  static const String KEY_SETTING_FRI_GI_TIME = "FridayTimeGetIn";
  static const String KEY_SETTING_SAT_GI_TIME = "SaturdayTimeGetIn";
  static const String KEY_SETTING_SUN_GI_TIME = "SundayTimeGetIn";
  static const String KEY_SETTING_WEEK_GO_TIME = "WeekTimeGetOut";
  static const String KEY_SETTING_MON_GO_TIME = "MondayTimeGetOut";
  static const String KEY_SETTING_TUE_GO_TIME = "TuesdayTimeGetOut";
  static const String KEY_SETTING_WED_GO_TIME = "WednesdayTimeGetOut";
  static const String KEY_SETTING_THU_GO_TIME = "ThursdayTimeGetOut";
  static const String KEY_SETTING_FRI_GO_TIME = "FridayTimeGetOut";
  static const String KEY_SETTING_SAT_GO_TIME = "SaturdayTimeGetOut";
  static const String KEY_SETTING_SUN_GO_TIME = "SundayTimeGetOut";
  static const String KEY_SETTING_UUID = "uuid";
  static const String KEY_SETTING_VIBRATE = "VIBRATE";
  static const String KEY_SETTING_SOUND = "SOUND";
  static const String KEY_SETTING_ALARM = "ALARM";
  static const String KEY_SETTING_GI_SWITCH = "GI_SWITCH";
  static const String KEY_SETTING_GO_SWITCH = "GO_SWITCH";

  static const String DEFAULT_GI_TIME = "09:00:00";
  static const String DEFAULT_GO_TIME = "18:00:00";

  static const String MSG_NOT_TOKEN = "로그 아웃 후에 다시 로그인 해주세요.";
  static const String MSG_GET_IN_EXIST = "이미 출근 등록이 완료 되었습니다.";
  static const String MSG_GET_IN_SUCCESS = "출근 등록이 완료 되었습니다.";
  static const String MSG_GET_OUT_SUCCESS = "퇴근 등록이 완료 되었습니다.";
  static const String MSG_GET_IN_FAIL = "출근 등록이 실패 하였습니다.";
  static const String MSG_GET_OUT_FAIL = "퇴근 등록이 실패 하였습니다.";
  static const String MSG_MINOR_FAIL = "비콘이 존재 하지 않습니다. 등록을 실패하였습니다.";
  static const String MSG_LODING = "등록중입니다 ....";
  static const String MSG_PERMISSON_LOCATION = "위치 권한을 항상 허용으로 변경해 주세요.";
  static const String MSG_LOGIN_FAIL = "ID 또는 Passwoard 를 확인하세요.";

  static const String TITLE_PERMISSION = "권한 허용";
  static const String TITLE_DIALOG = "알림";

  static const String UUID_DEFAULT = "74278BDB-B644-4520-8F0C-720EEAFFFFFF";

  static const String NOTIFICATION_CHANNEL_ID = "channelID";
  static const String NOTIFICATION_CHANNEL_ID_NO_ALARM = "channelIDNoAlarm";
  static const String NOTIFICATION_CHANNEL_NAME = "channelName";
  static const String NOTIFICATION_CHANNEL_NAME_NO_ALARM = "channelNameNoAlarm";

  static bool isDebug = true;

  static String TITLE_SETTING_GET_IN = "WORK ON";
  static String TITLE_SETTING_GET_IN_SUB = "Set up your work schedule";
  static String TITLE_SETTING_GET_OFF = "WORK OFF";
  static String TITLE_SETTING_GET_OFF_SUB = "Set up your work schedule";
  static String TITLE_SETTING_ALARM = "Alarm Setting";
  static String TITLE_SETTING_INITIALIZATION = "Initialization";
  static String TITLE_SETTING_UUID = "UUID";
  static String TITLE_SETTING_UUID_SUB = "Currently set UUID:";
  static String TITLE_SETTING_UUID_DEFAULT_BUTTON = "Default Value Setting";
  static String TITLE_SETTING_UUID_GET_BUTTON = "Get UUID";

  void UUID_SUBtKR() {
    TITLE_SETTING_GET_IN = "출근";
    TITLE_SETTING_GET_IN_SUB = "출근 일정을 설정하세요";
    TITLE_SETTING_GET_OFF = "퇴근";
    TITLE_SETTING_GET_OFF_SUB = "퇴근 알람을 설정하세요";
    TITLE_SETTING_ALARM = "알람 설정";
    TITLE_SETTING_INITIALIZATION = "초기화";
    TITLE_SETTING_UUID_SUB = "현재 설정된 UUID:";
    TITLE_SETTING_UUID_DEFAULT_BUTTON = "초기값 세팅";
    TITLE_SETTING_UUID_GET_BUTTON = "UUID 가져오기";
  }
}
