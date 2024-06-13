// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/repo/i_repo.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_core/meeting_kit.dart';

class HistoryRepo extends IRepo {
  HistoryRepo._internal();

  static final HistoryRepo _singleton = HistoryRepo._internal();

  factory HistoryRepo() => _singleton;

  Future<NEResult<List<NERemoteHistoryMeeting>>> getAllHistoryMeetings(
      [int? startId]) {
    return NEMeetingKit.instance
        .getPreMeetingService()
        .getHistoryMeetingList(startId ?? 0, 20);
  }

  Future<NEResult<NERemoteHistoryMeeting>> getHistoryMeetingDetailsByMeetingId(
      int meetingId) {
    return NEMeetingKit.instance
        .getPreMeetingService()
        .getHistoryMeeting(meetingId);
  }

  Future<NEResult<List<NERemoteHistoryMeeting>>> getFavoriteMeetings(
      {int? startId}) async {
    final result = await NEMeetingKit.instance
        .getPreMeetingService()
        .getFavoriteMeetingList(startId ?? 0, 20);
    return result;
  }

  Future<NEResult<int>> favoriteMeeting(int meetingId) async {
    return NEMeetingKit.instance
        .getPreMeetingService()
        .addFavoriteMeeting(meetingId);
  }

  Future<NEResult<void>> cancelFavoriteByRoomArchiveId(
      int roomArchiveId) async {
    return NEMeetingKit.instance
        .getPreMeetingService()
        .removeFavoriteMeeting(roomArchiveId);
  }

  Future<NEResult<NERemoteHistoryMeetingDetail>> getHistoryMeetingDetail(
      int roomArchiveId) async {
    return NEMeetingKit.instance
        .getPreMeetingService()
        .getHistoryMeetingDetail(roomArchiveId);
  }
}
