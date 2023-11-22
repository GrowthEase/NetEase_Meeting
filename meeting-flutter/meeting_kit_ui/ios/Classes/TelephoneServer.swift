// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreTelephony
import Flutter
import Foundation
import YXAlog_iOS

let telephoneServerTag: String = "TelephoneServer"

@objcMembers
public class TelephoneServer: NSObject {
  var callCenter: CTCallCenter = .init()
}

extension TelephoneServer: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let set = callCenter.currentCalls?.filter { $0.callState == CTCallStateConnected || $0.callState == CTCallStateIncoming || $0.callState == CTCallStateDialing }
    if let set = set {
      MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ CurrentCalls -> Call in progress.")
      set.forEach { call in
        MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ CallID: \(call.callID). CallState: \(call.callState)")
      }
    } else {
      MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ CurrentCalls -> Call not made.")
    }
    events(["isInCall": false])
    callCenter.callEventHandler = { call in
      MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ Call callback -> CallID: \(call.callID) -> CallState: \(call.callState)")
      switch call.callState {
      case CTCallStateConnected, CTCallStateIncoming, CTCallStateDialing:
        events(["isInCall": true])
      default:
        events(["isInCall": false])
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    callCenter.callEventHandler = nil
    return nil
  }
}
