// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yunxin_meeting/meeting_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await NEMeetingPlugin().getAssetService().loadCustomServer();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Android Platform Images'),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image(
                    image: PlatformImage(
                      key: 'android',
                      quality: 50,
                    ),
                    isAntiAlias: true,
                  ),
                  Image(
                    image: PlatformImage(key: 'android'),
                    width: 24,
                    height: 24,
                  ),
                  Icon(
                    Icons.android,
                  ),
                  Icon(
                    Icons.android,
                    size: 48.0,
                  ),
                  Image(
                    image: PlatformImage(key: 'android'),
                    width: 48.0,
                    height: 48.0,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Text('iOS Platform Images'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image(
                    image: PlatformImage(key: 'iphone'),
                    fit: BoxFit.fill,
                  ),
                  Image(
                    image: PlatformImage(key: "iphone"),
                    width: 24,
                    height: 24,
                    fit: BoxFit.fill,
                  ),
                  Image(
                    image: PlatformImage(key: 'iphone'),
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
