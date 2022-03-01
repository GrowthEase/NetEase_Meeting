/**
 * @file account_service.h
 * @brief 账号服务头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_CLIENT_SERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_CLIENT_SERVICE_H_

#include "service_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 账户服务
 */
class NEM_SDK_INTERFACE_EXPORT NEAccountService : public NEService
{
public:
	using NEGetPersonalMeetingIdCallback = NECallback<std::string>;
    using NEGetAccountInfoCallback = NECallback<AccountInfo>;
  
public:
    /** 
     * @brief 获取个人会议信息
     * @param cb 回调
     * @return void
     */
	virtual void getPersonalMeetingId(const NEGetPersonalMeetingIdCallback& cb) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS
#endif // NEM_SDK_INTERFACE_INTERFACE_CLIENT_SERVICE_H_
