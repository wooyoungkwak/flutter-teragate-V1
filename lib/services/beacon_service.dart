import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';

import '../models/beacon_model.dart';

// 비콘 초기화
Future<void> initBeacon(Function setNotification, Function setRunning, Function setResult, Function setGlovalVariable, Function setForGetIn, 
  Function getIsRunning, Function getWorkSucces, StreamController<String> beaconStreamController) async {

  SecureStorage secureStorage = SecureStorage();

  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(
        title: "Need Location Permission",
        message: "This app collects location data to work with beacons."
    );

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      if(Env.isDebug) debugPrint(" ********* Call Method: ${call.method}");

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

  BeaconsPlugin.listenToBeacons(beaconStreamController);

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
      if(Env.isDebug) debugPrint("Error: $error");
    }

  );
    
}

// 비콘 기본 정보 설정
Future<void> setBeacon() async {
  
  /* 
  BeaconsPlugin.addRegion("myBeacon", "01022022-f88f-0000-00ae-9605fd9bb620");
  BeaconsPlugin.addRegion("iBeacon", "12345678-1234-5678-8f0c-720eaf059935");
  */

  await BeaconsPlugin.addRegion("Teraenergy", "12345678-1234-5678-8f0c-720eaf059935");

  BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
  BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
  BeaconsPlugin.setForegroundScanPeriodForAndroid(foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
  BeaconsPlugin.setBackgroundScanPeriodForAndroid(backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);
}

// 비콘 시작
Future<void> startBeacon() async {
  await BeaconsPlugin.startMonitoring();
}

// 비콘 재 시작
Future<void> restartBeacon() async {
  setBeacon();
  await startBeacon();
}

// 비콘 멈춤
Future<void> stopBeacon() async {
  await BeaconsPlugin.stopMonitoring();
}