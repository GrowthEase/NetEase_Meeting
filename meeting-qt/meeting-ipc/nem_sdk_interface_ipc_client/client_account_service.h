/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_CLIENT_SERVICE_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_CLIENT_SERVICE_H_

#include "account_service.h"
#include "client_prochandler_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS


class NEM_SDK_INTERFACE_EXPORT NEAccountProcHandler : public NEProcHandler
{
public:
	virtual void onGetPersonalMeetingId(const NEAccountService::NEGetPersonalMeetingIdCallback& cb) = 0;
};

class NEM_SDK_INTERFACE_EXPORT NEAccountServiceIPCClient :
    public NEServiceIPCClient<NEAccountProcHandler, NEAccountService>
{
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_IPC_CLIENT_INTERFACE_CLIENT_SERVICE_H_
