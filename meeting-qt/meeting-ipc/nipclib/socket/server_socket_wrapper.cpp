/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nipclib/socket/server_socket_wrapper.h"
#include "tnet_utils.h"
#include "tsk_debug.h"
#include "tnet_transport.h"
#include "tnet_proxydetect.h"
#include "nipclib/socket/socket_wrapper.h"
NIPCLIB_BEGIN_DECLS
namespace internal {

//static int OnNetLogCallback(const void* arg, const char* fmt, ...)
//{
//	va_list ap;
//	va_start(ap, fmt);
//	//#define buffer_size 2048
//	//	std::string msg;
//	//	msg.resize(buffer_size);
//	//	int length = vsnprintf_s(const_cast<char*>( msg.data()), buffer_size, buffer_size - 1, fmt, ap);
//	//	if (length < 0)
//	_vscprintf(fmt, ap);
//	va_end(ap);
//	return 0;
//}

TcpServerImpl::TcpServerImpl() :
    handler_(nullptr),
    socket_handle_(nullptr),
    bind_port_(0),
    host_("127.0.0.1")
{
}

TcpServerImpl::~TcpServerImpl()
{
    Close();
    handler_ = nullptr;
}
void TcpServerImpl::SetBindHost(const std::string& host)
{
    host_ = host;
}
void TcpServerImpl::SetHandler(TcpClientHandler *handler)
{
    handler_ = handler;
}
int TcpServerImpl::OnTcpCallback(const tnet_transport_event_t* e)
{
    auto weak_tcp_client = (std::weak_ptr<TcpServerImpl>*)(e->callback_data);
    auto tcp_client = ((weak_tcp_client != nullptr && !weak_tcp_client->expired()) ? weak_tcp_client->lock() : nullptr);
    if (nullptr == tcp_client)
    {
        delete weak_tcp_client;
        weak_tcp_client = nullptr;
        return -1;
    }
    switch (e->type) {
    case event_data:
    {
        tcp_client->OnReceive(e->local_fd, NO_ERROR, (const char*)e->data, e->size);
    }
    break;
    case event_error:
    case event_closed:
    {
        tcp_client->OnClose(e->local_fd, NO_ERROR);
    }
    break;
    case event_connected:
    {
        tcp_client->OnConnect(e->local_fd, ERROR_SUCCESS);
    }
    break;
    case event_accepted:
    {
        tcp_client->OnAccept(e->local_fd, NO_ERROR);

    }
    break;
    default:
    {
        break;
    }
    }
    return 0;
}
bool TcpServerImpl::Init(int port)
{
    InitLog();
    tnet_sockfd_init(host_.c_str(), port, tnet_socket_type_tcp_ipv4, &fd_);
    tnet_socket_t* srv_socket = new tnet_socket_t();
    memset(srv_socket, 0, sizeof(tnet_socket_t));
    srv_socket->port = port;
    srv_socket->type = tnet_socket_type_tcp_ipv4;
    srv_socket->fd = fd_;
    srv_socket->refCount = 1;
    memcpy(srv_socket->ip, host_.data(), host_.length());
    // memcpy_s(srv_socket->ip, host_.length(), host_.data(), host_.length());
    socket_handle_ = tnet_transport_create_2(srv_socket, "TCP/IPV4 TRANSPORT");
    if (nullptr == socket_handle_)
    {
        return false;
    }
    // Set our callback function
    tnet_transport_set_callback(socket_handle_, &TcpServerImpl::OnTcpCallback, new std::weak_ptr<TcpServerImpl>(shared_from_this()));
    if (tnet_transport_start(socket_handle_))
    {
        return false;
    }
    tnet_ip_t ip_t;
    tnet_transport_get_ip_n_port(socket_handle_, fd_, &ip_t, &bind_port_);
    return true;
}

void TcpServerImpl::InitLog()
{

}
void TcpServerImpl::RemoveClient(tnet_fd_t fd)
{
    std::lock_guard<std::mutex> auto_lock(client_socket_list__lock_);
    client_socket_list_.erase(fd);
}
void TcpServerImpl::AddClient(const std::shared_ptr<TcpClientImpl>& client)
{
    std::lock_guard<std::mutex> auto_lock(client_socket_list__lock_);
    client_socket_list_[client->fd_] = client;
}
void TcpServerImpl::Close()
{
    if (socket_handle_ != nullptr)
    {
        tnet_transport_set_callback(socket_handle_, nullptr, nullptr);//将BizTcpClient作为回调数据传到回调函数里，方便接口访问。
        TSK_OBJECT_SAFE_FREE(socket_handle_);//该释放操作会执行close fd，无需在上层显示关闭
    }
}

void TcpServerImpl::OnClose(tnet_fd_t fd, int error_code)
{
    auto client = GetClient(fd);
    if (client != nullptr)
        client->OnClose(error_code);
    RemoveClient(fd);
}
void TcpServerImpl::OnConnect(tnet_fd_t fd, int error_code)
{
    handler_->OnSocketConnect(error_code);
}

void TcpServerImpl::OnAccept(tnet_fd_t fd, int error_code)
{
    std::shared_ptr<TcpClientImpl> client = std::make_shared< TcpClientImpl>();
    client->Init(fd);
    client->socket_handle_ = socket_handle_;
    if (handler_->OnAcceptClient((void*)client->fd_))
    {
        AddClient(client);
    }
    else
    {
        client->Close();
    }
}

void TcpServerImpl::OnReceive(tnet_fd_t fd, int error_code, const void *data, size_t size)
{
    auto client = GetClient(fd);
    if (client != nullptr)
        client->OnReceive(error_code, data, size);
}

void TcpServerImpl::OnSend(tnet_fd_t fd, int error_code)
{
    auto client = GetClient(fd);
    if (client != nullptr)
        client->OnSend(error_code);
}
}
NIPCLIB_END_DECLS