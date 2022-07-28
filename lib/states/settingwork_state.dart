
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:intl/intl.dart';
import 'package:teragate_test/utils/debug_util.dart';
  
  class SettingWorkTime extends StatefulWidget {
    
    final  int getstate;
  
  const SettingWorkTime(this.getstate ,Key? key) : super(key: key);

  @override
  SettingWorkTimeState createState() => SettingWorkTimeState();
}

class SettingWorkTimeState extends State<SettingWorkTime> {  

  late SecureStorage secureStorage;

  //
  List<String> timeGetIn = ["08:30","08:30","08:30","08:30","08:30","08:30","08:30"];
  List<String> timeGetOut = ["18:30","18:30","18:30","18:30","18:30","18:30","18:30"];
  List<String> week = ["월요일","화요일","수요일","목요일","금요일","토요일","일요일"];
  List<String> weekEN = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  List<String> timetext = ["TimeGetIn","TimeGetOut"];
  List<String> weekAlarmIn = ["MondayAlarmIn","TuesdayAlarmIn","WednesdayAlarmIn","ThursdayAlarmIn","FridayAlarmIn","SaturdayAlarmIN","SundayAlarmIn"];
  List<String> weekAlarmOut = ["MondayAlarmOut","TuesdayAlarmOut","WednesdayAlarmOut","ThursdayAlarmOut","FridayAlarmOut","SaturdayAlarmOut","SundayAlarmOut"];

  List<bool> switchday = [true,true,true,true,true,false,false]; //스위치 true/false
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
        title: const Text(
          '알람 설정 ', 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
        ),
        actions: const [],
        centerTitle: true,
        elevation: 4,
        
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView.separated(
        
            padding: const EdgeInsets.symmetric(vertical: 30),
            itemCount: week.length,
            separatorBuilder: (BuildContext context, int index) =>
            	const Divider(thickness: 3),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: (){
                  openTimePicker(context, index);
                }, 
                  child:  FutureBuilder(
                    future: test(),
                    builder: (context, snapshot) {
                  if (snapshot.hasData == false) {
                    return const CircularProgressIndicator();
                  }
                  else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); 
                  }
                  else {
                 return Container(
                  color: const Color(0xffF6F2F2),
                  width: double.infinity,
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    
                    children: [
                      if(widget.getstate==0)Text(timeGetIn[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                      if(widget.getstate==1)Text(timeGetOut[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                      Text(week[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                      Align(                                          
                      child: Switch(
                      value: switchday[index],
                      onChanged: (newValue) {
                        if(widget.getstate==0){
                        setState(() => switchday[index] = newValue);
                        secureStorage.write(weekAlarmIn[index], newValue.toString());
                        }
                        if(widget.getstate==1){
                        setState(() => switchday[index] = newValue);
                        secureStorage.write(weekAlarmOut[index], newValue.toString());
                        }
                      }
                      ),
                      ),
                      ],
                      ),
                      );
                  }
                }),
                
          );
          }
          )
          );
    
  }

    void openTimePicker(BuildContext context, int weekindex)  {
      
    BottomPicker.time(      title:  "Set your next meeting time",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize:  15,
        color: Colors.orange
      ),
      onSubmit: (index) async {
        String formattedDate = DateFormat('kk:mm').format(index).toString();
        //stage에 저장 (키값:요일+text[출근/퇴근], 선택 날짜+시간);
        secureStorage.write(weekEN[weekindex]+timetext[widget.getstate],formattedDate);
    setState(() {
      if(widget.getstate==0){
        timeGetIn[weekindex] = formattedDate;
      }else {
        timeGetOut[weekindex] = formattedDate;
      }
    });
      },
      onClose: () {
      },
      use24hFormat:  true
    ).show(context);
     }
  Future<String> test() async{
    //getstate가 0 이면 출근
    if(widget.getstate==0){
    for(int i=0; i<7; i++){
     String? cheak = await secureStorage.read(weekEN[i]+timetext[widget.getstate]);
     if(cheak!=null){
      timeGetIn[i] = cheak.toString();
     }
    }
    }
    //getstate가 1 이면 퇴근
    if(widget.getstate==1){
    for(int i=0; i<7; i++){
     String? cheak = await secureStorage.read(weekEN[i]+timetext[widget.getstate]);
     if(cheak!=null){
      timeGetOut[i] = cheak.toString();
     }
    }
    }
    for(int i=0; i<7; i++){
      if(widget.getstate==0){
      String? change = await secureStorage.read(weekAlarmIn[i]);
      if(change == null) switchday[i] = false;
      if(change=="true")switchday[i]= true;
      if(change=="false")switchday[i]= false;
      }
      if(widget.getstate==1){
      String? change = await secureStorage.read(weekAlarmOut[i]);
      if(change == null) switchday[i] = false;
      if(change=="true")switchday[i]= true;
      if(change=="false")switchday[i]= false;
      }
    }
    return "re";
  }
}


  
