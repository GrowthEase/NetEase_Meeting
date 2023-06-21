// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import Flutter
import YXAlog_iOS

let lifecycleServerTag = "LifecycleServer"

@objcMembers
public class LifecycleServer: NSObject {
  var events: FlutterEventSink?
}

extension LifecycleServer: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.events = events
    MeetingUILog.infoLog(lifecycleServerTag, desc: "\(lifecycleServerTag) -> First Listen")
    NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    return nil
  }

  @objc func didEnterBackground() {
    MeetingUILog.infoLog(lifecycleServerTag, desc: "\(lifecycleServerTag) -> enter background")
    events?(["isInBackground": true])
  }

  @objc func willEnterForeground() {
    MeetingUILog.infoLog(lifecycleServerTag, desc: "\(lifecycleServerTag) -> will enter foreground")
    events?(["isInBackground": false])
  }
}
