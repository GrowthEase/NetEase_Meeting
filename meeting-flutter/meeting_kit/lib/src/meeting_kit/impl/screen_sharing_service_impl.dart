// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEScreenSharingServiceImpl extends NEScreenSharingService
    with _AloggerMixin, EventTrackMixin {
  static final _NEScreenSharingServiceImpl _instance =
      _NEScreenSharingServiceImpl._();

  factory _NEScreenSharingServiceImpl() => _instance;

  final screenSharing = NEMeetingUIKit.instance.getScreenSharingService();

  _NEScreenSharingServiceImpl._() {}

  @override
  Future<NEResult<String>> startScreenShare(
    NEScreenSharingParams param,
    NEScreenSharingOptions opts,
  ) async {
    apiLogger.i('startScreenShare');
    return screenSharing.startScreenShare(param, opts);
  }

  @override
  Future<NEResult<void>> stopScreenShare() async {
    apiLogger.i('stopScreenShare');
    return screenSharing.stopScreenShare();
  }

  @override
  void addScreenSharingStatusListener(NEScreenSharingStatusListener listener) {
    apiLogger.i('addScreenSharingStatusListener');
    screenSharing.addScreenSharingStatusListener(listener);
  }

  @override
  void removeScreenSharingStatusListener(
      NEScreenSharingStatusListener listener) {
    apiLogger.i('removeScreenSharingStatusListener');
    screenSharing.removeScreenSharingStatusListener(listener);
  }
}
