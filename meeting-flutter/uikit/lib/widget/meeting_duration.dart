// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MeetingDuration extends StatefulWidget {
  final int start;

  MeetingDuration(this.start);

  @override
  State<StatefulWidget> createState() {
    return MeetingDurationState();
  }
}

class MeetingDurationState extends State<MeetingDuration> {
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;

  late int startMilliseconds;

  late int elapsed;

  @override
  void initState() {
    super.initState();
    startMilliseconds = widget.start * 1000;
    elapsed = startMilliseconds;
    stopwatch.start();
    timer = Timer.periodic(new Duration(seconds: 1), updateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(transfer(elapsed),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none));
  }

  void updateTime(Timer timer) {
    elapsed = startMilliseconds + stopwatch.elapsedMilliseconds;
    setState(() {});
  }

  String transfer(int elapsed) {
    int hundreds = (elapsed / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hour = (minutes / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    if (hour > 0) {
      String hourStr = hour.toString().padLeft(2, '0');
      return "$hourStr:$minutesStr:$secondsStr";
    }else{
      return "$minutesStr:$secondsStr";
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
