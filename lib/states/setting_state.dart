import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
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

  const Setting(this.uuid, this.switchGetIn, this.switchGetOut,
      this.switchAlarm, Key? key)
      : super(key: key);

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

  TextStyle textStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'suit',
      color: Colors.white,
      fontSize: 20);

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
    return _createContainerByBackground(_initScaffoldByAppbar(
        _createWillPopScope(_createListView(_initContainerByRadius()))));
  }

  ListView _createListView(Widget widget) {
    return ListView(
      children: [widget],
    );
  }

  Container _createContainerByBackground(Widget widget) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"), fit: BoxFit.fill)),
        child: widget);
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
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: const Color(0xff17171C),
            borderRadius: BorderRadius.circular(10)),
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
    //return Visibility(visible: Platform.isIOS, child: widget);
    return Visibility(visible: true, child: widget); // 테스트
  }

  SizedBox _initSizedBoxByicon_2Text(
      AssetImage image, String mainText, String subText) {
    return SizedBox(
        child: Row(children: [
      Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        color: const Color(0xff314CF8),
        child: ImageIcon(
          image,
          color: Colors.white,
        ),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Text(mainText,
                style: textStyle.copyWith(
                    fontSize: 18, fontWeight: FontWeight.w700))),
        Text(subText,
            style: textStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff7B7D8E))),
      ])
    ]));
  }

  SizedBox _initSizedBoxByicon_1Text(AssetImage image, String mainText) {
    return SizedBox(
        child: Row(children: [
      Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        color: const Color(0xff314CF8),
        child: ImageIcon(
          image,
          color: Colors.white,
        ),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Text(mainText,
                style: textStyle.copyWith(
                    fontSize: 18, fontWeight: FontWeight.w700))),
      ])
    ]));
  }

  Scaffold _initScaffoldByAppbar(Widget widget) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const ImageIcon(
            AssetImage("assets/arrow_back_white_24dp.png"),
            color: Colors.white,
          ),
          onPressed: () async {
            await _saveValue();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Text("Setting",
            style:
                textStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.transparent,
      body: widget,
    );
  }

  Container _initContainerByRadius() {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      decoration: const BoxDecoration(
          color: Color(0xff27282E),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
      child: Column(
        children: <Widget>[
          _initContainerByUuid(),
          _createGestureDetector(onTapWorkIn, _initContainerByGetIn()),
          _createGestureDetector(onTapWorkOut, _initContainerByGetOut()),
          _createGestureDetector(onTapAlarm, _initContainerByAlarm()),
          _createVisibility(
              _createGestureDetector(onTapInit, _initContainerByInitIos()))
        ],
      ),
    );
  }

  Row _initRowByTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        color: const Color(0xff314CF8),
        child: const ImageIcon(
          AssetImage("assets/bluetooth_white_24dp.png"),
          color: Colors.white,
        ),
      ),
      RichText(
        text: TextSpan(children: [
          TextSpan(
              text: Env.TITLE_SETTING_UUID,
              recognizer: TapGestureRecognizer()
                ..onTapDown = (details) async {},
              style: textStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
    ]);
  }

  TextFormField _initTextFormFieldBytextUUID() {
    return TextFormField(
        controller: uuidContoroller,
        validator: (value) =>
            (value!.isEmpty) ? Env.TITLE_SETTING_UUID_SUB : null,
        style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
        decoration: const InputDecoration(border: OutlineInputBorder()));
  }

  Padding _initPaddingByButton(String text) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(8.0),
            color: const Color(0xff444653),
            child: MaterialButton(
                onPressed: () {
                  setState(() {
                    uuidContoroller =
                        TextEditingController(text: Env.INITIAL_UUID);
                  });
                },
                child: Text(text,
                    style: textStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)))));
  }

  Container _initContainerByUuid() {
    return _createContainer(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // _initRowByTitle(),
        _initSizedBoxByicon_1Text(AssetImage("assets/bluetooth_white_24dp.png"),
            Env.TITLE_SETTING_UUID),
        Container(
          margin: const EdgeInsets.only(top: 18, bottom: 10),
          alignment: Alignment.centerLeft,
          child: Text(Env.TITLE_SETTING_UUID_SUB,
              style: textStyle.copyWith(
                  color: const Color(0xff9093A5),
                  fontWeight: FontWeight.w400,
                  fontSize: 14)),
        ),
        Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            color: const Color(0xff27282E),
            child: _initTextFormFieldBytextUUID()),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _initPaddingByButton(Env.TITLE_SETTING_UUID_DEFAULT_BUTTON),
          //Visibility(visible: false, child: _initPaddingByGetUUID())
          Visibility(
              visible: true,
              child: _initPaddingByButton(Env.TITLE_SETTING_UUID_GET_BUTTON))
        ])
        // 테스트
      ],
    ));
  }

  Container _initContainerByGetIn() {
    return _createContainer(
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _initSizedBoxByicon_2Text(const AssetImage("assets/getin_white_24dp.png"),
          Env.TITLE_SETTING_GET_IN, Env.TITLE_SETTING_GET_IN_SUB),
      FittedBox(
          fit: BoxFit.fill,
          child: Switch(
              value: switchGetIn,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xff26C145),
              inactiveTrackColor: const Color(0xff444653),
              onChanged: (newValue) {
                setState(() => switchGetIn = newValue);
              }))
    ]));
  }

  Container _initContainerByGetOut() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _initSizedBoxByicon_2Text(
            const AssetImage("assets/getout_white_24dp.png"),
            Env.TITLE_SETTING_GET_OFF,
            Env.TITLE_SETTING_GET_OFF_SUB),
        FittedBox(
            fit: BoxFit.fill,
            child: Switch(
                value: switchGetOut,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xff26C145),
                inactiveTrackColor: const Color(0xff444653),
                onChanged: (newValue) {
                  setState(() => switchGetOut = newValue);
                }))
      ],
    ));
  }

  Container _initContainerByAlarm() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _initSizedBoxByicon_1Text(
            const AssetImage("assets/volume_up_white_24dp.png"),
            Env.TITLE_SETTING_ALARM),
        FittedBox(
            fit: BoxFit.fill,
            child: Switch(
                value: switchAlarm,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xff26C145),
                inactiveTrackColor: const Color(0xff444653),
                onChanged: (newValue) {
                  setState(() => switchAlarm = newValue);
                }))
      ],
    ));
  }

  Container _initContainerByInitIos() {
    return _createContainer(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _initSizedBoxByicon_1Text(
            const AssetImage("assets/restart_alt_white_24dp.png"),
            Env.TITLE_SETTING_INITIALIZATION),
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

    List<String?> initTimeList = [
      timeMon,
      timeTue,
      timeWed,
      timeThu,
      timeFri,
      timeSat,
      timeSun
    ];
    List<String?> initSwitchList = [
      switchMon,
      switchTue,
      switchWed,
      switchThu,
      switchFri,
      switchSat,
      switchSun
    ];

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SettingWorkTime(
                Env.WORK_GET_IN, initSwitchList, initTimeList, null)));
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

    List<String?> initTimeList = [
      timeMon,
      timeTue,
      timeWed,
      timeThu,
      timeFri,
      timeSat,
      timeSun
    ];
    List<String?> initSwitchList = [
      switchMon,
      switchTue,
      switchWed,
      switchThu,
      switchFri,
      switchSat,
      switchSun
    ];

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SettingWorkTime(
                Env.WORK_GET_OUT, initSwitchList, initTimeList, null)));
  }

  void onTapAlarm() {
    //iOS일 경우, 넘기지 말고 안드일때만 넘겨야한다.
    // if (Platform.isAndroid) {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingAlarm(null)));
    // }

    setState(() => switchAlarm = !switchAlarm);
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
    await Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<void> _saveValue() async {
    secureStorage.write(Env.KEY_SETTING_UUID, uuidContoroller.text);
    secureStorage.write(Env.KEY_SETTING_GI_SWITCH, switchGetIn.toString());
    secureStorage.write(Env.KEY_SETTING_GO_SWITCH, switchGetOut.toString());
    secureStorage.write(Env.KEY_SETTING_ALARM, switchAlarm.toString());
    secureStorage.write(Env.KEY_SETTING_VIBRATE, switchAlarm.toString());
    secureStorage.write(Env.KEY_SETTING_SOUND, switchAlarm.toString());
  }

  void _initValue() {
    switchGetIn = widget.switchGetIn!;
    switchGetOut = widget.switchGetOut!;
    switchAlarm = widget.switchAlarm!;
  }
}
