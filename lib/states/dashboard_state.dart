import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
import 'package:teragate_test/utils/Log_util.dart';

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

  String? name = "";
  String? deviceip = "";
  Timer? backgroundTimer;
  SimpleFontelicoProgressDialog? progressDialog;
  bool isShowProcess = false;
  late StreamSubscription streamSubscription;
  final StreamController<String> beaconStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    secureStorage = SecureStorage();

    WidgetsBinding.instance.addObserver(this);

    _initIp();

    _runBackgroundTimer().then((_backgroundTimer) => backgroundTimer = _backgroundTimer);

    _initProgressDialog().then((_progressDialog) => progressDialog = _progressDialog);

    _initNotification();
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
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _createWillPopScope(_initScaffoldByMain());
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          MoveToBackground.moveTaskToBack();
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
                _showProgressDialog();
                _runToGetIn();
              }),
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '퇴근',
              onTap: () async {
                _showProgressDialog();
                _runToGetOut();
              }),
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '그룹웨어',
              onTap: () async {
                _moveWebview(context);
              }),
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: '환경설정',
              onTap: () async {
                await _moveSetting(context);
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

  void _showNotification(String message) {
    selectNotificationType(flutterLocalNotificationsPlugin, Env.TITLE_DIALOG, message);
  }

  // ip 설정 ( wifi or mobile (lte, 5G 등 ) )
  void _initIp() {
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.mobile) {
        getIPAddressByMobile().then((map) {
          Log.log(' mobile ip address = ${map["ip"]}');
          deviceip = map["ip"];
        });
      } else if (result == ConnectivityResult.wifi) {
        getIPAddressByWifi().then((map) {
          Log.log(' wifi ip address = ${map["ip"]}');
          deviceip = map["ip"];
        });
      }
    });

    streamSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        getIPAddressByMobile().then((map) {
          Log.log(' mobile ip address = ${map["ip"]}');
          deviceip = map["ip"];
        });
      } else if (result == ConnectivityResult.wifi) {
        getIPAddressByWifi().then((map) {
          Log.log(' wifi ip address = ${map["ip"]}');
          deviceip = map["ip"];
        });
      }
    });
  }

  void _moveLogin() async {
    String? isChecked = await secureStorage.read(Env.KEY_ID_CHECK);
    if (isChecked == null && isChecked == "false") {
      secureStorage.write(Env.LOGIN_ID, "");
    }
    secureStorage.write(Env.LOGIN_PW, "");
    secureStorage.write(Env.KEY_LOGIN_STATE, "false");
    secureStorage.write(Env.KEY_ACCESS_TOKEN, "");
    secureStorage.write(Env.KEY_REFRESH_TOKEN, "");

    _stopBackgroundTimer();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
  }

  void _moveWebview(BuildContext context) async {
    String? userId = await secureStorage.read(Env.KEY_LOGIN_RETURN_ID);
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebViews(userId!, null)));
  }

  Future<void> _moveSetting(BuildContext context) async {
    String? uuid = await secureStorage.read(Env.KEY_SETTING_UUID);
    String? getin = await secureStorage.read(Env.KEY_SETTING_GI_SWITCH);
    String? getout = await secureStorage.read(Env.KEY_SETTING_GO_SWITCH);
    String? alarm = await secureStorage.read(Env.KEY_SETTING_ALARM);

    String beaconuuid = (uuid == null ? Env.UUID_DEFAULT : uuid);
    bool switchGetIn = (getin == null ? false : (getin == "true" ? true : false));
    bool switchGetOut = (getout == null ? false : (getout == "true" ? true : false));
    bool switchAlarm = (alarm == null ? false : (alarm == "true" ? true : false));

    Navigator.push(context, MaterialPageRoute(builder: (context) => Setting(beaconuuid, switchGetIn, switchGetOut, switchAlarm, null)));
  }

  void _runToGetIn() async {
    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);

    if (accessToken == null) {
      _showNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    if (refreshToken == null) {
      _showNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    processGetIn(accessToken, refreshToken, deviceip!, secureStorage, 0).then((workInfo) {
      _hideProgressDialog();
      if (workInfo.success) {
        _showNotification(workInfo.message);
      } else {
        _showNotification(workInfo.message);
      }
    });
  }

  void _runToGetOut() async {
    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);

    if (accessToken == null) {
      _showNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    if (refreshToken == null) {
      _showNotification(Env.MSG_NOT_TOKEN);
      return;
    }

    processGetOut(accessToken, refreshToken, deviceip!, secureStorage, 0).then((workInfo) {
      _hideProgressDialog();
      if (workInfo.success) {
        _showNotification(workInfo.message);
      } else {
        _showNotification(workInfo.message);
      }
    });
  }

  Future<void> _setWorkGetIn() async {
    String texttime;
    String? alarmtime;
    String? alarmSwitch;

    switch (getWeek()) {
      case 'Mon':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_MON_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_MON_GI_SWITCH);
        break;
      case 'Tue':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_TUE_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_TUE_GI_SWITCH);
        break;
      case 'Wed':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_WED_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_WED_GI_SWITCH);
        break;
      case 'Thu':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_THU_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_THU_GI_SWITCH);
        break;
      case 'Fri':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_FRI_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_FRI_GI_SWITCH);
        break;
      case 'Sat':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_SAT_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_SAT_GI_SWITCH);
        break;
      case 'Sun':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_SUN_GI_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_SUN_GI_SWITCH);
        break;
    }

    // ignore: unrelated_type_equality_checks
    if (alarmSwitch != null && alarmSwitch == "true") {
      if (alarmtime != null) {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + alarmtime;
      } else {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + Env.DEFAULT_GI_TIME;
      }
      Log.log("GI : alarmtime = $alarmtime :: alarmSwitch = $alarmSwitch :: texttime = $texttime");
      _runToBeacon(_runToGetIn, texttime);
    }
  }

  Future<void> _setWorkGetOut() async {
    String texttime;
    String? alarmtime;
    String? alarmSwitch;

    switch (getWeek()) {
      case 'Mon':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_MON_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_MON_GO_SWITCH);
        break;
      case 'Tue':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_TUE_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_TUE_GO_SWITCH);
        break;
      case 'Wed':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_WED_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_WED_GO_SWITCH);
        break;
      case 'Thu':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_THU_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_THU_GO_SWITCH);
        break;
      case 'Fri':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_FRI_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_FRI_GO_SWITCH);
        break;
      case 'Sat':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_SAT_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_SAT_GO_SWITCH);
        break;
      case 'Sun':
        alarmtime = await secureStorage.read(Env.KEY_SETTING_SUN_GO_TIME);
        alarmSwitch = await secureStorage.read(Env.KEY_SETTING_SUN_GO_SWITCH);
        break;
    }

    // ignore: unrelated_type_equality_checks
    if (alarmSwitch != null && alarmSwitch == "true") {
      if (alarmtime != null) {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + alarmtime;
      } else {
        texttime = getDateToStringForYYYYMMDDInNow() + " " + Env.DEFAULT_GO_TIME;
      }
      Log.log("GO : alarmtime = $alarmtime :: alarmSwitch = $alarmSwitch :: texttime = $texttime");
      _runToBeacon(_runToGetOut, texttime);
    }
  }

  void _runToBeacon(Function setForGetInOut, String texttime) {
    Duration diffTime = getToDateTime(texttime).difference(getNow());
    if (diffTime.inMinutes.toInt() == 0) {
      if (!isShowProcess) _showProgressDialog();
      initBeacon(_showNotification, _hideProgressDialog, setForGetInOut, beaconStreamController, secureStorage);
      startBeacon();
    }
  }

  Future<Timer> _runBackgroundTimer() async {
    Timer? timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      String? giSwitch = await secureStorage.read(Env.KEY_SETTING_GI_SWITCH);
      String? goSwitch = await secureStorage.read(Env.KEY_SETTING_GO_SWITCH);

      if (giSwitch == "true" && goSwitch == "true") {
        _setWorkGetIn().then((value) => _setWorkGetOut());
      } else {
        if (giSwitch == "true") {
          _setWorkGetIn();
        }

        if (goSwitch == "true") {
          _setWorkGetOut();
        }
      }
    });

    return timer;
  }

  Future<void> _stopBackgroundTimer() async {
    backgroundTimer!.cancel();
  }

  Future<SimpleFontelicoProgressDialog> _initProgressDialog() async {
    return SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
  }

  void _showProgressDialog() async {
    progressDialog!.show(message: Env.MSG_LODING, width: 200);
    isShowProcess = true;
  }

  void _hideProgressDialog() async {
    progressDialog!.hide();
    isShowProcess = false;
  }
}
