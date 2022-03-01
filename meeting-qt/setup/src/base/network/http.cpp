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

#include "http.h"
#include "base/log/log_impl.h"
#include "base/file/file_util.h"

#define ADD_NOS_HEADER

#ifdef ADD_NOS_HEADER
#include "base/encrypt/des.h"
#include "base/util/base64.h"
#include "jsoncpp/include/json/value.h"
#include "jsoncpp/include/json/writer.h"
#endif//ADD_NOS_HEADER

static char error_buffer[CURL_ERROR_SIZE];

namespace nbase
{
static size_t OnRawDataGotMemory(void *data, size_t size, size_t nmemb, void *param)
{
	if (NULL == param)
		return 0;

	size_t sizes = size * nmemb;
	std::string *content = reinterpret_cast<std::string *>(param);
	content->append(reinterpret_cast<char *>(data), sizes);
	return sizes;
}

static size_t OnRawDataGotFile(void *data, size_t size, size_t nmemb, void *param)
{
	if (NULL == param)
		return 0;

	FILE *file = reinterpret_cast<FILE *>(param);
	return fwrite(data, size, nmemb, file);
}

HttpError Http::GlobalInit(uint32_t init_param/* = CURL_GLOBAL_DEFAULT*/)
{
	memset(error_buffer, 0, CURL_ERROR_SIZE);
	return curl_global_init(init_param);
}

void Http::GlobalCleanup()
{
	curl_global_cleanup();
}

Http::Http()
	: connection_(NULL),
	  headers_(NULL),
	  last_error_(CURLE_OK)
{
	connection_ = curl_easy_init();
	if (NULL == connection_)
	{
		last_error_ = CURLE_FAILED_INIT;
		DEFLOG(nbase::LogInterface::LV_ERR, 
		       __FILE__, 
		       __LINE__, 
		       "nbase::Http: curl_easy_init() error");
	}
}

Http::~Http()
{
	Cleanup();
}

void Http::Cleanup()
{
	if (headers_)
	{
		curl_slist_free_all(headers_);
		headers_ = NULL;
	}
	if (connection_)
	{
		curl_easy_cleanup(connection_);
		connection_ = NULL;
	}
}

TimeDelta Http::SetTimeout(const TimeDelta &timeout)
{
	TimeDelta delta = timeout_;
	timeout_ = timeout;
	return delta;
}

HttpError Http::SetHeaderField(const HttpString &field, const HttpString &value)
{
	HttpString header;
	header.append(field + ": " + value);
	headers_ = curl_slist_append(headers_, header.c_str());
	return CURLE_OK; 
}

HttpError Http::SetCookie(const HttpString &cookie)
{
	if (IsValid())
		last_error_ = curl_easy_setopt(connection_, CURLOPT_COOKIE, cookie.c_str());
	return last_error_;
}

HttpError Http::GetCookieList(std::list<std::string> &cookies)
{
	cookies.clear();
	if (!IsValid())
		return CURLE_FAILED_INIT;
	curl_slist *list = NULL;
	last_error_ = curl_easy_getinfo(connection_, CURLINFO_COOKIELIST, &list);
	if (last_error_ == CURLE_OK)
	{
		curl_slist *next = list;
		while (next)
		{
			cookies.push_back(next->data);
			next = next->next;
		}
		curl_slist_free_all(list);
	}
	return last_error_;
}

HttpError Http::SetCookieList(const std::list<std::string> &cookies)
{
	if (!IsValid())
		return CURLE_FAILED_INIT;
	std::list<std::string>::const_iterator iter = cookies.begin();
	for (; iter != cookies.end(); iter++)
	{
		last_error_ = curl_easy_setopt(connection_, CURLOPT_COOKIELIST, iter->c_str());
		if (last_error_ != CURLE_OK)
			return last_error_;
	}
	return CURLE_OK;
}

HttpError Http::SetReferer(const HttpString &referer)
{
	if (IsValid())
		last_error_ = curl_easy_setopt(connection_, CURLOPT_REFERER, referer.c_str());
	return last_error_;
}

static int ConvertProxyType(HttpProxyType type)
{
	switch (type) {
	case ProxySock5:
		return CURLPROXY_SOCKS5;
	case ProxySock4:
		return CURLPROXY_SOCKS4;
	default:
		return ProxyHttp11;
	}
}

HttpError Http::SetProxy( const Proxy &proxy )
{
	if(!IsValid())
		return CURLE_FAILED_INIT;

	curl_easy_setopt(connection_, CURLOPT_HTTPPROXYTUNNEL, 1L);
	curl_easy_setopt(connection_, CURLOPT_PROXYTYPE, ConvertProxyType(proxy.type));
	curl_easy_setopt(connection_, CURLOPT_PROXY, proxy.host.c_str());
	curl_easy_setopt(connection_, CURLOPT_PROXYPORT, proxy.port);

	if (!proxy.user.empty()) {
		curl_easy_setopt(connection_,
			CURLOPT_PROXYUSERNAME,
			proxy.user.c_str());
		if (!proxy.pass.empty())
			curl_easy_setopt(connection_,
			CURLOPT_PROXYPASSWORD,
			proxy.pass.c_str());
	}

	return CURLE_OK;
}

HttpError Http::HttpGet(const HttpString &url,
	                    HttpString &out_content,
	                    bool cleanup/* = true*/)
{
	return HttpGet(url, OnRawDataGotMemory, &out_content, cleanup);
}

HttpError Http::HttpGet(const HttpString &url,
	                    const std::wstring &filepath)
{
	FILE *file = OpenFile(filepath, L"wb+");

	last_error_ = HttpGet(url, OnRawDataGotFile, file);

	CloseFile(file);

	return last_error_; 
}

HttpError Http::HttpGet(const HttpString &url, 
	                    HttpDataProcessor callback, 
						void *param,
						bool cleanup/* = true*/)
{
	HttpString ca_path, post;
    return CurlHelper(false, url, false, ca_path, post, callback, param, cleanup);
}

HttpError Http::HttpPost(const HttpString &url,
	                     const HttpString &post,
	                     HttpString &out_content,
	                     bool cleanup/* = true*/)
{
	out_content.clear();
	return HttpPost(url, post, OnRawDataGotMemory, &out_content, cleanup);
}

HttpError Http::HttpPost(const HttpString &url,
	                     const HttpString &post,
	                     const std::wstring &filepath)
{
	FILE *file = OpenFile(filepath, L"wb+");

	last_error_ = HttpPost(url, post, OnRawDataGotFile, file);

	CloseFile(file);

	return last_error_; 
}

HttpError Http::HttpPost(const HttpString &url,
	                     const HttpString &post,
	                     HttpDataProcessor callback,
	                     void *param,
	                     bool cleanup/* = true*/)
{
	HttpString ca_path;
    return CurlHelper(true, url, false, ca_path, post, callback, param, cleanup);
}

HttpError Http::HttpsGet(const HttpString &url,
	                     bool ssl_peer_verify,
	                     const HttpString &ca_path,
	                     HttpString &out_content,
	                     bool cleanup/* = true*/)
{
	return HttpsGet(url, 
		            ssl_peer_verify, 
					ca_path, 
					OnRawDataGotMemory, 
					&out_content, 
					cleanup);
}

HttpError Http::HttpsGet(const HttpString &url,
	                     bool ssl_peer_verify,
	                     const HttpString &ca_path,
	                     const std::wstring &filepath)
{
	FILE *file = OpenFile(filepath, L"wb+");

	last_error_ = HttpsGet(url, 
		                   ssl_peer_verify, 
						   ca_path, 
						   OnRawDataGotFile, 
						   file);

	CloseFile(file);

	return last_error_;
}

HttpError Http::HttpsGet(const HttpString &url,
	                     bool ssl_peer_verify,
	                     const HttpString &ca_path,
	                     HttpDataProcessor callback,
	                     void *param,
	                     bool cleanup/* = true*/)
{
	HttpString post;
    return CurlHelper(false,
		              url,
					  ssl_peer_verify,
					  ca_path,
					  post,
					  callback,
					  param,
					  cleanup);
}

HttpError Http::HttpsPost(const HttpString &url,
	                      bool ssl_peer_verify,
	                      const HttpString &ca_path,
	                      const HttpString &post,
	                      HttpString &out_content,
	                      bool cleanup/* = true*/)
{
	return HttpsPost(url,
		             ssl_peer_verify,
					 ca_path, post,
					 OnRawDataGotMemory,
					 &out_content,
					 cleanup);
}

HttpError Http::HttpsPost(const HttpString &url,
	                      bool ssl_peer_verify,
	                      const HttpString &ca_path,
	                      const HttpString &post,
	                      const std::wstring &filepath)
{
	FILE *file = OpenFile(filepath, L"wb+");

	last_error_ = HttpsPost(url,
		                    ssl_peer_verify,
							ca_path, post,
							OnRawDataGotFile,
							file);

	CloseFile(file);

	return last_error_;
}

HttpError Http::HttpsPost(const HttpString &url,
	                      bool ssl_peer_verify,
	                      const HttpString &ca_path,
	                      const HttpString &post,
	                      HttpDataProcessor callback,
	                      void *param,
	                      bool cleanup/* = true*/)
{
	return CurlHelper(true,
		              url,
					  ssl_peer_verify,
					  ca_path,
					  post,
					  callback,
					  param,
					  cleanup);
}

HttpError Http::ErrorHelper(const char *format, HttpError error)
{
	DEFLOG(nbase::LogInterface::LV_ERR, 
		   __FILE__, 
		   __LINE__, 
		   format,
		   error);
	Cleanup();
	return last_error_;
}

HttpError Http::ErrorHelper(const char *format, const char *error)
{
	DEFLOG(nbase::LogInterface::LV_ERR, 
		   __FILE__, 
		   __LINE__, 
		   format,
		   error);
	Cleanup();
	return last_error_;
}

HttpError Http::CurlHelper(bool http_post,
	                       const HttpString &url,
	                       bool ssl_peer_verify,
	                       const HttpString &ca_path,
	                       const HttpString &post,
	                       HttpDataProcessor callback,
	                       void *param,
	                       bool cleanup/* = true*/)
{
	if (connection_ == NULL)
	{
		connection_ = curl_easy_init();
		if (NULL == connection_)
		{
			last_error_ = CURLE_FAILED_INIT;
			DEFLOG(nbase::LogInterface::LV_ERR, 
				__FILE__, 
				__LINE__, 
				"nbase::Http: curl_easy_init() error");
			return last_error_;
		}
	}

	// set error buffer
	last_error_ = curl_easy_setopt(connection_, CURLOPT_ERRORBUFFER, error_buffer);
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_URL error:%d", 
			last_error_);
	}

	// set verify peer
	if (ssl_peer_verify)
	{
		last_error_ = curl_easy_setopt(connection_, CURLOPT_SSL_VERIFYPEER, 1L);
	}
	else
	{
		last_error_ = curl_easy_setopt(connection_, CURLOPT_SSL_VERIFYPEER, 0L);
	}
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_SSL_VERIFYPEER error:%s", 
			error_buffer);
	}

	// set ca path
	if (!ca_path.empty())
	{
		last_error_ = curl_easy_setopt(connection_, CURLOPT_CAPATH, ca_path.c_str());
		if (last_error_ != CURLE_OK)
		{
			return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_CAPATH error:%s", 
				error_buffer);
		}
	}

	if (headers_ != NULL)
	{
		last_error_ = curl_easy_setopt(connection_, CURLOPT_HTTPHEADER, headers_);
		if (last_error_ != CURLE_OK)
		{
			return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_HTTPHEADER error:%s", 
				error_buffer);
		}
	}

	// set url
	last_error_ = curl_easy_setopt(connection_, CURLOPT_URL, url.c_str());
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_URL error:%s", 
			error_buffer);
	}

	// set post
	if (http_post)
	{
		last_error_ = curl_easy_setopt(connection_, CURLOPT_POST, 1);
		if (last_error_ != CURLE_OK)
		{
			return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_POST error:%s", 
				error_buffer);
		}
		if (!post.empty())
		{
			last_error_ = curl_easy_setopt(connection_, CURLOPT_POSTFIELDS, post.c_str());
			if (last_error_ != CURLE_OK)
			{
				return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_COPYPOSTFIELDS error:%s", 
					error_buffer);
			}
			// to post large file, use CURLOPT_POSTFIELDSIZE_LARGE instead
			last_error_ = curl_easy_setopt(connection_, CURLOPT_POSTFIELDSIZE, post.size());
			if (last_error_ != CURLE_OK)
			{
				return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_POSTFIELDSIZE error:%s", 
					error_buffer);
			}
		}
	}

	// set redirect option
	last_error_ = curl_easy_setopt(connection_, CURLOPT_FOLLOWLOCATION, 1);
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_FOLLOWLOCATION error:%s", 
			error_buffer);
	}

	// set write function
	last_error_ = curl_easy_setopt(connection_, CURLOPT_WRITEFUNCTION, callback);
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_WRITEFUNCTION error:%s", 
			error_buffer);
	}

	// set write data
	last_error_ = curl_easy_setopt(connection_, CURLOPT_WRITEDATA, param);
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_WRITEDATA error:%s", 
			error_buffer);
	}

	if (timeout_ > TimeDelta())
	{
		// set write data
		last_error_ = curl_easy_setopt(connection_, CURLOPT_TIMEOUT, timeout_.ToSeconds());
		if (last_error_ != CURLE_OK)
		{
			return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_TIMEOUT error:%s", 
				error_buffer);
		}
	}

