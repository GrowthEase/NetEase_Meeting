/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

//
//  nio_proxy.cpp
//  eim_mac
//
//  Created by jezhee zhou on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include "nio_proxy.h"
#include "nio_base_tcp.h"
#include "base/util/base64.h"
#include "base/time/time.h"
#include "base/util/string_util.h"
#include "network_util.h"

#if defined(WITH_LIBEVENT) || defined(WITH_IOCP)

namespace nbase
{

/*字节对齐*/
#pragma pack(push, 1)

struct ProxySocketLayer::Sock5Req1    //socks5的第一次请求：验证用户
{
	char Ver; 
	char nMethods; 
	char Methods[255];
};
struct ProxySocketLayer::Sock5Ans1    //socks5的第一次应答
{ 
	char Ver; 
	char Method;
};
struct ProxySocketLayer::Socks5AuthReq  //socks5中需要用户名密码验证
{ 
	char Ver; 
	char Ulen; 
	char Name[255]; // 变长
	char PLen; 
	char Pass[255]; // 变长
};
struct ProxySocketLayer::Socks5AuthAns
{ 
	char Ver; 
	char Status; 
};
struct ProxySocketLayer::Sock5Req2   //socks5中第二次请求：连接目标地址
{
    char Ver; 
    char Cmd; 
    char Rsv; 
    char Atyp;
    char DomainLen;
    char Domain[512 - 5];
};

struct ProxySocketLayer::Sock5Ans2  //socks5中第二次应答
{ 
	char Ver; 
	char Rep;
	char Rsv; 
	char Atyp; 
	char other[256];
};
struct ProxySocketLayer::Sock4Req1  //socks4第一次请求
{ 
	char VN; 
	char CD; 
	unsigned short Port; 
	unsigned long IPAddr; 
	char other[256]; // 变长
};
struct ProxySocketLayer::Sock4aReq1 //socks4a第一次请求
{ 
	char VN; 
	char CD; 
	unsigned short Port; 
	char InvalidIP[4];
	char UserID[1];
	char Domain[512];
};
struct ProxySocketLayer::Sock4Ans1  //socks4和socks4a的第一次应答
{ 
	char VN; 
	char CD; 
	unsigned short Port; 
	unsigned long IPAddr; 
};

#pragma pack(pop)

ProxySocketLayer::ProxySocketLayer(nbase::TcpClient *client, const nbase::ProxySet *proxy)
{
    status_         = kStatusNotInited;
    tcp_client_     = client;
    proxy_.host_    = proxy->host_;
    proxy_.port_    = proxy->port_;
    proxy_.type_    = proxy->type_;
    proxy_.username_ = proxy->username_;
    proxy_.password_ = proxy->password_;
}

ProxySocketLayer::~ProxySocketLayer()
{
    
}

int ProxySocketLayer::Connect(const char *host, int port, uint32_t timeout/*=-1*/)
{
    host_ = host;
    port_ = port;
    
    if (timeout != -1) // 添加一个超时定时器
    {
        nbase::TimeDelta delay = nbase::TimeDelta::FromSeconds(timeout);
        connect_timer_.Start(delay, this, &ProxySocketLayer::OnConnectTimeout);
    }
    
    return tcp_client_->ConnectDirectly(proxy_.host_.c_str(), proxy_.port_);    
}

void ProxySocketLayer::OnRead()
{
    switch (proxy_.type_)
    {
        case kProxyTypeHttp11:
            Http11GetAuthResult();
            break;
        case kProxyTypeSocks5:
        {
            switch (status_)
            {
                case kStatusSocks5Request1:
                    Socks5GetResult1();
                    break;
                case kStatusSocks5Auth:
                    Socks5GetAuthResult();
                    break;
                case kStatusSocks5Request2:
                    Socks5GetResult2();
                    break;
                default:
                    break;
            }
        }
            break;
        case kProxyTypeSocks4:
        case kProxyTypeSocks4A:
            Socks4GetResult();
            break;
        case kProxyTypeSocks5UDP: // TODO:
            break;
        default:
            break;
    }
    
    // 没人处理了，把数据读走，以免卡死
    const int kBufLen = 1024;
    char buf[kBufLen];
    tcp_client_->Read(buf, kBufLen);
}

void ProxySocketLayer::OnConnect()
{
    assert(status_ == kStatusNotInited);
    status_ = kStatusServerConnected;
    switch (proxy_.type_)
    {
        case kProxyTypeHttp11:
            Http11SendAuthRequest();
            break;
        case kProxyTypeSocks5:
            Socks5SendRequest1();
            break;
        case kProxyTypeSocks4:
            Socks4SendRequest();
            break;
        case kProxyTypeSocks4A:
            Socks4aSendRequest();
            break;
        case kProxyTypeSocks5UDP: // TODO:
            break;
        default:
            break;
    }
}
    
void ProxySocketLayer::OnConnectTimeout()
{
    status_ = kStatusConnectFailed;
}

bool ProxySocketLayer::IsProxyConnected()
{
    return status_ == kStatusHostConnected;
}

void ProxySocketLayer::DoWhenConnectFailed()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Setup proxy error, type=%d, status=%d", proxy_.type_, status_);
    
