/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_IPC_IPC_CLIENT_H_
#define NIPCLIB_IPC_IPC_CLIENT_H_

#include "nipclib/socket/socket_wrapper.h"
#include "nipclib/ipc/ipc_base.h"

NIPCLIB_BEGIN_DECLS

class NIPCLIB_EXPORT IPCClient : public NS_NIPCLIB::IPCBase<NS_NIPCLIB::internal::TcpClientImpl>
{
public:
	IPCClient() {}
	~IPCClient() {}
public:
    int GetKeepAliveInterval() const { return keep_alive_interval_; }
    void SetKeepAliveInterval(int interval) { keep_alive_interval_ = interval; }

 private:
	virtual void OnClose(int error_code) override;
	virtual void OnConnect(int error_code) override;
	virtual void OnReceive(const IPCData& data) override;
private:
	virtual void OnInternalBegin() override;
	virtual void OnInternalEnd() override;
	virtual void DoClose() override;
	virtual int InvokeSendData(const IPCData& data) override;
private:
	int index_ = 0;
    std::unique_ptr<std::thread> keep_alive_thread_ = nullptr;
    std::chrono::steady_clock::time_point keep_alive_latest_ = std::chrono::steady_clock::now();
    std::atomic_int keep_alive_interval_{10};
};

NIPCLIB_END_DECLS
#endif