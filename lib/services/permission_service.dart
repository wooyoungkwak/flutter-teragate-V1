import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'package:teragate_test/config/env.dart';

 callPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetooth,
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse
  ].request();

  if (statuses.values.every((element) => element.isGranted)) {
    if (Env.isDebug) debugPrint('권한획득');
    return 'success';
  } 

  if (Env.isDebug) debugPrint('권한거절');

  AppSettings.openAppSettings();
  return 'failed';
} 
