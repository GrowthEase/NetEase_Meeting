// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "account_prochandler.h"
#include "manager/auth_manager.h"
#include "manager/global_manager.h"

void NEAccountProcHandlerIMP::onGetPersonalMeetingId(const NS_I_NEM_SDK::NEAccountService::NEGetPersonalMeetingIdCallback& cb) {
    YXLOG_API(Info) << "Received onGetPersonalMeetingId." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        auto authStatus = AuthManager::getInstance()->getAuthStatus();
        YXLOG(Info) << "authStatus:" << authStatus << YXLOGEnd;
        if (authStatus != kAuthLoginSuccessed) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "Not logged in", "");
        } else {
            auto authInfo = AuthManager::getInstance()->getAuthInfo();
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", authInfo.personalRoomId);
        }
    });
}
