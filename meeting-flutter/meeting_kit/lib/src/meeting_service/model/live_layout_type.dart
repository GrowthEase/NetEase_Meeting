// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class LiveLayoutType {
  static const int none = 0;
  static const int gallery = 1;
  static const int focus = 2;
  static const int screenShare = 3;

  static bool isGallery(int type) {
    return type == gallery;
  }
}
