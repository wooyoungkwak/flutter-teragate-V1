import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/utils/debug_util.dart';


class SettingBeacon extends StatefulWidget {
  final String uuiddata;
  const SettingBeacon(this.uuiddata, Key? key) : super(key: key);

  @override
  SettingBeaconState createState() => SettingBeaconState();
}

class SettingBeaconState extends State<SettingBeacon> {

  late TextEditingController uuidContoroller;
  late SecureStorage secureStorage;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextStyle style = const TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final _formKey = GlobalKey<FormState>();
  late bool initcheck;

  @override
  void initState() {
    super.initState();
    initcheck = true;
    secureStorage = SecureStorage();
  }


  @override
  Widget build(BuildContext context) {
    uuidContoroller = TextEditingController(text: "");
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Log.debug(uuidContoroller.text);
      InputDecoration.collapsed(hintText: uuidContoroller.text);
      secureStorage.write(Env.KEY_UUID, uuidContoroller.text);
      Navigator.of(context).pop();
    },
  ), 
        title: const Text(
          'Beacon Scan', 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
        ),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: 
      WillPopScope(    
      onWillPop: () {
        Log.debug(uuidContoroller.text);
        InputDecoration.collapsed(hintText: uuidContoroller.text);
        secureStorage.write(Env.KEY_UUID, uuidContoroller.text);
        Navigator.of(context).pop();
        return Future(() => false);
      },
      child: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                                 FutureBuilder(
                  future: setuuid(),
                  builder: (context, snapshot) {  
                    if (snapshot.hasData == false) {
                      return const CircularProgressIndicator();
                    }
                  else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); 
                  }
                  else { return 
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: uuidContoroller,
                    validator: (value) => (value!.isEmpty) ? " UUID를 입력해주세요" : null,
                    style: style,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.bluetooth), labelText: "UUID", border: OutlineInputBorder()), //클릭시 legend 효과
                  ),
                );
                }}),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 5.0, 
                    borderRadius: BorderRadius.circular(30.0), 
                    color: Colors.red,
                    child: MaterialButton(
                      onPressed: () {
                          setState(() {
                            Log.debug(Env.INITIAL_UUID);
                            uuidContoroller = TextEditingController(text: Env.INITIAL_UUID);
                            secureStorage.write(Env.KEY_UUID, Env.INITIAL_UUID);
                          });
                      },
                      child: Text(
                        "초기값 세팅",
                        style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                //UUID 가져오기
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0), 
                    color: Colors.red,
                    child: MaterialButton(
                      onPressed: () {
                          setState(() {
                            //기능이 완성되면 이부분 수정해주세요
                            Log.debug("65132132132123");
                            uuidContoroller = TextEditingController(text: "123123123123123123123");
                            secureStorage.write(Env.KEY_UUID,"123123123123123123123");
                          });
                      },
                      child: Text(
                        "UUID 가져오기",
                        style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      )
    );
  }
  
  Future<String>setuuid() async{
    String? saveuuid = await secureStorage.read(Env.KEY_UUID);
    uuidContoroller = TextEditingController(text: saveuuid);
  if(initcheck){
    setState(() {
      uuidContoroller = TextEditingController(text: saveuuid);
      initcheck=false;
      });
  }
  return "re";

}

}