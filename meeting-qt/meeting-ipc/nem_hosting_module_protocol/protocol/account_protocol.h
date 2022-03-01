/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_PROTOCOL_ACCOUNT_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_ACCOUNT_PROTOCOL_H_

#include "nem_hosting_module_protocol/config/build_config.h"
#include "nem_hosting_module_core/protocol/protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum AccountCID
{
	AccountCID_QueryPersonalMeetingId = 1,
	AccountCID_QueryPersonalMeetingId_CB = 2,
};

using QueryPersonalMeetingIdRequest = NEMIPCProtocolEmptyBody;
class QueryPersonalMeetingIdResponse : public NEMIPCProtocolErrorInfoBody	
{
public:
	virtual void OnOtherPack(Json::Value& root) const override;
	virtual void OnOtherParse(const Json::Value& root) override;
public:
	std::string personal_meeting_id_;
};

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS

#endif//NEM_HOSTING_MODULE_PROTOCOL_AUTH_PROTOCOL_H_
