import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/utils/debug_util.dart';

import '../models/beacon_model.dart';

// 비콘 초기화
Future<void> initBeacon(Function setNotification, Function setRunning, Function setResult, Function setGlovalVariable, Function setForGetIn, Function getIsRunning, Function getWorkSucces, StreamController<String> beaconStreamController) async {

  SecureStorage secureStorage = SecureStorage();
  String uuid = "";
  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(title: "Need Location Permission", message: "This app collects location data to work with beacons.");

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      if (Env.isDebug) Log.debug(" ********* Call Method: ${call.method}");

      if (call.method == 'scannerReady') {
        startBeacon();
        setRunning(true);
      } else if (call.method == 'isPermissionDialogShown') {
        setNotification("Beacon 을 스켄할 수 없습니다. ??? ");
      }
    });

    //리슨투비콘을 최상단으로 올렸음, 해당사항이 변경점임.
    BeaconsPlugin.listenToBeacons(beaconStreamController);
  } else if (Platform.isIOS) {
    //리슨투비콘을 최상단으로 올렸음, 해당사항이 변경점임.
    BeaconsPlugin.listenToBeacons(beaconStreamController);

    // startBeacon();
    setRunning(true);
  }

  //Send 'true' to run in background
  await BeaconsPlugin.runInBackground(true);

  //Valid values: 0 = no messages, 1 = errors, 2 = all messages
  beaconStreamController.stream.listen((data) async {

        if (data.isNotEmpty && getIsRunning()) {
          setResult("출근 처리 중입니다.", false);

          if (!getWorkSucces()) {

            BeaconsPlugin.stopMonitoring(); //모니터링 종료
            setRunning(!getIsRunning());
            Map<String, dynamic> userMap = jsonDecode(data);
            var iBeacon = BeaconData.fromJson(userMap);

            if ( iBeacon.uuid != uuid  ) {
              return;
            }

            String beaconKey = iBeacon.minor; // 비콘의 key 값
            bool keySucces = false; // key 일치여부 확인

            String dbKey = '50000'; //임시로 고정

            String? name = await secureStorage.read('krName');
            String? id = await secureStorage.read('LOGIN_ID');
            String? pw = await secureStorage.read('LOGIN_PW');

            setGlovalVariable(name, id, pw);

            if (beaconKey == dbKey) {
              keySucces = true;
            } else {
              keySucces = false;
            }

            if (keySucces) {
              setForGetIn();
            } else {
              setNotification("Key값이 다릅니다. 재시도 해주세요!"); //다이얼로그창
            }
            keySucces = false;
          }
        }
      },
      onDone: () {},
      onError: (error) {
        if (Env.isDebug) Log.debug("Error: $error");
      });
}

Future<void> setBeacon() async {
  /* 
  BeaconsPlugin.addRegion("myBeacon", "01022022-f88f-0000-00ae-9605fd9bb620");
  BeaconsPlugin.addRegion("iBeacon", "12345678-1234-5678-8f0c-720eaf059935");
  */

  // await BeaconsPlugin.addRegion(
  //     "Teraenergy", "12345678-1234-5678-8f0c-720eaf059935");

  BeaconsPlugin.addBeaconLayoutForAndroid(
      "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
  BeaconsPlugin.addBeaconLayoutForAndroid(
      "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
  BeaconsPlugin.setForegroundScanPeriodForAndroid(
      foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
  BeaconsPlugin.setBackgroundScanPeriodForAndroid(
      backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);

  BeaconsPlugin.addRegionForIOS("74278bdb-b644-4520-8f0c-720eeaffffff", 65504, 46263, "iBeacon");
}

Future<void> initBeaconBySetting() async {
  final StreamController<String> beaconStreamController = StreamController<String>.broadcast();

}

// 비콘 시작
Future<void> startBeacon() async {
  await BeaconsPlugin.startMonitoring();
}

Future<void> restartBeacon() async {
  setBeacon();
  await startBeacon();
}

// 비콘 멈춤
Future<void> stopBeacon() async {
  await BeaconsPlugin.stopMonitoring();
}
