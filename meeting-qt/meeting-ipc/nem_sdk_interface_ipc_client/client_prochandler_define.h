/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_IPC_CLIENT_DEFINE_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_IPC_CLIENT_DEFINE_PROCHANDLER_H_

#include "public_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

class NEM_SDK_INTERFACE_EXPORT NEProcHandler : public virtual NEObject
{
public:
    NEProcHandler() {}
    virtual ~NEProcHandler() {};
};

template<class TNEProcHandler, class TNEService>
class NEServiceIPCClient : public TNEService
{
public:
    NEServiceIPCClient() : procHandler(nullptr) {}
    virtual ~NEServiceIPCClient() {}
public:
    virtual void setProcHandler(TNEProcHandler* handler) { procHandler = handler; }
    virtual TNEProcHandler* getProcHandler() const { return procHandler; }
protected:
    inline TNEProcHandler* _ProcHandler() const { return procHandler; }
protected:
    TNEProcHandler* procHandler;
};

NNEM_SDK_INTERFACE_END_DECLS

#endif//NEM_SDK_INTERFACE_IPC_CLIENT_DEFINE_PROCHANDLER_H_