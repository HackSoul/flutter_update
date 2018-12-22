package com.wedoview.gyc.flutterupdate;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.Toast;

public class ApkInstallReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if(intent.getAction().equals(DownloadManager.ACTION_DOWNLOAD_COMPLETE)){
            System.out.println("下载完成");
            long downloadApkId =intent.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1);
            System.out.println("downloadApkId:" + downloadApkId);

            installApk(context, downloadApkId);
        }
    }

    /**
     * 安装apk
     */
    private void installApk(Context context,long downloadApkId) {
        DownloadManager downManager= (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
        Uri downloadFileUri = downManager.getUriForDownloadedFile(downloadApkId);
        if (downloadFileUri != null) {
            Intent install= new Intent(Intent.ACTION_VIEW);
            install.setDataAndType(downloadFileUri, "application/vnd.android.package-archive");
            install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(install);
        }else{
            Toast.makeText(context, "下载失败", Toast.LENGTH_SHORT).show();
        }
    }
}