#if defined (DEBUG) || defined (_DEBUG)    
	last_error_ = curl_easy_setopt(connection_, CURLOPT_VERBOSE, 1L); 
#endif

	// enable cookie
	last_error_ = curl_easy_setopt(connection_, CURLOPT_COOKIEFILE, "");
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_setopt() CURLOPT_COOKIEFILE error:%s", 
			error_buffer);
	}
    
	// excute
	last_error_ =  curl_easy_perform(connection_);
	if (last_error_ != CURLE_OK)
	{
		return ErrorHelper("nbase::Http: curl_easy_perform() failed error:%s", 
			error_buffer);
	}

	if (cleanup)
		Cleanup();

	return last_error_;
}
//对nos的链接，追加header
void Http::AddNosHeader(const HttpString &uid, int32_t ct, int32_t nt)
{
#ifdef ADD_NOS_HEADER
	SetHeaderField("YX-PN", "yxmc");
	SetHeaderField("YX-VSN", "1");
	SetHeaderField("YX-CTT", GetNosCTT(uid, ct, nt));
#endif//ADD_NOS_HEADER
}
HttpString Http::GetNosCTT(const HttpString &uid, int32_t ct, int32_t nt)
{
	std::string des;
#ifdef ADD_NOS_HEADER
	char des_key[8] = { 65, 78, 23, 11, 43, 56, 7, 93 };
	Json::Value root;
	root["ct"] = ct;//1;
	root["nt"] = nt;//1;
	root["t"] = (uint32_t)time(0);
	root["u"] = uid;
	Json::FastWriter fast_writer;
	std::string src = fast_writer.write(root);
	des = yxDES::Encrypt(src, des_key);
	nbase::Base64Encode(des, &des);
#endif//ADD_NOS_HEADER
	return des;
}

}  // namespace nbase