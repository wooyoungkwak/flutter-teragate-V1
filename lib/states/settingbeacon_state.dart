import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/states/setting_state.dart';


class SettingBeacon extends StatefulWidget {
  final String uuiddata;
  const SettingBeacon(this.uuiddata, Key? key) : super(key: key);

  @override
  SettingBeaconState createState() => SettingBeaconState();
}

class SettingBeaconState extends State<SettingBeacon> {

  
    var flutterSecureStorage = const FlutterSecureStorage();
  var switchListTileValue1 = true;
  var switchListTileValue2 = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    //테스트용 임시 데이터
    final List<String> entries = <String>['UUID: 123456789-123456-456879-123456789', 'UUID: 123456789-123456-456879-123456789', 'UUID: 123456789-123456-456879-123456789',];
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
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
      body: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 30),
            itemCount: entries.length,
            separatorBuilder: (BuildContext context, int index) =>
            	const Divider(thickness: 3),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () =>Setuuid(index),
                child: Container(height: 50,color:const Color.fromARGB(207, 183, 218, 176),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(entries[index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),], 
                ) 
                )

              );
            })
    );
  }
  void Setuuid(int index) async{
    SharedStorage shared = await SharedStorage();
    shared.write("key", index);
    print(shared.readToInt("key"));
Route route = MaterialPageRoute(builder: (context) => Setting(null));
Navigator.pushReplacement(context, route);
//     Navigator.pop(context);
   
  }
}