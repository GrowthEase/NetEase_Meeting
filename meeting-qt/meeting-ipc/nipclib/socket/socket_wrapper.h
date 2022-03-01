/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_SOCKET_WRAPPER_H__
#define NIPCLIB_SOCKET_WRAPPER_H__

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include "nipclib/proxy_config/proxy_info.h"
#include "tnet_transport.h"
#include "nipclib/socket/socket_handler.h"
#include <memory>

NIPCLIB_BEGIN_DECLS

bool would_block(bool connecting = false);

namespace internal{
	class TcpServerImpl;
class NIPCLIB_EXPORT TcpClientImpl:public std::enable_shared_from_this<TcpClientImpl>
{
	friend class TcpServerImpl;
public:
	TcpClientImpl();

	virtual ~TcpClientImpl();

	void SetHandler(TcpClientHandler *handler);
	void SetProxy(ProxyType type, const std::string& host, int port, const std::string& user, const std::string& password);

	bool Init(const std::string& host, int port);
	bool Init(tnet_fd_t fd);
	std::string GetHost() const { return host_; }
	int GetPort() const { return port_; }
	int GetLocalPort() const { return local_port_; }
	int	Write(const void *data, size_t size);
	int	Read(const void *data, size_t size);
	void Close();

	bool IsConnected();

protected:
	void OnClose(int error_code);
	void OnConnect(int error_code);
	void OnAccept(int error_code);
	void OnReceive(int error_code, const void *data, size_t size);
	void OnSend(int error_code);
    static int OnTcpCallback(const tnet_transport_event_t* e);
private:
	void InitLog();
	tnet_socket_type_e CalcSocketType(const std::string& host, std::string& description);
private:
	TcpClientHandler		*handler_;
	tnet_transport_t          *socket_handle_;
	std::string host_;
	tnet_port_t port_;
	tnet_port_t local_port_;
	ProxyInfo             proxyinfo_;
	int				        fd_;
	bool					is_connected_;
	bool create_by_server_;
};
}
NIPCLIB_END_DECLS
#endif // NIPCLIB_SOCKET_WRAPPER_H__
