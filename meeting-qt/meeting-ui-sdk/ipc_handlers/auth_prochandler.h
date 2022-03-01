/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_PROCHANDLER_AUTH_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_APP_PROCHANDLER_AUTH_PROCHANDLER_H_

#include "auth_service_interface.h"
#include "client_auth_service.h"

class NEAuthServiceProcHandlerIMP : public QObject, public NS_I_NEM_SDK::NEAuthServiceProcHandler {
    Q_OBJECT
public:
    NEAuthServiceProcHandlerIMP(QObject* parent = nullptr);
    virtual void onLoginWithNEMeeting(const std::string& account,
                                      const std::string& password,
                                      const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) override;
    virtual void onLoginWithSSOToken(const std::string& ssoToken, const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) override;
    virtual void onTryAutoLogin(const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) override;
    virtual void onLogin(const std::string& accountId,
                         const std::string& accountToken,
                         const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) override;
    virtual void onLogin(const std::string& appKey,
                         const std::string& account,
                         const std::string& token,
                         const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) override;
    virtual void onLoginAnonymous(const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) override;
    virtual void onGetAccountInfo(const NS_I_NEM_SDK::NEAuthService::NEGetAccountInfoCallback& cb) override;
    virtual void onLogout(bool cleanup, const NS_I_NEM_SDK::NEAuthService::NEAuthLogoutCallback& cb) override;

signals:
    void loginSignal(const QString& account, const QString& token, void* cb);
    void logoutSignal(void* cb);

public slots:
    void onAuthStatusChanged(neroom::NEAuthStatus status, const neroom::NEAuthStatusExCode& error);

private:
    NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback m_loginCallback = nullptr;
    NS_I_NEM_SDK::NEAuthService::NEAuthLogoutCallback m_logoutCallback = nullptr;
};

#endif  // ! NEM_SDK_INTERFACE_APP_PROCHANDLER_AUTH_PROCHANDLER_H_
