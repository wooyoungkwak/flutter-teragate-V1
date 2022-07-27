
import 'dart:convert';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:intl/intl.dart';


class SettingWork extends StatelessWidget {

  
  final  int getstate;


  const SettingWork(this.getstate,Key? key) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home:  Scaffold(
        body: SettingWorkTime(getstate,null),
      ),
    );
  }
}

  
  class SettingWorkTime extends StatefulWidget {
    
    final  int getstate;
  
  const SettingWorkTime(this.getstate ,Key? key) : super(key: key);

  @override
  SettingWorkTimeState createState() => SettingWorkTimeState();
}

class SettingWorkTimeState extends State<SettingWorkTime> {  

  late SecureStorage strage;

  //
  List<String> timeGetIn = ["08:30","08:30","08:30","08:30","08:30","08:30","08:30"];
  List<String> timeGetOut = ["18:30","18:30","18:30","18:30","18:30","18:30","18:30"];
  List<String> week = ["월요일","화요일","수요일","목요일","금요일","토요일","일요일"];
  List<String> weekEN = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  List<String> timetext = ["TimeGetIn","TimeGetOut"];

  List<bool> switchday = [true,true,true,true,true,false,false]; //스위치 true/false
  final scaffoldKey = GlobalKey<ScaffoldState>();

    @override
  void initState() {
    super.initState();
    
    strage = SecureStorage();
  }
  
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
  ), 
        backgroundColor: const Color(0x0fff5f5f),
        automaticallyImplyLeading: true,
        title: const Text(
          'Beacon Scan', 
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
                  //Scaffold.of(context).showSnackBar(SnackBar(content: Text(index.toString())));
                
                }, 
                                child:  FutureBuilder(
                    future: test(),
                    builder: (context, snapshot) {
  
                  // 해당 부분은 data를 아직 받아 오지 못했을 때 실행되는 부분
                  if (snapshot.hasData == false) {
                    return CircularProgressIndicator(); // CircularProgressIndicator : 로딩 에니메이션
                  }

                  // error가 발생하게 될 경우 반환하게 되는 부분
                  else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // 에러명을 텍스트에 뿌려줌
                  }

                  // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 부분
                  else {
                    //return Text(snapshot.data.toString());

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
            strage.write(weekEN[index], newValue.toString());
            setState(() => switchday[index] = newValue);
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
        debugPrint(formattedDate);
        strage.write(weekEN[weekindex]+timetext[widget.getstate],formattedDate);
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
  Future<String?> test() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> week = 
    {'dayWeek':'월요일좋아','alarm':'ON' , 'workingTime':'08:30', 'quittingTime':'18:00'};
    prefs.setString("day", json.encode(week));
    String? userPref = prefs.getString('day');
    Map<String,dynamic> Info = jsonDecode(userPref!) as Map<String, dynamic>;


    return await "test";
  }
}


  
