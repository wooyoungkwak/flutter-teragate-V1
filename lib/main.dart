import 'package:flutter/material.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/services/login_service.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/states/main_state.dart';
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
    Future.delayed(const Duration(seconds: 2), () => _checkUser(context));
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

  void _checkUser(context) async {
    SecureStorage secureStorage = SecureStorage();
    Map<String, String> allStorage = await secureStorage.getFlutterSecureStorage().readAll();
    String statusUser = '';
    String loginId = '';
    String loginPw = '';
    if (allStorage.isNotEmpty) {
      allStorage.forEach((k, v) {
        if (Env.isDebug) debugPrint('k : $k, v : $v');
        if (v == Env.STATUS_LOGIN) statusUser = k;

        if (k == 'LOGIN_ID') loginId = v;
        if (k == 'LOGIN_PW') loginPw = v;
      });
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
    }
        
    login(loginId, loginPw).then((data) {
      if (data.success) {
        if (statusUser.isNotEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Beacon()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
        }
      } else {
        showSnackBar(context, data.message);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
      }
    });
  }
}
