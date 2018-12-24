import 'dart:async';

import 'package:flutter/services.dart';

class FlutterUpdate {
  static const MethodChannel _channel =
      const MethodChannel('flutter_update');

  static Future<String> downloadApk() async {
    final String version = await _channel.invokeMethod('downloadApk', {
      "url": "http://file.vidovision.com/file/appfile/apk/download"
    });
    return version;
  }

  static Future<String> get progress async {
    return await _channel.invokeMethod("getProgress");
  }

  static Future<String> update() async {
    return await _channel.invokeMethod("update");
  }

  static Future<String> canUpdate() async {
    return await _channel.invokeMethod("canUpdate");
  }
}
