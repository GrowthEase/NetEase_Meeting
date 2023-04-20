// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import Flutter
import CoreTelephony

@objcMembers
public class TelephoneServer: NSObject {
  var callCenter: CTCallCenter = .init()
}

extension TelephoneServer: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let set = callCenter.currentCalls?.filter { $0.callState == CTCallStateConnected || $0.callState == CTCallStateIncoming || $0.callState == CTCallStateDialing }
    events(["isInCall": set != nil ? true : false])
    callCenter.callEventHandler = { call in
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
