// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.meeting;

import android.app.PictureInPictureParams;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.util.Rational;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.splashscreen.SplashScreen;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import com.netease.yunxin.meeting.util.FileProviderUtil;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.security.cert.Certificate;
import java.security.cert.CertificateEncodingException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

public class MainActivity extends FlutterActivity {

  private static final String TAG = "MeetingMainActivity";

  private static final String CHANNEL = "meeting.meeting.netease.im/cnannel";

  private static final String EVENTS = "meeting.meeting.netease.im/events";

  private static final String[] fixPlugins =
      new String[] {
        "com.crazecoder.openfile.OpenFilePlugin", // Fix NullPointerException
      };

  private BroadcastReceiver linksReceiver;

  private String startString;
  private int meetingStatus = 0;

  // 最小化状态
  private final int inMeetingMinimized = 4;

  @Nullable
  @Override
  public FlutterEngine provideFlutterEngine(@NonNull Context context) {
    return MeetingApplication.getApplication().getEngine();
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    Intent intent = getIntent();
    Uri data = intent.getData();
    DartExecutor dartExecutor = flutterEngine.getDartExecutor();
    new MethodChannel(dartExecutor.getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
            (call, result) -> {
              if (call.method.equals("initialLink")) {
                if (startString != null) {
                  result.success(startString);
                  startString = null;
                } else {
                  result.success("");
                }
              } else if (call.method.equals("apkDownloadOk")) {
                String filePath = call.argument("filePath");
                installApk(filePath, result);
              } else if (call.method.equals("notifyMeetingStatusChanged")) {
                meetingStatus = call.argument("meetingStatus");
              }
            });
    if (data != null) {
      startString = data.toString();
    }
    new EventChannel(dartExecutor, EVENTS)
        .setStreamHandler(
            new EventChannel.StreamHandler() {

              @Override
              public void onListen(Object args, final EventChannel.EventSink events) {
                linksReceiver = createChangeReceiver(events);
              }

              @Override
              public void onCancel(Object args) {
                linksReceiver = null;
              }
            });
    addPlugins(flutterEngine);
  }

  private void notifyResult(MethodChannel.Result result, int code, String msg) {
    notifyResult(result, code, msg, null);
  }

  private void notifyResult(MethodChannel.Result result, int code, String msg, Object data) {
    try {
      Map<String, Object> map = new HashMap<>(4);
      map.put("code", code);
      map.put("msg", msg);
      map.put("data", data);
      result.success(map);
    } catch (Throwable throwable) {
      throwable.printStackTrace();
    }
  }

