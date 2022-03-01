/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/14
//
// Network io udp socket implementation by libevent

#include "nio_base_udp.h"

#if defined(WITH_LIBEVENT)

namespace nbase
{
// UdpSock --------------------------------------------------------------------------------
UdpSock::UdpSock(struct event_base *event_base, 
	             uint16_t port, 
				 const char *host, 
				 ProxySet *proxyset)
	: event_base_(event_base), listener_(0)
{
	sock_ = ::socket(AF_INET, SOCK_DGRAM, 0);
	if (sock_ == INVALID_SOCKET)
	{
		DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "nbase::UdpSock: socket() error");
	}
	else
	{
		set_block(sock_, false);
		reuse_address(sock_);

		sockaddr_in addr;
		memset(&addr, 0, sizeof(addr));
		addr.sin_family = AF_INET;
		if (host)
			addr.sin_addr.s_addr = ::inet_addr(host);
		addr.sin_port = htons(port);

		int r = ::bind(sock_, (const sockaddr *)&addr, sizeof(addr));
		if (r != 0)
		{
			DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "nbase::UdpSock: bind() error");
		}
		else
		{
			int bufSize = SO_MAX_MSG_SIZE;
			setsockopt(sock_, SOL_SOCKET, SO_SNDBUF, (const char *)&bufSize, sizeof(bufSize));
			bufSize = 32 * 1024;
			setsockopt(sock_, SOL_SOCKET, SO_RCVBUF, (const char *)&bufSize,sizeof(bufSize));
			event_set(&event_read_, (int)sock_, EV_READ | EV_PERSIST, OnSocketEvent, this);
			if (NULL != event_base_)
				event_base_set(event_base_, &event_read_);
			event_add(&event_read_, NULL);
		}
	}
}

void UdpSock::OnSocketEvent(int fd, short event, void *arg)
{
	UdpSock *udp_sock = (UdpSock *)arg;
	assert(udp_sock);
	udp_sock->OnEvent(fd, event);
}

void UdpSock::OnEvent(int fd, short event)
{
	assert(fd == sock_);
	if (event & EV_READ)
	{
		if (listener_)  
			listener_->OnRead();
	}
}

int UdpSock::Write(uint32_t ip, uint16_t port, const void *data, size_t size)
{
	sockaddr_in addr;
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(ip);
	addr.sin_port = htons(port);
	int n = ::sendto(sock_, (const char *)data, size, 0, (const sockaddr *)&addr, sizeof(addr));
	if (n == -1 && !would_block())
		DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "nbase::UdpSock: Write(): sendto() error");
	if (n == -1)
		n = 0;
	return n;
}

int UdpSock::Read(uint32_t &ip, uint16_t &port, void *data, size_t size)
{
	sockaddr_in addr;
	int len = sizeof(addr);
	int n   = ::recvfrom(sock_, (char *)data, size, 0, (sockaddr *)&addr, (socklen_t*)&len);
	if (n == -1 && !would_block())
		DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "nbase::UdpSock: Read(): recvfrom() error");
	if (n ==-1)
		n = 0;
	ip   = ntohl(addr.sin_addr.s_addr);
	port = ntohs(addr.sin_port);
	return n;
}

}  // namespace nbase

#endif  // WITH_LIBEVENT