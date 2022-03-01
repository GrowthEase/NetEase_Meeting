/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_PROTOCOL_GLOBAL_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_GLOBAL_PROTOCOL_H_

#include "nem_hosting_module_protocol/config/build_config.h"
#include "nem_hosting_module_core/protocol/protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum GlobalCID
{
	GlobalCID_Init = 1,
	GlobalCID_Init_CB,
	GlobalCID_UnInit,
	GlobalCID_UnInit_CB,
	GlobalCID_QuerySDKVersion,
	GlobalCID_QuerySDKVersion_CB,
    GlobalCID_ActiveWindow,
    GlobalCID_ActiveWindow_CB,
};
class InitRequest : public NEMIPCProtocolBody
{
public:
	virtual void OnPack(Json::Value& root) const override;
	virtual void OnParse(const Json::Value& root) override;
public:
	NEMeetingSDKConfig init_config_;
};
using InitResponse = NEMIPCProtocolErrorInfoBody;

using UnInitRequest = NEMIPCProtocolEmptyBody;
using UnInitResponse = NEMIPCProtocolErrorInfoBody;

using QuerySDKVersionRequest = NEMIPCProtocolEmptyBody;
class QuerySDKVersionResponse : public NEMIPCProtocolErrorInfoBody
{
protected:
	virtual void OnOtherPack(Json::Value& root) const override;
	virtual void OnOtherParse(const Json::Value& root) override;
public:
	std::string sdkVersion;
};

using ActiveWindowRequest = NEMIPCProtocolEmptyBody;
using ActiveWindowResponse = NEMIPCProtocolErrorInfoBody;

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS
#endif
