import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/config/env.dart';

// deprecate : 사용하지 않음 ...
class SettingAlarm extends StatefulWidget {
  const SettingAlarm(Key? key) : super(key: key);

  @override
  SettingAlarmState createState() => SettingAlarmState();
}

class SettingAlarmState extends State<SettingAlarm> {
  late SecureStorage secureStorage;
  bool switchVibrate = true;
  bool switchSound = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  get children => null;

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
          title: const Text('알람 설정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          actions: const [],
          centerTitle: true,
          elevation: 4,
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Switch(
                    value: switchSound,
                    onChanged: (newValue) {
                      setState(() => switchSound = newValue);
                      secureStorage.write("Alarm", switchSound.toString());
                    },
                  );
                },
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(children: [
                          TextSpan(text: '진 동', style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400)),
                        ]),
                      ),
                      Align(
                        child: Switch(
                          value: switchVibrate,
                          onChanged: (newValue) {
                            setState(() => switchVibrate = newValue);
                            secureStorage.write(Env.KEY_SETTING_VIBRATE, switchVibrate.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(children: [
                          TextSpan(
                            text: '알람음',
                            style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                        ]),
                      ),
                      Switch(
                        value: switchSound,
                        onChanged: (newValue) {
                          setState(() => switchSound = newValue);
                          secureStorage.write(Env.KEY_SETTING_ALARM, switchSound.toString());
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Future<String> setuuid() async {
    String? vibrate = await secureStorage.read(Env.KEY_SETTING_VIBRATE);
    String? sound = await secureStorage.read(Env.KEY_SETTING_SOUND);

    if (vibrate == "true") {
      switchVibrate = true;
    } else if (vibrate == "false") {
      switchVibrate = false;
    }
    if (sound == "true") {
      switchSound = true;
    } else if (sound == "false") {
      switchSound = false;
    }

    setState(() {
      if (vibrate == null) {
        switchVibrate = false;
        secureStorage.write(Env.KEY_SETTING_VIBRATE, switchVibrate.toString());
      }

      if (sound == null) {
        switchSound = false;
        secureStorage.write(Env.KEY_SETTING_SOUND, switchSound.toString());
      }
    });

    // 리턴 값이 있어야 감지가 됩니다!
    return "re";
  }
}
