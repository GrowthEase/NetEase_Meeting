// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlMessageListener {

  static final ControlMessageListener _instance = ControlMessageListener._();

  factory ControlMessageListener() => _instance;

  ControlMessageListener._();

  final StreamController<ControlActionData> _controlStreamController = StreamController<ControlActionData>.broadcast();

  Stream<ControlActionData> get controlMessageStream => _controlStreamController.stream;

  StreamSubscription? serverControlStreamSubscription;

  void init() {
    serverControlStreamSubscription?.cancel();
    serverControlStreamSubscription = InRoomRepository.onServerControlReceived.listen((MeetingAction model) {
      if (model is! TCAction) {
        return;
      }

      var meetingAction = ControlActionFactory.buildAction(model);

      if(meetingAction is ControlActionData){
        if(meetingAction is! TCUnBindResultAction && DeviceInfo.deviceId != meetingAction.controllerDeviceId){
          return;
        }
      }
      _controlStreamController.add(meetingAction as ControlActionData);
    });
  }
}
