/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/14
//
// Network io async tcp socket implementation by libevent

#include "nio_base_tcp.h"

#if defined(WITH_LIBEVENT)

namespace nbase
{

// TcpClient ---------------------------------------------------------
TcpClient::TcpClient(struct event_base *event_base)
	: sock_(-1), event_base_(event_base), listener_(0), port_(0), connected_(false)
{
	// create socket
	sock_ = ::socket(AF_INET, SOCK_STREAM, 0);
	if (sock_ == INVALID_SOCKET)
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpClient: socket() error");
	}
	else
	{
		// bind read and write event into libevent
		event_set(&event_read_,  (int)sock_, EV_READ|EV_PERSIST, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_read_);
		event_add(&event_read_,  NULL);
		event_set(&event_write_, (int)sock_, EV_WRITE, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_write_);
		event_add(&event_write_, NULL);
	}
}

TcpClient::~TcpClient()
{
	// delete event from libevent
	event_del(&event_read_);
	event_del(&event_write_);
	// close socket
	::closesocket(sock_);
}

void TcpClient::OnSocketEvent(int fd, short event, void *arg)
{
	TcpClient *client = (TcpClient *)arg;
	assert(client);
	client->OnEvent(fd, event);
}

void TcpClient::OnEvent(int fd, short event)
{
	assert(fd == sock_);
	if (!connected_)
	{// if not connected yet, this event means connected
		if (event & EV_WRITE)
		{
			// connected
			connected_ = true;
			//event_del(&event_write_);
			listener()->OnConnect();
			return;
		}
	}
	if (event & EV_READ)
	{
		// The READ event will occur when socket disconnected on select/poll mode.
		// So that we must get the state to help us judge if it is Read or Close event.
		char buf[1];
		int n = ::recv(sock_, buf, 1, MSG_PEEK);
		if (n == 0 || (n == SOCKET_ERROR && !would_block()))
			listener()->OnClose();
		else
			listener()->OnRead();
	}
	else if (event & EV_WRITE)
	{
		// Write event
		listener()->OnWrite();
	}
}

void TcpClient::Select(event_t add, event_t remove)
{
	if (sock_ == INVALID_SOCKET)
	{
		return;
	}
	add    &= EREAD | EWRITE;
	remove &= EREAD | EWRITE;
	add    &= ~remove;
	if (add & EREAD)
	{
		event_del(&event_read_);
		event_set(&event_read_, (int)sock_, EV_READ|EV_PERSIST, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_read_);
		event_add(&event_read_, NULL);
	}
	if (add & EWRITE)
	{
		event_del(&event_write_);
		event_set(&event_write_, (int)sock_, EV_WRITE, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_write_);
		event_add(&event_write_, NULL);
	}
	if (remove & EREAD)
	{
		event_del(&event_read_);
	}
	if (remove & EWRITE)
	{
		event_del(&event_write_);
	}
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
		event_del(&event_write_);
		event_set(&event_write_, (int)sock_, EV_WRITE, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_write_);
		event_add(&event_write_, NULL);
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

// TcpConnection ---------------------------------------------------------
TcpConnection::TcpConnection(SOCKET fd, struct event_base *event_base)
	: sock_(fd), event_base_(event_base), listener_(0)
{
	if (sock_ == INVALID_SOCKET)  
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpConnection: invalid socket");
	}
	else
	{
		set_block(sock_, false);

		// get peer ip from socket
		sockaddr_in addr;
		int         len = sizeof(addr);
		::getpeername(sock_, (sockaddr *)&addr, (socklen_t*)&len);
		peer_ = ::inet_ntoa(addr.sin_addr);

		// initialize event listen
		event_set(&event_read_,  (int)sock_, EV_READ|EV_PERSIST, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_read_);
		event_add(&event_read_,  NULL);
		event_set(&event_write_, (int)sock_, EV_WRITE, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_write_);
		event_add(&event_write_,  NULL);
	}
}

TcpConnection::~TcpConnection()
{
	event_del(&event_read_);
	event_del(&event_write_);
	::closesocket(sock_);
}

void TcpConnection::OnSocketEvent(int fd, short event, void *arg)
{
	TcpConnection *connection = (TcpConnection *)arg;
	assert(connection);
	connection->OnEvent(fd, event);
}

