// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import UIKit

@objcMembers
public class NEVolumeListener: NSObject, FlutterStreamHandler {
  private let audioSession: AVAudioSession = .sharedInstance()
  private let notification: NotificationCenter = .default
  private var eventSink: FlutterEventSink?
  private var isObserving: Bool = false
  private let volumeKey: String = "outputVolume"

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    registerVolumeObserver()
    eventSink?(audioSession.outputVolume)

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    removeVolumeObserver()

    return nil
  }

  private func registerVolumeObserver() {
    audioSessionObserver()
    notification.addObserver(
      self,
      selector: #selector(audioSessionObserver),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  func audioSessionObserver() {
    if !isObserving {
      audioSession.addObserver(self,
                               forKeyPath: volumeKey,
                               options: [.new, .old],
                               context: nil)
      isObserving = true
    }
  }

  private func removeVolumeObserver() {
    audioSession.removeObserver(self,
                                forKeyPath: volumeKey)
    notification.removeObserver(self,
                                name: UIApplication.didBecomeActiveNotification,
                                object: nil)
    isObserving = false
  }

  override public func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
    if keyPath == volumeKey {
      /// 会有一次变量初次赋值从0直接到1，需要过滤这次
      if let change = change,
         let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int,
         let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
         oldValue == 0,
         newValue == 1 {
        return
      }
      eventSink?(audioSession.outputVolume)
    }
  }
}
