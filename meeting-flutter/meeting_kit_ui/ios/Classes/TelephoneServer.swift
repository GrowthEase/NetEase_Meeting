// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreTelephony
import Flutter
import Foundation

@objcMembers
public class TelephoneServer: NSObject {
  var callCenter: CTCallCenter = .init()
}

extension TelephoneServer: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    events(["isInCall": hasCall()])
    callCenter.callEventHandler = { [weak self] call in
      MeetingUILog.infoLog("TelephoneServer", desc: "callEventHandler")
      if let self = self {
        events(["isInCall": self.hasCall()])
      }
    }
    return nil
  }

  func hasCall() -> Bool {
    let hasCall = callCenter.currentCalls?.contains(where: { $0.callState == CTCallStateConnected || $0.callState == CTCallStateIncoming || $0.callState == CTCallStateDialing }) == true
    MeetingUILog.infoLog("TelephoneServer", desc: "hasCall: \(hasCall)")
    return hasCall
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    callCenter.callEventHandler = nil
    return nil
  }
}
