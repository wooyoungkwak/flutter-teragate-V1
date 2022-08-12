import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:teragate_test/services/server_service.dart';
import 'package:teragate_test/services/permission_service.dart';
import 'package:teragate_test/utils/alarm_util.dart';
import 'package:teragate_test/states/dashboard_state.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  late TextEditingController _loginIdContoroller;
  late TextEditingController _passwordContorller;
  bool checkBoxValue = false;
  late bool initcheck;
  Color boxColor = const Color(0xff27282E);
  TextStyle textStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontFamily: 'sunn',
      color: Colors.white,
      fontSize: 20);
  TextStyle textFieldStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontFamily: 'sunn',
      color: Color(0xffA3A6B9),
      fontSize: 20);

  final _formKey = GlobalKey<FormState>();
  late SecureStorage secureStorage;

  @override
  void initState() {
    super.initState();
    callPermissions();

    _loginIdContoroller = TextEditingController(text: "");
    _passwordContorller = TextEditingController(text: "");

    initcheck = true;

    secureStorage = SecureStorage();
  }

  @override
  void dispose() {
    _loginIdContoroller.dispose();
    _passwordContorller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _createContainerByBackground(
        _createWillPopScope(_initPaddingByMain()));
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          SystemNavigator.pop();
          return Future(() => false);
        },
        child: widget);
  }

  ListView _createListView(List<Widget> children) {
    return ListView(shrinkWrap: true, children: children);
  }

  Padding _createPadding(double size, Widget widget) {
    return Padding(padding: EdgeInsets.all(size), child: widget);
  }

  Padding _createPaddingByOnly(
      double top, double bottom, double left, double right, Widget widget) {
    return Padding(
        padding:
            EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
        child: widget);
  }

  Padding _createPaddingBySementic(
      double vertical, double horizontal, Widget widget) {
    return Padding(
        padding:
            EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
        child: widget);
  }

  Padding _initPaddingByMain() {
    return _createPadding(
      8.0,
      Form(
        key: _formKey,
        child: Center(
          child: _createListView(
            <Widget>[
              _createPaddingBySementic(
                0.0,
                15.0,
                const Text('Groupware',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sunn',
                        color: Colors.white,
                        fontSize: 20)),
              ),
              _createPaddingByOnly(
                  8.0,
                  30.0,
                  80.0,
                  80.0,
                  Image.asset(
                    'assets/workon_logo.png',
                    fit: BoxFit.fitWidth,
                  )),
              _createPadding(
                  16.0,
                  _initTextFormField(false, _loginIdContoroller,
                      " 아이디를 입력해 주세요", textFieldStyle, "Id")),
              _createPadding(
                  16.0,
                  _initTextFormField(true, _passwordContorller,
                      " 패스워드를 입력해 주세요", textFieldStyle, "Password")),
              FutureBuilder(
                  future: _setsaveid(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return _createPaddingBySementic(
                          0.0,
                          16.0,
                          _createGestureDetector(
                              setCheckbox,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _createContainerByCheckboxBackground(Checkbox(
                                    activeColor: boxColor,
                                    checkColor: Colors.white,
                                    value: checkBoxValue,
                                    onChanged: (value) {
                                      setCheckbox();
                                    },
                                  )),
                                  Text('ID Check',
                                      style: textStyle.copyWith(fontSize: 16)),
                                  Transform.scale(scale: 1.5),
                                ],
                              )));
                    }
                  }),
              _createPaddingBySementic(
                35.0,
                16.0,
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(8.0),
                  color: Color(0xff314CF8),
                  child: MaterialButton(
                      height: 0.0,
                      onPressed: () async {
                        if (_formKey.currentState!.validate())
                          await _setLogin();
                      },
                      child: Text("Sign in", style: textStyle)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _initTextFormField(
      bool isObscureText,
      TextEditingController controller,
      String message,
      TextStyle style,
      String decorationType) {
    return TextFormField(
        obscureText: isObscureText,
        controller: controller,
        validator: (value) => (value!.isEmpty) ? message : null,
        style: style,
        decoration: decorationType == "Id"
            ? InputDecoration(
                filled: true,
                fillColor: boxColor,
                prefixIcon: Image.asset('assets/person_outline_black_24dp.png',
                    fit: BoxFit.scaleDown),
                labelText: "ID",
                labelStyle: textFieldStyle,
                border: const OutlineInputBorder())
            : InputDecoration(
                filled: true,
                fillColor: boxColor,
                prefixIcon: Image.asset('assets/lock_open_black_24dp.png',
                    fit: BoxFit.scaleDown),
                labelText: "Password",
                labelStyle: textFieldStyle,
                border: const OutlineInputBorder()));
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

  GestureDetector _createGestureDetector(Function callback, Widget widget) {
    return GestureDetector(
        onTap: () {
          callback();
        },
        child: widget);
  }

  Container _createContainerByCheckboxBackground(Widget widget) {
    return Container(
      height: 17.0,
      width: 17.0,
      alignment: Alignment.center,
      color: boxColor,
      margin: EdgeInsets.only(right: 5),
      child: widget,
    );
  }

  void setCheckbox() {
    setState(() {
      checkBoxValue = !checkBoxValue;
    });
    secureStorage.write(Env.KEY_ID_CHECK, checkBoxValue.toString());
  }

  Future<String> _setsaveid() async {
    if (initcheck) {
      String? chek = await secureStorage.read(Env.KEY_ID_CHECK);
      if (chek == null) {
        setState(() {
          checkBoxValue = false;
        });
      } else if (chek == "true") {
        checkBoxValue = true;
        String? sevedid = await secureStorage.read(Env.LOGIN_ID);
        if (sevedid != null) {
          setState(() {
            _loginIdContoroller = TextEditingController(text: sevedid);
          });
        }
      } else if (chek == "false") {
        checkBoxValue = false;
      }
      initcheck = false;
    }
    return "...";
  }

  Future<void> _setLogin() async {
    login(_loginIdContoroller.text, _passwordContorller.text).then((loginInfo) {
      if (loginInfo.success!) {
        secureStorage.write(Env.LOGIN_ID, _loginIdContoroller.text);
        secureStorage.write(Env.LOGIN_PW, _passwordContorller.text);
        secureStorage.write('krName', '${loginInfo.data?['krName']}');
        secureStorage.write(
            Env.KEY_ACCESS_TOKEN, '${loginInfo.tokenInfo?.getAccessToken()}');
        secureStorage.write(
            Env.KEY_REFRESH_TOKEN, '${loginInfo.tokenInfo?.getRefreshToken()}');
        secureStorage.write(Env.KEY_LOGIN_STATE, "true");
        secureStorage.write(
            Env.KEY_LOGIN_RETURN_ID, loginInfo.data!["userId"].toString());

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Dashboard()));
      } else {
        showSnackBar(context, loginInfo.message!);
      }
    });
  }
}
