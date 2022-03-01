/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CORE_SERVICE_H_
#define NEM_HOSTING_MODULE_CORE_SERVICE_H_
#include "nem_hosting_module_core/config/build_config.h"
#include "nemeeting_sdk_interface_include.h"
#include <string>
#include <map>
#include <mutex>
#include "nipclib/base/any.h"
#include "nipclib/base/ipc_thread.h"
#include  "nipclib/base/callback.h"
#include "nipclib/base/singleton.h"
#include "nipclib/ipc/ipc_def.h"
#include "nipclib/ipc/ipc_server.h"
#include "nipclib/ipc/ipc_client.h"
#include "nem_hosting_module_core/protocol/protocol.h"


NNEM_SDK_HOSTING_MODULE_CORE_BEGIN_DECLS

USING_NS_NNEM_SDK_INTERFACE

class IPCAsyncResponseCallback
{
public:
	IPCAsyncResponseCallback() {

	}
	template<class TCallback>
	IPCAsyncResponseCallback(const TCallback& cb) : callback_(cb){

	}
public:
	template<class TCallback>
	TCallback GetResponseCallback() const{
		return NS_NIPCLIB::any_cast<TCallback>(callback_);;
	}
	template<class TCallback>
	void SetResponseCallback(const TCallback& cb) {
		callback_ = cb;
	}
private:
	NS_NIPCLIB::any callback_;
};
class IPCAsyncRequestManager : public NS_NIPCLIB::Singleton<IPCAsyncRequestManager>
{
public:
	void AddResponseCallback(uint64_t sn, const IPCAsyncResponseCallback& cb) {
		std::lock_guard<std::recursive_mutex> auto_lock(request_list_lock_);
		AddResponseCallback_i(sn, cb);
	}
	void RemoveResponseCallback(uint64_t sn) {
		std::lock_guard<std::recursive_mutex> auto_lock(request_list_lock_);
		RemoveResponseCallback_i(sn);
	}
	bool PeekResponseCallback(uint64_t sn, IPCAsyncResponseCallback& cb) {
		std::lock_guard<std::recursive_mutex> auto_lock(request_list_lock_);
		auto it = request_list_.find(sn);
		if (it != request_list_.end())
		{
			cb = it->second;
			return true;
		}
		return false;
	}
	bool GetResponseCallback(uint64_t sn, IPCAsyncResponseCallback& cb) {
		std::lock_guard<std::recursive_mutex> auto_lock(request_list_lock_);
		auto it = request_list_.find(sn);
		if (it != request_list_.end())
		{
			cb = it->second;
			RemoveResponseCallback_i(sn);
			return true;
		}
		return false;
	}
	void Clear()
	{
		std::lock_guard<std::recursive_mutex> auto_lock(request_list_lock_);
		request_list_.clear();
	}
private:
	inline void RemoveResponseCallback_i(uint64_t sn) {
		request_list_.erase(sn);
	}
	inline void AddResponseCallback_i(uint64_t sn, const IPCAsyncResponseCallback& cb) {
		request_list_[sn] = cb;
	}
private:
	std::recursive_mutex request_list_lock_;
	std::map<uint64_t, IPCAsyncResponseCallback> request_list_;
};
template<class TIPCType>
class IService : virtual public NS_NIPCLIB::SupportWeakCallback
{
public:
	IService(int sid) : sid_(sid) , ipc_controller_(nullptr), proc_thread_(nullptr){};
	int GetSID() const { return sid_; }
	virtual void OnLoad() {}
	virtual void OnRelease() {}
	virtual void OnReceivePack(int cid,const std::string& data,const IPCAsyncResponseCallback& cb)
	{
		if (proc_thread_ != nullptr)
			proc_thread_->TaskLoop()->PostTask(ToWeakCallback([this,cid,data,cb]() {
			OnPack(cid, data, cb);
		}));
	}
	virtual void OnReceivePack(int cid, const std::string& data, uint64_t sn)
	{
		if (proc_thread_ != nullptr)
			proc_thread_->TaskLoop()->PostTask(ToWeakCallback([this, cid, data, sn]() {
			OnPack(cid, data, sn);
		}));
	}
	void SetProcThread(const std::shared_ptr<NS_NIPCLIB::IPCThread>& thread)
	{
		proc_thread_ = thread;
	}
	void SetIPCController(const std::shared_ptr<TIPCType>& ipc_controller)
	{
		ipc_controller_ = ipc_controller;
	}

    int GetKeepAliveInterval() const
	{ 
		if (ipc_controller_ != nullptr) {
            return ipc_controller_->GetKeepAliveInterval();
        }
        return 10;
	}
    void SetKeepAliveInterval(int interval)
	{
        if (ipc_controller_ != nullptr) {
            return ipc_controller_->SetKeepAliveInterval(interval);
        }
	}

protected:
	virtual void OnPack(int cid, const std::string& data,const IPCAsyncResponseCallback& cb) = 0;
	virtual void OnPack(int cid, const std::string& data, uint64_t sn) = 0;
	virtual void PostTaskToProcThread(const NS_NIPCLIB::Task& task)
	{
		if (proc_thread_ != nullptr)
			proc_thread_->TaskLoop()->PostTask(ToWeakCallback(task));
	}
	virtual void SendData(int cid,const NEMIPCProtocolBody& data, const IPCAsyncResponseCallback& cb)
	{
		SendData(GetSID(), cid, data,cb);		
	}
	virtual void SendData(int cid, const NEMIPCProtocolBody& data, uint64_t sn)
	{
		SendData(GetSID(), cid, data, sn);
	}
	virtual void SendData(int sid,int cid, const NEMIPCProtocolBody& data, const IPCAsyncResponseCallback& cb)
	{
		if (ipc_controller_ != nullptr)
		{
			NEMIPCProtocol protocol(sid, cid);
			auto ipc_data = NS_NIPCLIB::IIPC::MakeIPCData();
			protocol.Pack(*ipc_data, data);
			ipc_controller_->SendData(ipc_data);
			IPCAsyncRequestManager::GetInstance()->AddResponseCallback(protocol.SN(), cb);
		}
	}
	virtual void SendData(int sid, int cid, const NEMIPCProtocolBody& data, uint64_t sn)
	{
		if (ipc_controller_ != nullptr)
		{
			NEMIPCProtocol protocol(sid, cid,sn);
			auto ipc_data = NS_NIPCLIB::IIPC::MakeIPCData();
			protocol.Pack(*ipc_data, data);
			ipc_controller_->SendData(ipc_data);
		}
	}
protected:
	int sid_;
	std::shared_ptr<TIPCType> ipc_controller_;
	std::shared_ptr<NS_NIPCLIB::IPCThread> proc_thread_;
};
template<class TIPCType>
using Service = std::shared_ptr<IService<TIPCType>>;
NNEM_SDK_HOSTING_MODULE_CORE_END_DECLS

#endif //NEM_HOSTING_MODULE_CORE_SERVICE_H_
