// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NIPCLIB_SERVER_SOCKET_WRAPPER_H__
#define NIPCLIB_SERVER_SOCKET_WRAPPER_H__

#include "nipclib/config/build_config.h"
#include "nipclib/nipclib_export.h"

#include <memory.h>
#include <map>
#include <mutex>
#include "nipclib/proxy_config/proxy_info.h"
#include "nipclib/socket/socket_handler.h"
#include "tnet_transport.h"

NIPCLIB_BEGIN_DECLS

namespace internal {
class TcpClientImpl;
class NIPCLIB_EXPORT TcpServerImpl : public std::enable_shared_from_this<TcpServerImpl> {
public:
    TcpServerImpl();
    virtual ~TcpServerImpl();
    void SetHandler(TcpClientHandler* handler);
    void SetBindHost(const std::string& host);
    std::string GetBindHost() const { return host_; }
    int GetBindPort() const { return bind_port_; }
    bool Init(int port);
    void Close();
    inline std::shared_ptr<TcpClientImpl> GetClient(tnet_fd_t fd) const {
        std::shared_ptr<TcpClientImpl> ret = nullptr;
        std::lock_guard<std::mutex> auto_lock(client_socket_list__lock_);
        auto it = client_socket_list_.find(fd);
        if (it != client_socket_list_.end())
            ret = it->second;
        return ret;
    }

protected:
    void OnClose(tnet_fd_t fd, int error_code);
    void OnConnect(tnet_fd_t fd, int error_code);
    void OnAccept(tnet_fd_t fd, int error_code);
    void OnReceive(tnet_fd_t fd, int error_code, const void* data, size_t size);
    void OnSend(tnet_fd_t fd, int error_code);
    void OnError(int error_code, const void* data, size_t size);
    static int OnTcpCallback(const tnet_transport_event_t* e);

private:
    void InitLog();

    void RemoveClient(tnet_fd_t fd);
    void AddClient(const std::shared_ptr<TcpClientImpl>& client);

private:
    TcpClientHandler* handler_ = nullptr;
    tnet_transport_t* socket_handle_ = nullptr;
    tnet_fd_t fd_ = -1;
    std::string host_;
    tnet_port_t bind_port_;
    mutable std::mutex client_socket_list__lock_;
    std::map<tnet_fd_t, std::shared_ptr<TcpClientImpl>> client_socket_list_;
};
}  // namespace internal

NIPCLIB_END_DECLS
#endif  // NIPCLIB_SERVER_SOCKET_WRAPPER_H__
