/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nipclib/proxy_config/proxy_info.h"
#include "nipclib/socket/tcp_client_socket.h"


#include "nipclib/socket/socket_wrapper.h"

NIPCLIB_BEGIN_DECLS

bool TcpClientSocket::WouldBlock(bool connecting/* = false*/)
{
    return would_block(connecting);
}

TcpClientSocket::TcpClientSocket()
{
    tcp_client_ = std::make_shared<internal::TcpClientImpl>();
}
void TcpClientSocket::RegisterCallback(TcpClientHandler *handler)
{
    if (!tcp_client_)
        return;
    tcp_client_->SetHandler(handler);
}

void TcpClientSocket::UnregisterCallback()
{
    if (!tcp_client_)
        return;
    tcp_client_->SetHandler(nullptr);
}

bool TcpClientSocket::Init(const std::string& host, int port)
{
    if (!tcp_client_)
        return false;

    return tcp_client_->Init(host, port);
}
void TcpClientSocket::SetProxy(const ProxyInfo* proxyinfo)
{
    if (!proxyinfo || !tcp_client_)
    {
        return;
    }
    tcp_client_->SetProxy(proxyinfo->type_, proxyinfo->host_, proxyinfo->port_, proxyinfo->user_, proxyinfo->password_);
}
int	TcpClientSocket::Read(const void *data, size_t size)
{
    if (!tcp_client_)
        return -1;
    return tcp_client_->Read(data, size);
}

int	TcpClientSocket::Write(const void *data, size_t size)
{
    if (!tcp_client_)
        return -1;
    return tcp_client_->Write(data, size);
}

void TcpClientSocket::Close()
{
    if (!tcp_client_)
        return;
    tcp_client_->Close();
}

NIPCLIB_END_DECLS