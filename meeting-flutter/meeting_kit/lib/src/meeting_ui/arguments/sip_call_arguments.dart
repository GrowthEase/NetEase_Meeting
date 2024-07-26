// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class SipCallArguments {
  final NERoomContext roomContext;
  final ValueListenable<bool> isMySelfManagerListenable;
  final String? outboundPhoneNumber;

  SipCallArguments(this.roomContext, this.isMySelfManagerListenable,
      this.outboundPhoneNumber);
}
