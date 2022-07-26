
import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SettingWork extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        body: SettingWorkTime(null),
      ),
    );
  }
}

  
  class SettingWorkTime extends StatefulWidget {
    
  
  const SettingWorkTime(Key? key) : super(key: key);

  @override
  SettingWorkTimeState createState() => SettingWorkTimeState();
}

class SettingWorkTimeState extends State<SettingWorkTime> {
  var flutterSecureStorage = const FlutterSecureStorage();
  
  String time2 = "08:30";
  String time1 = "     AM";
  List<String> day = ["월요일","화요일","수요일","목요일","금요일","토요일","일요일",];
  List<bool> switchday = [true,true,true,true,true,false,false];
  //스위치 true/false
  var switchListTileValue1 = true;
  var switchListTileValue2 = true;
  

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
        flutterSecureStorage.write(key: "dayTime", value: time1+time2);
    
    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
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
            itemCount: day.length,
            separatorBuilder: (BuildContext context, int index) =>
            	const Divider(thickness: 3),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: (){
                  
                openTimePicker(context);
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
      color: Color(0xffF6F2F2),
      width: double.infinity,
      child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        
        children: [
          Text(snapshot.data.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
          Text(day[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
          Align(                                          
          child: Switch(
          value: switchday[index],
          onChanged: (newValue) =>
          setState(() => switchday[index] = newValue),
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

    void openTimePicker(BuildContext context)  {
      
    BottomPicker.time(      title:  "Set your next meeting time",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize:  15,
        color: Colors.orange
      ),
      onSubmit: (index) async {
    flutterSecureStorage.write(key: "dayTime", value: index.toString());
    debugPrint(await flutterSecureStorage.read(key: "dayTime").toString());
    setState(() {
      time2 = index;
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
//    debugPrint(Info.dayWeek);


    await Future.delayed(Duration(seconds: 1)); // 비동기 과정을 보여주기 위해 시간을 딜레이 시킨다.
    return await flutterSecureStorage.read(key: 'dayTime');
  }
}


  
