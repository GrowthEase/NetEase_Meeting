// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import Flutter

@objcMembers
public class CheckIpadServer: NSObject {
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "isIPad" {
      result(UIDevice.current.userInterfaceIdiom == .pad)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
