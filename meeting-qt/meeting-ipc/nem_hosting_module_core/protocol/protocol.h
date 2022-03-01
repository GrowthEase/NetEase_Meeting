/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CORE_PROTOCOL_H_
#define NEM_HOSTING_MODULE_CORE_PROTOCOL_H_
#include "nem_hosting_module_core/config/build_config.h"
#include "nemeeting_sdk_interface_include.h"
#include <string>
#include <map>
#include <mutex>
#include <any>
#include <atomic>
#include "jsoncpp/include/json/json.h"
#include "nipclib/base/packet.h"
#include "nipclib/ipc/ipc_def.h"

NNEM_SDK_HOSTING_MODULE_CORE_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

class NEMIPCProtocolHead
{
public:
	NEMIPCProtocolHead(int sid, int cid) : sid_(sid), cid_(cid) {
		sn_ = (--g_sn_);
	}
	NEMIPCProtocolHead(int sid, int cid, uint64_t sn) : sid_(sid), cid_(cid) ,sn_(sn){
	}
public:
	int sid_;
	int cid_;
	uint64_t sn_;
    static std::atomic_uint64_t g_sn_;
};
class NEMIPCProtocolBody
{
public:
	virtual bool Empty() const { return false; }
	virtual std::string Pack() const
	{
		Json::Value root;
		OnPack(root);
		return Json::FastWriter().write(root);
	}
	virtual bool Parse(const std::string& data)
	{
		if (data.empty())
			return true;
		Json::Value root;
		if (!Json::Reader().parse(data, root))
			return false;
		OnParse(root);
		return true;
	}
protected:
	virtual void OnPack(Json::Value& root) const = 0;
	virtual void OnParse(const Json::Value& root) = 0;
};
class NEMIPCProtocolEmptyBody : public NEMIPCProtocolBody
{
public:
	virtual bool Empty() const { return true; }
protected:
	virtual void OnPack(Json::Value& root) const {};
	virtual void OnParse(const Json::Value& root) {};
};
class ProTocolHelper
{
public:
	static void PackNEMError(const NEErrorCode& error_code,const std::string& error_msg, Json::Value& root)
	{
		root["Error"]["ErrorCode"] = (int)error_code;
		root["Error"]["ErrorMessage"] = error_msg;
	}
	static void ParseError(const Json::Value& root, NEErrorCode& error_code, std::string& error_msg)
	{
		error_code = (NEErrorCode)root["Error"]["ErrorCode"].asInt();
		error_msg = root["Error"]["ErrorMessage"].asString();
	}
};
class NEMIPCProtocolErrorInfoBody : public NEMIPCProtocolBody
{
protected:
	virtual void OnPack(Json::Value& root) const 
	{
		ProTocolHelper::PackNEMError(error_code_, error_msg_,root);
		OnOtherPack(root);
	};
	virtual void OnParse(const Json::Value& root) 
	{
		ProTocolHelper::ParseError(root, error_code_, error_msg_);
		OnOtherParse(root);
	};
	virtual void OnOtherPack(Json::Value& root) const
	{

	}
	virtual void OnOtherParse(const Json::Value& root)
	{

	}	
public:
	NEErrorCode error_code_;
	std::string error_msg_;
};
class NEMIPCProtocol
{
public:
	NEMIPCProtocol(int sid, int cid) : head_(sid, cid) {}
	NEMIPCProtocol(int sid, int cid, uint64_t sn) : head_(sid, cid, sn) {}
	NEMIPCProtocol() : head_(0, 0, 0) {}
public:	
	bool Pack(std::string& data,const NEMIPCProtocolBody& body)
	{
		NS_NIPCLIB::PackBuffer pack_buffer;
		NS_NIPCLIB::Pack pack(pack_buffer);
		pack.push_uint16(head_.sid_);
		pack.push_uint16(head_.cid_);
		pack.push_uint64(head_.sn_);
		if (body.Empty())
		{
			pack.push_uint16(0);
		}
		else
		{
			pack.push_uint16(1);
			pack.push_varstr(body.Pack());
		}
		data.clear();
		data.append(pack.data(), pack.size());
		return true;
	}
	bool Parse(const NS_NIPCLIB::IPCData& data)
	{
		NS_NIPCLIB::Unpack unpack(data->data(), data->size());
		head_.sid_ = unpack.pop_uint16();
		head_.cid_ = unpack.pop_uint16();
		head_.sn_ = unpack.pop_uint64();
		int has_body = unpack.pop_uint16();
		if (has_body != 0)
			body_text_ = unpack.pop_varstr();
		return true;
	}
	int SID() const
	{
		return head_.sid_;
	}
	int CID() const
	{
		return head_.cid_;
	}
	uint64_t SN() const
	{
		return head_.sn_;
	}
	std::string BodyText() const
	{
		return body_text_;
	}
private:
	NEMIPCProtocolHead head_;
	std::string body_text_;
};
enum ServiceID
{
	SID_Global = 0,
	SID_Auth = 1,
	SID_Metting = 2,
	SID_Setting = 3,
	SID_Account = 4,
    SID_Feedback = 5,
    SID_PreMeeting = 6
};
NNEM_SDK_HOSTING_MODULE_CORE_END_DECLS

#endif //NEM_HOSTING_MODULE_CORE_PROTOCOL_H_