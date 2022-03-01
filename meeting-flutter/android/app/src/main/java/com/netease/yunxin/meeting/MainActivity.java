// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.meeting;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.net.Uri;

import com.netease.yunxin.meeting.util.FileProviderUtil;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.security.cert.Certificate;
import java.security.cert.CertificateEncodingException;
import java.util.HashSet;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "meeting.meeting.netease.im/cnannel";

    private static final String EVENTS = "meeting.meeting.netease.im/events";

    private BroadcastReceiver linksReceiver;

    private String startString;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        Intent intent = getIntent();
        Uri data = intent.getData();
        DartExecutor dartExecutor = flutterEngine.getDartExecutor();
        new MethodChannel(dartExecutor.getBinaryMessenger(), CHANNEL).setMethodCallHandler((call, result) -> {
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
            }
        });
        if (data != null) {
            startString = data.toString();
        }
        new EventChannel(dartExecutor, EVENTS).setStreamHandler(new EventChannel.StreamHandler() {

            @Override
            public void onListen(Object args, final EventChannel.EventSink events) {
                linksReceiver = createChangeReceiver(events);
            }

            @Override
            public void onCancel(Object args) {
                linksReceiver = null;
            }
        });
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
        if (intent.getAction() == android.content.Intent.ACTION_VIEW && linksReceiver != null) {
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
        } catch (IOException e) {
            e.printStackTrace();
        } catch (CertificateEncodingException ee) {
            ee.printStackTrace();
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
            while (is.read(buffer, 0, buffer.length) != -1) {
                ;
            }
            is.close();
            return jarEntry != null ? jarEntry.getCertificates() : null;
        } catch (IOException e) {
            e.printStackTrace();
        } catch (RuntimeException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Set<Signature> getSignature(Context context) {
        Set<Signature> signatures = new HashSet<>();
        if (context != null) {
            try {
                PackageInfo pkgInfo = context.getPackageManager().
                        getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNATURES);
                if (pkgInfo != null) {
                    if (pkgInfo.signatures != null) {
                        for (Signature signature : pkgInfo.signatures) {
                            signatures.add(signature);
                        }
                    }
                }
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        }
        return signatures;
    }

}
