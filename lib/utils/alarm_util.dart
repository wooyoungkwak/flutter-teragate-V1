import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/utils/debug_util.dart';

void showToast(String text) {
  Fluttertoast.showToast(
    fontSize: 13,
    msg: '   $text   ',
    backgroundColor: Colors.black,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.grey[400],
  ));
}

void _showDialog(BuildContext context, String title, var contentWigets, var actions) {
  showDialog(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: contentWigets,
            ),
          ),
          actions: actions,
        );
      });
}

void showConfirmDialog(BuildContext context, String title, String text) {
  _showDialog(context, title, <Widget>[
    Text(text)
  ], <Widget>[
    TextButton(
      child: const Text('ok'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ]);
}

void showOkCancelDialog(BuildContext context, String title, String text, Function okCallback) {
  _showDialog(context, title, <Widget>[
    Text(text)
  ], <Widget>[
    TextButton(
      child: const Text('ok'),
      onPressed: () {
        okCallback();
      },
    ),
    TextButton(
      child: const Text('cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ]);
}

//노티알람 종류 선택, iOS같은 경우에는 사운드랑 진동이 하나로 묶여있다...
Future<void> selectNotiType(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String tag, String subtitle) async {
  late SecureStorage strage = SecureStorage();

  String? soundCheck = await strage.read(Env.KEY_SETTING_ALARM);
  String? vibCheck = await strage.read(Env.KEY_SETTING_VIBRATE);

  //초기설정은 null값이니 ture 로 변환해서 실행해줘야 한다.

  if (Env.isDebug) Log.debug("============= 설정값들 : ${soundCheck} , ${vibCheck}");

  if (soundCheck == 'true' && vibCheck == 'true') {
    //사운드 / 진동 둘다 체크되어있는 정상상태일 경우
    if (Env.isDebug) Log.debug("============= 정상노티");
    showNotification(flutterLocalNotificationsPlugin, tag, subtitle);
  } else if (soundCheck == 'true' && vibCheck == 'false') {
    //사운드만 체크되어있는 경우
    if (Env.isDebug) Log.debug("============= 사운드만");

    showNotificationWithNoVibration(flutterLocalNotificationsPlugin, tag, subtitle);
  } else if (soundCheck == 'false' && vibCheck == 'true') {
    //진동만 체크되어있는 경우
    if (Env.isDebug) Log.debug("============= 진동만");
    showNotificationWithNoSound(flutterLocalNotificationsPlugin, tag, subtitle);
  } else {
    //진동 , 소리 둘다 안되있는경우
    if (Env.isDebug) Log.debug("============= 걍 다없는거");
    showNotificationWithNoOptions(flutterLocalNotificationsPlugin, tag, subtitle);
  }
}

//일반 알람(진동 , 소리 둘다 켜져있을때)
Future showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag,
    String subtitle) async {
  int id = 0;
  var androidNotificationDetails = const AndroidNotificationDetails(
      Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      ongoing: true, importance: Importance.high, priority: Priority.high);

  var iOSPlatformChannelSpecifics = const IOSNotificationDetails();

  var notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iOSPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(id, tag, subtitle, notificationDetails, payload: 'item x');
}

//----------------------------------------------------------------------------//

//소리없는 알람(진동만 켜져있을때)
Future<void> showNotificationWithNoSound(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String tag,
    String subtitle) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      playSound: false, styleInformation: DefaultStyleInformation(true, true));

  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentSound: false);

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(0, "소리없는거", subtitle, platformChannelSpecifics,
      payload: 'item x');
}

//진동없는 알람(소리만 켜져있을때)
Future<void> showNotificationWithNoVibration(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String tag,
    String subtitle) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      enableVibration: false,
      enableLights: true,
      ongoing: true,
      importance: Importance.high,
      priority: Priority.high);

  const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(0, "진동없는거", subtitle, platformChannelSpecifics,
      payload: 'item x');
}

//진동, 소리없는 노티피케이션
Future<void> showNotificationWithNoOptions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String tag,
    String subtitle) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Env.NOTIFICATION_CHANNEL_ID, Env.NOTIFICATION_CHANNEL_NAME,
      enableVibration: false,
      enableLights: true,
      ongoing: true,
      importance: Importance.high,
      priority: Priority.high);

  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentSound: false);

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, "다없는거", subtitle, platformChannelSpecifics,
      payload: 'item x');
}
