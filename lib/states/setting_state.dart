import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/states/settingalarm_state.dart';
import 'package:teragate_test/states/settingbeacon_state.dart';
import 'package:teragate_test/states/settingwork_state.dart';




class Setting extends StatefulWidget {
  
  const Setting(Key? key) : super(key: key);
  


  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting>  {

  late SecureStorage strage;
  //스위치 true/false
  bool switchListTileValue1 = true;
  bool switchListTileValue2 = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String beaconuuid= "";
  
  @override
  void initState() {
    super.initState();
    
    strage = SecureStorage();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
  ), 
        backgroundColor: const Color(0x0fff5f5f),
        automaticallyImplyLeading: true,
        title: const Text(
          '환경 설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
        ),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column( children: <Widget>[
          GestureDetector(          
                onTap: () { 
                  onTap();

    },
            child: Container(
              padding: const EdgeInsets.all(10),
              height: 100,
              margin: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
              ),
              child: Stack(
                children: [
                  FutureBuilder(
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

                 return Align(
                    alignment: const AlignmentDirectional(0.07, 0.21),
                    child :RichText( 
                    text: TextSpan(children: [
                      const TextSpan(
                            text: 'UUID:   ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(                        
                          text: snapshot.data.toString(),
                          //텍스트를 클릭시 이벤트를 발생시키기 위함
                          style: const TextStyle(color: Colors.red)),
                      ]),
                  )

                  );
                  }
                }),
                  
                ],
              ),
              
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
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
                            builder: (context) => const SettingWork(0,null)));
                    },
                    style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                    ]),
                    ),
                    Align(                                          
                    child: Switch(
                      value: switchListTileValue1,
                      onChanged: (newValue) =>
                      setState(() => switchListTileValue1 = newValue),
                      ),
                      ),
                      ],
                      ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
              child: Row(
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
                           builder: (context) => const SettingWork(1,null)));
                              },
                            style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                      ]),
                  ),
                  Switch(
                    value: switchListTileValue2,
                    onChanged: (newValue) =>
                    setState(() => switchListTileValue2 = newValue),
            ),
                ],
              ),
          ),
                    Container(
                      padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  RichText( 
                    text: TextSpan(children: [
                        TextSpan(
                            text: '알람 설정',
                            //텍스트를 클릭시 이벤트를 발생시키기 위함
                            recognizer: TapGestureRecognizer()
                            //클래스 생성과 동시에 '선언부..함수명'을 입력하면 클래스 변수 없이 함수를 바로 호출 가능함
                              ..onTapDown = (details) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingAlarm('setset',null)));
                              },
                            style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                      ]),
                  ),
                ],
              ),
          ),
        ],
      ),
      ),
    );
  }


  void onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => SettingBeacon("testuuid",null)));
  }

  Future<void> test() async{
    String? chek = await strage.read("uuid");
    debugPrint("test 진입");
    if (chek == null){
      chek = "UUID가 설정 안 되어있습니다.";
          debugPrint(chek);
          strage.write("uuid", "123123123123123123");
      beaconuuid = chek;
    }else{
      beaconuuid = chek;
    }
  }
}