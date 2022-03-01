/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_SOCKET_TCP_CLIENT_SOCKET_H__
#define NIPCLIB_SOCKET_TCP_CLIENT_SOCKET_H__

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include "nipclib/proxy_config/proxy_info.h"
#include "nipclib/socket/socket_handler.h"
#include <string>
#include <memory>

NIPCLIB_BEGIN_DECLS

namespace internal
{
	class TcpClientImpl;
}
class NIPCLIB_EXPORT TcpClientSocket
{
public:
	TcpClientSocket();
	virtual ~TcpClientSocket(){}

	static bool WouldBlock(bool connecting = false);
	void RegisterCallback(TcpClientHandler *handler);
	void UnregisterCallback();
	bool Init(const std::string& host, int port);
	void SetProxy(const ProxyInfo* proxyinfo);
	int	Read(const void *data, size_t size);
	int	Write(const void *data, size_t size);
	void Close();

private:
	std::shared_ptr<internal::TcpClientImpl> tcp_client_;

};
NIPCLIB_END_DECLS
#endif // NIPCLIB_SOCKET_TCP_CLIENT_SOCKET_H__
