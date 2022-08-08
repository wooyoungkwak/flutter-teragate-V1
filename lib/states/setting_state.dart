import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/states/settingbeacon_state.dart';
import 'package:teragate_test/states/settingwork_state.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/utils/Log_util.dart';
import 'dart:io' show Platform;

class Setting extends StatefulWidget {
  final String uuid;
  final bool? switchGetIn;
  final bool? switchGetOut;
  final bool? switchAlarm;

  const Setting(this.uuid, this.switchGetIn, this.switchGetOut, this.switchAlarm, Key? key) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  late SecureStorage secureStorage;
  //스위치 true/false
  bool switchGetIn = false;
  bool switchGetOut = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late TextEditingController uuidContoroller;
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  bool switchAlarm = false;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();
    uuidContoroller = TextEditingController(text: widget.uuid);
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
        child: widget
      );
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

  FutureBuilder _createFutureBuilder(Future callback, Widget widget) {
    return FutureBuilder(
        future: callback,
        builder: (context, snapshot) {
          return widget;
        });
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
            _initContainerByUuid(),
            _createGestureDetector(onTapWorkIn, _initContainerByGetIn()),
            _createGestureDetector(onTapWorkOut, _initContainerByGetOut()),
            _createGestureDetector(onTapAlarm, _initContainerByAlarm()),
            _createVisibility(_createGestureDetector(onTapInit, _initContainerByInitIos()))
          ],
        ),
      ),
    );
  }

  // UUID text 작성
  Padding _initPaddingBytextUUID() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(controller: uuidContoroller, validator: (value) => (value!.isEmpty) ? " UUID를 입력해주세요" : null, style: style, decoration: const InputDecoration(prefixIcon: Icon(Icons.bluetooth), labelText: "UUID", border: OutlineInputBorder())),
    );
  }

  // 초기값 세팅
  Padding _initPaddingBySetUUID() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.red,
            child: MaterialButton(
                onPressed: () {
                  setState(() {
                    uuidContoroller = TextEditingController(text: Env.INITIAL_UUID);
                  });
                },
                child: Text("초기값 세팅", style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)))));
  }

  // UUID 가져오기
  Padding _initPaddingByGetUUID() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.red,
            child: MaterialButton(
                onPressed: () {
                  setState(() {
                    uuidContoroller = TextEditingController(text: "123123123123123123123");
                  });
                },
                child: Text(
                  "UUID 가져오기",
                  style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ))));
  }

  Container _initContainerByUuid() {
    return _createContainer(Column(
      children: [_initPaddingBytextUUID(), _initPaddingBySetUUID(), Visibility(visible: false, child: _initPaddingByGetUUID())],
    ));
  }

  Container _initContainerByGetIn() {
    return _createContainer(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      RichText(
        text: TextSpan(children: [
          TextSpan(text: '출근 일정', recognizer: TapGestureRecognizer()..onTapDown = (details) async {}, style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
        ]),
      ),
      Switch(
          value: switchGetIn,
          onChanged: (newValue) {
            setState(() => switchGetIn = newValue);
          })
    ]));
  }

  Container _initContainerByGetOut() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(text: '퇴근 일정', recognizer: TapGestureRecognizer()..onTapDown = (details) async {}, style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
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

  Container _initContainerByInitIos() {
    return _createContainer(Row(
      children: [
        RichText(
          text: const TextSpan(children: [
            TextSpan(text: '초기화', style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
          ]),
        ),
      ],
    ));
  }

  Container _initContainerByAlarm() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: const TextSpan(children: [
            TextSpan(
              text: '알람 설정',
              style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ]),
        ),
        Switch(
          value: switchAlarm,
          onChanged: (newValue) {
            setState(() => switchAlarm = newValue);
            secureStorage.write(Env.KEY_SETTING_VIBRATE, switchAlarm.toString());
            secureStorage.write(Env.KEY_SETTING_ALARM, switchAlarm.toString());
          },
        ),
      ],
    ));
  }

  void onTapWorkIn() async {
    String? timeMon = await secureStorage.read(Env.KEY_SETTING_MON_GI_TIME);
    String? timeTue = await secureStorage.read(Env.KEY_SETTING_TUE_GI_TIME);
    String? timeWed = await secureStorage.read(Env.KEY_SETTING_WED_GI_TIME);
    String? timeThu = await secureStorage.read(Env.KEY_SETTING_THU_GI_TIME);
    String? timeFri = await secureStorage.read(Env.KEY_SETTING_FRI_GI_TIME);
    String? timeSat = await secureStorage.read(Env.KEY_SETTING_SAT_GI_TIME);
    String? timeSun = await secureStorage.read(Env.KEY_SETTING_SUN_GI_TIME);

    String? switchMon = await secureStorage.read(Env.KEY_SETTING_MON_GI_SWITCH);
    String? switchTue = await secureStorage.read(Env.KEY_SETTING_TUE_GI_SWITCH);
    String? switchWed = await secureStorage.read(Env.KEY_SETTING_WED_GI_SWITCH);
    String? switchThu = await secureStorage.read(Env.KEY_SETTING_THU_GI_SWITCH);
    String? switchFri = await secureStorage.read(Env.KEY_SETTING_FRI_GI_SWITCH);
    String? switchSat = await secureStorage.read(Env.KEY_SETTING_SAT_GI_SWITCH);
    String? switchSun = await secureStorage.read(Env.KEY_SETTING_SUN_GI_SWITCH);

    List<String?> initTimeList = [timeMon, timeTue, timeWed, timeThu, timeFri, timeSat, timeSun];
    List<String?> initSwitchList = [switchMon, switchTue, switchWed, switchThu, switchFri, switchSat, switchSun];

    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingWorkTime(Env.WORK_GET_IN, initSwitchList, initTimeList, null)));
  }

  void onTapWorkOut() async {
    String? timeMon = await secureStorage.read(Env.KEY_SETTING_MON_GO_TIME);
    String? timeTue = await secureStorage.read(Env.KEY_SETTING_TUE_GO_TIME);
    String? timeWed = await secureStorage.read(Env.KEY_SETTING_WED_GO_TIME);
    String? timeThu = await secureStorage.read(Env.KEY_SETTING_THU_GO_TIME);
    String? timeFri = await secureStorage.read(Env.KEY_SETTING_FRI_GO_TIME);
    String? timeSat = await secureStorage.read(Env.KEY_SETTING_SAT_GO_TIME);
    String? timeSun = await secureStorage.read(Env.KEY_SETTING_SUN_GO_TIME);

    String? switchMon = await secureStorage.read(Env.KEY_SETTING_MON_GO_SWITCH);
    String? switchTue = await secureStorage.read(Env.KEY_SETTING_TUE_GO_SWITCH);
    String? switchWed = await secureStorage.read(Env.KEY_SETTING_WED_GO_SWITCH);
    String? switchThu = await secureStorage.read(Env.KEY_SETTING_THU_GO_SWITCH);
    String? switchFri = await secureStorage.read(Env.KEY_SETTING_FRI_GO_SWITCH);
    String? switchSat = await secureStorage.read(Env.KEY_SETTING_SAT_GO_SWITCH);
    String? switchSun = await secureStorage.read(Env.KEY_SETTING_SUN_GO_SWITCH);

    List<String?> initTimeList = [timeMon, timeTue, timeWed, timeThu, timeFri, timeSat, timeSun];
    List<String?> initSwitchList = [switchMon, switchTue, switchWed, switchThu, switchFri, switchSat, switchSun];

    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingWorkTime(Env.WORK_GET_OUT, initSwitchList, initTimeList, null)));
  }

  void onTapAlarm() {
    //iOS일 경우, 넘기지 말고 안드일때만 넘겨야한다.
    // if (Platform.isAndroid) {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingAlarm(null)));
    // }
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
              children: const <Widget>[
                Text("데이터 초기화"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "데이터를 초기화하시겠습니까? \n초기화 후에는 로그인 페이지로 자동 이동합니다.",
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                  //데이터 초기화 실행.
                  initSecureData();
                },
              ),
              TextButton(
                child: const Text("취소"),
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

  Future<void> _saveValue() async {
    secureStorage.write(Env.KEY_SETTING_UUID, uuidContoroller.text);
    secureStorage.write(Env.KEY_SETTING_GI_ON_OFF, switchGetIn.toString());
    secureStorage.write(Env.KEY_SETTING_GO_ON_OFF, switchGetOut.toString());
    secureStorage.write(Env.KEY_SETTING_ALARM, switchAlarm.toString());
    secureStorage.write(Env.KEY_SETTING_VIBRATE, switchAlarm.toString());
    secureStorage.write(Env.KEY_SETTING_VIBRATE, switchAlarm.toString());

  }

  void _initValue() {
    switchGetIn = widget.switchGetIn!;
    switchGetOut = widget.switchGetOut!;
    switchAlarm = widget.switchAlarm!;
  }
}
