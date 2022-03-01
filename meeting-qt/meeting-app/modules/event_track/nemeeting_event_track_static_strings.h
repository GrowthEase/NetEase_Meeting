/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEMEETING_EVENT_TRACK_STATIC_STRINGS_H
#define NEMEETING_EVENT_TRACK_STATIC_STRINGS_H

#include <QString>

namespace ststist_static_strings {

const QString kModuleTypeWeMeeting = "we_meeting";
const QString kModuleTypeMeeting = "meeting";

const QString kApplicationInit = "application_init";
const QString kLogin = "login";
const QString kLogout = "logout";
const QString kFeedback = "feedback";
const QString kRegister = "register";

const QString kSDKInit = "sdk_init";
const QString kPageMeeting = "page_meeting";
const QString kMeetingCreate = "meeting_create";
const QString kMeetingJoin = "meeting_join";
const QString kMeetingFinsh = "meeting_finish";
const QString kUsePersonalId = "use_personal_id";
const QString kOpenCamera = "open_camera";
const QString kOpenMicro = "open_micro";
const QString kMeetingCancel = "cancel_meeting";
const QString kSwitchAudio = "switch_audio";
const QString kSwitchCamera = "switch_camera";
const QString kScreenSharing = "screen_share";
const QString kMemberScreenSharing = "member_screen_share";
const QString kManagerMembers = "manage_member";
const QString kInvite = "invite";
const QString kMuteAll = "mute_all";
const QString kUnmuteAll = "unmute_all";
const QString kSwitchMemberAudio = "switch_audio_member";
const QString kSwitchMemberVideo = "switch_camera_member";
const QString kFocusMember = "focus_member";
const QString kRemoveMember = "remove_member";
const QString kTransferHost = "changehost";
const QString kSelfLeaveMeeting = "self_leave_meeting";
const QString kSelfFinshMeeting = "self_finish_meeting";
const QString kUserJoinMeeting = "user_join_meeting";
const QString kUserVideoState = "user_video_state";
const QString kFirstVideoFrameReceived = "first_video_data_received";
const QString kUserVideoProfileChanged = "user_change_profile";
const QString kUserLeaveMeeting = "user_leave_meeting";

}

#endif // NEMEETING_EVENT_TRACK_STATIC_STRINGS_H
