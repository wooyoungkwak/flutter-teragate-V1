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
  List<String> weekKR = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일","월~금요일"];
  List<String> weekAlarmInTime = [Env.KEY_SETTING_MON_GI_TIME, Env.KEY_SETTING_TUE_GI_TIME, Env.KEY_SETTING_WED_GI_TIME, Env.KEY_SETTING_THU_GI_TIME, Env.KEY_SETTING_FRI_GI_TIME, Env.KEY_SETTING_SAT_GI_TIME, Env.KEY_SETTING_SUN_GI,Env.KEY_SETTING_WEEK_GI_TIME];
  List<String> weekAlarmOutTime = [Env.KEY_SETTING_MON_GO_TIME, Env.KEY_SETTING_TUE_GO_TIME, Env.KEY_SETTING_WED_GO_TIME, Env.KEY_SETTING_THU_GO_TIME, Env.KEY_SETTING_FRI_GO_TIME, Env.KEY_SETTING_SAT_GO_TIME, Env.KEY_SETTING_SUN_GO,Env.KEY_SETTING_WEEK_GO_TIME];
  List<String> weekAlarmIn = [Env.KEY_SETTING_MON_GI, Env.KEY_SETTING_TUE_GI, Env.KEY_SETTING_WED_GI, Env.KEY_SETTING_THU_GI, Env.KEY_SETTING_FRI_GI, Env.KEY_SETTING_SAT_GI, Env.KEY_SETTING_SUN_GI,Env.KEY_SETTING_WEEK_GI];
  List<String> weekAlarmOut = [Env.KEY_SETTING_MON_GO, Env.KEY_SETTING_TUE_GO, Env.KEY_SETTING_WED_GO, Env.KEY_SETTING_THU_GO, Env.KEY_SETTING_FRI_GO, Env.KEY_SETTING_SAT_GO, Env.KEY_SETTING_SUN_GO,Env.KEY_SETTING_WEEK_GO];
  List<bool> switchDay = [true,true, true, true, true, false, false, true]; //스위치 true/false
  List<String> title = ["출근 알람","퇴근 알람"];
  int colorvla = 0;
  List<String> colorChange = [" Colors.black","Colors.white"];
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
        title: Text(title[widget.getstate], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: 
      ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            color: const Color(0xffF6F2F2),
            width: double.infinity,
            child: Row (
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [                                                              
                if (widget.getstate == 0) Text(initTimeGetIn[ weekKR.length-1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300))
                else if (widget.getstate == 1) Text(initTimeGetOut[ weekKR.length-1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                Text(weekKR[ weekKR.length-1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                Align(
                  child: Switch(
                    value: switchDay[ weekKR.length-1],
                    onChanged: (newValue) {
                      if (widget.getstate == 0) {
                        setState(() { 
                          switchDay[ weekKR.length-1] = newValue;
                          if(newValue){
                            colorvla = 1;
                          }else{
                            colorvla = 0;
                          }
                        });
                        secureStorage.write(weekAlarmIn[ weekKR.length-1], newValue.toString());
                      } else if (widget.getstate == 1) {
                        setState(() {
                           switchDay[ weekKR.length-1] = newValue;
                           if(newValue){
                            colorvla = 1;
                          }else{
                            colorvla = 0;
                          }
                        });
                        secureStorage.write(weekAlarmOut[ weekKR.length-1], newValue.toString());
                      }
                    }
                  ),
                )
              ],
            ),  
          ),
          IgnorePointer(
            ignoring: !switchDay[weekKR.length-1],
            ignoringSemantics: false,
            child : 
            Expanded(
              child: Container(
                color: Color.fromARGB(255, 241, 237, 237),
                height: 500.0,
                child: getListView()
              )
            )    
          ),
          
        ]  
      )
    );
  }

  ListView getListView(){
    return  
      ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 30),
        itemCount: weekKR.length-1,
        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 3),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              openTimePicker(context, index);
            },
            child:
              Container(
                color: const Color.fromARGB(255, 241, 237, 237),
                width: double.infinity,
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [                                                              
                    if (widget.getstate == 0) Text(initTimeGetIn[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300))
                    else if (widget.getstate == 1) Text(initTimeGetOut[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                    Text(weekKR[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                    Align(
                      child: Switch(
                        value: switchDay[index],
                        onChanged: (newValue) {
                          if (widget.getstate == 0) {
                            setState(() => switchDay[index] = newValue);
                            secureStorage.write(weekAlarmIn[index], newValue.toString());
                          } else if (widget.getstate == 1) {
                            setState(() => switchDay[index] = newValue);
                            secureStorage.write(weekAlarmOut[index], newValue.toString());
                          }
                        }
                      ),
                    )
                  ],
                ),
              )                                      
          );
        }
      );
  }

  void openTimePicker(BuildContext context, int weekindex) async {
    BottomPicker.time(
      title: "Set your next meeting time",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange),
      onSubmit: (index) async {
        String formattedDate = DateFormat('kk:mm').format(index).toString();
        setState(() {
          if (widget.getstate == 0) {
            initTimeGetIn[weekindex] = formattedDate;
            secureStorage.write(weekAlarmInTime[weekindex], formattedDate);
          } else {
            initTimeGetOut[weekindex] = formattedDate;
            secureStorage.write(weekAlarmOutTime[weekindex], formattedDate);
          }
        });
      },
      onClose: () {},
      use24hFormat: true
    )
    .show(context);
  }

  Future<String> setInitTime() async {
    
    if (widget.getstate == 0) {
      //getstate가 0 이면 출근
      for (int i = 0; i < weekKR.length; i++) {
        String? check = await secureStorage.read(weekAlarmInTime[i]);
        if (check != null) {
          initTimeGetIn[i] = check.toString();
        }
        await setSwitch(i);
      }
    } else if (widget.getstate == 1) {
        //getstate가 1 이면 퇴근
      for (int i = 0; i < weekKR.length; i++) {
        String? check = await secureStorage.read(weekAlarmOutTime[i]);
        if (check != null) {
          initTimeGetOut[i] = check.toString();
        }
        await setSwitch(i);
      }
    }

    return "re";
  }

  Future<void> setSwitch(int i) async{
    if (widget.getstate == 0) {
      String? change = await secureStorage.read(weekAlarmIn[i]);
      if (change == null) secureStorage.write(weekAlarmIn[i], switchDay[i].toString()) ;
      if (change == "true") {
        switchDay[i] = true; 
      } else if (change == "false") {
        switchDay[i] = false;
      }
    } else if (widget.getstate == 1) {
      String? change = await secureStorage.read(weekAlarmOut[i]);
      if (change == null) secureStorage.write(weekAlarmOut[i], switchDay[i].toString()) ;
      if (change == "true") {
        switchDay[i] = true;
      } else if (change == "false") {
        switchDay[i] = false;
      }
    }
  }
}
