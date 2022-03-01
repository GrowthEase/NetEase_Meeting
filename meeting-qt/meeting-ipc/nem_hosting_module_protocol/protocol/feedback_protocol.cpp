/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_protocol/protocol/feedback_protocol.h"
NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_CORE

void FeedbackRequest::OnPack(Json::Value& root) const
{
    root["path"] = path_;
    root["type"] = type_;
}
void FeedbackRequest::OnParse(const Json::Value& root)
{
    path_ = root["path"].asCString();
    type_ = root["type"].asInt();
}

void FeedbackResponse::OnOtherPack(Json::Value& root) const
{
    root["url"] = url_;
    root["type"] = type_;
}

void FeedbackResponse::OnOtherParse(const Json::Value& root)
{
    url_ = root["url"].asCString();
    type_ = root["type"].asInt();
}

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS


