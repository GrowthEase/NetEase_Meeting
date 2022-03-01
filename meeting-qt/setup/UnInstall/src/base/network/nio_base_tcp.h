/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/14
//
// Network io async tcp socket

#ifndef BASE_NETWORK_NIO_BASE_TCP_H_
#define BASE_NETWORK_NIO_BASE_TCP_H_

#include "nio_base.h"

namespace nbase
{

#if defined(WITH_LIBEVENT)

/*
 *  Purpose     Tcp client implementation. This IO class provide
 *              Write\Read function and callback from Read\Write\Close\Connect
 *              events. It is used on client usualy.
 */
class BASE_EXPORT TcpClient : public NIOBinaryClientInterface
{
public:
	TcpClient(struct event_base *event_base);
	~TcpClient();

public:
	// dispatch for libevent
	static void OnSocketEvent(int fd, short event, void *arg);
	// on event arrived
	void OnEvent(int fd, short event);

public:  // from NIOClientInterface, event callback
	virtual void OnRead()    {}
	virtual void OnWrite()   {}
	virtual void OnClose()   {}
	virtual void OnConnect() {}

	SOCKET sock() { return sock_; }
	// Bind listener
	void   Bind(NIOClientInterface *h) { listener_ = h; }
	// Select
	void   Select(event_t add, event_t remove);
	// Connect to server
	int    Connect(const char *host, int port);
	// Send binary data
	int    Write(const void *data, size_t size);
	// Receive binary data
	int    Read(void *buf, size_t size);

private:
	inline NIOClientInterface* listener()
	{
		if (listener_)  
			return listener_;
		else
			return this;
	}

private:
	SOCKET                  sock_;              // client socket
	struct event_base      *event_base_;        // event base struct
	struct event            event_read_;        // read event
	struct event            event_write_;       // write event
	NIOClientInterface     *listener_;          // <reference>
	std::string             host_;              // host ip address
	int                     port_;              // host port
	bool                    connected_;         // is connected
};

/*
 *  Purpose     Tcp connnection implementation. This IO class provide
 *              Write\Read function and callback from Read\Write\Close
 *              events. It is used with TcpServer together usualy.
 */
class BASE_EXPORT TcpConnection : public NIOBinaryConnectionInterface
{
public:
	TcpConnection(SOCKET fd, struct event_base *event_base);
	virtual ~TcpConnection();

public:
	// dispatch for libevent
	static void OnSocketEvent(int fd, short event, void *arg);
	// on event arrived
	void OnEvent(int fd, short event);

public:  // from ConnectionHandler
	virtual void OnRead()  {}
	virtual void OnWrite() {}
	virtual void OnClose() {}

public:
	SOCKET sock() { return sock_; }
	// Bind listener
	void   Bind(NIOConnectionInterface *h) { listener_ = h; }
	// from BinaryClient >>
	void   Select(event_t add, event_t remove);
	// Send binary data
	int    Write(const void *data, size_t size);
	// Receive binary data
	int    Read(void *buf, size_t size);

private:
	inline NIOConnectionInterface * listener()
	{
		if (listener_)  
			return listener_;
		else
			return this;
	}

private:
	SOCKET                  sock_;            // socket
	struct event_base      *event_base_;      // event base struct
	struct event            event_read_;      // read event
	struct event            event_write_;     // write event
	NIOConnectionInterface *listener_;        // <reference>
	std::string             peer_;            // peer ip
};


/*
 *  Purpose     Tcp server implementation. This IO class provide
 *              callback from Accept events.
 *              It is used on server mode usualy.
 */
class BASE_EXPORT TcpServer : public NIOServerAbleInterface
{
public:
	TcpServer(struct event_base *event_base, uint16_t port, const char *host = NULL);
	virtual ~TcpServer();

public:
	// dispatch for libevent
	static void OnSocketEvent(int fd, short event, void *arg);
	// event arrived
	void OnEvent(int fd, short event);

public:  // from TcpServerHandler
	virtual void OnAccept(SOCKET fd) {}

public:
	SOCKET sock() { return sock_; }
	// Bind listener
	void   Bind(NIOServerAbleInterface *h) { listener_ = h; }
	// Listen the socket
	int    Listen(int backlog = 500);

private:
	inline NIOServerAbleInterface* listener()
	{
		if (listener_)
			return listener_;
		else
			return this;
	}

private:
	SOCKET                  sock_;          // socket
	struct event_base      *event_base_;    // event base struct
	struct event            event_read_;    // accept event
	NIOServerAbleInterface *listener_;      // <reference>
};

#elif defined(WITH_IOCP)

//#include "base/framework/win_io_message_pump.h"

/*
 *  Purpose     Tcp client implementation. This IO class provide
 *              Write\Read function and callback from IOCP
 *              events. It is used on client usualy.
 */
class BASE_EXPORT TcpClient : public NIOBinaryClientInterface
{
public:
	TcpClient();
	~TcpClient();

public:  // from NIOClientInterface, event callback
	virtual void OnRead()    {}
	virtual void OnWrite()   {}
	virtual void OnClose()   {}
	virtual void OnConnect() {}

	SOCKET sock() { return sock_; }
	// Bind listener
	void   Bind(NIOClientInterface *h) { listener_ = h; }
	// Connect to server
	int    Connect(const char *host, int port);
	// Send binary data
	int    Write(const void *data, size_t size);
	// Receive binary data
	int    Read(void *buf, size_t size);

private:
	inline NIOClientInterface* listener()
	{
		if (listener_)  
			return listener_;
		else
			return this;
	}

private:
	SOCKET                  sock_;              // client socket
	NIOClientInterface     *listener_;          // <reference>
	std::string             host_;              // host ip address
	int                     port_;              // host port
	bool                    connected_;         // is connected
};
#else

#endif  // WITH_LIBEVENT or WITH_IOCP

}  // namespace nbase

#endif  // BASE_NETWORK_NIO_BASE_TCP_H_