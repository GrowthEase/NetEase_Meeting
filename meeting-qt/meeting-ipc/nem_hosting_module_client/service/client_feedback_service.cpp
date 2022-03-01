/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_client/service/client_feedback_service.h"
#include "nem_hosting_module_protocol/protocol/feedback_protocol.h"


NNEM_SDK_HOSTING_MODULE_CLIENT_BEGIN_DECLS

USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL


NEFeedbackServiceIMP::NEFeedbackServiceIMP()
    :IService(ServiceID::SID_Feedback)
{

}




NEFeedbackServiceIMP::~NEFeedbackServiceIMP()
{

}



void NEFeedbackServiceIMP::OnLoad()
{

}

void NEFeedbackServiceIMP::OnRelease()
{

}

void NEFeedbackServiceIMP::feedback(const int& type, const std::string& path, const NEFeedbackService::NEFeedbackCallback& cb)
{
    if (_ProcHandler() != nullptr)
    {
        _ProcHandler()->onFeedback(type, path, cb);
    }

}



void NEFeedbackServiceIMP::OnPack(int cid, const std::string& data, uint64_t sn)
{
    switch (cid)
    {
    case FeedbackCID::FeedbackCID_feedback:
    {
        FeedbackRequest request;
        if (request.Parse(data))
        {
            feedback(request.type_, request.path_, ToWeakCallback([this, sn](NEErrorCode error_code, const std::string& error_msg, const std::string& url, const int& type) {
                FeedbackResponse response;
                response.error_code_ = error_code;
                response.error_msg_ = error_msg;
                response.url_ = url;
                response.type_ = type;
                SendData(FeedbackCID::FeedbackCID_feedback_CB, response, sn);
            }));
        }

    }
    break;
    default:
        break;
    }

}

NNEM_SDK_HOSTING_MODULE_CLIENT_END_DECLS


