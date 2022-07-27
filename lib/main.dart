import 'package:flutter/material.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/services/server_service.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/states/dashboard_state.dart';
import 'package:teragate_test/utils/alarm_util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 2), () => _checkUser(context));
    _checkUser(context).then((data) => move(data["loginId"], data["loginPw"]));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Icon(
        Icons.stream,
        size: 80,
        color: Colors.blue,
      )),
    );
  }

  Future<Map<String, String?>> _checkUser(context) async {
    SecureStorage secureStorage = SecureStorage();
    Map<String, String> allStorage = await secureStorage.getFlutterSecureStorage().readAll();
    String? loginId;
    String? loginPw;

    if (allStorage.isNotEmpty) {
      allStorage.forEach((k, v) {
        if (k == Env.LOGIN_ID) loginId = v;
        if (k == Env.LOGIN_PW) loginPw = v;
      });

      // login(loginId, loginPw).then((data) {
      //   if (data.success) {
      //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
      //   } else {
      //     showSnackBar(context, data.message);
      //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
      //   }
      // });
    // } else {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
    }
    
    return {
      "loginId": loginId,
      "loginPw": loginPw
    };
  }

  void move(String? id, String? password) {
    if (id != null && password != null ) {
      debugPrint(" move ..... id & password exist ..... ");
      login(id, password).then((data) {
        if (data.success) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        } else {
          showSnackBar(context, data.message);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
        }
      });
    } else {
      debugPrint(" move ..... id & password not !!!!!!!! ");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
    }
  }
  
}
