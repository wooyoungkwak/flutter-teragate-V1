import 'package:flutter/material.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/services/server_service.dart';
import 'package:teragate_test/states/login_state.dart';
import 'package:teragate_test/states/dashboard_state.dart';
import 'package:teragate_test/utils/alarm_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  late SecureStorage secureStorage;

  @override
  void initState() {
    super.initState();
    initSet();
  }

  @override
  Widget build(BuildContext context) {
    return _createContainerByBackground(Center(
        child: _createPaddingByOnly(
            8.0,
            30.0,
            80.0,
            80.0,
            Image.asset(
              'assets/workon_logo.png',
              fit: BoxFit.fitWidth,
            ))));
  }

  Container _createContainerByBackground(Widget widget) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background.png"), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget,
      ),
    );
  }

  Padding _createPaddingByOnly(
      double top, double bottom, double left, double right, Widget widget) {
    return Padding(
        padding:
            EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
        child: widget);
  }

  void initSet() async {
    secureStorage = SecureStorage();
    await _checkUser(context)
        .then((data) => move(data["loginId"], data["loginPw"]));
  }

  Future<Map<String, String?>> _checkUser(context) async {
    String? loginId = await secureStorage.read(Env.LOGIN_ID);
    String? loginPw = await secureStorage.read(Env.LOGIN_PW);

    return {"loginId": loginId, "loginPw": loginPw};
  }

  void move(String? id, String? password) async {
    String? isLogin = await secureStorage.read(Env.KEY_LOGIN_STATE);
    if (isLogin == "true") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Dashboard()));
    } else {
      if (id != null && password != null) {
        login(id, password).then((loginInfo) {
          if (loginInfo.success!) {
            secureStorage.write(Env.KEY_ACCESS_TOKEN,
                '${loginInfo.tokenInfo?.getAccessToken()}');
            secureStorage.write(Env.KEY_REFRESH_TOKEN,
                '${loginInfo.tokenInfo?.getRefreshToken()}');
            secureStorage.write(
                Env.KEY_LOGIN_RETURN_ID, loginInfo.data!["userId"].toString());
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Dashboard()));
          } else {
            showSnackBar(context, loginInfo.message!);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Login()));
          }
        });
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
      }
    }
  }
}
