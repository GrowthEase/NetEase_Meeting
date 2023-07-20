// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include "auth_service_interface.h"
#include "client_auth_service.h"
#include "controller/auth_controller.h"
#include "meeting.h"
#include "setting_service.h"

using namespace neroom;
using namespace nem_sdk_interface;

Q_DECLARE_METATYPE(NEAuthStatus)
Q_DECLARE_METATYPE(NEAuthStatusExCode)
Q_DECLARE_METATYPE(NEAccountInfo)

typedef struct tagAutoLoginInfo {
    QString accountId;
    QString accountToken;
} AutoLoginInfo;

class LoginCacheInfo {
public:
    QString cacheAppKey;
    QString cacheAccountId;
    QString cacheAccountToken;
    bool isVaild() const { return !cacheAppKey.isEmpty() && !cacheAccountId.isEmpty() && !cacheAccountToken.isEmpty(); }
};

class AuthManager : public QObject {
    Q_OBJECT
private:
    AuthManager(QObject* parent = nullptr);

public:
    SINGLETONG(AuthManager)
    ~AuthManager();

    Q_PROPERTY(QString authAccountId READ authAccountId WRITE setAuthAccountId NOTIFY authAccountIdChanged)
    Q_PROPERTY(bool autoLoginMode READ autoLoginMode WRITE setAutoLoginMode NOTIFY autoLoginModeChanged)
    Q_PROPERTY(bool isHostAccount READ isHostAccount WRITE setIsHostAccount NOTIFY isHostAccountChanged)
    Q_PROPERTY(bool isSupportBeauty READ isSupportBeauty)
    Q_PROPERTY(QString authNickName READ authNickName NOTIFY authNickNameChanged)

    Q_INVOKABLE bool autoLogin();
    Q_INVOKABLE void autoLogout();

    bool initialize();
    void release();
    bool doLogin(const QString& accountId, const QString& accountToken);
    bool doAnonymousLogin(const neroom::NECallback<>& callback);
    bool doLoginWithPassword(const QString& username, const QString& password);
    bool doLoginWithSSOToken(const QString& ssoToken);
    bool doTryAutoLogin(const nem_sdk_interface::NEAuthService::NEAuthLoginCallback& cb);
    void doLogout(bool bExit = false);
    NEAccountInfo getAuthInfo();
    NEAuthStatus getAuthStatus();
    nem_sdk_interface::NELoginType getLoginType() const { return m_loginType; }

    // Auth event handler
    void onAuthStatusChanged(NEAuthStatus authStatus, const NEAuthStatusExCode& result = NEAuthStatusExCode());
    //    virtual void onAuthInfoChanged(const AccountInfoPtr authInfo) override;
    //    virtual void onAuthInfoExpired() override;
    //    virtual void onError(uint32_t errorCodeEx, const std::string& errorMessage) override;

    QString authAccountId() const;
    void setAuthAccountId(const QString& authAccountId);

    QString authAppKey() const;
    void setAuthAppKey(const QString& authAppKey);

    void setAutoLoginInfo(const QString& accountId, const QString& accountToken);

    bool autoLoginMode() const;
    void setAutoLoginMode(bool autoLoginMode);

    bool isHostAccount() const;
    void setIsHostAccount(bool isHostAccount);

    bool isSupportBeauty() const;

    QString authNickName() const;
    void setAuthNickName(const QString& authNickName);

    void saveAccountSettings(const QJsonObject& settings);
    QJsonObject getAccountSettings() const;

    bool isAnonymousLogin() const { return m_anonymousLogin; }
    void setAnonymousLogin(bool isAnonymousLogin) { m_anonymousLogin = isAnonymousLogin; }

signals:
    void login(NEAuthStatus authStatus, const NEAccountInfo& authAccountInfo);
    void logout();
    void authInfoExpired();
    void error(uint32_t errorCode, const QString& errorMessage);
    void authAccountIdChanged();
    void autoLoginModeChanged();
    void authStatusChanged(NEAuthStatus authStatus, const NEAuthStatusExCode& error = NEAuthStatusExCode());
    void isHostAccountChanged();
    void authNickNameChanged();

public slots:
    void onLoginUI(NEAuthStatus authStatus, const NEAccountInfo& authAccountInfo);
    void onLogoutUI();
    void onAuthInfoExpiredUI();

private:
    bool writeLoginCache(const LoginCacheInfo& cacheInfo);
    LoginCacheInfo readLoginCache() const;

private:
    std::shared_ptr<NEMeeingAuthController> m_authController = nullptr;
    QString m_authAccountId;
    QString m_authAppKey;
    QString m_authNickName;
    AutoLoginInfo m_autoLoginInfo;
    bool m_autoLoginMode = false;
    bool m_logoutExit = false;
    bool m_isHostAccount = false;
    nem_sdk_interface::NELoginType m_loginType = nem_sdk_interface::kLoginTypeUnknown;
    bool m_anonymousLogin = false;
};

#endif  // AUTHMANAGER_H
