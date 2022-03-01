/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_protocol/protocol/settings_protocol.h"
NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

void ShowUIWndRequest::OnPack(Json::Value& root) const
{
}
void ShowUIWndRequest::OnParse(const Json::Value& root)
{
}

void SettingsChangeNotify::OnPack(Json::Value& root) const
{
    root["type_"] = type_;
    root["status_"] = status_;
}
void SettingsChangeNotify::OnParse(const Json::Value& root)
{
    type_ = (SettingChangType)root["type_"].asInt();
    status_ = root["status_"].asBool();
}

void SettingsBoolRequest::OnPack(Json::Value& root) const
{
    root["status_"] = status_;
}
void SettingsBoolRequest::OnParse(const Json::Value& root)
{
    status_ = root["status_"].asBool();
}

void SettingsBoolResponse::OnOtherPack(Json::Value& root) const
{
    root["status_"] = status_;
}
void SettingsBoolResponse::OnOtherParse(const Json::Value& root)
{
    status_ = root["status_"].asBool();
}


void SettingsIntRequest::OnPack(Json::Value& root) const
{
	root["value_"] = value_;
}
void SettingsIntRequest::OnParse(const Json::Value& root)
{
	value_ = root["value_"].asUInt();
}

void SettingsIntResponse::OnOtherPack(Json::Value& root) const
{
	root["value_"] = value_;
}
void SettingsIntResponse::OnOtherParse(const Json::Value& root)
{
	value_ = root["value_"].asUInt();
}

void SettingsGetHistoryMeetingRequest::OnPack(Json::Value& root) const {
    ;
}

void SettingsGetHistoryMeetingRequest::OnParse(const Json::Value& root) {
    ;
}

void SettingsGetHistoryMeetingResponse::OnOtherPack(Json::Value& root) const {
    if (params_.empty() == false) {
        for (auto& item : params_) {
            Json::Value json_item;
            json_item["meetingId"] = item.meetingId;
            json_item["meetingUniqueId"] = (Json::UInt64)item.meetingUniqueId;
            json_item["shortMeetingId"] = item.shortMeetingId;
            json_item["meetingSubject"] = item.subject;
            json_item["password"] = item.password;
            json_item["nickname"] = item.nickname;
            json_item["sipId"] = item.sipId;
            root["HistoryMeetingItems"].append(json_item);
        }
    }
}



void SettingsGetHistoryMeetingResponse::OnOtherParse(const Json::Value& root) {
    for (auto& item : root["HistoryMeetingItems"]) {
        NEHistoryMeetingItem meetingItem;
        meetingItem.meetingId = item["meetingId"].asString();
        meetingItem.meetingUniqueId = item["meetingUniqueId"].asUInt();
        meetingItem.shortMeetingId = item["shortMeetingId"].asString();
        meetingItem.subject = item["meetingSubject"].asString();
        meetingItem.password = item["password"].asString();
        meetingItem.nickname = item["nickname"].asString();
        meetingItem.sipId = item["sipId"].asString();
        params_.push_back(meetingItem);
    }
}

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS
