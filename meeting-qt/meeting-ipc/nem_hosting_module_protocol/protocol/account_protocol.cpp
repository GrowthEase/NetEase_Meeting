/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_protocol/protocol/account_protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS


void QueryPersonalMeetingIdResponse::OnOtherPack(Json::Value& root) const
{
	root["personal_meeting_id_"] = personal_meeting_id_;
}
void QueryPersonalMeetingIdResponse::OnOtherParse(const Json::Value& root)
{
	personal_meeting_id_ = root["personal_meeting_id_"].asString();
}

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS