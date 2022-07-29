import 'dart:async';

import 'package:flutter/services.dart';
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

//플러터 플로팅버튼용
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late SecureStorage secureStorage;
  late StreamSubscription subscription;

  int nrMessagesReceived = 0;

  String? name = "test";
  String? id = "test1"; //id
  String? pw = "test2"; //pw
  String? deviceip = "00";

  var isRunning = false;
  bool isInForeground = true;
  var workSucces = false;

  final StreamController<String> beaconStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    secureStorage = SecureStorage();
    initBeacon(setNotification, setForGetIn, beaconStreamController, secureStorage).then((_subscription) => subscription = _subscription);
    
    WidgetsBinding.instance.addObserver(this);

    getIPAddress().then((map) => deviceip = map["ip"]);
    const duration = Duration(seconds: 10);

    initNotification();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    isInForeground = state == AppLifecycleState.resumed;
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
          SystemNavigator.pop();
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
                    label: '시작',
                    onTap: () async {
                      // initBeacon(setNotification, setForGetIn, beaconStreamController, secureStorage);
                      await startBeacon();
                      subscription.resume();
                    }),
                SpeedDialChild(
                    child: const Icon(Icons.copy),
                    label: '정지',
                    onTap: () async {
                      subscription.pause();
                      await stopBeacon();
                    }),
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

  void setRunning(bool state) {
    setState(() {
      isRunning = state;
    });
  }

  bool getIsRunning() {
    return isRunning;
  }

  bool getWorkSucces() {
    return workSucces;
  }

  // 로그인 화면으로 이동
  void moveLogin() async{
    String? isChecked = await secureStorage.read(Env.KEY_ID_CHECK);
    if ( isChecked == null && isChecked == "false") {
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

}
