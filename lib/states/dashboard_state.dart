import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

//현재시간
import 'package:teragate_test/states/setting_state.dart';
import 'package:teragate_test/utils/debug_util.dart';
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

  String? name = "test";
  String? id = "test1"; //id
  String? pw = "test2"; //pw
  String? deviceip = "00";

  final StreamController<String> beaconStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    secureStorage = SecureStorage();
    initBeacon(setNotification, setForGetIn, beaconStreamController, secureStorage);

    WidgetsBinding.instance.addObserver(this);

    getIPAddress().then((map) => deviceip = map["ip"]);
    const duration = Duration(seconds: 10);

    initNotification();

    _backgroundTimer();
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
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('TERA GATE 출퇴근'),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    showOkCancelDialog(context, "로그아웃", '로그인 페이지로 이동하시겠습니까?', moveLogin);
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
                  Expanded(child: comuteItem()), // 변경 ui 출력 테스트
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
                      setForGetIn();
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: '퇴근',
                    onTap: () async {
                      setForGetOut();
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: '그룹웨어',
                    onTap: () async {
                      moveWebview(context, id!, pw!);
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: '환경설정',
                    onTap: () async {
                      moveSetting(context);
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: '초기화',
                    onTap: () async {
                      secureStorage.delete(Env.KEY_GET_IN_CHECK);
                    })
              ],
            ),
          ),
        ));
  }

  Widget comuteItem() {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Container(
          child: Text(
            "이름 : $name",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
          ),
          margin: const EdgeInsets.all(8.0),
        ),
        Container(
          child: Text(
            "디바이스 아이피 : $deviceip",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
          ),
          margin: const EdgeInsets.all(8.0),
        ),
        Container(
          child: Text(
            "접속시간 : ${getDateToStringForAllInNow()}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
          ),
          margin: const EdgeInsets.all(8.0),
        )
      ]),
    );
  }

  // Notifcation 알람 초기화
  Future<void> initNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
  }

  void setNotification(String message) {
    showNotification(flutterLocalNotificationsPlugin, Env.TITLE_BEACON_NOTIFICATION, message);
  }

  // 로그인 화면으로 이동
  void moveLogin() async {
    String? isChecked = await secureStorage.read(Env.KEY_ID_CHECK);
    if (isChecked == null && isChecked == "false") {
      secureStorage.write(Env.LOGIN_ID, "");
    }
    secureStorage.write(Env.LOGIN_PW, "");
    secureStorage.write(Env.KEY_LOGIN_STATE, "false");
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
  }

  // 웹 뷰 화면으로 이동
  void moveWebview(BuildContext context, String? id, String? pw) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebViews(id!, pw!, null)));
  }

  //환경 설정 화면으로 이동
  void moveSetting(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Setting(null)));
  }

  // 출근 등록
  void setForGetIn() async {
    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);
    processGetIn(accessToken!, refreshToken!, deviceip!, secureStorage, 0).then((workInfo) {
      if (workInfo.success) {
        setNotification(workInfo.message);
      } else {
        setNotification(workInfo.message);
      }
    });
  }

  // 퇴근 등록
  void setForGetOut() async {
    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);
    processGetOut(accessToken!, refreshToken!, deviceip!, secureStorage, 0).then((workInfo) {
      if (workInfo.success) {
        setNotification(workInfo.message);
      } else {
        setNotification(workInfo.message);
      }
    });
  }

  //요일별 알람 체크(출근)
  Future<Map<String, dynamic>> getInTime(String key) async {
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

  //요일별 알람 체크(퇴근)
  Future<Map<String, dynamic>> getOutTime(String key) async {
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

  //남은 시간 계산(초)
  Future<void> _backgroundTimer() async {
    Timer? t = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Log.debug("_backgroundTimer");
      if (await secureStorage.read(Env.KEY_SETTING_GI_ON_OFF) == "true") {
        _workIn();
      } else if (await secureStorage.read(Env.KEY_SETTING_GO_ON_OFF) == "true") {
        _workOut();
      }
    });

    //if(t.isActive) t.cancel();

    // Future.delayed(Duration(seconds: diff.inSeconds.toInt()), () async {
    //   showNotification(flutterLocalNotificationsPlugin, "자동 출근 테스트?", texttime);
    //   initBeacon(setNotification, setForGetIn, beaconStreamController, secureStorage);
    //   await startBeacon();
    //   	});

    // Timer.run(() async{
    //   showNotification(flutterLocalNotificationsPlugin, "자동 출근 테스트?", diff.inSeconds.toString());
    //   oneCheck = false; //완료되면 다시 타이머 작동
    //   //initBeacon(setNotification, setForGetIn, beaconStreamController, secureStorage);
    //   //await startBeacon();
    // });
  }

  Future<void> _workIn() async {
    Map<String, dynamic>? gimap;
    String texttime;
    String? alarmtime;

    if (await secureStorage.read(Env.KEY_SETTING_GI_ON_OFF) == "true") {
      if (await secureStorage.read(Env.KEY_SETTING_WEEK_GI) == "false") {
        switch (getWeek()) {
          case 'Mon':
            gimap = await getInTime(Env.KEY_SETTING_MON_GI);
            break;
          case 'Tue':
            gimap = await getInTime(Env.KEY_SETTING_THU_GI);
            break;
          case 'Wed':
            gimap = await getInTime(Env.KEY_SETTING_WED_GI);
            break;
          case 'Thu':
            gimap = await getInTime(Env.KEY_SETTING_THU_GI);
            break;
          case 'Fri':
            gimap = await getInTime(Env.KEY_SETTING_FRI_GI);
            break;
          case 'Sat':
            gimap = await getInTime(Env.KEY_SETTING_SAT_GI);
            break;
          case 'Sun':
            gimap = await getInTime(Env.KEY_SETTING_SUN_GI);
            break;
        }
        alarmtime = gimap!["alarmtime"];
        bool alarmSwitch = gimap["alarmSwitch"];

        // ignore: unrelated_type_equality_checks
        if (alarmSwitch == "true") {
          if (alarmtime != null) {
            texttime = getDateToStringForYYYYMMDDInNow() + " " + alarmtime;
          } else {
            texttime = getDateToStringForYYYYMMDDInNow() + " " + "08:30:00";
          }
          _excuteWork(setForGetIn, texttime);
        }
      } else {
        String? temp = await secureStorage.read(Env.KEY_SETTING_WEEK_GI_TIME);
        texttime = getDateToStringForYYYYMMDDInNow() + " " + temp!;
        _excuteWork(setForGetIn, texttime);
      }
    }
  }

  Future<void> _workOut() async {
    Map<String, dynamic>? gimap;
    String texttime;
    String? alarmtime;
    if (await secureStorage.read(Env.KEY_SETTING_GO_ON_OFF) == "true") {

      if (await secureStorage.read(Env.KEY_SETTING_WEEK_GO) == "false") {

        switch (getWeek()) {
          case 'Mon':
            gimap = await getOutTime(Env.KEY_SETTING_MON_GO);
            break;
          case 'Tue':
            gimap = await getOutTime(Env.KEY_SETTING_THU_GO);
            break;
          case 'Wed':
            gimap = await getOutTime(Env.KEY_SETTING_WED_GO);
            break;
          case 'Thu':
            gimap = await getOutTime(Env.KEY_SETTING_THU_GO);
            break;
          case 'Fri':
            gimap = await getOutTime(Env.KEY_SETTING_FRI_GO);
            break;
          case 'Sat':
            gimap = await getOutTime(Env.KEY_SETTING_SAT_GO);
            break;
          case 'Sun':
            gimap = await getOutTime(Env.KEY_SETTING_SUN_GO);
            break;
        }

        alarmtime = gimap!["alarmtime"];
        bool alarmSwitch = gimap["alarmSwitch"];

        // ignore: unrelated_type_equality_checks
        if (alarmSwitch == "true") {
          if (alarmtime != null) {
            texttime = getDateToStringForYYYYMMDDInNow() + " " + alarmtime;
          } else {
            texttime = getDateToStringForYYYYMMDDInNow() + " " + "18:00:00";
          }
          await _excuteWork(setForGetOut, texttime);
        }

      } else {
        String? temp = await secureStorage.read(Env.KEY_SETTING_WEEK_GO_TIME);
        texttime = getDateToStringForYYYYMMDDInNow() + " " + temp!;
        _excuteWork(setForGetOut, texttime);
      }
    }
  }

  Future<void> _excuteWork(Function setForGetInOut, String texttime) async {
    Duration diffTime = getToDateTime(texttime).difference(getNow());
    if (diffTime.inMinutes.toInt() == 0) {
      initBeacon(setNotification, setForGetIn, beaconStreamController, secureStorage);
      startBeacon();
    }
    Log.debug(" diffTime ====> $diffTime.inMinutes.toInt() ");
  }

  // Future<void> test() async{
  //   Log.debug(" week ============== ");
  //   Log.debug( " gi mon = ${await secureStorage.read(Env.KEY_SETTING_MON_GI)}" );
  //   Log.debug( " gi thu = ${await secureStorage.read(Env.KEY_SETTING_THU_GI)}" );
  //   Log.debug( " gi wed = ${await secureStorage.read(Env.KEY_SETTING_WED_GI)}" );
  //   Log.debug( " gi Thu = ${await secureStorage.read(Env.KEY_SETTING_THU_GI)}" );
  //   Log.debug( " gi fri = ${await secureStorage.read(Env.KEY_SETTING_FRI_GI)}" );
  //   Log.debug( " gi sat = ${await secureStorage.read(Env.KEY_SETTING_SAT_GI)}" );
  //   Log.debug( " gi sun = ${await secureStorage.read(Env.KEY_SETTING_SUN_GI)}" );
  //   Log.debug(" time ============== ");
  //   Log.debug( " gi mon time = ${await secureStorage.read(Env.KEY_SETTING_MON_GI_TIME)}" );
  //   Log.debug( " gi thu time = ${await secureStorage.read(Env.KEY_SETTING_THU_GI_TIME)}" );
  //   Log.debug( " gi wed time = ${await secureStorage.read(Env.KEY_SETTING_WED_GI_TIME)}" );
  //   Log.debug( " gi Thu time = ${await secureStorage.read(Env.KEY_SETTING_THU_GI_TIME)}" );
  //   Log.debug( " gi fri time = ${await secureStorage.read(Env.KEY_SETTING_FRI_GI_TIME)}" );
  //   Log.debug( " gi sat time = ${await secureStorage.read(Env.KEY_SETTING_SAT_GI_TIME)}" );
  //   Log.debug( " gi sun time = ${await secureStorage.read(Env.KEY_SETTING_SUN_GI_TIME)}" );

  //   Log.debug(" =================== ");
  //   Log.debug(" week ============== ");
  //   Log.debug( " go mon = ${await secureStorage.read(Env.KEY_SETTING_MON_GO)}" );
  //   Log.debug( " go thu = ${await secureStorage.read(Env.KEY_SETTING_THU_GO)}" );
  //   Log.debug( " go wed = ${await secureStorage.read(Env.KEY_SETTING_WED_GO)}" );
  //   Log.debug( " go Thu = ${await secureStorage.read(Env.KEY_SETTING_THU_GO)}" );
  //   Log.debug( " go fri = ${await secureStorage.read(Env.KEY_SETTING_FRI_GO)}" );
  //   Log.debug( " go sat = ${await secureStorage.read(Env.KEY_SETTING_SAT_GO)}" );
  //   Log.debug( " go sun = ${await secureStorage.read(Env.KEY_SETTING_SUN_GO)}" );
  //   Log.debug(" time ============== ");
  //   Log.debug( " gi mon time = ${await secureStorage.read(Env.KEY_SETTING_MON_GO_TIME)}" );
  //   Log.debug( " gi thu time = ${await secureStorage.read(Env.KEY_SETTING_THU_GO_TIME)}" );
  //   Log.debug( " gi wed time = ${await secureStorage.read(Env.KEY_SETTING_WED_GO_TIME)}" );
  //   Log.debug( " gi Thu time = ${await secureStorage.read(Env.KEY_SETTING_THU_GO_TIME)}" );
  //   Log.debug( " gi fri time = ${await secureStorage.read(Env.KEY_SETTING_FRI_GO_TIME)}" );
  //   Log.debug( " gi sat time = ${await secureStorage.read(Env.KEY_SETTING_SAT_GO_TIME)}" );
  //   Log.debug( " gi sun time = ${await secureStorage.read(Env.KEY_SETTING_SUN_GO_TIME)}" );

  // }
}
