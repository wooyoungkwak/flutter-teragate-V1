import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

//현재시간
import 'package:date_format/date_format.dart';
import 'package:teragate_test/states/setting_state.dart';
import 'package:timer_builder/timer_builder.dart';

import 'package:teragate_test/services/network_service.dart';
import 'package:teragate_test/services/server_service.dart';
import 'package:teragate_test/services/beacon_service.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/states/webview_state.dart';
import 'package:teragate_test/utils/alarm_util.dart';

import 'package:teragate_test/models/storage_model.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with WidgetsBindingObserver {

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late SecureStorage secureStorage;

  int nrMessagesReceived = 0;
  final results = [];

  String? name = "test";
  String? id = "test1"; //id
  String? pw = "test2"; //pw
  String? deviceip = "00";

  var isRunning = false;
  bool isInForeground = true;
  var workSucces = false;

  late DateTime alertTime;
  final StreamController<String> beaconStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    
    initBeacon(setNotification, setRunning, setResult, setGlovalVariable, setForGetIn, getIsRunning, getWorkSucces, beaconStreamController);
    setBeacon();

    WidgetsBinding.instance.addObserver(this);
    
    getIPAddress().then((map) => deviceip = map["ip"]);
    const duration = Duration(seconds: 10);
    alertTime = DateTime.now().add(duration);
    
    initNotification();
    secureStorage = SecureStorage();
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
    return MaterialApp(
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
            child: const Text("근태 확인", style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.blue,) ,),
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
                    formatDate(DateTime.now(), [hh, ':', nn, ':', ss, ' ', am]),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w200
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // if (isRunning) {
                    //   await stopBeacon();
                    // } else {
                    //   await restartBeacon();
                    // }
                    // setRunning(!isRunning);
                    String? accessToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
                    getIn(deviceip!, accessToken!).then((loginInfo) {
                      debugPrint("출근 .... ");
                      debugPrint(loginInfo.success.toString());
                    });
                  },
                  child: Text(isRunning ? '출근 처리중' : '출 근', style: const TextStyle(fontSize: 20)),
                ),
              ),
              Visibility(
                visible: results.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // setForGetOut();

                      String? accssToken = await secureStorage.read(Env.KEY_ACCESS_TOKEN);
                      getOut(deviceip!, accssToken!).then((loginInfo) {
                         debugPrint("퇴근 .... ");
                         debugPrint(loginInfo.success.toString());
                      });
                    },
                    child: const Text("퇴 근", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // moveWebview(context, id!, pw!);

                    debugPrint("login =======================");
                    login(id!, pw!).then((loginInfo) { 
                      debugPrint(loginInfo.tokenInfo?.getAccessToken());
                      secureStorage.write(Env.KEY_ACCESS_TOKEN, '${loginInfo.tokenInfo?.getAccessToken()}');
                      secureStorage.write(Env.KEY_REFRESH_TOKEN, '${loginInfo.tokenInfo?.getRefreshToken()}');
                    });
                    debugPrint("login =======================");
                  },
                  child: const Text('그룹웨어 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // showOkCancelDialog(context, "로그아웃", '로그인 페이지로 이동하시겠습니까?', moveLogin);

                    String? refreshToken = await secureStorage.read(Env.KEY_REFRESH_TOKEN);
                    getTokenByRefreshToken(refreshToken!).then((tokenInfo) {
                      secureStorage.write(Env.KEY_ACCESS_TOKEN, tokenInfo.getAccessToken());
                      secureStorage.write(Env.KEY_REFRESH_TOKEN, tokenInfo.getRefreshToken());
                      if( Env.isDebug ) (tokenInfo.getAccessToken());
                    });
                    
                  },
                  child: const Text('로그아웃 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    moveSetting(context);
                  },
                  child: const Text('환경 설정 ', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget comuteItem() {
    return Scaffold(
      body: Column(
      crossAxisAlignment:  CrossAxisAlignment.start,

        children: <Widget>[
                    Container(
            child: Text("이름 : $name", style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,) ,),
            margin: const EdgeInsets.all(8.0),
          ),
          Container(
            child: Text("디바이스 아이피 : $deviceip", style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,) ,),
            margin: const EdgeInsets.all(8.0),
          ),
          Container(
            child: Text("접속시간 : $alertTime", style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,) ,),
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
      var initializationSettings = InitializationSettings( 
      android: initializationSettingsAndroid, 
      iOS: initializationSettingsIOS
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
  }

  void setNotification(String message) {
    showNotification(flutterLocalNotificationsPlugin, Env.TITLE_BEACON_NOTIFICATION, message);
  }

  void setRunning(bool state){
    setState(() {
      isRunning = state;
    });
  }

  void setResult(String message, bool workSucces) {
    results.add(message);
    if ( workSucces ) {
      workSucces = true;
      alertTime = DateTime.now().add(const Duration(seconds: 10));
    }
  }

  void setGlovalVariable(String _name, String _id, String _pw){
    name = _name;
    id = _id;
    pw = _pw;
  }

  bool getIsRunning() {
    return isRunning;
  }

  bool getWorkSucces() {
    return workSucces;
  }

  // 로그인 화면으로 이동
  void moveLogin(){
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
  }

  // 웹 뷰 화면으로 이동
  void moveWebview(BuildContext context, String? id, String? pw) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViews(id!, pw!, null)
      )
    );
  }

  //환경 설정 화면으로 이동
  void moveSetting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Setting(null)
      )
    );
  }

  // 출근 등록
  void setForGetIn() {
    // getIn(deviceip).then((data) {
    //   showConfirmDialog(context, Env.TITLE_DIALOG, "출근하셨습니다 $name님!");
    //   setResult("msg: $name님 출근", true);
    // });
  }
  
  // 퇴근 등록
  void setForGetOut() {
    // getOut(deviceip).then((data) {
    //   if (data.success) {
    //     showConfirmDialog(context, Env.TITLE_DIALOG, "퇴근하셨습니다 $name님!");
    //     setResult("msg: $name님 퇴근", false);
    //   } else {
    //     showConfirmDialog(context, Env.TITLE_DIALOG, "퇴근처리가 되지 않았습니다. ");
    //   }
    // });
  }

}

