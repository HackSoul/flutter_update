import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_update/flutter_update.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String downloadId = "";
  Timer timer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String downloadId;
    try {
      downloadId = await FlutterUpdate.downloadApk();
      timer = Timer.periodic(Duration(seconds: 1), (t) {
         FlutterUpdate.progress.then((str) {
           print("result:" + str);
           setState(() {});
         });
      });
    } on PlatformException {
      downloadId = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      downloadId = downloadId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter_Update'),
        ),
        body: Column(
          children: <Widget>[
            Text('$downloadId'),
          ],
        )
      ),
    );
  }
}
