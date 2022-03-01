/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "account_prochandler.h"
#include "manager/global_manager.h"
#include "manager/auth_manager.h"

void NEAccountProcHandlerIMP::onGetPersonalMeetingId(const NS_I_NEM_SDK::NEAccountService::NEGetPersonalMeetingIdCallback& cb)
{
    YXLOG_API(Info) << "Get personal meeting ID." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        auto authInfo = AuthManager::getInstance()->getAuthInfo();
        if (authInfo)
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", authInfo->getPersonalRoomId());
        else
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "Not logged in", "");
    });
}

