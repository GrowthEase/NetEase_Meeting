// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

///算上两个横线的长度
const int meetingIdMinLength = 1;
const int meetingIdMaxLength = 12;

const int showTypePresenter = 0;
const int showTypeGallery = 1;

const int actionTurnPageUp = 0;
const int actionTurnPageDown = 1;

const int actionStatusUnlock = 0;
const int actionStatusLock = 1;

///TV正在更新
const int errorCodeUpgrading = -101;
///不能配对tv
const int errorCodeCannotMatchTv = -102;

const int requestIdFetchMemberPairInMeeting = 1;
const int requestIdFetchMemberCreateOrJoinSuccess = 2;
const int requestIdFetchMemberMemberChange = 3;
const int requestIdFetchMemberUserJoin = 4;
const int requestIdFetchMemberAllMuteAudio = 5;

const int requestIdJoinMeetingCommon = 1;
const int requestIdJoinMeetingPassword = 2;