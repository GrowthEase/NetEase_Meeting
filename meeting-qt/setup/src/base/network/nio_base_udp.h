/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/14
//
// Network io udp socket

#ifndef BASE_NETWORK_NIO_BASE_UDP_H_
#define BASE_NETWORK_NIO_BASE_UDP_H_

#include "nio_base.h"
#include "base/memory/ref_count.h"
#include <stdexcept>

namespace nbase
{

#if defined(WITH_LIBEVENT)

/*
 *  Purpose     Udp socket implementation. This IO class provide
 *              Write\Read function.
 */
class BASE_EXPORT UdpSock
{
public:
	UdpSock(struct event_base *event_base, 
		    uint16_t port, 
			const char *host, 
			ProxySet *proxyset = NULL);
	virtual ~UdpSock(){}

public:
	// dispatch for libevent
	static void OnSocketEvent(int fd, short event, void *arg);
	// event arrived
	void        OnEvent(int fd, short event);

	SOCKET      sock() { return sock_; }
	// Bind listener
	void        Bind(NIOInputAbleInterface *h) { listener_ = h; }
	// Send binary data
	int         Write(uint32_t ip, uint16_t port, const void *data, size_t size);
	// Receive binary data
	int         Read(uint32_t &ip, uint16_t &port, void *data, size_t size);

private:
	SOCKET                 sock_;           // udp socket
	struct event_base     *event_base_;     // event base struct
	struct event           event_read_;     // read event
	NIOInputAbleInterface *listener_;       // <reference>
};

/*
 *  Purpose     Udp IO template class inherit UdpSock. This IO class used reference count.
 *              This class implementation the OnRead() callback method and call template object
 *              OnPacket() method
 */
template <class IOClass>
class UdpIO : public nbase::UdpSock,
	          public nbase::NIOInputAbleInterface,
	          public nbase::RefCount
{
	IOClass & io_;

public:
	UdpIO(IOClass &io, 
          struct event_base *event_base, 
          const char *ip, 
          uint16_t port)
		: nbase::UdpSock(event_base, port, ip), io_(io)
	{
		Bind(this);
	}
	virtual ~UdpIO(){}

	void OnRead()
	{
		// Add reference count to prevent crash when the object destroy
		this->AddRef();
		nbase::scoped_refptr<UdpIO> ref = this;

		for (uint32_t nmax = 100; nmax > 0; --nmax)
		{// must setting a max packet count here
			char buff[1024*32];
			uint32_t ip;
			uint16_t port;
			int n = Recvfrom(ip, port, buff, sizeof(buff));
			if (n <= 0)
				break;
			else
			{// n > 0
				try
				{
					// Call template object's OnPacket() method
					io_.OnPacket(ip, port, (const char *)buff, n);
				}
				catch(const std::runtime_error &){}
			}
		}
	}
	int  Sendto(uint32_t ip, uint16_t port, const void * data, size_t size)
	{
		try
		{
			return Write(ip, port, data, size);
		}
		catch(const std::runtime_error &)
		{
			return 0;
		}
	}
	int  Recvfrom(uint32_t &ip, uint16_t &port, void *buf, size_t size)
	{
		try
		{
			return Read(ip, port, buf, size);
		}
		catch(const std::runtime_error &)
		{
			return 0;
		}
	}
};

#else
#endif  // WITH_LIBEVENT

}  // namespace nbase

#endif  // BASE_NETWORK_NIO_BASE_UDP_H_