/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/16
//
// Http base implementation

#ifndef BASE_NETWORK_HTTP_H_
#define BASE_NETWORK_HTTP_H_

#include "base/base_export.h"
#include "base/base_types.h"
#include "base/time/time.h"
#include <curl/curl.h>
#include <string>
#include <list>

namespace nbase
{
typedef CURL              HttpConnection;
typedef CURLcode          HttpError;
typedef struct curl_slist HttpHeader;
typedef std::string       HttpString;

enum HttpProxyType
{
	ProxyNone = -1,
	ProxyHttp11 =  CURLPROXY_HTTP,
	ProxyHttp10 = CURLPROXY_HTTP_1_0,
	ProxySock4 = CURLPROXY_SOCKS4,
	ProxySock5 = CURLPROXY_SOCKS5,
	ProxySock4a = CURLPROXY_SOCKS4A,
	ProxySock5HostName = CURLPROXY_SOCKS5_HOSTNAME,
};

struct Proxy
{
	uint16_t port;
	HttpProxyType type;
	std::string host;
	std::string user;
	std::string pass;

	Proxy() : port(0), type(ProxyNone) {}
	bool IsEmpty() const { return type == ProxyNone; }
	void Clear()
	{
		port = 0;
		type = ProxyNone;
		host.clear();
		user.clear();
		pass.clear();
	}
};

/*
 *	Purpose		A callback function definition for received or put data processing
 *	data		A pointer pointed to buffer data
 *	size		block size
 *	nmemb		count of block
 *  param       A pointer pointed to anything you posted.
 *	Remark		All received datas are RAW-DATA
 */
typedef size_t (*HttpDataProcessor)(void *data, size_t size, size_t nmemb, void *param);

class BASE_EXPORT Http
{
public:
	static HttpError GlobalInit(uint32_t init_param = CURL_GLOBAL_DEFAULT);
	static void GlobalCleanup();

public:
	Http();
	~Http();

	// Get last error, the error code is CURLcode
	HttpError last_error() const { return last_error_; }
	// Check the http connection is valid
	bool IsValid() const { return connection_ != NULL; }
	// Cleanup the current http connection
	void Cleanup();

public:
	// Set the timeout of http request
	TimeDelta SetTimeout(const TimeDelta &timeout);

	HttpError SetHeaderField(const HttpString &field, const HttpString &value);
	HttpError SetCookie(const HttpString &cookie);
	HttpError GetCookieList(std::list<std::string> &cookies);
	HttpError SetCookieList(const std::list<std::string> &cookies);
	HttpError SetReferer(const HttpString &referer);
	HttpError SetProxy(const Proxy &proxy);

	HttpError HttpGet(const HttpString &url,
		              HttpString &out_content,
					  bool cleanup = true);
	HttpError HttpGet(const HttpString &url,
		              const std::wstring &filepath);
	HttpError HttpGet(const HttpString &url,
		              HttpDataProcessor callback,
					  void *param,
					  bool cleanup = true);

	HttpError HttpPost(const HttpString &url,
		               const HttpString &post,
					   HttpString &out_content,
					   bool cleanup = true);
	HttpError HttpPost(const HttpString &url,
		               const HttpString &post,
		               const std::wstring &filepath);
	HttpError HttpPost(const HttpString &url,
		               const HttpString &post,
		               HttpDataProcessor callback,
					   void *param,
					   bool cleanup = true);

	HttpError HttpsGet(const HttpString &url,
		               bool ssl_peer_verify,
					   const HttpString &ca_path,
		               HttpString &out_content,
		               bool cleanup = true);
	HttpError HttpsGet(const HttpString &url,
		               bool ssl_peer_verify,
		               const HttpString &ca_path,
		               const std::wstring &filepath);
	HttpError HttpsGet(const HttpString &url,
		               bool ssl_peer_verify,
		               const HttpString &ca_path,
		               HttpDataProcessor callback,
		               void *param,
		               bool cleanup = true);

	HttpError HttpsPost(const HttpString &url,
		                bool ssl_peer_verify,
		                const HttpString &ca_path,
		                const HttpString &post,
		                HttpString &out_content,
		                bool cleanup = true);
	HttpError HttpsPost(const HttpString &url,
		                bool ssl_peer_verify,
		                const HttpString &ca_path,
		                const HttpString &post,
		                const std::wstring &filepath);
	HttpError HttpsPost(const HttpString &url,
		                bool ssl_peer_verify,
		                const HttpString &ca_path,
		                const HttpString &post,
		                HttpDataProcessor callback,
		                void *param,
		                bool cleanup = true);

	//对nos的链接，追加header
	void AddNosHeader(const HttpString &uid, int32_t ct, int32_t nt);

private:
	HttpError ErrorHelper(const char *format, HttpError error);
	HttpError ErrorHelper(const char *format, const char *error);
	HttpError CurlHelper(bool http_post,
		                 const HttpString &url,
		                 bool ssl_peer_verify,
						 const HttpString &ca_path,
						 const HttpString &post,
						 HttpDataProcessor callback,
						 void *param,
						 bool cleanup = true);

	HttpString GetNosCTT(const HttpString &uid, int32_t ct, int32_t nt);

protected:
	HttpConnection *connection_;
	HttpHeader     *headers_;
	HttpError       last_error_;
	TimeDelta       timeout_;    
};

}  // namespace nbase

#endif  // BASE_NETWORK_HTTP_H_