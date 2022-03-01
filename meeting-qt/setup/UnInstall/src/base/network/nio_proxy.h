/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2012, NetEase Inc. All rights reserved.
//
// Author: zhoujianghua<zhoujianghua@corp.netease.com>
// Date: 2012-3-27
//
// Network io proxy interface

#ifndef BASE_NETWORK_NIO_PROXY_H_
#define BASE_NETWORK_NIO_PROXY_H_
#include "nio_base.h"

#if defined(WITH_LIBEVENT) || defined(WITH_IOCP)

namespace nbase
{
class TcpClient;
    
class ProxySocketLayer
{
public:
    ProxySocketLayer(TcpClient *client, const ProxySet *proxy);
    ~ProxySocketLayer();
    
    int Connect(const char *host, int port, uint32_t timeout = -1);
    void OnRead();
	void OnConnect();
    bool IsProxyConnected();
    
    // 连接超时处理函数
    void OnConnectTimeout();
private:
    // Http11
    bool Http11SendAuthRequest();
    bool Http11GetAuthResult();
   
    // Socks5
    bool Socks5SendRequest1();
    bool Socks5GetResult1();
    bool Socks5SendAuthRequst();
    bool Socks5GetAuthResult();
    bool Socks5SendRequst2();
    bool Socks5GetResult2();
    
    // Socks4a 应答和Socks公用
    bool Socks4aSendRequest();
    // Socks4
    bool Socks4SendRequest();
    bool Socks4GetResult();
    
    void DoWhenConnectFailed();
    void DoWhenConnectted();
    
    
private:
    ProxySet        proxy_;         // 代理信息
    TcpClient       *tcp_client_;   // 执行真正的发送和接收任务
    std::string     host_;          // 待连接服务器的IP
	uint32_t        port_;          // 待连接的服务器的端口
    int             status_;        // 当前连接状态
    
    nbase::OneShotTimer<ProxySocketLayer> connect_timer_;   // 连接代理服务器的timer
    
    struct Sock5Req1;               //socks5的第一次请求：验证用户
	struct Sock5Ans1;               //socks5的第一次应答
	struct Socks5AuthReq;           //socks5中需要用户名密码验证
	struct Socks5AuthAns;           //socks5中关于用户名密码验证的应答
	struct  Sock5Req2;               //socks5中第二次请求：连接目标地址
	struct Sock5Ans2;               //socks5中第二次应答
	struct Sock4Req1;               //socks4第一次请求
	struct Sock4aReq1;              //socks4a第一次请求
	struct Sock4Ans1;               //socks4和socks4a的第一次应答
    
    enum ProxyConnectStatus
    {
        kStatusNotInited        = -1,   // 还没有连上代理服务器
        kStatusServerConnected  = 0,    // 和代理服务器已连接上
        kStatusConnectFailed,           // 连接已失败
        kStatusHostConnected,           // 成功，和目标主机已连上
        // 以下为各协议私用
        // http11
        kStatusHttp11Auth       = 10,   //
        // socks5
        kStatusSocks5Request1   = 20,
        kStatusSocks5Auth,
        kStatusSocks5Request2,
        //socks4
        kStatusSocks4Auth       = 30,
    };
};
}
#endif  // WITH_LIBEVENT or WITH_IOCP

#endif
