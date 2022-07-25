import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  // showDialog(
  //     context: context,
  //     barrierDismissible: false, //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
  //         title: Column(
  //           children: const <Widget>[
  //             Text("Dialog Title"),
  //           ],
  //         ), //Dialog Main Title
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Text(text),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("ok"),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     }
  // );

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
  // showDialog(
  //     context: context,
  //     barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             children: <Widget>[
  //               Text(text),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('ok'),
  //             onPressed: () {
  //               okCallback();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('cancel'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //           ),
  //         ],
  //       );
  //     }
  //   );

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
      "your channel id", 
      "your channel name",
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