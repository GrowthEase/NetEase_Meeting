// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import AVFoundation

@objcMembers
public class NEMeetingAudioManager: NSObject {
  public func enumAudioDevices() -> [AVAudioSessionPortDescription]? {
    AVAudioSession.sharedInstance().availableInputs
  }

  public func getSelectedAudioDevice() -> AVAudioSessionPortDescription? {
    AVAudioSession.sharedInstance().currentRoute.outputs.first
  }

  public func showAudioDevicePicker() {
    if #available(iOS 11.0, *) {
      let routePickerView = AVRoutePickerView()
      if let routePickerButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
        routePickerButton.sendActions(for: .touchUpInside)
      }
    }
  }
}
