import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/states/settingalarm_state.dart';
import 'package:teragate_test/states/settingbeacon_state.dart';
import 'package:teragate_test/states/settingwork_state.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/utils/debug_util.dart';
import 'dart:io' show Platform;

class Setting extends StatefulWidget {
  const Setting(Key? key) : super(key: key);

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  late SecureStorage secureStorage;
  //스위치 true/false
  bool switchGetIn = false;
  bool switchGetOut = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String beaconuuid = "";

  bool switchval = true;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();
    _initValue();
  }

  @override
  Widget build(BuildContext context) {
    return _createWillPopScope(_initScaffold());
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          _saveValue();
          Navigator.pop(context);
          return Future(() => false);
        },
        child: widget);
  }

  Container _createContainer(Widget widget) {
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
        ),
        child: widget);
  }

  GestureDetector _createGestureDetector(Function callback, Widget widget) {
    return GestureDetector(
        onTap: () {
          callback();
        },
        child: widget);
  }

  Visibility _createVisibility(Widget widget) {
    return Visibility(visible: Platform.isIOS, child: widget);
  }

  Scaffold _initScaffold() {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await _saveValue();
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0x0fff5f5f),
        automaticallyImplyLeading: true,
        title: const Text('환경 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _createGestureDetector(onTapuuid, _initContainerByUuid()),
            _createGestureDetector(onTapWorkIn, _initContainerByGetIn()),
            _createGestureDetector(onTapWorkOut, _initContainerByGetOut()),

            _createGestureDetector(onTapAlarm, _initSetupSwitch()),
            // _createGestureDetector(onTapAlarm, _initContainerByAlarm()),

            _createVisibility(_createGestureDetector(onTapInit, _initContainerByInitIos()))
          ],
        ),
      ),
    );
  }

  Container _initContainerByUuid() {
    return _createContainer(Stack(
      children: [
        Align(
            alignment: const AlignmentDirectional(0.07, 0.21),
            child: RichText(
              text: TextSpan(children: [
                const TextSpan(text: 'UUID:   ', style: TextStyle(color: Colors.black)),
                TextSpan(text: beaconuuid, style: const TextStyle(color: Colors.red)),
              ]),
            ))
      ],
    ));
  }

  Container _initContainerByGetIn() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '출근 일정',
                //텍스트를 클릭시 이벤트를 발생시키기 위함
                recognizer: TapGestureRecognizer()
                  //클래스 생성과 동시에 '선언부..함수명'을 입력하면 클래스 변수 없이 함수를 바로 호출 가능함
                  ..onTapDown = (details) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingWorkTime(Env.WORK_GET_IN, null)));
                  },
                style:
                    const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
          ]),
        ),
        Switch(
            value: switchGetIn,
            onChanged: (newValue) {
              setState(() => switchGetIn = newValue);
            }),
      ],
    ));
  }

  Container _initContainerByGetOut() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '퇴근 일정',
                //텍스트를 클릭시 이벤트를 발생시키기 위함
                recognizer: TapGestureRecognizer()
                  //클래스 생성과 동시에 '선언부..함수명'을 입력하면 클래스 변수 없이 함수를 바로 호출 가능함
                  ..onTapDown = (details) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingWorkTime(Env.WORK_GET_OUT, null)));
                  },
                style:
                    const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
          ]),
        ),
        Switch(
            value: switchGetOut,
            onChanged: (newValue) {
              setState(() => switchGetOut = newValue);
              secureStorage.write(Env.KEY_SETTING_GO_ON_OFF, newValue.toString());
            }),
      ],
    ));
  }

  Container _initContainerByAlarm() {
    return _createContainer(Row(
      children: [
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: '알람 설정',
                style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
          ]),
        ),
      ],
    ));
  }

  Container _initContainerByInitIos() {
    return _createContainer(Row(
      children: [
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: '초기화',
                style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
          ]),
        ),
      ],
    ));
  }

  Container _initSetupSwitch() {
    return _createContainer(Row(
      children: [
        RichText(
          text: const TextSpan(children: [
            TextSpan(
              text: '알람설정',
              style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ]),
        ),
        Switch(
          value: switchval,
          onChanged: (newValue) {
            setState(() => switchval = newValue);
            secureStorage.write(Env.KEY_SETTING_VIBRATE, switchval.toString());
            secureStorage.write(Env.KEY_SETTING_ALARM, switchval.toString());
          },
        ),
      ],
    ));
  }

  void onTapuuid() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingBeacon("", null)));
  }

  void onTapWorkIn() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingWorkTime(Env.WORK_GET_IN, null)));
  }

  void onTapWorkOut() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingWorkTime(Env.WORK_GET_OUT, null)));
  }

  void onTapAlarm() {
    //iOS일 경우, 넘기지 말고 안드일때만 넘겨야한다.

    if (Platform.isAndroid) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingAlarm(null)));
    }
  }

  void onTapInit() {
    //얼럿다이얼로그로 창을 띄워준 후, 그 창에서 확인버튼까지 클릭해야지 시큐어데이터를 삭제하고 그 뒤에 메인(로그인)페이지로 이동시켜준다.
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text("데이터 초기화"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "데이터를 초기화하시겠습니까? \n초기화 후에는 로그인 페이지로 자동 이동합니다.",
                ),
              ],
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                  //데이터 초기화 실행.
                  initSecureData();
                },
              ),
              new TextButton(
                child: new Text("취소"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> initSecureData() async {
    //1. SecureStorage의 데이터를 전부 삭제한다
    //2. 해당 삭제작업이 완료된 후, 메인페이지(로그인창)으로 이동
    //3. 백버튼 사용은 막혀있으므로 처리할 필요가 없음

    secureStorage.deleteAll();

    await Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<String> _initValue() async {
    String? uuid = await secureStorage.read(Env.KEY_SETTING_UUID);
    String? getin = await secureStorage.read(Env.KEY_SETTING_GI_ON_OFF);
    String? getout = await secureStorage.read(Env.KEY_SETTING_GO_ON_OFF);

    //------------------------------------------------------------------------//

    //알람세팅용... 수정예정.
    String? vibrate = await secureStorage.read(Env.KEY_SETTING_VIBRATE);
    String? alarm = await secureStorage.read(Env.KEY_SETTING_ALARM);

    //널값일떄 자동으로 값 넣어주는거 처리 해야할듯.. 이렇게 수동으로하면 꼬일가능성 매우높음.
    // String? alarmState = await secureStorage.read(Env.KEY_SETTING_ALARM);

    if (vibrate == null) {
      setState(() {
        switchval = false;
        secureStorage.write(Env.KEY_SETTING_ALARM, switchval.toString());
      });
    }
    if (alarm == null) {
      setState(() {
        switchval = false;
        secureStorage.write(Env.KEY_SETTING_ALARM, switchval.toString());
      });
    }
    if (vibrate == "true") {
      switchval = true;
    } else if (vibrate == "false") {
      switchval = false;
    }
    if (alarm == "true") {
      switchval = true;
    } else if (alarm == "false") {
      switchval = false;
    }

    setState(() {
      // ignore: prefer_if_null_operators
      beaconuuid = (uuid == null ? Env.UUID_DEFAULT : uuid);
    });
    switchGetIn = (getin == "true" ? true : false);
    switchGetOut = (getout == "true" ? true : false);

    return "";
  }

  Future<void> _saveValue() async {
    secureStorage.write(Env.KEY_SETTING_UUID, beaconuuid);
    secureStorage.write(Env.KEY_SETTING_GI_ON_OFF, switchGetIn.toString());
    secureStorage.write(Env.KEY_SETTING_GO_ON_OFF, switchGetOut.toString());
  }
}