  @Override
  public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    removePlugins(flutterEngine);
    super.cleanUpFlutterEngine(flutterEngine);
  }

  private BroadcastReceiver createChangeReceiver(final EventChannel.EventSink events) {
    return new BroadcastReceiver() {

      @Override
      public void onReceive(Context context, Intent intent) {
        // NOTE: assuming intent.getAction() is Intent.ACTION_VIEW
        String dataString = intent.getDataString();
        if (dataString == null) {
          events.success("");
        } else {
          events.success(dataString);
        }
      }
    };
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    if (android.content.Intent.ACTION_VIEW.equals(intent.getAction()) && linksReceiver != null) {
      linksReceiver.onReceive(this.getApplicationContext(), intent);
    }
  }

  private void installApk(String filePath, MethodChannel.Result result) {
    if (filePath == null) {
      result.success(-1);
      return;
    }
    File file = new File(filePath);
    if (!file.exists()) {
      result.success(-2);
      return;
    }
    if (!checkSignature(this, file)) {
      result.success(-3);
      return;
    }
    Intent intent = new Intent(Intent.ACTION_VIEW);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
    Uri uri = FileProviderUtil.getUriForFile(this, file);
    intent.setDataAndType(uri, "application/vnd.android.package-archive");
    startActivity(intent);
    finish();
  }

  public static boolean checkSignature(Context context, File file) {
    boolean ret = false;
    if (file != null) {
      Set<Signature> signatures = getSignaturesFromApk(file);
      Set<Signature> selfSignatures = getSignature(context);
      for (Signature signature : signatures) {
        for (Signature selfSignature : selfSignatures) {
          if (signature.equals(selfSignature)) {
            ret = true;
            break;
          }
        }
        if (ret) {
          break;
        }
      }
    }
    return ret;
  }

  public static Set<Signature> getSignaturesFromApk(File file) {
    Set<Signature> signatures = new HashSet<>();
    JarFile jarFile = null;
    try {
      jarFile = new JarFile(file);
      JarEntry jarEntry = jarFile.getJarEntry("AndroidManifest.xml");
      Certificate[] certs = loadCertificates(jarFile, jarEntry, new byte[8192]);
      if (certs != null) {
        for (Certificate cert : certs) {
          if (cert != null) {
            signatures.add(new Signature(cert.getEncoded()));
          }
        }
      }
    } catch (IOException | CertificateEncodingException e) {
      e.printStackTrace();
    } finally {
      if (jarFile != null) {
        try {
          jarFile.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }
    return signatures;
  }

  private static Certificate[] loadCertificates(JarFile jarFile, JarEntry jarEntry, byte[] buffer) {
    try {
      InputStream is = new BufferedInputStream(jarFile.getInputStream(jarEntry));
      while (is.read(buffer, 0, buffer.length) != -1) {}
      is.close();
      return jarEntry != null ? jarEntry.getCertificates() : null;
    } catch (IOException | RuntimeException e) {
      e.printStackTrace();
    }
    return null;
  }

  public static Set<Signature> getSignature(Context context) {
    Set<Signature> signatures = new HashSet<>();
    if (context != null) {
      try {
        PackageInfo pkgInfo =
            context
                .getPackageManager()
                .getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNATURES);
        if (pkgInfo != null) {
          if (pkgInfo.signatures != null) {
            signatures.addAll(Arrays.asList(pkgInfo.signatures));
          }
        }
      } catch (PackageManager.NameNotFoundException e) {
        e.printStackTrace();
      }
    }
    return signatures;
  }

  @Override
  public void onCreate(Bundle savedInstanceState) {
    SplashScreen splashScreen = SplashScreen.installSplashScreen(this);
    super.onCreate(savedInstanceState);
    Log.i(TAG, "onCreate@" + hashCode());
    WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
    WindowInsetsControllerCompat insetsController =
        WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
    if (insetsController != null) {
      insetsController.setAppearanceLightNavigationBars(true);
      insetsController.setAppearanceLightStatusBars(true);
    }
    getWindow().setStatusBarColor(getResources().getColor(android.R.color.transparent));
    getWindow().setNavigationBarColor(getResources().getColor(android.R.color.transparent));
    splashScreen.setKeepOnScreenCondition(() -> !isFlutterUIReady);
  }

  private static volatile boolean isFlutterUIReady = false;

  @Override
  public void onFlutterUiDisplayed() {
    Log.i(TAG, "onFlutterUiDisplayed");
    super.onFlutterUiDisplayed();
    isFlutterUIReady = true;
  }

  @Override
  public void onFlutterUiNoLongerDisplayed() {
    Log.i(TAG, "onFlutterUiNoLongerDisplayed");
    super.onFlutterUiNoLongerDisplayed();
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    Log.i(TAG, "onDestroy@" + hashCode());
  }

  private void addPlugins(@NonNull FlutterEngine flutterEngine) {
    try {
      for (String fixPlugin : fixPlugins) {
        Class<?> clazz = Class.forName(fixPlugin);
        flutterEngine.getPlugins().add((FlutterPlugin) clazz.newInstance());
      }
    } catch (Throwable e) {
      e.printStackTrace();
    }
  }

  private void removePlugins(@NonNull FlutterEngine flutterEngine) {
    try {
      for (String fixPlugin : fixPlugins) {
        Class<?> clazz = Class.forName(fixPlugin);
        flutterEngine.getPlugins().remove((Class<? extends FlutterPlugin>) clazz);
      }
    } catch (Throwable e) {
      e.printStackTrace();
    }
  }
  // 实现点击 Home 键进入 PiP
  @RequiresApi(Build.VERSION_CODES.O)
  public void onUserLeaveHint() {
    super.onUserLeaveHint();
    //    FloatingService.enablePip(null, this);
    pip();
  }

  @Override
  public void onBackPressed() {
    super.onBackPressed();
    //    pip();
  }

  private void pip() {
    if (meetingStatus != inMeetingMinimized) return;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      PictureInPictureParams.Builder builder =
          new PictureInPictureParams.Builder().setAspectRatio(new Rational(9, 16));

      enterPictureInPictureMode(builder.build());
    }
  }
}
