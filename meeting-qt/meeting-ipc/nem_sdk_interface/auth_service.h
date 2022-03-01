/**
 * @file auth_service.h
 * @brief 登录服务头文件
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

#ifndef NEM_SDK_INTERFACE_INTERFACE_AUTHSERVICE_H_
#define NEM_SDK_INTERFACE_INTERFACE_AUTHSERVICE_H_
#include <string>
#include "service_define.h"

NNEM_SDK_INTERFACE_BEGIN_DECLS

/**
 * @brief 监听登录状态变更通知
 * @see NEAuthService#addAuthListener
 * @see NEAuthService#removeAuthListener
 */
class NEAuthListener : public NEObject
{
public:
    /**
     * @brief 被踢出，登录状态变更为未登录，原因为当前登录账号已在其他设备上重新登录
     * @return void
     */
    virtual void onKickOut() = 0;

    /**
     * @brief 账号信息过期通知，原因为用户修改了密码，应用层随后应该重新登录
     * @return void
     */
    virtual void onAuthInfoExpired() = 0;
};

/**
 * @brief 登录服务
 */
class NEM_SDK_INTERFACE_EXPORT NEAuthService : public NEService
{
public:
    using NEAuthLoginCallback = NEEmptyCallback;
    using NEAuthLogoutCallback = NEEmptyCallback;
    using NEGetAccountInfoCallback = NECallback<AccountInfo>;
public:
    /**
     * 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
     * @param account     登录账号
     * @param password    登录密码
     * @param cb 回调接口，该回调不会返回额外的结果数据
     */
    virtual void loginWithNEMeeting(const std::string& account, const std::string& password, const NEAuthLoginCallback& cb) = 0;

    /**
     * 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
     * @param ssoToken 单点登录时返回的 token 串
     * @param cb 回调接口，该回调不会返回额外的结果数据
     */
    virtual void loginWithSSOToken(const std::string& ssoToken, const NEAuthLoginCallback& cb) = 0;

    /**
     * 自动登录鉴权。
     * @param cb 回调接口，该回调不会返回额外的结果数据
     */
    virtual void tryAutoLogin(const NEAuthLoginCallback& cb) = 0;

    /**
     * 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
     * @param accountId  登录账号
     * @param token      登录令牌
     * @param cb 回调接口，该回调不会返回额外的结果数据
     */
    virtual void login(const std::string& accountId, const std::string& token, const NEAuthLoginCallback& cb) = 0;

    /**
     * 登录鉴权。在已登录状态下可以创建和加入会议，但在未登录状态下只能加入会议
     * @deprecated 已废弃
     * @param appKey     应用的appKey
     * @param accountId  登录账号
     * @param token      登录令牌
     * @param cb 回调接口，该回调不会返回额外的结果数据
     */
#ifdef WIN32
    __declspec(deprecated)
#else
    __attribute__((deprecated("", "")))
#endif
    virtual void login(const std::string& appKey, const std::string& accountId, const std::string& token, const NEAuthLoginCallback& cb) = 0;

    /**
     * 获取账号信息，该会议号可在创建会议时使用
     * @param cb 回调接口，回调数据类型为{@link AccountInfo}。
     */
    virtual void getAccountInfo(const NEGetAccountInfoCallback& cb) = 0;

    /**
     * 注销当前已登录的账号
     * @param cleanup 是否清理账户缓存信息（若清理则调用 tryAutoLogin 将返回失败）
     * @param cb 回调接口，该回调不会返回额外的结果数据
     */
    virtual void logout(bool cleanup = false, const NEAuthLoginCallback& cb = nullptr) = 0;

    /**
     * 注册登录状态监听器，用于接收登陆状态变更通知
     * @param listener 要添加的监听实例
     */
    virtual void addAuthListener(NEAuthListener* listener) = 0;

    /**
     * 移除对应的登录状态的监听实例
     * @param listener 要移除的监听实例
     */
    virtual void removeAuthListener(NEAuthListener* listener) = 0;

    /**
     * 匿名登录
     * @param cb 回调接口，该回调不会返回额外的结果数据
     * @deprecated 已废弃
     */
#ifdef WIN32
    __declspec(deprecated)
#else
    __attribute__((deprecated("", "")))
#endif
	virtual void loginAnonymous(const NEAuthLoginCallback& cb) = 0;
};

NNEM_SDK_INTERFACE_END_DECLS

#endif // ! NEM_SDK_INTERFACE_INTERFACE_AUTHSERVICE_H_
