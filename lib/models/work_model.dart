import 'package:teragate_test/config/env.dart';

class WorkData {
  List<String> initTimeGetIn = ["08:30", "08:30", "08:30", "08:30", "08:30", "08:30", "08:30"];
  List<String> initTimeGetOut = ["18:00", "18:00", "18:00", "18:00", "18:00", "18:00", "18:00"];
  List<String> weekKR = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  List<String> weekAlarmGITime = [Env.KEY_SETTING_MON_GI_TIME, Env.KEY_SETTING_TUE_GI_TIME, Env.KEY_SETTING_WED_GI_TIME, Env.KEY_SETTING_THU_GI_TIME, Env.KEY_SETTING_FRI_GI_TIME, Env.KEY_SETTING_SAT_GI_TIME, Env.KEY_SETTING_SUN_GI_TIME];
  List<String> weekAlarmGOTime = [Env.KEY_SETTING_MON_GO_TIME, Env.KEY_SETTING_TUE_GO_TIME, Env.KEY_SETTING_WED_GO_TIME, Env.KEY_SETTING_THU_GO_TIME, Env.KEY_SETTING_FRI_GO_TIME, Env.KEY_SETTING_SAT_GO_TIME, Env.KEY_SETTING_SUN_GO_TIME];
  List<String> weekAlarmGI = [Env.KEY_SETTING_MON_GI_SWITCH, Env.KEY_SETTING_TUE_GI_SWITCH, Env.KEY_SETTING_WED_GI_SWITCH, Env.KEY_SETTING_THU_GI_SWITCH, Env.KEY_SETTING_FRI_GI_SWITCH, Env.KEY_SETTING_SAT_GI_SWITCH, Env.KEY_SETTING_SUN_GI_SWITCH];
  List<String> weekAlarmGO = [Env.KEY_SETTING_MON_GO_SWITCH, Env.KEY_SETTING_TUE_GO_SWITCH, Env.KEY_SETTING_WED_GO_SWITCH, Env.KEY_SETTING_THU_GO_SWITCH, Env.KEY_SETTING_FRI_GO_SWITCH, Env.KEY_SETTING_SAT_GO_SWITCH, Env.KEY_SETTING_SUN_GO_SWITCH];
  List<bool> switchDay = [true, true, true, true, true, false, false]; //스위치 true/false
}