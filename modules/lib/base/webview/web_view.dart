import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../business/account/edit_my_info_view.dart';

class WebView extends StatelessWidget {
  WebView({super.key});

  Map get arguments => Get.arguments ?? {};
  String get title => arguments['title'] ?? '';
  String get url => arguments['url'] ?? 'https://cdn.luminaai.buzz/';

  late final WebViewController webController =
      WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0B12),
      appBar: AppBar(
          leading: InkWell(onTap: Get.back, child: Container(padding: EdgeInsets.all(16), child: Image.asset('$assetsDir/icon_back.png', fit: BoxFit.fill))),
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.transparent),
      body: WebViewWidget(controller: webController),
    );
  }
}
