// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class RoomErrorRepository {
  // static final StreamController<int> _httpApiError =
  //     StreamController.broadcast();
  //ignore: close_sinks
  static final StreamController<int> _nimApiError =
      StreamController.broadcast();

  static void httpApiError(int errorCode) {
    _nimApiError.add(errorCode);
  }

// static void nimApiError(int errorCode) {
//   _nimApiError.add(errorCode);
// }

// static StreamController<int>? _authInfoExpired;

// static Stream<int> get httpApiErrorStream => _httpApiError.stream;
//
// static Stream<int> get nimApiErrorStream => _nimApiError.stream;

// static Stream<int> get authInfoExpiredError {
//   if (_authInfoExpired == null) {
//     _authInfoExpired = StreamController.broadcast();
//     httpApiErrorStream
//         .where((code) => code == MeetingErrorCode.unauthorized)
//         .listen((element) => _authInfoExpired!.add(0));
//     nimApiErrorStream
//         .where((code) => code == MeetingErrorCode.unauthorized)
//         .listen((element) => _authInfoExpired!.add(0));
//   }
//   return _authInfoExpired!.stream;
// }
}
