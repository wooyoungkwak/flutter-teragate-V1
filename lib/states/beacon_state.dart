import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

//현재시간
import 'package:date_format/date_format.dart';
import 'package:timer_builder/timer_builder.dart';

import 'package:teragate_test/services/network_service.dart';
import 'package:teragate_test/services/work_service.dart';
import 'package:teragate_test/services/beacon_service.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/states/webview_state.dart';
import 'package:teragate_test/utils/alarm_util.dart';


class Beacon extends StatefulWidget {
  const Beacon({Key? key}) : super(key: key);

  @override
  BeaconState createState() => BeaconState();
}

class BeaconState extends State<Beacon> with WidgetsBindingObserver {
  // DateTime now = DateTime.now();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  int nrMessagesReceived = 0;
  final results = [];

  String? userId = "1";
  String? name = "test";
  String? id = "test1"; //id
  String? pw = "test2"; //pw
  String? deviceip = "00";

  var isRunning = false;
  bool isInForeground = true;
  // var flutterSecureStorage = const FlutterSecureStorage();
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
                    if (isRunning) {
                      await stopBeacon();
                    } else {
                      await restartBeacon();
                    }
                    setRunning(!isRunning);
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
                      setForGetOut();
                    },
                    child: const Text("퇴 근", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    moveWebview(context, id!, pw!);
                  },
                  child: const Text('그룹웨어 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    showOkCancelDialog(context, "로그아웃", '로그인 페이지로 이동하시겠습니까?', moveLogin);
                  },
                  child: const Text('로그아웃 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    moveWebview(context, id!, pw!);
                  },
                  child: const Text('시작 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    moveWebview(context, id!, pw!);
                  },
                  child: const Text('중지 ', style: TextStyle(fontSize: 20)),
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
            child: Text("유저아이디 : $userId", style: const TextStyle(
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

  // Future<void> initBeacon() async {

  //   if (Platform.isAndroid) {
  //     await BeaconsPlugin.setDisclosureDialogMessage(
  //         title: "Need Location Permission",
  //         message: "This app collects location data to work with beacons."
  //     );

  //     BeaconsPlugin.channel.setMethodCallHandler((call) async {
  //       if(Env.isDebug) debugPrint(" ********* Call Method: ${call.method}");

  //       if (call.method == 'scannerReady') {
  //         await BeaconsPlugin.startMonitoring();
  //         setRunning(true);
  //       } else if (call.method == 'isPermissionDialogShown') {
  //         showNotification(flutterLocalNotificationsPlugin, Env.BEACON_NOTIFICATION_TITLE, "Beacon 을 스켄할 수 없습니다. ??? ");
  //       }

  //     });

  //   } else if (Platform.isIOS) {
  //     // showNotification(Env.BEACON_NOTIFICATION_TITLE, "Beacons monitoring started..");
  //     await BeaconsPlugin.startMonitoring();
  //     setRunning(true);
  //   }

  //   //Send 'true' to run in background
  //   await BeaconsPlugin.runInBackground(true);

  //   BeaconsPlugin.listenToBeacons(beaconStreamController);

  //   beaconStreamController.stream.listen(
  //       (data) async {
  //         if (data.isNotEmpty && isRunning) {

  //           setResult("출근 처리 중입니다", false);

  //           if (!workSucces) {
  //             BeaconsPlugin.stopMonitoring(); //모니터링 종료
  //             setRunning(!isRunning);
  //             Map<String, dynamic> userMap = jsonDecode(data);
  //             var iBeacon = BeaconData.fromJson(userMap);
  //             String beaconKey = iBeacon.minor; // 비콘의 key 값
  //             bool keySucces = false; // key 일치여부 확인

  //             //DB에서 key 가져오기
  //             /*               
  //             var url = Uri.parse("${Env.SERVER_URL}/keyCheck");
  //             var response = await http.get(url);
  //             var result = utf8.decode(response.bodyBytes);
  //             Map<String, dynamic> keyMap = jsonDecode(result);
  //             var cheak_key = keyinfo.fromJson(keyMap);
  //             if(Env.isDebug) debugPrint('DB key :' + '${cheak_key.commute_key}');
  //             String dbKey = '${cheak_key.commute_key}'; 임시제거 
  //             */

  //             String dbKey = '50000'; //임시로 고정

  //             userId = await flutterSecureStorage.read(key: 'user_id');
  //             name = await flutterSecureStorage.read(key: 'kr_name');
  //             id = await flutterSecureStorage.read(key: 'LOGIN_ID');
  //             pw = await flutterSecureStorage.read(key: 'LOGIN_PW');

  //             if (beaconKey == dbKey) {
  //               keySucces = true;
  //             } else {
  //               keySucces = false;
  //             }

  //             if (keySucces) {
  //               checkOverlapForGetIn(userId);
  //               //DB:출근 기록 확인

  //               if (true) {
  //                 //출근
  //                 if(Env.isDebug) debugPrint(" 출근진입 ( device ip $deviceip )");
  //                 getIn(userId, deviceip).then((data) {
  //                   //출근에 대한 정보 db저장
  //                   debugPrint(data);
  //                   showConfirmDialog(context, Env.DIALOG_TITLE, "출근하셨습니다 $name님!");
  //                   setResult("msg: $name님 출근", true);
  //                 });
  //               }
  //               /*
  //               else {
  //                 if(Env.isDebug) debugPrint(data.success);
  //                 showConfirmDialog(context, " ${name}님 이미 출근하셨습니다."); //다이얼로그창
  //                 setState(() {
  //                   results.add("msg: ${name}님 이미 출근 하셨습니다");
  //                 });
  //               } 
  //               */

  //             } else {
  //               showConfirmDialog(context, Env.DIALOG_TITLE, "Key값이 다릅니다. 재시도 해주세요!"); //다이얼로그창
  //             }
  //             nrMessagesReceived = 0;
  //             keySucces = false;
  //           }
  //         }
  //       },
  //       onDone: () {},
  //       onError: (error) {
  //         if(Env.isDebug) debugPrint("Error: $error");
  //       }
  //   );
  
  // }

  // 비콘 초기화
  // Future<void> setBeacon() async {
    
  //   /* 
  //   BeaconsPlugin.addRegion("myBeacon", "01022022-f88f-0000-00ae-9605fd9bb620");
  //   BeaconsPlugin.addRegion("iBeacon", "12345678-1234-5678-8f0c-720eaf059935");
  //   */

  //   await BeaconsPlugin.addRegion("Teraenergy", "12345678-1234-5678-8f0c-720eaf059935");

  //   BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
  //   BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
  //   BeaconsPlugin.setForegroundScanPeriodForAndroid(foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
  //   BeaconsPlugin.setBackgroundScanPeriodForAndroid(backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);
  // }

  void setNotification(String message) {
    showNotification(flutterLocalNotificationsPlugin, Env.BEACON_NOTIFICATION_TITLE, message);
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

  void setGlovalVariable(String _userId, String _name, String _id, String _pw){
    userId = _userId;
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

  // 출근 등록
  void setForGetIn() {
    getIn(userId, deviceip).then((data) {
      showConfirmDialog(context, Env.DIALOG_TITLE, "출근하셨습니다 $name님!");
      setResult("msg: $name님 출근", true);
    });
  }
  
  // 퇴근 등록
  void setForGetOut() {
    getOut(userId, deviceip).then((data) {
      if (data.success) {
        showConfirmDialog(context, Env.DIALOG_TITLE, "퇴근하셨습니다 $name님!");
        setResult("msg: $name님 퇴근", false);
      } else {
        showConfirmDialog(context, Env.DIALOG_TITLE, "퇴근처리가 되지 않았습니다. ");
      }
    });
  }

}

