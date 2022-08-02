import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:intl/intl.dart';
import 'package:teragate_test/config/env.dart';

class SettingWorkTime extends StatefulWidget {
  final int getstate;

  const SettingWorkTime(this.getstate, Key? key) : super(key: key);

  @override
  SettingWorkTimeState createState() => SettingWorkTimeState();
}

class SettingWorkTimeState extends State<SettingWorkTime> {
  late SecureStorage secureStorage;
  
  List<String> initTimeGetIn = ["08:30","08:30", "08:30", "08:30", "08:30", "08:30", "08:30", "08:30"];
  List<String> initTimeGetOut = ["18:00","18:00", "18:00", "18:00", "18:00", "18:00", "18:00", "18:00"];
  List<String> weekKR = ["월~금요일","월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  List<String> weekAlarmInTime = [Env.KEY_SETTING_MON_GI_TIME, Env.KEY_SETTING_TUE_GI_TIME, Env.KEY_SETTING_WED_GI_TIME, Env.KEY_SETTING_THU_GI_TIME, Env.KEY_SETTING_FRI_GI_TIME, Env.KEY_SETTING_SAT_GI_TIME, Env.KEY_SETTING_SUN_GI];
  List<String> weekAlarmOutTime = [Env.KEY_SETTING_MON_GO_TIME, Env.KEY_SETTING_TUE_GO_TIME, Env.KEY_SETTING_WED_GO_TIME, Env.KEY_SETTING_THU_GO_TIME, Env.KEY_SETTING_FRI_GO_TIME, Env.KEY_SETTING_SAT_GO_TIME, Env.KEY_SETTING_SUN_GO];
  List<String> weekAlarmIn = [Env.KEY_SETTING_MON_GI, Env.KEY_SETTING_TUE_GI, Env.KEY_SETTING_WED_GI, Env.KEY_SETTING_THU_GI, Env.KEY_SETTING_FRI_GI, Env.KEY_SETTING_SAT_GI, Env.KEY_SETTING_SUN_GI];
  List<String> weekAlarmOut = [Env.KEY_SETTING_MON_GO, Env.KEY_SETTING_TUE_GO, Env.KEY_SETTING_WED_GO, Env.KEY_SETTING_THU_GO, Env.KEY_SETTING_FRI_GO, Env.KEY_SETTING_SAT_GO, Env.KEY_SETTING_SUN_GO];
  List<bool> switchDay = [true, true, true, true, true, false, false]; //스위치 true/false
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    secureStorage = SecureStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0x0fff5f5f),
          automaticallyImplyLeading: true,
          title: const Text('알람 설정 ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          actions: const [],
          centerTitle: true,
          elevation: 4,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 30),
            itemCount: weekKR.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 3),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  openTimePicker(context, index);
                },
                child: FutureBuilder(
                    future: test(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Container(
                          color: const Color(0xffF6F2F2),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget.getstate == 0) Text(initTimeGetIn[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                              if (widget.getstate == 1) Text(initTimeGetOut[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                              Text(weekKR[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                              Align(
                                child: Switch(
                                    value: switchDay[index],
                                    onChanged: (newValue) {
                                      if (widget.getstate == 0) {
                                        setState(() => switchDay[index] = newValue);
                                        secureStorage.write(weekAlarmIn[index], newValue.toString());
                                      }
                                      if (widget.getstate == 1) {
                                        setState(() => switchDay[index] = newValue);
                                        secureStorage.write(weekAlarmOut[index], newValue.toString());
                                      }
                                    }),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              );
            }));
  }

  void openTimePicker(BuildContext context, int weekindex) {
    BottomPicker.time(
            title: "Set your next meeting time",
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange),
            onSubmit: (index) async {
              String formattedDate = DateFormat('kk:mm').format(index).toString();
              if (widget.getstate == 0) secureStorage.write(weekAlarmInTime[weekindex], formattedDate);
              if (widget.getstate == 1) secureStorage.write(weekAlarmOutTime[weekindex], formattedDate);
              setState(() {
                if (widget.getstate == 0) {
                  initTimeGetIn[weekindex] = formattedDate;
                } else {
                  initTimeGetOut[weekindex] = formattedDate;
                }
              });
            },
            onClose: () {},
            use24hFormat: true)
        .show(context);
  }

  Future<String> test() async {
    //getstate가 0 이면 출근
    if (widget.getstate == 0) {
      for (int i = 0; i < 7; i++) {
        String? cheak = await secureStorage.read(weekAlarmInTime[i]);
        if (cheak != null) {
          initTimeGetIn[i] = cheak.toString();
        }
      }
    }
    //getstate가 1 이면 퇴근
    if (widget.getstate == 1) {
      for (int i = 0; i < 7; i++) {
        String? cheak = await secureStorage.read(weekAlarmOutTime[i]);
        if (cheak != null) {
          initTimeGetOut[i] = cheak.toString();
        }
      }
    }
    for (int i = 0; i < 7; i++) {
      if (widget.getstate == 0) {
        String? change = await secureStorage.read(weekAlarmIn[i]);
        if (change == null) secureStorage.write(weekAlarmIn[i], switchDay[i].toString()) ;
        if (change == "true") switchDay[i] = true;
        if (change == "false") switchDay[i] = false;
      }
      if (widget.getstate == 1) {
        String? change = await secureStorage.read(weekAlarmOut[i]);
        if (change == null) secureStorage.write(weekAlarmOut[i], switchDay[i].toString()) ;
        if (change == "true") switchDay[i] = true;
        if (change == "false") switchDay[i] = false;
      }
    }
    return "re";
  }
}
