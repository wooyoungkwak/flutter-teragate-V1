import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/utils/Log_util.dart';
import 'package:teragate_test/utils/time_util.dart';

import '../models/beacon_model.dart';

// 비콘 초기화
Future<void> initBeacon(Function _showNotification, Function _hideProgressDialog, Function setForGetInOut, StreamController beaconStreamController, SecureStorage secureStorage) async {

  int index = 0;  
  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(title: "Need Location Permission", message: "This app collects location data to work with beacons.");

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      Log.log(" ********* Call Method: ${call.method}");

      if (call.method == 'scannerReady') {
        await _setBeacon();
        await startBeacon();
      } else if (call.method == 'isPermissionDialogShown') {
        _hideProgressDialog();
        _showNotification("Beacon 을 검색 할 수 없습니다. 권한을 확인 하세요.");
      }
    });

  } else if (Platform.isIOS) {
    BeaconsPlugin.setDebugLevel(2);
    Future.delayed(const Duration(milliseconds: 3000), () async {
      _setBeacon();
      await startBeacon();
    }); //Send 'true' to run in background

    Future.delayed(const Duration(milliseconds: 3000), () async {
      await BeaconsPlugin.runInBackground(true);
    }); //Send 'true' to run in background
  }

  BeaconsPlugin.listenToBeacons(beaconStreamController);

  // beaconStreamController.stream.first.then((data) async {
  //   if (data.isNotEmpty) {
  //     String? uuid = await secureStorage.read(Env.KEY_SETTING_UUID);
  //     uuid = uuid!.toUpperCase();
      
  //     Map<String, dynamic> userMap = jsonDecode(data);
  //     var iBeacon = BeaconData.fromJson(userMap);

  //     if (iBeacon.uuid.toUpperCase() != uuid) {
  //       _showNotification(Env.MSG_MINOR_FAIL);
  //       return;
  //     }

  //     String beaconKey = iBeacon.minor;

  //     if (beaconKey != getMinorToDate()) {
  //       _showNotification(Env.MSG_MINOR_FAIL);
  //     } else {
  //       setForGetInOut();
  //     }

  //     BeaconsPlugin.stopMonitoring();
  //   } else {
  //     BeaconsPlugin.stopMonitoring();
  //   }
  // });

  beaconStreamController.stream.listen((event) {
    if (event.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(event);
      var iBeacon = BeaconData.fromJson(userMap);
      index ++;
      Log.debug(" (index = $index) **************** ${iBeacon.uuid}");
    }
  });

}

Future<void> _setBeacon() async {
  await BeaconsPlugin.addRegion("iBeacon", Env.UUID_DEFAULT);
  if (Platform.isAndroid) {
    BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
    BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.setForegroundScanPeriodForAndroid(foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
    BeaconsPlugin.setBackgroundScanPeriodForAndroid(backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);
  }
}

// 비콘 시작
Future<void> startBeacon() async {
  await BeaconsPlugin.startMonitoring();
}

// 비콘 멈춤
Future<void> stopBeacon() async {
  await BeaconsPlugin.stopMonitoring();
}
