import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:teragate_test/models/beacon_model.dart';
import 'package:teragate_test/services/network_service.dart';
import 'package:teragate_test/services/work_service.dart';

//현재시간
import 'package:date_format/date_format.dart';
import 'package:timer_builder/timer_builder.dart';

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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int _nrMessagesReceived = 0;
  final _results = [];

  final String _tag = "Beacons Plugin";
  var isRunning = false;
  bool _isInForeground = true;
  String? deviceip = "00";
  String? userId = "1";
  String? name = "test";
  var flutterSecureStorage = const FlutterSecureStorage();
  String? id = "test1"; //id
  String? pw = "test2"; //pw
  var workSucces = false;

  late DateTime alert;
  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();

  @override
  void initState() {
    init();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    
    const duration = Duration(seconds: 10);
    alert = DateTime.now().add(duration);

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = const AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = const IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings( android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
  }

  Future init() async {
    //사용하는 기기의 IP 가져오기
    final Map<String, dynamic> wifiInfo = await WifiInfo.getIPAddress();
    if (!mounted) return;
    deviceip = wifiInfo["ip"];
    if(Env.isDebug) debugPrint(deviceip);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    beaconEventsController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      //Prominent disclosure
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Background Locations",
          message:
              "[This app] collects location data to enable [feature], [feature], & [feature] even when the app is closed or not in use");

      //Only in case, you want the dialog to be shown again. By Default, dialog will never be shown if permissions are granted.
      //await BeaconsPlugin.clearDisclosureDialogShowFlag(false);
    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if(Env.isDebug) debugPrint("Method: ${call.method}");
        if (call.method == 'scannerReady') {
          _showNotification("Beacons monitoring started..");
          await BeaconsPlugin.startMonitoring();
          setState(() {
            isRunning = true;
          });
        } else if (call.method == 'isPermissionDialogShown') {
          _showNotification(
              "Prominent disclosure message is shown to the user!");
        }
      });
    } else if (Platform.isIOS) {
      _showNotification("Beacons monitoring started..");
      await BeaconsPlugin.startMonitoring();
      setState(() {
        isRunning = true;
      });
    }

    /* BeaconsPlugin.addRegion("myBeacon", "01022022-f88f-0000-00ae-9605fd9bb620");
    BeaconsPlugin.addRegion("iBeacon", "12345678-1234-5678-8f0c-720eaf059935");
 */

    await BeaconsPlugin.addRegion(
        "Teraenergy", "12345678-1234-5678-8f0c-720eaf059935");

     BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
      BeaconsPlugin.addBeaconLayoutForAndroid(
          "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
     

    BeaconsPlugin.setForegroundScanPeriodForAndroid(foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

    beaconEventsController.stream.listen(
        (data) async {
          if (data.isNotEmpty && isRunning) {
            //if (_nrMessagesReceived <= 2) {
              setState(() {
                _results.add("출근 처리 중입니다");
                _showNotification("출근 처리 중입니다.");
                _nrMessagesReceived++;
              });

              if (!_isInForeground) {
                _showNotification("Beacons DataReceived: " + data);
              }

              if(Env.isDebug) debugPrint("Beacons DataReceived: " + data);
            //}
            if (!workSucces) {
              _nrMessagesReceived = 0;
              BeaconsPlugin.stopMonitoring(); //모니터링 종료
              setState(() {
                //스캔 종료
                isRunning = !isRunning;
              });

              Map<String, dynamic> userMap = jsonDecode(data);
              if(Env.isDebug) debugPrint(userMap.toString());
              var iBeacon = BeaconData.fromJson(userMap);
              
              if(Env.isDebug) debugPrint('안녕하세요, ${iBeacon.name} 회사!');
              if(Env.isDebug) debugPrint('${iBeacon.minor} 오늘의 인증 key 입니다(비콘)');

              String beaconKey = iBeacon.minor; // 비콘의 key 값
              bool keySucces = false; // key 일치여부 확인

              //DB에서 key 가져오기
/*               var url = Uri.parse("${Env.SERVER_URL}/keyCheck");
              var response = await http.get(url);
              var result = utf8.decode(response.bodyBytes);
              Map<String, dynamic> keyMap = jsonDecode(result);
              var cheak_key = keyinfo.fromJson(keyMap);
              if(Env.isDebug) debugPrint('DB key :' + '${cheak_key.commute_key}');
              String dbKey = '${cheak_key.commute_key}'; 임시제거 */

              String dbKey = '50000'; //임시로 고정

              userId = await flutterSecureStorage.read(key: 'user_id');
              name = await flutterSecureStorage.read(key: 'kr_name');
              id = await flutterSecureStorage.read(key: 'LOGIN_ID');
              pw = await flutterSecureStorage.read(key: 'LOGIN_PW');

              if (beaconKey == dbKey) {
                keySucces = true;
              } else {
                keySucces = false;
              }

              if (keySucces) {
                checkOverlapForGetIn(userId);
                //DB:출근 기록 확인

                if (true) {
                  //출근
                  if(Env.isDebug) debugPrint("#############출근진입############");
                  getIn(userId, deviceip).then((data) {
                    //출근에 대한 정보 db저장
                    debugPrint(data);
                    flutterDialog(context, "출근하셨습니다 $name님!"); //다이얼로그창
                    setState(() {
                      _results.add("msg: $name님 출근");
                      alert = DateTime.now().add(const Duration(seconds: 10));
                      _showNotification("출근하셨습니다");
                      workSucces = true;
                    });
                  });
                }
/*                      else {
                      if(Env.isDebug) debugPrint(data.success);
                      flutterDialog(context, " ${name}님 이미 출근하셨습니다."); //다이얼로그창
                      setState(() {
                        _results.add("msg: ${name}님 이미 출근 하셨습니다");
                      });
                    } */

              } else {
                flutterDialog(context, "Key값이 다릅니다. 재시도 해주세요!"); //다이얼로그창
              }
              _nrMessagesReceived = 0;
              keySucces = false;
            }
          }
        },
        onDone: () {},
        onError: (error) {
          if(Env.isDebug) debugPrint("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (!mounted) return;
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
                logoutBtn();

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
                      fontWeight: FontWeight.w200,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (isRunning) {
                      await BeaconsPlugin.stopMonitoring(); //비콘 스캔 시작
                    } else {
                      initPlatformState();
                      await BeaconsPlugin.startMonitoring(); //비콘 스캔 종료
                    }
                    setState(() {
                      isRunning = !isRunning;
                    });
                  },
                  child: Text(isRunning ? '출근 처리중' : '출 근',
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              Visibility(
                visible: _results.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      leaveWork();
                    },
                    child: const Text("퇴 근", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebView(id!, pw!, null)));
                  },
                  child: const Text('그룹웨어 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    logoutBtn();
                  },
                  child: const Text('로그아웃 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebView(id!, pw!, null)));
                  },
                  child: const Text('시작 ', style: TextStyle(fontSize: 20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WebView(id!, pw!, null)));
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

  Future logoutBtn() {
    return showDialog(
        context: context,
        barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('로그아웃'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('로그인 페이지로 이동하시겠습니까?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ok'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Login()));
                },
              ),
              TextButton(
                child: const Text('cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  //퇴근 기능
  void leaveWork() {
    getOut(userId, deviceip).then((data) {
      if (data.success) {
        if(Env.isDebug) debugPrint("#############퇴근진입############");
        flutterDialog(context, "퇴근하셨습니다 $name님!"); //다이얼로그창
      } else {
        flutterDialog(context, "퇴근처리가 안됩니다"); //다이얼로그창
      }
      setState(() {
        _results.add("msg: $name님 퇴근");
      });
    });
  }

  void _showNotification(String subtitle) {
    var rng = Random();
    Future.delayed(const Duration(seconds: 5)).then((result) async {
      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'your channel id', 'your channel name',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          rng.nextInt(100000), _tag, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }

  // void flutterDialog(context, String text) {
  //   showDialog(
  //       context: context,
  //       //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10.0)),
  //           //Dialog Main Title
  //           title: Column(
  //             children: const <Widget>[
  //               Text("Dialog Title"),
  //             ],
  //           ),
  //           //
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               Text(
  //                 text,
  //               ),
  //             ],
  //           ),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: const Text("확인"),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

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
            child: Text("접속시간 : $alert", style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.blue,) ,),
            margin: const EdgeInsets.all(8.0),
          )
      ]),

    );
  }


}

