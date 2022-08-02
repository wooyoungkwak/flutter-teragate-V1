import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teragate_test/config/env.dart';

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
    }
  );
}

void showConfirmDialog(BuildContext context, String title, String text) {
  _showDialog(
    context, 
    title, 
    <Widget>[Text(text)], 
    <Widget>[
      TextButton(
          child: const Text('ok'),
          onPressed: () {
            Navigator.pop(context);
          },
      ),
    ]
  );

}

void showOkCancelDialog(BuildContext context, String title, String text, Function okCallback) {
  _showDialog(
    context, 
    title, 
    <Widget>[Text(text)], 
    <Widget>[
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
    ]
  );
}

Future showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String tag, String subtitle) async {

  int id = 0;
  var androidNotificationDetails = const AndroidNotificationDetails(
      Env.NOTIFICATION_CHANNEL_ID, 
      Env.NOTIFICATION_CHANNEL_NAME,
      ongoing: true,
      importance: Importance.high,
      priority: Priority.high
  );

  var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
  
  var notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
      id, 
      tag, 
      subtitle, 
      notificationDetails,
      payload: 'item x'
  );

}