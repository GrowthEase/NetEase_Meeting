// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class CountdownButton extends StatefulWidget {
  final int countdownDuration;
  final String buttonText;
  final VoidCallback onPressed;
  final void Function() closeDialog;

  CountdownButton({
    required this.countdownDuration,
    required this.buttonText,
    required this.onPressed,
    required this.closeDialog,
  });

  @override
  _CountdownButtonState createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  bool _isCountingDown = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdown = widget.countdownDuration;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _isCountingDown = false;
          _timer?.cancel();
          widget.closeDialog();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoDialogAction(
      child: Text(_isCountingDown
          ? '${widget.buttonText}(${_countdown}s)'
          : widget.buttonText),
      onPressed: widget.onPressed,
    );
  }
}
