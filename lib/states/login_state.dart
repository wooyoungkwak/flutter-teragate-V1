import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:teragate_test/services/server_service.dart';
import 'package:teragate_test/services/permission_service.dart';
import 'package:teragate_test/utils/alarm_util.dart';
import 'package:teragate_test/utils/Log_util.dart';
import 'package:teragate_test/states/dashboard_state.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  late TextEditingController _loginIdContoroller;
  late TextEditingController _passwordContorller;
  bool checkBoxValue = false;
  late bool initcheck;

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
    //Widget 여기서 UI화면 작성
    return _createWillPopScope(_initScaffoldByMain());
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

  Padding _createPaddingBySementic(double vertical, double horizontal, Widget widget) {
    return Padding(padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal), child: widget);
  }

  Scaffold _initScaffoldByMain() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'), //APP BAR 만들기
        automaticallyImplyLeading: false,
      ),
      //body는 appbar아래 화면을 지정.
      body: _createPadding(
        8.0,
        Form(
          key: _formKey,
          child: Center(
            //가운데로 지정
            child: _createListView(
              <Widget>[
                _createPadding(16.0, _initTextFormField(false, _loginIdContoroller, " 아이디를 입력해 주세요", style, "Id")),
                _createPadding(16.0, _initTextFormField(true, _passwordContorller, " 패스워드를 입력해 주세요", style, "Password")),
                FutureBuilder(
                    future: _setsaveid(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return _createPadding(
                          16.0,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                activeColor: Colors.white,
                                checkColor: Colors.blue,
                                value: checkBoxValue,
                                onChanged: (value) {
                                  setState(() {
                                    checkBoxValue = value!;
                                  });
                                  secureStorage.write(Env.KEY_ID_CHECK, checkBoxValue.toString());
                                },
                              ),
                              const Text('아이디 저장'),
                              Transform.scale(scale: 1.5),
                            ],
                          ),
                        );
                      }
                    }),
                _createPaddingBySementic(
                  0.0,
                  16.0,
                  Material(
                    elevation: 5.0, //그림자효과
                    borderRadius: BorderRadius.circular(30.0), //둥근효과
                    color: Colors.red,
                    child: MaterialButton(
                      //child - 버튼을 생성
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) await _setLogin();
                      },
                      child: Text(
                        "로그인",
                        style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _initTextFormField(bool isObscureText, TextEditingController controller, String message, TextStyle style, String decorationType) {
    return TextFormField(
        obscureText: isObscureText,
        controller: controller,
        validator: (value) => (value!.isEmpty) ? message : null,
        style: style,
        decoration: decorationType == "Id" ? const InputDecoration(prefixIcon: Icon(Icons.person), labelText: "Id", border: OutlineInputBorder()) : const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: "Password", border: OutlineInputBorder()));
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
        secureStorage.write(Env.KEY_ACCESS_TOKEN, '${loginInfo.tokenInfo?.getAccessToken()}');
        secureStorage.write(Env.KEY_REFRESH_TOKEN, '${loginInfo.tokenInfo?.getRefreshToken()}');
        secureStorage.write(Env.KEY_LOGIN_STATE, "true");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Dashboard()));
      } else {
        showSnackBar(context, loginInfo.message!);
      }
    });
  }

  // Future<void> _computeExcuteTest() async {
  //   final respFromOtherIsolate = await compute(sum, [1, 2, 5]);
  //   Log.debug(" *************** result = $respFromOtherIsolate");
  // }

  // Future<int> sum(List<int> params) async {
  //   return params.reduce((a, b) => a + b);
  // }

  // Future<void> initIsolate() async {
  //   Isolate.spawn(isolateTest, 1);
  //   Isolate.spawn(isolateTest, 2);
  //   Isolate.spawn(isolateTest, 3);
  // }

  // isolateTest(var m) {
  //   Log.debug(" test = $m");
  // }
}
