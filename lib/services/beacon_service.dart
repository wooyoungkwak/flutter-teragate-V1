import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/utils/debug_util.dart';
import 'package:teragate_test/utils/time_util.dart';

import '../models/beacon_model.dart';

// 비콘 초기화
Future<void> initBeacon(
    Function setNotification,
    Function setForGetIn,
    StreamController<String> beaconStreamController,
    SecureStorage secureStorage) async {
  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(
        title: "Need Location Permission",
        message: "This app collects location data to work with beacons.");

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      if (Env.isDebug) Log.debug(" ********* Call Method: ${call.method}");

      if (call.method == 'scannerReady') {
        await setBeacon();
        await startBeacon();
      } else if (call.method == 'isPermissionDialogShown') {
        setNotification("Beacon 을 스켄할 수 없습니다. ??? ");
      }
    });
    BeaconsPlugin.listenToBeacons(beaconStreamController);
  } else if (Platform.isIOS) {
    BeaconsPlugin.setDebugLevel(2);
    BeaconsPlugin.listenToBeacons(beaconStreamController);
    await setBeacon();
    await startBeacon();
  }

  //Send 'true' to run in background
  await BeaconsPlugin.runInBackground(true);

  //Valid values: 0 = no messages, 1 = errors, 2 = all messages
  beaconStreamController.stream.listen(
      (data) async {
        if (data.isNotEmpty) {
          Log.debug(
              " =============== beacon Stream Controller listen ==============");
          String? uuid = await secureStorage.read(Env.KEY_UUID);

          // TODO : 임시
          uuid = "74278bdb-b644-4520-8f0c-720eeaffffff";

          Map<String, dynamic> userMap = jsonDecode(data);
          var iBeacon = BeaconData.fromJson(userMap);

          Log.debug(iBeacon.uuid);

          if (iBeacon.uuid != uuid) {
            return;
          }

          String beaconKey = iBeacon.minor; // 비콘의 key 값

          Log.debug(" =====> ${getMinorToDate()} : $beaconKey");

          if (beaconKey != getMinorToDate()) {
            setNotification(Env.MSG_MINOR_FAIL); //다이얼로그창
          } else {
            setForGetIn();
          }
          BeaconsPlugin.stopMonitoring(); //모니터링 종료
        }
      },
      onDone: () {},
      onError: (error) {
        if (Env.isDebug) Log.debug("Error: $error");
      });
}

Future<void> setBeacon() async {
  await BeaconsPlugin.addRegion(
      "iBeacon", "74278bdb-b644-4520-8f0c-720eeaffffff");
  if (Platform.isAndroid) {
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
    // BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);
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
