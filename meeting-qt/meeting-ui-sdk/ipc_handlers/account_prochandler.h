/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_APP_PROCHANDLER_H_

#include "client_account_service.h"

class NEAccountProcHandlerIMP : public NS_I_NEM_SDK::NEAccountProcHandler
{
public:
    virtual void onGetPersonalMeetingId(const NS_I_NEM_SDK::NEAccountService::NEGetPersonalMeetingIdCallback& cb) override;
};

#endif // NEM_SDK_INTERFACE_APP_PROCHANDLER_H_
