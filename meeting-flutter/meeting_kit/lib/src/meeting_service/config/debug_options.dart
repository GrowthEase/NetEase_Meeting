// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class DebugOptions {
  static final DebugOptions _instance = DebugOptions._();

  factory DebugOptions() => _instance;

  DebugOptions._();

  Map? _options;

  void parseOptions(Map? options) {
    _options = options;
  }

  bool get isDebugMode => kDebugMode || _options?['debugMode'] == 1;
}
