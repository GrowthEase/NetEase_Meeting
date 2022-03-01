/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_SOCKET_SOCKET_HANDLER_H__
#define NIPCLIB_SOCKET_SOCKET_HANDLER_H__

#include <stddef.h>

#if !defined(OS_WIN)
#define SOCKET_ERROR	(-1)
#define ERROR_SUCCESS	0L
#define NO_ERROR		0L
#endif

NIPCLIB_BEGIN_DECLS

class NIPCLIB_EXPORT TcpClientHandler
{
public:
	virtual bool OnAcceptClient(void* client_fd) = 0;
	virtual void OnSocketClose(int error_code) = 0;
	virtual void OnSocketConnect(int error_code) = 0;
	virtual void OnReceiveSocketData(int error_code, const void *data, size_t size) = 0;//接收到的数据直接传输过来
	virtual void OnSendSocketData(int error_code) = 0;

};


NIPCLIB_END_DECLS
#endif // NIPCLIB_SOCKET_SOCKET_HANDLER_H__
