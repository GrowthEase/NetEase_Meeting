/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_IPC_IPC_SERVER_H_
#define NIPCLIB_IPC_IPC_SERVER_H_

#include "nipclib/socket/server_socket_wrapper.h"
#include "nipclib/ipc/ipc_base.h"

NIPCLIB_BEGIN_DECLS

class NIPCLIB_EXPORT IPCServer : public NS_NIPCLIB::IPCBase<NS_NIPCLIB::internal::TcpServerImpl>
{
	class ClinetHandler : public TcpClientHandler
	{
	public:
		ClinetHandler(IPCServer* ipc_server) : ipc_server_(ipc_server) {}
		virtual bool OnAcceptClient(void* client_fd) override { return true; }
		virtual void OnSocketClose(int error_code) override
		{
			ipc_server_->OnClientClose(error_code);
		}
		virtual void OnSocketConnect(int error_code) override {}
		virtual void OnReceiveSocketData(int error_code, const void *data, size_t size) override
		{
			ipc_server_->OnReceiveSocketData(error_code, data, size);
		}
		virtual void OnSendSocketData(int error_code) override {}
	private:
		IPCServer* ipc_server_;
	};
public:
	friend class ClinetHandler;
	IPCServer() : client_fd_(-1) , client_(nullptr), client_handler_(nullptr){}
public:
	void AttachClientClose(const std::function<void()>& client_close_callback);
    int GetKeepAliveInterval() const { return keep_alive_interval_; }
    void SetKeepAliveInterval(int interval) { keep_alive_interval_ = interval; }

private:
	virtual bool OnAccept(void* client_fd) override;
	virtual void OnClose(int error_code) override;
	virtual void OnReceive(const IPCData& data) override;
private:
	void OnClientClose(int error_code);
private:
	virtual void OnInternalBegin() override;
	virtual void OnInternalEnd() override;
	virtual void DoClose() override;
	virtual int InvokeSendData(const IPCData& data) override;
	void Reset();	
private:
	std::function<void()> client_close_callback_;
	std::recursive_mutex client_socket_fd_lock_;
	int client_fd_;
	std::shared_ptr<NS_NIPCLIB::internal::TcpClientImpl> client_;
	std::unique_ptr<ClinetHandler> client_handler_;
    std::unique_ptr<std::thread> keep_alive_thread_ = nullptr;
    std::chrono::steady_clock::time_point keep_alive_latest_ = std::chrono::steady_clock::now();
    std::atomic_int keep_alive_interval_{10};
};


NIPCLIB_END_DECLS

#endif//NIPCLIB_IPC_IPC_SERVER_H_