    status_ = kStatusConnectFailed;
    connect_timer_.Stop();
}
    
void ProxySocketLayer::DoWhenConnectted()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
            __FILE__, 
            __LINE__, 
            "connect proxy successed, type=%d", proxy_.type_);
    status_ = kStatusHostConnected;
    connect_timer_.Stop();
}
    
bool ProxySocketLayer::Http11SendAuthRequest()
{
    char buff[10240];
	if (!proxy_.username_.empty())
	{
		/*"用户名:密码" 需要经过base64编码*/
		std::string authInfo = proxy_.username_ + ":" + proxy_.password_;
        nbase::Base64Encode(authInfo, &authInfo);
        
		sprintf(buff, "CONNECT %s:%d HTTP/1.1\r\nHost: %s:%d\r\nProxy-Authorization: Basic %s\r\nProxy-Connection: Keep-Alive\r\n\r\n", 
                host_.c_str(), port_, host_.c_str(), port_, authInfo.c_str()); 
	}
	else
	{
		sprintf(buff, "CONNECT %s:%d HTTP/1.1\r\nHost: %s:%d\r\nProxy-Connection: Keep-Alive\r\n\r\n", 
                host_.c_str(), port_, host_.c_str(), port_); 
	}
    
	if (0 != tcp_client_->Write(buff, (int)strlen(buff)))
    {
        DEFLOG(nbase::LogInterface::LV_APP, 
               __FILE__, 
               __LINE__, 
               "Http11SendAuthRequest, send buffer: %s", buff);
        
        status_ = kStatusHttp11Auth;
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}

bool ProxySocketLayer::Http11GetAuthResult()
{
    const char start[] = "HTTP/";
    const int kBufLen = 10240;
    char buf[kBufLen];
    std::string upper_string;
    int received = tcp_client_->Read(buf, kBufLen);
    if (received <= 0)
        return false;
    buf[received] = '0';
    upper_string = nbase::MakeUpperString(buf);
	int start_len = strlen(start);
    if (received < start_len || memcmp(start, upper_string.c_str(), start_len))
    {
        goto failed;
    }
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Http11GetAuthResult, recv buffer: %s", buf);
    
    if (upper_string.find("200 CONNECTION ESTABLISHED") != std::string::npos || upper_string.find("200 OK") != std::string::npos)
    {
        DoWhenConnectted();
        return true;
    }
    
failed:
    DoWhenConnectFailed();
    return false;
}

bool ProxySocketLayer::Socks5SendRequest1()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Socks5SendRequest1, type=%d, status=%d", proxy_.type_, status_);
    
    // 第一次请求：验证用户
	Sock5Req1 request1;
    memset(&request1, 0, sizeof(request1));
	request1.Ver = 0x05;			// socks5
	request1.nMethods = 0x02;		// 验证方式的总数
	request1.Methods[0] = 0x00;	// NO AUTHENTICATION REQUIRED
	request1.Methods[1] = 0x02;	// USERNAME/PASSWORD
    if (tcp_client_->Write((char *)&request1, 2 + request1.nMethods) != 0)
    {
        status_ = kStatusSocks5Request1;
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks5GetResult1()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Socks5GetResult1, type=%d, status=%d", proxy_.type_, status_);
    
    // 第一次应答
	Sock5Ans1 reply1;
    int num = tcp_client_->Read((char *)&reply1, sizeof(reply1));
    if (0 == num || reply1.Ver != 5)
    {
        goto cleanup;
    }
    /*需要用户名和密码验证*/
    if (reply1.Method == 0x02)
    {
        Socks5SendAuthRequst();
        return true;
    }
    else if (reply1.Method == 0x00)
    {
        Socks5SendRequst2();
        return true;
    }
    
cleanup:
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks5SendAuthRequst()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Socks5SendAuthRequst, type=%d, status=%d", proxy_.type_, status_);
    
    char buff[10240];
    Socks5AuthReq * auth_req = (Socks5AuthReq *)buff;
    int req_len = 0;
    auth_req->Ver = 0x01; req_len ++;
    auth_req->Ulen = (char)proxy_.username_.length(); req_len ++;
    strcpy(auth_req->Name, proxy_.username_.c_str()); req_len += (int)proxy_.username_.length();
    char pwd_len = (char)proxy_.password_.length();
    memcpy((char*)auth_req+req_len, &pwd_len, 1); req_len ++;
    strcpy((char*)auth_req+req_len, proxy_.password_.c_str()); req_len += (int)proxy_.password_.length();
    
    if (0 != tcp_client_->Write((char *)auth_req, req_len))
    {
        status_ = kStatusSocks5Auth;
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks5GetAuthResult()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Socks5GetAuthResult, type=%d, status=%d", proxy_.type_, status_);
    
    /*关于身份验证的应答*/
    Socks5AuthAns auth_reply;
    int num = tcp_client_->Read((char *)&auth_reply, sizeof(auth_reply));
    if (num != 0 && auth_reply.Status == 0x00)
    {
        Socks5SendRequst2();
        return true;
    }
    
    DoWhenConnectFailed();
    return false; 
}
    
bool ProxySocketLayer::Socks5SendRequst2()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Socks5SendRequst2, type=%d, status=%d", proxy_.type_, status_);
    
    // 第二次请求：连接目标地址
    int req_len;
	Sock5Req2 req2;
	req2.Ver = 0x05; // socks版本
	req2.Cmd = 0x01; // CONNECT X'01', BIND X'02', UDP ASSOCIATE X'03'
	req2.Rsv = 0x00; // RESERVED
	req2.Atyp = 0x03; // IP V4 address: X'01', DOMAINNAME: X'03', IP V6 address: X'04'
	req2.DomainLen = (char)host_.length(); // 1 byte of name length
	strcpy(req2.Domain, host_.c_str()); // the name for Domain name
	*(u_short*)(req2.Domain + host_.length()) = ntohs(port_); // network byte order port number, 2 bytes
    
	req_len = 5 + (int)host_.length() + 2;
    if (0 != tcp_client_->Write((char *)&req2, req_len))
    {
        status_ = kStatusSocks5Request2;
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks5GetResult2()
{
    DEFLOG(nbase::LogInterface::LV_APP, 
           __FILE__, 
           __LINE__, 
           "Socks5GetResult2, type=%d, status=%d", proxy_.type_, status_);
    
    // 第二次应答
	Sock5Ans2 reply2;
	memset(&reply2, 0, sizeof(reply2));
    
    int num = tcp_client_->Read((char *)&reply2, sizeof(reply2));
    if (num != 0 && reply2.Rep == 0x00) // 连接成功，万事OK
    {
        DoWhenConnectted();
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks4SendRequest()
{
    Sock4Req1 request_4;
    request_4.VN = 0x04; // VN是SOCK版本，应该是4；
    request_4.CD = 0x01; // CD是SOCK的命令码，1表示CONNECT请求，2表示BIND请求；
    request_4.Port = ntohs(port_);
    request_4.IPAddr = nbase::InetStringToNumber(host_);
    request_4.other[0] = '\0';
        
    if (0 != tcp_client_->Write((char *)&request_4, 9))
    {
        status_ = kStatusSocks4Auth;
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks4aSendRequest()
{
    Sock4aReq1 request_4a;		// Socks4的请求   
    request_4a.VN = 0x04; // VN是SOCK版本，应该是4；
	request_4a.CD = 0x01; // CD是SOCK的命令码，1表示CONNECT请求，2表示BIND请求；
	request_4a.Port = ntohs(port_);
	memset(request_4a.InvalidIP, 0, 4); request_4a.InvalidIP[3] = 0x1; // first three must be 0x00 and the last one must not be 0x00
	request_4a.UserID[0] = 0x0;
	strcpy(request_4a.Domain, host_.c_str());
    if (0 != tcp_client_->Write((char *)&request_4a, 9 + host_.length() + 1))
    {
        status_ = kStatusSocks4Auth;
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
bool ProxySocketLayer::Socks4GetResult()
{
    Sock4Ans1 reply;
    int num = tcp_client_->Read((char *)&reply, sizeof(reply));
    if (num != 0 && reply.CD == 90) 
    {
        DoWhenConnectted();
        return true;
    }
    
    DoWhenConnectFailed();
    return false;
}
    
}

#endif  // WITH_LIBEVENT or WITH_IOCP