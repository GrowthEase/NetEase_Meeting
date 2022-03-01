/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_FEEDBACKPROCHANDLER_H_
#define NEM_SDK_INTERFACE_APP_FEEDBACKPROCHANDLER_H_

#include "client_feedback_service.h"

class NEFeedbackServiceProcHandlerIMP : public NS_I_NEM_SDK::NEFeedbackServiceProcHandler
{
public:
    virtual void onFeedback(const int& type, const std::string& path, const NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback& cb) override;
};

#endif // NEM_SDK_INTERFACE_APP_FEEDBACKPROCHANDLER_H_
