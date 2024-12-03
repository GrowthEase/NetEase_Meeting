// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class LoadingUtil {
  static void showLoading({bool allowClick = false}) {
    BotToast.showLoading(allowClick: allowClick);
  }

  static void cancelLoading() {
    BotToast.closeAllLoading();
  }
}
