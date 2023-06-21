// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import Flutter
import CallKit
import YXAlog_iOS

let telephoneServerTag: String = "TelephoneServer"

@objcMembers
public class TelephoneServer: NSObject {
  let callObserver = CXCallObserver()
  var events: FlutterEventSink?

  func startObserving() {
    callObserver.setDelegate(self, queue: nil)
  }

  func stopObserving() {
    callObserver.setDelegate(nil, queue: nil)
  }
}

extension TelephoneServer: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.events = events
    MeetingUILog.infoLog(telephoneServerTag, desc: "\(telephoneServerTag) -> First Listen")
    let call = callObserver.calls.first(where: { isInCall($0) })
    callObserver.calls.forEach {
      MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ \(telephoneServerTag) -> uuid: \($0.uuid). isOutgoing: \($0.isOutgoing). isOnHold: \($0.isOnHold). hasConnected: \($0.hasConnected). hasEnded: \($0.hasEnded)")
    }
    if let call = call {
      MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ \(telephoneServerTag) -> uuid: \(call.uuid). isOutgoing: \(call.isOutgoing). isOnHold: \(call.isOnHold). hasConnected: \(call.hasConnected). hasEnded: \(call.hasEnded)")
    }
    events(["isInCall": call != nil ? true : false])
    startObserving()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopObserving()
    return nil
  }
}

extension TelephoneServer: CXCallObserverDelegate {
  public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
    MeetingUILog.infoLog(telephoneServerTag, desc: "☎️ \(telephoneServerTag) -> callObserver -> uuid: \(call.uuid). isOutgoing: \(call.isOutgoing). isOnHold: \(call.isOnHold). hasConnected: \(call.hasConnected). hasEnded: \(call.hasEnded)")
    events?(["isInCall": isInCall(call)])
  }

  func isInCall(_ call: CXCall) -> Bool {
    if call.isOutgoing {
      if call.hasEnded { return false }
      if call.hasConnected || call.isOnHold { return true }
      return true
    }
    if call.hasEnded { return false }
    if call.hasConnected || call.isOnHold { return true }
    return true
  }
}
