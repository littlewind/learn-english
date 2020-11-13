
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  final String url;

  MyWebView({@required this.url});

  @override
  MyWebViewState createState() => MyWebViewState();
}

class MyWebViewState extends State<MyWebView> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      onPageStarted: (url) => print("page started : $url"),
      onPageFinished: (url) => print('page finished : $url'),
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}