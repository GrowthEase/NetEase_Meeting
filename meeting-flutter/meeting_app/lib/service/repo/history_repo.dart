// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/service/model/history_meeting.dart';
import 'package:nemeeting/service/repo/i_repo.dart';
import 'package:nemeeting/service/response/result.dart';

class HistoryRepo extends IRepo {
  HistoryRepo._internal();

  static final HistoryRepo _singleton = HistoryRepo._internal();

  factory HistoryRepo() => _singleton;

  Future<Result<List<HistoryMeeting>>> getAllHistoryMeetings(
      [int? startId]) async {
    return appService.getAllHistoryMeetings(startId);
  }

  Future<Result<List<FavoriteMeeting>>> getFavoriteMeetings(
      [int? startId]) async {
    return appService.getFavoriteMeetings(startId);
  }

  Future<Result<int?>> favourteMeeting(int roomArchiveId) async {
    return appService.favouriteMeeting(roomArchiveId);
  }

  Future<Result<void>> cancelFavoriteByFavoriteId(int favoriteId) async {
    return appService.cancelFavoriteMeetingByFavoriteId(favoriteId);
  }

  Future<Result<void>> cancelFavoriteByRoomArchiveId(int roomArchiveId) async {
    return appService.cancelFavoriteMeetingByRoomArchiveId(roomArchiveId);
  }
}
