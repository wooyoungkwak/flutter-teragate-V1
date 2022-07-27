import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';

import '../models/beacon_model.dart';

// 비콘 초기화

final StreamController<String> beaconEventsController = StreamController<String>.broadcast();

Future<void> initBeacon(Function setNotification, Function setRunning, Function setResult, Function setGlovalVariable, Function setForGetIn, Function getIsRunning, Function getWorkSucces, StreamController<String> beaconStreamController) async {
  SecureStorage secureStorage = SecureStorage();

  //리슨투비콘을 최상단으로 올렸음, 해당사항이 변경점임.
  BeaconsPlugin.listenToBeacons(beaconStreamController);

  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(title: "Need Location Permission", message: "This app collects location data to work with beacons.");

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      if (Env.isDebug) debugPrint(" ********* Call Method: ${call.method}");

      if (call.method == 'scannerReady') {
        startBeacon();
        setRunning(true);
      } else if (call.method == 'isPermissionDialogShown') {
        setNotification("Beacon 을 스켄할 수 없습니다. ??? ");
      }
    });
  } else if (Platform.isIOS) {
    startBeacon();
    setRunning(true);
  }

  //Send 'true' to run in background
  await BeaconsPlugin.runInBackground(true);

  //Valid values: 0 = no messages, 1 = errors, 2 = all messages

  beaconStreamController.stream.listen(
      (data) async {
        if (data.isNotEmpty && getIsRunning()) {
          setResult("출근 처리 중입니다", false);

          if (!getWorkSucces()) {
            BeaconsPlugin.stopMonitoring(); //모니터링 종료
            setRunning(!getIsRunning());
            Map<String, dynamic> userMap = jsonDecode(data);
            var iBeacon = BeaconData.fromJson(userMap);
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
              if (true) {
                setForGetIn();
              }

              /*
            else {
              if(Env.isDebug) debugPrint(data.success);
              showConfirmDialog(context, " ${name}님 이미 출근하셨습니다."); //다이얼로그창
              setState(() {
                results.add("msg: ${name}님 이미 출근 하셨습니다");
              });
            } 
            */

            } else {
              setNotification("Key값이 다릅니다. 재시도 해주세요!"); //다이얼로그창
            }
            keySucces = false;
          }
        }
      },
      onDone: () {},
      onError: (error) {
        if (Env.isDebug) debugPrint("Error: $error");
      });
}

// 비콘 시작
Future<void> startBeacon() async {
  await BeaconsPlugin.startMonitoring();
}

// 비콘 멈춤
Future<void> stopBeacon() async {
  await BeaconsPlugin.stopMonitoring();
}
