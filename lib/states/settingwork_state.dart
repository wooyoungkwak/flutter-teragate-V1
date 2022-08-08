import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/config/env.dart';

import '../utils/time_util.dart';

class SettingWorkTime extends StatefulWidget {
  final String getstate;
  final List<String?> initSwitchList;
  final List<String?> initTimeList;

  const SettingWorkTime(this.getstate, this.initSwitchList, this.initTimeList, Key? key) : super(key: key);

  @override
  SettingWorkTimeState createState() => SettingWorkTimeState();
}

class SettingWorkTimeState extends State<SettingWorkTime> {
  late SecureStorage secureStorage;

  List<String> initTimeGetIn = ["08:30", "08:30", "08:30", "08:30", "08:30", "08:30", "08:30"];
  List<String> initTimeGetOut = ["18:00", "18:00", "18:00", "18:00", "18:00", "18:00", "18:00"];
  List<String> weekKR = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  List<String> weekAlarmGITime = [Env.KEY_SETTING_MON_GI_TIME, Env.KEY_SETTING_TUE_GI_TIME, Env.KEY_SETTING_WED_GI_TIME, Env.KEY_SETTING_THU_GI_TIME, Env.KEY_SETTING_FRI_GI_TIME, Env.KEY_SETTING_SAT_GI_TIME, Env.KEY_SETTING_SUN_GI_TIME];
  List<String> weekAlarmGOTime = [Env.KEY_SETTING_MON_GO_TIME, Env.KEY_SETTING_TUE_GO_TIME, Env.KEY_SETTING_WED_GO_TIME, Env.KEY_SETTING_THU_GO_TIME, Env.KEY_SETTING_FRI_GO_TIME, Env.KEY_SETTING_SAT_GO_TIME, Env.KEY_SETTING_SUN_GO_TIME];
  List<String> weekAlarmGI = [Env.KEY_SETTING_MON_GI_SWITCH, Env.KEY_SETTING_TUE_GI_SWITCH, Env.KEY_SETTING_WED_GI_SWITCH, Env.KEY_SETTING_THU_GI_SWITCH, Env.KEY_SETTING_FRI_GI_SWITCH, Env.KEY_SETTING_SAT_GI_SWITCH, Env.KEY_SETTING_SUN_GI_SWITCH];
  List<String> weekAlarmGO = [Env.KEY_SETTING_MON_GO_SWITCH, Env.KEY_SETTING_TUE_GO_SWITCH, Env.KEY_SETTING_WED_GO_SWITCH, Env.KEY_SETTING_THU_GO_SWITCH, Env.KEY_SETTING_FRI_GO_SWITCH, Env.KEY_SETTING_SAT_GO_SWITCH, Env.KEY_SETTING_SUN_GO_SWITCH];
  List<bool> switchDay = [true, true, true, true, true, false, false]; //스위치 true/false
  List<String> title = ["출근 알람", "퇴근 알람"];
  int colorvla = 0;
  List<String> colorChange = [" Colors.black", "Colors.white"];
  final scaffoldKey = GlobalKey<ScaffoldState>();

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

  IgnorePointer _createContainerByIgnore(Widget widget) {
    return IgnorePointer(ignoring: false, ignoringSemantics: false, child: widget);
  }

  Container _createContainer(Widget widget) {
    return Container(color: const Color(0xffF6F2F2), width: double.infinity, child: widget);
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

  Scaffold _initScaffold() {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              await _saveValue();
              Navigator.pop(context);
            },
          ),
          backgroundColor: const Color(0x0fff5f5f),
          automaticallyImplyLeading: true,
          title: Text(widget.getstate == Env.WORK_GET_IN ? "출근 설정" : "퇴근 설정", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          actions: const [],
          centerTitle: true,
          elevation: 4,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: ListView(children: <Widget>[_initListView()]));
  }

  ListView _initListView() {
    return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 30),
        itemCount: weekKR.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 3),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                _initBottomPicker(context, index);
              },
              child: _createContainer(_initRowByWeek(index)));
        });
  }

  Row _initRowByWeek(index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.getstate == Env.WORK_GET_IN) Text(initTimeGetIn[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)) 
        else if (widget.getstate == Env.WORK_GET_OUT) Text(initTimeGetOut[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
        Text(weekKR[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
        Align(
          child: Switch(
              value: switchDay[index],
              onChanged: (newValue) {
                if (widget.getstate == Env.WORK_GET_IN) {
                  setState(() => switchDay[index] = newValue);
                } else if (widget.getstate == Env.WORK_GET_OUT) {
                  setState(() => switchDay[index] = newValue);
                }
              }),
        ),
      ],
    );
  }

  void _initBottomPicker(BuildContext context, int index) async {
    BottomPicker.time(
            title: "Set your next meeting time",
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange),
            onSubmit: (dateTime) async {
              String formattedDate = getPickerTime(dateTime);
              setState(() {
                if (widget.getstate == Env.WORK_GET_IN) {
                  initTimeGetIn[index] = formattedDate;
                } else {
                  initTimeGetOut[index] = formattedDate;
                }
              });
            },
            onClose: () {},
            use24hFormat: true)
        .show(context);
  }

  void _initValue() {  
    if (widget.getstate == Env.WORK_GET_IN) {
      for (int i = 0; i < weekAlarmGI.length; i++) {
        _initTimeByGetIN(i);
        _initSwitch(i);
      }
    } else {
      for (int i = 0; i < weekAlarmGI.length; i++) {
        _initTimeByGetOut(i);
        _initSwitch(i);
      }
    }
  }

  Future<void> _initTimeByGetIN(int index) async {
    String? check = widget.initTimeList[index];
    // ignore: prefer_if_null_operators, unnecessary_null_comparison
    initTimeGetIn[index] = check == null ? initTimeGetIn[index] : check;
  }

  Future<void> _initTimeByGetOut(int index) async {
    String? check = widget.initTimeList[index];
    // ignore: prefer_if_null_operators, unnecessary_null_comparison
    initTimeGetOut[index] = check == null ? initTimeGetOut[index] : check;
  }

  Future<void> _initSwitch(int index) async {
    String? change = widget.initSwitchList[index];
    // ignore: prefer_if_null_operators, unnecessary_null_comparison
    switchDay[index] = (change == null ? switchDay[index] : (change == "true" ? true : false));
  }

  Future<void> _saveValue() async {
    if (widget.getstate == Env.WORK_GET_IN) {
      for (int i = 0; i < weekAlarmGITime.length; i++) {
        secureStorage.write(weekAlarmGITime[i], initTimeGetIn[i]);
        secureStorage.write(weekAlarmGI[i], switchDay[i].toString());
      }
    } else if (widget.getstate == Env.WORK_GET_OUT) {
      for (int i = 0; i < weekAlarmGOTime.length; i++) {
        secureStorage.write(weekAlarmGOTime[i], initTimeGetOut[i]);
        secureStorage.write(weekAlarmGO[i], switchDay[i].toString());
      }
    }
  }
}
