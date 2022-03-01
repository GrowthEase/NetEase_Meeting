/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NIPCLIB_PROXY_CONFIG_PROXY_INFO_H_
#define NIPCLIB_PROXY_CONFIG_PROXY_INFO_H_

#include "nipclib/nipclib_export.h"
#include "nipclib/config/build_config.h"

#include <string>

NIPCLIB_BEGIN_DECLS

//代理类型（不同的网络库的代理类型值可能不同，传入相应网络库时必须根据网络库本身的定义转换！！！）
enum ProxyType
{
	kProxyNone		= 0,	//	不使用Proxy
	kProxyHttp11		= 1,	//	HTTP 1.1 Proxy
	kProxyHttp10		= 2,	//	HTTP 1.0 Proxy
	kProxyHttps		= 3,	//	HTTPS Proxy
	kProxySocks4		= 4,
	kProxySocks4a	= 5,
	kProxySocks5		= 6
};
class NIPCLIB_EXPORT ProxyInfo
{
public:
	ProxyInfo();
	ProxyInfo(ProxyType type, const std::string& host, uint16_t	port, const std::string& user = "", const std::string& password = "");
	ProxyInfo& operator = (const ProxyInfo& config);
public:
	static ProxyInfo FromString(const std::string& url);
	static std::string ToString(const ProxyInfo& info);
	inline bool Valid() const;
public:
	ProxyType	type_;
	std::string host_;
	uint16_t	port_;
	std::string user_;
	std::string password_;	
};
bool ProxyInfo::Valid() const {
	return type_ != kProxyNone && !host_.empty();
}
NIPCLIB_END_DECLS

#endif // NIPCLIB_PROXY_CONFIG_PROXY_INFO_H_
