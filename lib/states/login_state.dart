// ignore: unused_import
import 'dart:developer';
// ignore: unused_import
import 'dart:convert';
// ignore: unused_import
import 'dart:async';
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:teragate_test/services/login_service.dart';
import 'package:teragate_test/config/permission.dart';
import 'package:teragate_test/utils/alarm_util.dart';

import 'beacon_state.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  late TextEditingController _loginIdContoroller;
  late TextEditingController _passwordContorller;

  final flutterSecureStorage = const FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    callPermissions();
    _loginIdContoroller = TextEditingController(text: "");
    _passwordContorller = TextEditingController(text: "");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'), //APP BAR 만들기
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        //body는 appbar아래 화면을 지정.
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Center(
            //가운데로 지정
            child: ListView(
              //ListView - children으로 여러개 padding설정
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    //TextFormField
                    controller: _loginIdContoroller,
                    validator: (value) => (value!.isEmpty) ? " 아이디를 입력해 주세요" : null, //hint 역할
                    style: style,
                    decoration: const InputDecoration(
                        //textfield안에 있는 이미지
                        prefixIcon: Icon(Icons.person),
                        labelText: "Id", //hint
                        border: OutlineInputBorder()), //클릭시 legend 효과
                  ),
                ),
                Padding(
                  //두번째 padding <- LIstview에 속함.
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: _passwordContorller,
                    validator: (value) => (value!.isEmpty) ? "패스워드를 입력해 주세요" : null, //아무것도 누르지 않은 경우 이 글자 뜸.
                    style: style,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Password",
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  //세번째 padding
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0, //그림자효과
                    borderRadius: BorderRadius.circular(30.0), //둥근효과
                    color: Colors.red,
                    child: MaterialButton(
                      //child - 버튼을 생성
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginCheck(_loginIdContoroller.text,_passwordContorller.text).then((data) {
                            if (data.success) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Beacon()));
                            } else {
                              showSnackBar(context, data.message);
                            }
                          });
                        }
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
}
