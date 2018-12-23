package com.wedoview.gyc.flutterupdate;

import android.app.DownloadManager;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.Context.DOWNLOAD_SERVICE;

public class FlutterUpdatePlugin implements MethodCallHandler {
  private DownloadManager manager;
  private long downId;

  private FlutterUpdatePlugin(Registrar registrar) {
    this.manager = (DownloadManager) registrar.activeContext().getSystemService(DOWNLOAD_SERVICE);
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_update");
    channel.setMethodCallHandler(new FlutterUpdatePlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("downloadApk")) {
      String url = call.argument("url");
      System.out.println("url:" + url);
      DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
      request.setTitle("邻里社区");
      request.setDescription("软件更新");
      request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE | DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
      File saveFile = new File(Environment.getExternalStorageDirectory(), "community.apk");
      request.setDestinationUri(Uri.fromFile(saveFile));
      long downloadId = manager.enqueue(request);
      this.downId = downloadId;
      result.success("downloadId: " + downloadId);
    } else if (call.method.equals("getProgress")) {
      DownloadManager.Query query = new DownloadManager.Query();
      query.setFilterById(downId);
      Cursor cursor = manager.query(query);
      if (!cursor.moveToFirst()) {
        cursor.close();
        result.success("{}");
        return;
      }
      long downloadedSoFar = cursor.getLong(cursor.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
      long totalSize = cursor.getLong(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
      JSONObject json = new JSONObject();
      try {
        json.put("soFar", downloadedSoFar);
        json.put("totalSize", totalSize);
      } catch (JSONException e) {
        e.printStackTrace();
      }
      result.success(json.toString());
    } else {
      result.notImplemented();
    }
  }
}
