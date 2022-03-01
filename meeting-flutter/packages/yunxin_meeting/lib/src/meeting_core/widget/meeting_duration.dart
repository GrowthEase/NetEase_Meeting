// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingDuration extends StatefulWidget {
  final int startMilliseconds;

  MeetingDuration(this.startMilliseconds);

  @override
  State<StatefulWidget> createState() {
    return _MeetingDurationState();
  }
}

class _MeetingDurationState extends State<MeetingDuration> {
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;

  late int startMilliseconds;

  late int elapsed;

  @override
  void initState() {
    super.initState();
    startMilliseconds = widget.startMilliseconds;
    elapsed = startMilliseconds;
    stopwatch.start();
    timer = Timer.periodic(Duration(seconds: 1), updateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(transfer(elapsed),
        key: MeetingCoreValueKey.meetingDuration,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none, fontWeight: FontWeight.w400));
  }

  void updateTime(Timer timer) {
    elapsed = startMilliseconds + stopwatch.elapsedMilliseconds;
    setState(() {});
  }

  String transfer(int elapsed) {
    var hundreds = (elapsed / 10).truncate();
    var seconds = (hundreds / 100).truncate();
    var minutes = (seconds / 60).truncate();
    var hour = (minutes / 60).truncate();

    var minutesStr = (minutes % 60).toString().padLeft(2, '0');
    var secondsStr = (seconds % 60).toString().padLeft(2, '0');
    if (hour > 0) {
      var hourStr = hour.toString().padLeft(2, '0');
      return '$hourStr:$minutesStr:$secondsStr';
    }else{
      return '$minutesStr:$secondsStr';
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
