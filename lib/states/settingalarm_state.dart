import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';



class SettingAlarm extends StatefulWidget {
  final String uuiddata;
  const SettingAlarm(this.uuiddata, Key? key) : super(key: key);

  @override
  SettingAlarmState createState() => SettingAlarmState();
}

class SettingAlarmState extends State<SettingAlarm> {
  //스위치 true/false
  var switchListTileValue1 = true;
  var switchListTileValue2 = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  get children => null;
  
  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
  ), 
        backgroundColor: const Color(0x0fff5f5f),
        automaticallyImplyLeading: true,
        title: const Text(
          '알람 설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
        ),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Color.fromARGB(255, 99, 84, 84),
      body: SafeArea(
        child: Column( children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText( 
                text: TextSpan(children: [
                  TextSpan(
                    text: '진 동',
                    //텍스트를 클릭시 이벤트를 발생시키기 위함
                    recognizer: TapGestureRecognizer()
                    //클래스 생성과 동시에 '선언부..함수명'을 입력하면 클래스 변수 없이 함수를 바로 호출 가능함
                    ..onTapDown = (details) {
                    //onTapDown에서 반환되는 값으로 터치한 Screen 위치를 알 수 있다.
                    print(details.globalPosition);
                    },
                    style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                    ]),
                    ),
                    Align(                                          
                    child: Switch(
                      value: switchListTileValue1 ,
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
                            text: '알람음' ,
                            //텍스트를 클릭시 이벤트를 발생시키기 위함
                            recognizer: TapGestureRecognizer()
                            //클래스 생성과 동시에 '선언부..함수명'을 입력하면 클래스 변수 없이 함수를 바로 호출 가능함
                              ..onTapDown = (details) {
                              },
                            style: const TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400), ),
                      ]),
                  ),
                  Switch(
                    value: switchListTileValue2 ,
                    onChanged: (newValue) =>
                    setState(() => switchListTileValue2 = newValue),
            ),
                ],
              ),
          ),
        ],
      ),
      ),
    );
  }

}