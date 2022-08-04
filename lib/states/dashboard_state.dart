import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

//현재시간
import 'package:teragate_test/states/setting_state.dart';
import 'package:timer_builder/timer_builder.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/services/network_service.dart';
import 'package:teragate_test/services/server_service.dart';
import 'package:teragate_test/services/beacon_service.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/states/webview_state.dart';
import 'package:teragate_test/utils/alarm_util.dart';
import 'package:teragate_test/utils/time_util.dart';
import 'package:teragate_test/utils/debug_util.dart';

//플러터 플로팅버튼용
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

//Back버튼 기능 변경(종료 > background)
import 'package:move_to_background/move_to_background.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late SecureStorage secureStorage;

  int nrMessagesReceived = 0;

  String? name = "";
  String? id = ""; //id
  String? pw = ""; //pw
  String? deviceip = "";
  Timer? backgroundTimer;

  final StreamController<String> beaconStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    secureStorage = SecureStorage();
    // initBeacon(_setNotification, _runToGetIn, beaconStreamController, secureStorage);

    WidgetsBinding.instance.addObserver(this);

    getIPAddress().then((map) => deviceip = map["ip"]);

    _initNotification();

    _backgroundTimer().then((_backgroundTimer) => backgroundTimer = _backgroundTimer);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(appLifecycleState);
    switch (appLifecycleState) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void dispose() {
    beaconStreamController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          MoveToBackground.moveTaskToBack();
          return Future(() => false);
        },
        child: _initScaffoldByMain());
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future(() => false);
        },
        child: widget);
  }

  MaterialApp _createMaterialApp(Widget widget) {
    return MaterialApp(home: widget);
  }

  Container _createContainer(Widget widget) {
    return Container(
        margin: const EdgeInsets.all(8.0),
        // padding: const EdgeInsets.all(10),
        // decoration: const BoxDecoration(
        //   color: Color(0xFFEEEEEE),
        // ),
        child: widget);
  }

  Text _createText(String subject, String value) {
    return Text(
      "$subject : $value",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.blue,
      ),
    );
  }

  Scaffold _initScaffoldByMain() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TERA GATE 출퇴근'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showOkCancelDialog(context, "로그아웃", '로그인 페이지로 이동하시겠습니까?', _moveLogin);
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: const Text(
                "근태 확인",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
              margin: const EdgeInsets.all(8.0),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(child: _initScaffoldByComuteItem()), // 변경 ui 출력 테스트
            TimerBuilder.periodic(
              const Duration(seconds: 1),
              builder: (context) {
                return Text(
                  getDateToStringForAllInNow(),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
                );
              },
            ),
          ],
        ),
      ),
      //플로팅 버튼 추가하기. - 해당 버튼 변경시키기.

      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.redAccent,
        overlayColor: Colors.grey,
        overlayOpacity: 0.5,
        closeManually: true,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '출근',
              // backgroundColor: Colors.blue,
              onTap: () async {
                _runToGetIn();
              }),
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '퇴근',
              onTap: () async {
                _runToGetOut();
              }),
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '그룹웨어',
              onTap: () async {
                _moveWebview(context, id!, pw!);
              }),
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '환경설정',
              onTap: () async {
                _moveSetting(context);
              })
        ],
      ),
    );
  }

  Scaffold _initScaffoldByComuteItem() {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[_createContainer(_createText("이름", name!)), _createContainer(_createText("디바이스 아이피", deviceip!)), _createContainer(_createText("접속시간", getDateToStringForAllInNow()))]),
    );
  }

  // Notifcation 알람 초기화
  Future<void> _initNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
  }

  void _setNotification(String message) {
    selectNotiType(flutterLocalNotificationsPlugin, Env.TITLE_DIALOG, message);
  }

  void _moveLogin() async {
    String? isChecked = await secureStorage.read(Env.KEY_ID_CHECK);
    if (isChecked == null && isChecked == "false") {
      secureStorage.write(Env.LOGIN_ID, "");
    }
    secureStorage.write(Env.LOGIN_PW, "");
    secureStorage.write(Env.KEY_LOGIN_STATE, "false");
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
  }

  void _moveWebview(BuildContext context, String? id, String? pw) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebViews(id!, pw!, null)));
  }

  void _moveSetting(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Setting(null)));
  }

  void _runToGetIn() async {
    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);

    if (accessToken == null) {
      _setNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    if (refreshToken == null) {
      _setNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    processGetIn(accessToken, refreshToken, deviceip!, secureStorage, 0).then((workInfo) {
      if (workInfo.success) {
        _setNotification(workInfo.message);
      } else {
        _setNotification(workInfo.message);
      }
    });
  }

  void _runToGetOut() async {
    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);

    if (accessToken == null) {
      _setNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    if (refreshToken == null) {
      _setNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    processGetOut(accessToken, refreshToken, deviceip!, secureStorage, 0).then((workInfo) {
      if (workInfo.success) {
        _setNotification(workInfo.message);
      } else {
        _setNotification(workInfo.message);
      }
    });
  }

  Future<Map<String, dynamic>> _getTimeByGetIn(String key) async {
    String? result;
    bool alarmSwitch = false;
    if (await secureStorage.read(key) == "true") {
      switch (getWeek()) {
        case 'Mon':
          result = await secureStorage.read(Env.KEY_SETTING_MON_GI_TIME);
          break;
        case 'Tue':
          result = await secureStorage.read(Env.KEY_SETTING_THU_GI_TIME);
          break;
        case 'Wed':
          result = await secureStorage.read(Env.KEY_SETTING_WED_GI_TIME);
          break;
        case 'Thu':
          result = await secureStorage.read(Env.KEY_SETTING_THU_GI_TIME);
          break;
        case 'Fri':
          result = await secureStorage.read(Env.KEY_SETTING_FRI_GI_TIME);
          break;
        case 'Sat':
          result = await secureStorage.read(Env.KEY_SETTING_SAT_GI_TIME);
          break;
        case 'Sun':
          result = await secureStorage.read(Env.KEY_SETTING_SUN_GI_TIME);
          break;
      }
      alarmSwitch = true;
    }

    return {"alarmtime": result, "alarmSwitch": alarmSwitch};
  }

  Future<Map<String, dynamic>> _getTimeByGetOut(String key) async {
    String? result;
    bool alarmSwitch = false;
    String? value = await secureStorage.read(key);

    if (value == "true") {
      switch (getWeek()) {
        case 'Mon':
          result = await secureStorage.read(Env.KEY_SETTING_MON_GO_TIME);
          break;
        case 'Tue':
          result = await secureStorage.read(Env.KEY_SETTING_THU_GO_TIME);
          break;
        case 'Wed':
          result = await secureStorage.read(Env.KEY_SETTING_WED_GO_TIME);
          break;
        case 'Thu':
          result = await secureStorage.read(Env.KEY_SETTING_THU_GO_TIME);
          break;
        case 'Fri':
          result = await secureStorage.read(Env.KEY_SETTING_FRI_GO_TIME);
          break;
        case 'Sat':
          result = await secureStorage.read(Env.KEY_SETTING_SAT_GO_TIME);
          break;
        case 'Sun':
          result = await secureStorage.read(Env.KEY_SETTING_SUN_GO_TIME);
          break;
      }

      alarmSwitch = true;
    }
    return {"alarmtime": result, "alarmSwitch": alarmSwitch};
  }

  Future<void> _setWorkGetIn(String data) async {
    Map<String, dynamic>? gimap;
    String texttime;
    String? alarmtime;

    switch (getWeek()) {
      case 'Mon':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_MON_GI);
        break;
      case 'Tue':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_THU_GI);
        break;
      case 'Wed':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_WED_GI);
        break;
      case 'Thu':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_THU_GI);
        break;
      case 'Fri':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_FRI_GI);
        break;
      case 'Sat':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_SAT_GI);
        break;
      case 'Sun':
        gimap = await _getTimeByGetIn(Env.KEY_SETTING_SUN_GI);
        break;
    }
    alarmtime = gimap!["alarmtime"];
    bool alarmSwitch = gimap["alarmSwitch"];

    // ignore: unrelated_type_equality_checks
    if (alarmSwitch == true) {
      if (alarmtime != null) {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + alarmtime;
      } else {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + "08:30:00";
      }
      _runToBeacon(_runToGetIn, texttime);
    }

  }

  Future<void> _setWorkGetOut(String data) async {
    Map<String, dynamic>? gimap;
    String texttime;
    String? alarmtime;

    switch (getWeek()) {
      case 'Mon':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_MON_GO);
        break;
      case 'Tue':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_THU_GO);
        break;
      case 'Wed':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_WED_GO);
        break;
      case 'Thu':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_THU_GO);
        break;
      case 'Fri':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_FRI_GO);
        break;
      case 'Sat':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_SAT_GO);
        break;
      case 'Sun':
        gimap = await _getTimeByGetOut(Env.KEY_SETTING_SUN_GO);
        break;
    }

    alarmtime = gimap!["alarmtime"];
    bool alarmSwitch = gimap["alarmSwitch"];

    // ignore: unrelated_type_equality_checks
    if (alarmSwitch == true) {
      if (alarmtime != null) {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + alarmtime;
      } else {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + "18:00:00";
      }

      await _runToBeacon(_runToGetOut, texttime);
    }
  }

  Future<void> _runToBeacon(Function setForGetInOut, String texttime) async {
    Duration diffTime = getToDateTime(texttime).difference(getNow());
    if (diffTime.inMinutes.toInt() == 0) {
      initBeacon(_setNotification, setForGetInOut, beaconStreamController, secureStorage);
      startBeacon();
    }
  }

  Future<Timer> _backgroundTimer() async {
    Timer? timer = Timer.periodic(const Duration(seconds: 40), (timer) async {
      if (await secureStorage.read(Env.KEY_SETTING_GI_ON_OFF) == "true") {
        compute(_setWorkGetIn, "") ;
      }

      if (await secureStorage.read(Env.KEY_SETTING_GO_ON_OFF) == "true") {
        compute(_setWorkGetOut, "") ;
      }
    });

    //if(t.isActive) t.cancel();
    return timer;
  }
  
}
