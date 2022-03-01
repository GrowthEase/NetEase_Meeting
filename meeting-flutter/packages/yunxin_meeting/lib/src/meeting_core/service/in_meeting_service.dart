// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

mixin InMeetingDataServiceCallback {
  NEMeetingInfo? getCurrentMeetingInfo();
}

abstract class AudioManager {
  /// 订阅会议内某一音频流
  ///
  /// * [accountId] 订阅或者取消订阅的id
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<void>> subscribeRemoteAudioStream(String accountId, bool subscribe);

  /// 批量订阅会议内音频流
  ///
  /// * [accountIds] 订阅或者取消订阅的id列表
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<List<String>>> subscribeRemoteAudioStreams(List<String> accountIds, bool subscribe);

  /// 订阅会议内全部音频流
  ///
  /// * [subscribe] true：订阅， false：取消订阅
  Future<NEResult<void>> subscribeAllRemoteAudioStreams(bool subscribe);

  /// 开启音频dump
  Future<NEResult<void>> startAudioDump();

  /// 关闭音频dump
  Future<NEResult<void>> stopAudioDump();
}

class InMeetingService {
  static final InMeetingService _instance = InMeetingService._();

  factory InMeetingService() => _instance;

  InMeetingService._();

  final StreamController<NEHistoryMeetingItem> _historyMeetingItemStream = StreamController.broadcast();

  InMeetingDataServiceCallback? _serviceCallback;
  
  AudioManager? _audioDelegate;

  AudioManager? get audioManager => _audioDelegate;

  void _updateHistoryMeetingItem(NEHistoryMeetingItem? item) {
    if (item != null) {
      _historyMeetingItemStream.add(item);
    }
  }

  Stream<NEHistoryMeetingItem> get historyMeetingItemStream => _historyMeetingItemStream.stream;

  NEMeetingInfo? get currentMeetingInfo {
    return _serviceCallback != null
        ? _serviceCallback!.getCurrentMeetingInfo()
        : null;
  }
}
