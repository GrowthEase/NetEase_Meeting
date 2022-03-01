/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_IPC_IPC_DEF_H_
#define NIPCLIB_IPC_IPC_DEF_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <functional>

NIPCLIB_BEGIN_DECLS

using IPCData = std::shared_ptr<std::string>;
using IPCCloseCallback = std::function<void()>;
using IPCReadyCallback = std::function<void()>;
using IPCInitCallback = std::function<void(bool ret,const std::string& host, int port)>;
using IPCReceiveDataCallback = std::function<void(const IPCData& data)>;
using IPCKeepAliveTimeOutCallback = std::function<void()>;

class NIPCLIB_EXPORT IIPC
{
public:	
	static IPCData MakeIPCData()
	{
		return std::make_shared<IPCData::element_type>();
	}
	static IPCData MakeIPCData(const IPCData::element_type& data)
	{
		return std::make_shared<IPCData::element_type>(data);
	}
	static IPCData MakeIPCData(IPCData::element_type&& data)
	{
		return std::make_shared<IPCData::element_type>(std::forward<IPCData::element_type>(data));
	}
	virtual bool Init(int port = 0) = 0;
	virtual void Close() = 0;
	inline virtual bool Ready() = 0;
	virtual void AttachInit(const IPCInitCallback& init_callback) = 0;
	virtual void AttachReady(const IPCReadyCallback& ready_callback) = 0;
	virtual void AttachClose(const IPCCloseCallback& close_callback) = 0;
    virtual void AttachKeepAliveTimeOut(const IPCKeepAliveTimeOutCallback& keep_alive_callback) = 0;
	virtual int SendData(const IPCData& data) = 0;
	virtual void AttachReceiveData(const IPCReceiveDataCallback& receive_callback) = 0;
};
NIPCLIB_END_DECLS
#endif
