/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nipclib/ipc/ipc_client.h"
NIPCLIB_BEGIN_DECLS

void IPCClient::OnInternalBegin() {
    tcp_impl_ = std::make_shared<NS_NIPCLIB::internal::TcpClientImpl>();
    tcp_impl_->SetHandler(this);
    bool ret = tcp_impl_->Init("127.0.0.1", ipc_port_);
    if (tcp_impl_->GetLocalPort() == 0)
        ret = false;
    InvokeInitCallback(ret, tcp_impl_->GetHost(), tcp_impl_->GetLocalPort());
    if (!ret)
        Close();
}
void IPCClient::OnInternalEnd() {}
void IPCClient::DoClose() {
    tcp_impl_->Close();
}
int IPCClient::InvokeSendData(const IPCData& data) {
    return tcp_impl_->Write(data->data(), data->size());
}
void IPCClient::OnClose(int error_code) {
    TaskLoop()->PostTask([this]() {
        std::cout << "OnClose" << std::endl;
        tcp_impl_->Close();
        InvokeCloseCallback();
    });
}
void IPCClient::OnConnect(int error_code) {}
void IPCClient::OnReceive(const IPCData& data) {
    if (Ready()) {
        keep_alive_latest_ = std::chrono::steady_clock::now();
        if (data->compare("keep alive") == 0) {
        } else {
            InvokeReceiveDataCallback(data);
        }
    } else {
        // if (data->compare("close") == 0)
        //{
        //	tcp_impl_->Close();
        //	InvokeCloseCallback();
        //}
        // else
        if (data->compare("server ack") == 0) {
            SendData(MakeIPCData("client ack"));
        } else if (data->compare("negotiation completed") == 0) {
            SendData(MakeIPCData("negotiation completed"));
        } else if (data->compare("transport ready") == 0) {
            SetReady();
            keep_alive_latest_ = std::chrono::steady_clock::now();
            keep_alive_thread_ = std::make_unique<std::thread>([this]() {
                while (Ready()) {
                    int runTime = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - keep_alive_latest_).count();
                    int sleepTime = keep_alive_interval_ - runTime - (2 == keep_alive_interval_) ? 2 : 1;
                    sleepTime = sleepTime > 0 ? sleepTime : 0;
                    if (keep_alive_interval_ >= 0 && runTime >= keep_alive_interval_) {
                         InvokeKeepAliveTimeOutCallback();
                         break;
                    } else if (keep_alive_interval_ > 1 && sleepTime > 0) {
                        std::this_thread::sleep_for(std::chrono::seconds(sleepTime));
                    }
                }
            });
            keep_alive_thread_->detach();
        }
    }
}

NIPCLIB_END_DECLS
