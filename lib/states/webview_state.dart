import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/utils/Log_util.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}

class WebViews extends StatefulWidget {
  final String id;
  final String pw;
  const WebViews(this.id, this.pw, Key? key) : super(key: key);

  @override
  WebViewState createState() => WebViewState();
}

class WebViewState extends State<WebViews> {
  String? userPassward = "";
  String addres = Env.SERVER_GROUPWARE_URL;
  Map<String, String> param = {
    "loginId": "asd",
    "password": "qwe",
  };

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  String currentUrl = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    param = {
      "loginId": widget.id,
      "password": widget.pw,
    };

    return Scaffold(
        appBar: AppBar(title: const Text("Groupware Hi5")),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(addres)
                          .replace(queryParameters: param)), //실행 시 첫 접속 url
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    //POST 방식으로 접속
                    //controller.postUrl(url: Uri.parse("http://192.168.0.254:8080/appsignIn"),postData: postData);
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      currentUrl = url.toString();
                      urlController.text = currentUrl;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    Uri url = navigationAction.request.url!;
                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(url.scheme)) {
                      if (await canLaunchUrl(Uri.parse(url.toString()))) {
                        // Launch the App
                        await launchUrl(Uri.parse(url.toString()));
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    await controller.evaluateJavascript(source: """
                        var id = document.getElementById("inputId");
                        var password = document.getElementById("inputPassword");
                        id.value = "${widget.id}";
                        password.value = "${widget.pw}";
                        var form = document.getElementsByClass("login-btn");
                        form.click();
                        """);
                    // form.action(${Env.SERVER_GROUPWARE_URL});
                    // form.method("POST");

                    pullToRefreshController.endRefreshing();
                    setState(() {
                      currentUrl = url.toString();
                      urlController.text = currentUrl;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = "";
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      urlController.text = url.toString();
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    Log.debug(consoleMessage.toString());
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ])));
  }
}
