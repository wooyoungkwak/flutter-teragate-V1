import 'package:flutter/material.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';

class SettingBeacon extends StatefulWidget {
  final String uuid;
  const SettingBeacon(this.uuid, Key? key) : super(key: key);

  @override
  SettingBeaconState createState() => SettingBeaconState();
}

class SettingBeaconState extends State<SettingBeacon> {
  late TextEditingController uuidContoroller;
  late SecureStorage secureStorage;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final _formKey = GlobalKey<FormState>();
  late bool initcheck;

  @override
  void initState() {
    super.initState();
    initcheck = true;
    secureStorage = SecureStorage();
  }

  @override
  Widget build(BuildContext context) {
    uuidContoroller = TextEditingController(text: widget.uuid);

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _saveValue();
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Beacon Scan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          actions: const [],
          centerTitle: true,
          elevation: 4,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: _createWillPopScope(Form(
            key: _formKey,
            child: Center(
                child: ListView(shrinkWrap: true, children: <Widget>[
              _initPaddingBytextUUID(),
              _initPaddingBySetUUID(),
              Visibility(visible: false, child: _initPaddingByGetUUID()),
            ])))));
  }

  // 하드웨어 적인 Back 버튼
  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          _saveValue();
          Navigator.of(context).pop();
          return Future(() => false);
        },
        child: widget);
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

  // 설정값 저장
  void _saveValue() {
    secureStorage.write(Env.KEY_SETTING_UUID, uuidContoroller.text);
  }
}
