/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/12
//
// Network io async tcp socket implementation by libevent

#include "nio_base_tcp.h"

#if defined(WITH_IOCP)

namespace nbase
{
// TcpClient ---------------------------------------------------------
TcpClient::TcpClient()
	: sock_(INVALID_SOCKET), listener_(0), port_(0), connected_(false)
{
	// create socket
	sock_ = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP,
		NULL, NULL, WSA_FLAG_OVERLAPPED);
	if (sock_ == INVALID_SOCKET)
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpClient: WSASocket() error");
	}
}

TcpClient::~TcpClient()
{
	// close socket
	::closesocket(sock_);
}

int TcpClient::Connect(const char *host, int port)
{
	host_ = host;
	port_ = port;

	// initialize the socket
	set_block(sock_, false);
	reuse_address(sock_);
	sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_family      = AF_INET;
	addr.sin_addr.s_addr = ::inet_addr(host);
	addr.sin_port = htons(port);

	// connect host
	int r = ::connect(sock_, (const sockaddr *)&addr, sizeof(addr));
	if (r != 0 && !would_block())
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			__FILE__, 
			__LINE__, 
			"nbase::TcpClient: connect() error");
	}
	return r;
}

int TcpClient::Write(const void *data, size_t size)
{
	int n = ::send(sock_, (const char *)data, size, 0);
	if (n == -1 && !would_block())
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			__FILE__, 
			__LINE__, 
			"nbase::TcpClient: Write() send() error");
		return 0;
	}
	if (n == -1)      
		n = 0;
	// Set the write event when we can't send
	if (n < (int)size)
	{
	    // TODO:
	}
	return n;
}

int TcpClient::Read(void *buf, size_t size)
{
	int n = ::recv(sock_, (char *)buf, size, 0);
	if (n == 0 || (n == -1 && !would_block()))
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			__FILE__, 
			__LINE__, 
			"nbase::TcpClient: Read() recv() error");
		return 0;
	}
	if (n == -1)      
		n = 0;
	return n;
}

}  // namespace nbase

#endif  // WITH_IOCP