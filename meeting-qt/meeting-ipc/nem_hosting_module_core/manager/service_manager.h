/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_HOSTING_MODULE_CORE_MANAGER_SERVICE_MANAGER_H_
#define NEM_HOSTING_MODULE_CORE_MANAGER_SERVICE_MANAGER_H_
#include "nemeeting_sdk_interface_include.h"
#include "nem_hosting_module_core/config/build_config.h"
#include "nem_hosting_module_core/service/service.h"

NNEM_SDK_HOSTING_MODULE_CORE_BEGIN_DECLS
template<class TIPCType>
class  ServiceManager
{
public:
	static void RegisterService(const Service<TIPCType>& service)
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_service_map_);
		service_map_.insert(std::make_pair(service->GetSID(), service));
	}
	static Service<TIPCType> GetService(int sid)
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_service_map_);
		auto it = service_map_.find(sid);
		if (it != service_map_.end())
			return it->second;
		return nullptr;
	}
	static void UnRegisterService(int sid)
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_service_map_);
		service_map_.erase(sid);
	}
	static void Clear()
	{
		std::lock_guard<std::recursive_mutex> auto_lock(mut_service_map_);
		service_map_.clear();
	}
private:
	static std::recursive_mutex mut_service_map_;
	static std::map<int, Service<TIPCType>> service_map_;
};
template<class TIPCType>
std::recursive_mutex ServiceManager<TIPCType>::mut_service_map_;

template<class TIPCType>
std::map<int, Service<TIPCType>> ServiceManager<TIPCType>::service_map_;
NNEM_SDK_HOSTING_MODULE_CORE_END_DECLS
#endif //NEM_HOSTING_MODULE_CORE_MANAGER_SERVICE_MANAGER_H_