void TcpConnection::OnEvent(int fd, short event)
{
	assert(fd==sock_);

	if (event & EV_READ)
	{
		// The READ event will occur when socket disconnected on select/poll mode.
		// So that we must get the state to help us judge if it is Read or Close event.
		char buf[1];
		int n = ::recv(sock_, buf, 1, MSG_PEEK);
		if (n == 0 || (n == SOCKET_ERROR && !would_block()))
			listener()->OnClose();
		else
			listener()->OnRead();
	}
	else if (event & EV_WRITE)
	{
		listener()->OnWrite();
	}
}

void TcpConnection::Select(event_t add,event_t remove)
{
	if ( sock_==INVALID_SOCKET )  
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpConnection: invalid socket");
		return;
	}
	add    &= EREAD | EWRITE;
	remove &= EREAD | EWRITE;
	add    &= ~remove;
	if (add & EREAD)
	{
		event_del(&event_read_);
		event_set(&event_read_, (int)sock_, EV_READ|EV_PERSIST, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_read_);
		event_add(&event_read_, NULL);
	}
	if (add & EWRITE)
	{
		event_del(&event_write_);
		event_set(&event_write_, (int)sock_, EV_WRITE, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_write_);
		event_add(&event_write_, NULL);
	}
	if (remove & EREAD)
	{
		event_del(&event_read_);
	}
	if (remove & EWRITE)
	{
		event_del(&event_write_);
	}
}

int TcpConnection::Write(const void * data,size_t size)
{
	int n = ::send(sock_, (const char *)data, size, 0);
	if (n == -1 && !would_block())
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpConnection: Write() send() error");
		return 0;
	}
	if (n == -1)      
		n = 0;
	// Set the write event when we can't send
	if (n < (int)size)
	{
		event_del(&event_write_);
		event_set(&event_write_, (int)sock_, EV_WRITE, OnSocketEvent, this);
		if (NULL != event_base_)
			event_base_set(event_base_, &event_write_);
		event_add(&event_write_, NULL);
	}
	return n;
}

int TcpConnection::Read(void *buf, size_t size)
{
	int n = ::recv(sock_, (char *)buf, size, 0);
	if (n == 0 || (n == -1 && !would_block()))
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpConnection: Read() recv() error");
		return 0;
	}
	if (n == -1)      
		n = 0;
	return n;
}

// TcpServer ---------------------------------------------------------
TcpServer::TcpServer(struct event_base *event_base, uint16_t port, const char *host)
	: event_base_(event_base), listener_(0)
{
	// create socket
	sock_ = ::socket(AF_INET, SOCK_STREAM, 0);
	if (sock_ == INVALID_SOCKET)
	{
		DEFLOG(nbase::LogInterface::LV_ERR, 
			   __FILE__, 
			   __LINE__, 
			   "nbase::TcpServer: invalid socket");
	}
	else
	{
		set_block(sock_, false);
		reuse_address(sock_);

		sockaddr_in addr;
		memset(&addr, 0, sizeof(addr));
		addr.sin_family = AF_INET;
		addr.sin_addr.s_addr = htonl(INADDR_ANY);
		if (NULL != host)
			addr.sin_addr.s_addr = ::inet_addr(host);
		addr.sin_port = htons(port);

		int r = ::bind(sock_, (const sockaddr *)&addr, sizeof(addr));
		if (r == SOCKET_ERROR && !would_block()) 
		{
			DEFLOG(nbase::LogInterface::LV_ERR, 
				   __FILE__, 
				   __LINE__, 
				   "nbase::TcpServer: bind() error");
		}
		else
		{
			event_set(&event_read_, (int)sock_, EV_READ|EV_PERSIST, OnSocketEvent, this);
			if (NULL != event_base_)
				event_base_set(event_base_, &event_read_);
			event_add(&event_read_, NULL);
		}
	}
}

TcpServer::~TcpServer()
{
	event_del(&event_read_);
	::closesocket(sock_);
}

void TcpServer::OnSocketEvent(int fd, short event, void *arg)
{
	TcpServer *server = (TcpServer *)arg;
	assert(server);
	server->OnEvent(fd, event);
}

void TcpServer::OnEvent(int fd, short event)
{
	assert(fd == sock_);
	if (event == EV_READ)
	{
		sockaddr addr;
		int      len = sizeof(addr);
		SOCKET   fd  = ::accept(sock_, &addr, (socklen_t*)&len);
		if (fd != INVALID_SOCKET)
			listener()->OnAccept(fd);
	}
}

int TcpServer::Listen(int backlog)
{
	int r = ::listen(sock_, backlog);
	if (r == SOCKET_ERROR && !would_block())
	{
		DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "nbase::TcpServer: bind() error");
	}
	return r;
}

}  // namespace nbase

#endif  // WITH_LIBEVENT