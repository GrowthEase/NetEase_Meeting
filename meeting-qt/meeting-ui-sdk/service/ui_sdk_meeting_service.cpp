/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "service/ui_sdk_meeting_service.h"

#include "manager/meeting_manager.h"
#include "manager/auth_manager.h"

NEMeetingServiceIMP::NEMeetingServiceIMP()
{

}
NEMeetingServiceIMP::~NEMeetingServiceIMP()
{

}

void NEMeetingServiceIMP::startMeeting(const NEStartMeetingParams& param, const NEStartMeetingOptions& opts, const NEStartMeetingCallback& cb)
{
    CreateMeetingParam create_param;
    create_param.meeting_id_ = param.meetingId;
    create_param.nickname_ = param.displayName;
    create_param.audio_ = opts.noAudio ? DeviceStatus::kDeviceDisabledBySelf:DeviceStatus::kDeviceEnabled;
    create_param.video_ = opts.noVideo ? DeviceStatus::kDeviceDisabledBySelf:DeviceStatus::kDeviceEnabled;
    auto ret = MeetingManager::getInstance()->createMeeting(create_param,[cb](MeetingStatus result){
            if(cb != nullptr)
            {
                NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
                std::string err_msg = "FAILED";
                if(result == MeetingStatus::kMeetingConnected)
                {
                        err_msg = NE_ERROR_MSG_SUCCESS;
                        err_code = NEErrorCode::ERROR_CODE_SUCCESS;
                }
                cb(err_code,err_msg);
            }
    });
    if(ret != NEMErrorCode::kNEMNoError && cb != nullptr)
    {
        NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
        std::string err_msg = "FAILED";
        switch(ret)
        {
           case NEMErrorCode::kNEMAuthNotLoggedIn:
            err_msg = "Not logged in";
            break;
        default:
            break;
        }
        cb(err_code,err_msg);
    }
}
void NEMeetingServiceIMP::joinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb)
{
     auto login_status =  AuthManager::getInstance()->getLoginStatus();
    if (login_status == kLoginIdle)
       doAnonJoinMeeting(param,opts,cb);
    else if (login_status == kLoginSuccess)
       doJoinMeeting(param,opts,cb);
}
void NEMeetingServiceIMP::doJoinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb)
{
    JoinMeetingParam join_param;
    join_param.meeting_id_ = param.meetingId;
    join_param.nickname_ = param.displayName;
    join_param.audio_ = opts.noAudio ? DeviceStatus::kDeviceDisabledBySelf:DeviceStatus::kDeviceEnabled;
    join_param.video_ = opts.noVideo ? DeviceStatus::kDeviceDisabledBySelf:DeviceStatus::kDeviceEnabled;
    auto ret = MeetingManager::getInstance()->joinMeeting(join_param,[cb](MeetingStatus result){
            if(cb != nullptr)
            {
                NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
                std::string err_msg = "FAILED";
                if(result == MeetingStatus::kMeetingConnected)
                {
                        err_msg = NE_ERROR_MSG_SUCCESS;
                        err_code = NEErrorCode::ERROR_CODE_SUCCESS;
                }
                cb(err_code,err_msg);
            }
    });
    if(ret != NEMErrorCode::kNEMNoError && cb != nullptr)
    {
        NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
        std::string err_msg = "FAILED";
        switch(ret)
        {
           case NEMErrorCode::kNEMAuthNotLoggedIn:
            err_msg = "Not logged in";
            break;
        default:
            break;
        }
        cb(err_code,err_msg);
    }
}
void NEMeetingServiceIMP::doAnonJoinMeeting(const NEJoinMeetingParams& param, const NEJoinMeetingOptions& opts, const NEJoinMeetingCallback& cb)
{
    AnonJoinMeetingParam join_param;
    join_param.meeting_id_ = param.meetingId;
    join_param.nickname_ = param.displayName;
    join_param.audio_ = opts.noAudio ? DeviceStatus::kDeviceDisabledBySelf:DeviceStatus::kDeviceEnabled;
    join_param.video_ = opts.noVideo ? DeviceStatus::kDeviceDisabledBySelf:DeviceStatus::kDeviceEnabled;
    auto auth_info =  AuthManager::getInstance()->getAuthInfo();
    if(auth_info != nullptr)
        join_param.app_key_ = auth_info->getAppKey();
    auto ret = MeetingManager::getInstance()->anonJoinMeeting(join_param,[cb](MeetingStatus result){
            if(cb != nullptr)
            {
                NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
                std::string err_msg = "FAILED";
                if(result == MeetingStatus::kMeetingConnected)
                {
                        err_msg = NE_ERROR_MSG_SUCCESS;
                        err_code = NEErrorCode::ERROR_CODE_SUCCESS;
                }
                cb(err_code,err_msg);
            }
    });
    if(ret != NEMErrorCode::kNEMNoError && cb != nullptr)
    {
        NEErrorCode err_code = NEErrorCode::ERROR_CODE_FAILED;
        std::string err_msg = "FAILED";
        switch(ret)
        {
           case NEMErrorCode::kNEMAuthNotLoggedIn:
            err_msg = "Not logged in";
            break;
        default:
            break;
        }
        cb(err_code,err_msg);
    }
}
