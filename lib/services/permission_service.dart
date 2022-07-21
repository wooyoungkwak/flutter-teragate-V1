import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

Future<String> callPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetooth,
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse
  ].request();

  if (statuses.values.every((element) => element.isGranted)) {
    return 'permission success';
  } 

  AppSettings.openAppSettings();
  return 'permission failed';
} 
