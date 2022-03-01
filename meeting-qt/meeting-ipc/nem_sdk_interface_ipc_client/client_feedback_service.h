/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_FEEDBACK_SERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_FEEDBACK_SERVICE_H_

#include "feedback_service.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NEFeedbackServiceProcHandler : public NEProcHandler
{
public:
    virtual void onFeedback(const int& type, const std::string& path, const NEFeedbackService::NEFeedbackCallback& cb) = 0;
};

class NEM_SDK_INTERFACE_EXPORT NEFeedbackServiceIPCClient :
    public NEServiceIPCClient< NEFeedbackServiceProcHandler, NEFeedbackService>
{

};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_FEEDBACK_SERVICE_H_
