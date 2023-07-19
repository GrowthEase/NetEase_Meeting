// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef AUTHCONTROLLER_H
#define AUTHCONTROLLER_H

#include "auth_service_interface.h"
#include "base_type_defines.h"
using namespace neroom;

typedef enum tagNEAuthStatus {
    kAuthIdle,            /**< 默认无状态 */
    kAuthLoginProcessing, /**< 登录中 */
    kAuthLoginSuccessed,  /**< 登录成功 */
    kAuthLoginFailed,     /**< 登录失败 */
    kAuthInitRtcFailed,   /**< 初始化RTC失败 */
    kAuthInitIMFailed,    /**< 初始化IM失败 */
    kAuthEnterIMFailed,   /**< 进入IM失败 */
    kAuthLogOutSuccessed, /**< 登出成功 */
    kAuthLogOutFailed,    /**< 登出失败 */
    kAuthIMKickOut,       /**< 被踢出 */
} NEAuthStatus;

typedef struct tagNEAccountInfo {
    nem_sdk_interface::NELoginType loginType = nem_sdk_interface::kLoginTypeUnknown;
    std::string username;
    std::string accountId;
    std::string accountToken;
    std::string appKey;
    std::string personalRoomId;
    std::string shortRoomId;
    std::string displayName;
} NEAccountInfo;

/**
 * @brief 登录状态结构体
 */
typedef struct tagNEAuthStatusExCode {
    int errorCode = 0;        /**< 错误码 */
    std::string errorMessage; /**< 错误消息 */
    tagNEAuthStatusExCode(int code = 0, const std::string& message = "")
        : errorCode(code)
        , errorMessage(message) {}
} NEAuthStatusExCode;

class NEMeeingAuthController : neroom::INEAuthListener {
public:
    NEMeeingAuthController();
    ~NEMeeingAuthController();

    bool loginWithToken(const std::string& accountId, const std::string& accountToken);
    bool loginWithSSOToken(const std::string& ssoToken);
    bool loginWithAccount(const std::string& username, const std::string& password);
    bool anonymousLogin(const neroom::NECallback<>& callback);
    bool logout();

    NEAuthStatus getAuthStatus();
    NEAccountInfo getAccountInfo();

    void raiseExpiredCb();
    bool saveAccountSettings(const QJsonObject& settings, const neroom::NECallback<>& callback = neroom::NECallback<>());

    QJsonObject getAccountSettings() const;

public:
    virtual void onAuthEvent(NEAuthEvent authEvent) override;

private:
    bool doLoginRoom(const std::string& account, const std::string& token, const neroom::NECallback<>& callback = neroom::NECallback<>());

private:
    NEAccountInfo m_accountInfo;
    NEAuthStatus m_authStatus = kAuthIdle;
    QJsonObject m_settings;
};

#endif  // AUTHSERVICE_H
