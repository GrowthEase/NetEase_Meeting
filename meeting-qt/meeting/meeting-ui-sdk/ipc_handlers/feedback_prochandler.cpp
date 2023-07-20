// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "feedback_prochandler.h"
#include "manager/auth_manager.h"
#include "manager/feedback_manager.h"
#include "manager/global_manager.h"

void NEFeedbackServiceProcHandlerIMP::onFeedback(const int& type,
                                                 const std::string& path,
                                                 bool needAudioDump,
                                                 const NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback& cb) {
    YXLOG_API(Info) << "onFeedback, path: " << path << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        // to native sdk
        FeedbackManager::getInstance()->Uploadsources(type, path, needAudioDump, cb);
    });
}
