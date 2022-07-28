import 'package:flutter/material.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';


class SettingBeacon extends StatefulWidget {
  final String uuiddata;
  const SettingBeacon(this.uuiddata, Key? key) : super(key: key);

  @override
  SettingBeaconState createState() => SettingBeaconState();
}

class SettingBeaconState extends State<SettingBeacon> {

  late SecureStorage secureStorage;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    
    secureStorage = SecureStorage();
  }

  @override
  Widget build(BuildContext context) {
    //테스트용 임시 데이터
    final List<String> entries = <String>['UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321','UUID: 123456789-123456-456879-123456789', 'UUID: 987654321-654321-987654-987654321',];
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                onTap: () =>setuuid(entries[index]),
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
  void setuuid(String index) async{
    secureStorage.write(Env.KEY_UUID, index);
    Navigator.pop(context);
  }
}