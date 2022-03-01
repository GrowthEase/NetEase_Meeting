/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_PROTOCOL_FEEDBACK_PROTOCOL_H_
#define NEM_HOSTING_MODULE_PROTOCOL_FEEDBACK_PROTOCOL_H_

#include "nem_hosting_module_protocol/config/build_config.h"
#include "nem_hosting_module_core/protocol/protocol.h"

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

enum FeedbackCID
{
	FeedbackCID_feedback = 1,
    FeedbackCID_feedback_CB = 2,
};

class FeedbackRequest : public NEMIPCProtocolBody
{
public:
	virtual void OnPack(Json::Value& root) const override;
	virtual void OnParse(const Json::Value& root) override;

public:
    std::string path_;
    int type_;
};
class FeedbackResponse : public NEMIPCProtocolErrorInfoBody
{
public:
    virtual void OnOtherPack(Json::Value& root) const override;
    virtual void OnOtherParse(const Json::Value& root) override;
public:
    std::string url_;
    int type_;
};

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS

#endif//NEM_HOSTING_MODULE_PROTOCOL_FEEDBACK_PROTOCOL_H_
