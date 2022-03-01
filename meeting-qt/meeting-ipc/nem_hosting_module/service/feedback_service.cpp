/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module/service/feedback_service.h"
#include "nem_hosting_module_protocol/protocol/feedback_protocol.h"

NNEM_SDK_HOSTING_MODULE_BEGIN_DECLS
USING_NS_NNEM_SDK_HOSTING_MODULE_PROTOCOL


NEFeedbackServiceIMP::NEFeedbackServiceIMP()
    : IService(ServiceID::SID_Feedback)
    , feedback_srv_listener_(nullptr)
{

}
NEFeedbackServiceIMP::~NEFeedbackServiceIMP()
{

}


void NEFeedbackServiceIMP::feedback(const int& type, const std::string& path, const NEFeedbackCallback& cb)
{
    PostTaskToProcThread(ToWeakCallback([this, type, path, cb]() {
        FeedbackRequest request;
        request.path_ = path;
        request.type_ = type;
        SendData(FeedbackCID::FeedbackCID_feedback, request, IPCAsyncResponseCallback(cb));
    }));
}

void NEFeedbackServiceIMP::addListener(FeedbackServiceListener* listener)
{
    feedback_srv_listener_ = listener;
}

void NEFeedbackServiceIMP::OnPack(int cid, const std::string& data, const IPCAsyncResponseCallback& cb)
{
    switch (cid)
    {
    case FeedbackCID::FeedbackCID_feedback_CB:
    {
        FeedbackResponse response;
        if (response.Parse(data))
        {
            if (feedback_srv_listener_) {
                feedback_srv_listener_->onFeedbackStatus(response.type_, response.error_code_, response.url_);
            }
        }
    }
    break;
    }
}



NNEM_SDK_HOSTING_MODULE_END_DECLS


