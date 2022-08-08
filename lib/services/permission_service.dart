import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> callPermissions() async {

  List<Permission> permissions = [
    Permission.location
  ];

  if (Platform.isAndroid) {
    permissions.add(Permission.bluetoothScan);
    permissions.add(Permission.bluetoothConnect);
    permissions.add(Permission.bluetooth);
    permissions.add(Permission.locationAlways);
    permissions.add(Permission.locationWhenInUse);
  }

  Map<Permission, PermissionStatus> statuses = await permissions.request();

  if (statuses.values.every((element) => element.isGranted)) {
    return 'permission success';
  } 

  AppSettings.openAppSettings();
  return 'permission failed';
} 
