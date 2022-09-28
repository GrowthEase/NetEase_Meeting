// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nipclib/ipc/ipc_server.h"
#include "../../nipclib/base/packet.h"
#include "nipclib/socket/socket_wrapper.h"
NIPCLIB_BEGIN_DECLS

void IPCServer::OnInternalBegin() {
    if (tcp_impl_) {
        tcp_impl_->SetHandler(nullptr);
    }
    tcp_impl_ = std::make_shared<NS_NIPCLIB::internal::TcpServerImpl>();
    tcp_impl_->SetHandler(this);
    bool ret = tcp_impl_->Init(ipc_port_);
    InvokeInitCallback(ret, tcp_impl_->GetBindHost(), tcp_impl_->GetBindPort());
}
void IPCServer::OnInternalEnd() {}
void IPCServer::DoClose() {
    Log(1, "DoClose.");
    SetReady(false);
    if (tcp_impl_)
        tcp_impl_->Close();
}

int IPCServer::InvokeSendData(const IPCData& data) {
    Log(1, "InvokeSendData.");
    if (client_ != nullptr) {
        std::size_t len = client_->Write(data->data(), data->size());
        if (data->size() == len) {
            keep_alive_latest_ = std::chrono::steady_clock::now();
            Log(1, "client_ Write successfully.");
        } else {
            Log(1, "client_ Write failed.");
        }
        return len;
    }
    return -1;
}
void IPCServer::Reset() {
    Log(1, "Reset.");
    SetReady(false);
    std::lock_guard<std::recursive_mutex> auto_lock(client_socket_fd_lock_);
    client_fd_ = -1;
    if (client_ != nullptr) {
        client_->SetHandler(nullptr);
        client_ = nullptr;
    }
    if (client_handler_ != nullptr) {
        client_handler_ = nullptr;
    }
}
void IPCServer::AttachClientClose(const std::function<void()>& client_close_callback) {
    client_close_callback_ = client_close_callback;
}

void IPCServer::OnClose(int error_code) {
    Log(1, std::string("OnClose."));
}
void IPCServer::OnClientClose(int error_code) {
    Log(1, std::string("OnClientClose."));
    TaskLoop()->PostTask(ToWeakCallback([this]() {
        Reset();
        if (client_close_callback_ != nullptr)
            client_close_callback_();
    }));
}
bool IPCServer::OnAccept(void* client_fd) {
    Log(1, std::string("OnAccept."));
    if (client_fd_ != -1) {
        Log(1, std::string("client_fd_ is not -1."));
        return false;
    }
    std::lock_guard<std::recursive_mutex> auto_lock(client_socket_fd_lock_);
    if (client_fd_ == -1) {
        Log(1, std::string("client_fd_ is -1."));
        client_fd_ = (int64_t)client_fd;
        TaskLoop()->PostTask(ToWeakCallback([this]() {
            if (nullptr == tcp_impl_) {
                Log(1, std::string("tcp_impl_ is null."));
                return;
            }
            client_ = tcp_impl_->GetClient(client_fd_);
            if (nullptr == client_) {
                Log(1, std::string("client_ is null."));
                return;
            }
            client_handler_ = std::make_unique<ClinetHandler>(this);
            client_->SetHandler(client_handler_.get());
            std::shared_ptr<std::string> ipc_data = std::make_shared<std::string>("server ack");
            Log(1, std::string("send server ack"));
            SendData(ipc_data);
        }));
        return true;
    }
    return false;
}

void IPCServer::OnError(int error_code, const void* data, size_t size) {
    Log(1, std::string((char*)data, size));
}

void IPCServer::OnReceive(const IPCData& data) {
    if (Ready()) {
        keep_alive_latest_ = std::chrono::steady_clock::now();
        InvokeReceiveDataCallback(data);
    } else {
        if (data->compare("client ack") == 0) {
            Log(1, std::string("client ack"));
            SendData(MakeIPCData("negotiation completed"));
        } else if (data->compare("negotiation completed") == 0) {
            Log(1, std::string("negotiation completed"));
            SendData(MakeIPCData("transport ready"));
            SetReady();
            keep_alive_latest_ = std::chrono::steady_clock::now();
            std::thread* keep_alive_thread_ = new std::thread([this]() {
                while (Ready()) {
                    if (std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - keep_alive_latest_).count() > 1) {
                        if (!Ready()) {
                            break;
                        }
                        SendData(MakeIPCData("keep alive"));
                        keep_alive_latest_ = std::chrono::steady_clock::now();
                    }

                    if (!Ready()) {
                        break;
                    }

                    std::this_thread::sleep_for(std::chrono::seconds(1));
                    if (!Ready()) {
                        break;
                    }
                }
                keep_alive_exit_ = true;
            });
            keep_alive_thread_->detach();
        }
    }
}

NIPCLIB_END_DECLS
