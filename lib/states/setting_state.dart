import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/states/settingalarm_state.dart';
import 'package:teragate_test/states/settingbeacon_state.dart';
import 'package:teragate_test/states/settingwork_state.dart';
import 'package:teragate_test/config/env.dart';

class Setting extends StatefulWidget {
  
  const Setting(Key? key) : super(key: key);

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting>  {

  late SecureStorage secureStorage;
  //스위치 true/false
  bool switchgetin = false;
  bool switchgetout = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String beaconuuid= "";
  
  @override
  void initState() {
    super.initState();
    
    secureStorage = SecureStorage();
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
                  onTapuuid();

    },
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
              ),
              child: Stack(
                children: [
                  FutureBuilder(
                    future: setuuid(),
                    builder: (context, snapshot) {
                  // 해당 부분은 data를 아직 받아 오지 못했을 때 실행되는 부분
                  if (snapshot.hasData == false) {
                    return const CircularProgressIndicator(); // CircularProgressIndicator : 로딩 에니메이션
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
                          text:beaconuuid,
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
          GestureDetector(          
                onTap: () { 
                  onTapWorkIn();

    },
            child:
          Container(            
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
            ),
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
                            builder: (context) => const SettingWorkTime(0,null)));
                    },
                    style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                    ]),
                    ),
                    Align(                                          
                    child: Switch(
                      value: switchgetin,
                      onChanged: (newValue) {
                      setState(() => switchgetin = newValue);
                      secureStorage.write(Env.KEY_SETTING_GI_ON_OFF, switchgetin.toString());
                      }
                      ),
                      ),
                      ],
                      ),
                      ),
                      ),
                      GestureDetector(          
                        onTap: () { 
                          onTapWorkOut();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEEEEE),
                          ),
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
                                      builder: (context) => const SettingWorkTime(1,null)));
                                    },
                                    style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                                    ]), 
                                    ),
                                    Switch(
                                      value: switchgetout,
                                      onChanged: (newValue) {
                                      setState(() => switchgetout = newValue);
                                      secureStorage.write(Env.KEY_SETTING_GO_ON_OFF, switchgetout.toString());
                                      }
                                    ),
                              ],
                        ),
                        ),
                      ),
                      GestureDetector(          
                        onTap: () { 
                          onTapAlarm();
                        },  
                        child:
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                        ),
                        child: Row(
                          children: [
                            RichText( 
                              text: const TextSpan(children: [
                              TextSpan(
                                text: '알람 설정',
                                style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                              ]),
                            ),
                          ],
                        ),
          ),
        )
        ],
      ),
      ),
    );
  }


  void onTapuuid() {
    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => const SettingBeacon("testuuid",null)));
  }
    void onTapWorkIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => const SettingWorkTime(0,null)));
  }
    void onTapWorkOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => const SettingWorkTime(1,null)));
  }
    void onTapAlarm() {
    Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => const SettingAlarm(null)));
  }

  Future<String> setuuid() async{
    String? chek = await secureStorage.read(Env.KEY_UUID);

    if (chek == null){
      chek = Env.UUID_DEFAULT;
      secureStorage.write(Env.KEY_UUID, chek);
      beaconuuid = chek;
    }else{
      beaconuuid = chek;
    }
    setState(() {
      beaconuuid = chek.toString();
    });
    String? getin = await secureStorage.read(Env.KEY_SETTING_GI_ON_OFF);
    String? getout = await secureStorage.read(Env.KEY_SETTING_GO_ON_OFF);
     
    if(getin==null){
    setState(() {
      switchgetin = false; 
    });
    }
    if(getout== null){
    setState(() {
      switchgetout = false; 
    });
    }
    if(getin=="true")switchgetin= true;
    if(getin=="false")switchgetin= false;
    if(getout=="true")switchgetout= true;
    if(getout=="false")switchgetout= false; 
     

    return chek;
  }
}