/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "auth_prochandler.h"
#include "hosting_module_client.h"
#include "manager/auth_manager.h"
#include "manager/global_manager.h"
#include "utils/invoker.h"

NEAuthServiceProcHandlerIMP::NEAuthServiceProcHandlerIMP(QObject* parent)
    : QObject(parent) {
    connect(AuthManager::getInstance(), &AuthManager::authStatusChanged, this, &NEAuthServiceProcHandlerIMP::onAuthStatusChanged);
}

void NEAuthServiceProcHandlerIMP::onLoginWithNEMeeting(const std::string& account,
                                                       const std::string& password,
                                                       const NEAuthService::NEAuthLoginCallback& cb) {
    //.. login with nemeeting account ID
    YXLOG_API(Info) << "Received login with nemeeting request, account ID: " << account << YXLOGEnd;
    m_loginCallback = cb;
    Invoker::getInstance()->execute(
        [=]() { AuthManager::getInstance()->doLoginWithPassword(QString::fromStdString(account), QString::fromStdString(password)); });
}

void NEAuthServiceProcHandlerIMP::onLoginWithSSOToken(const std::string& ssoToken, const NEAuthService::NEAuthLoginCallback& cb) {
    YXLOG_API(Info) << "Received login with SSO token request: " << ssoToken << YXLOGEnd;
    m_loginCallback = cb;
    Invoker::getInstance()->execute([=]() { AuthManager::getInstance()->doLoginWithSSOToken(ssoToken.c_str()); });
}

void NEAuthServiceProcHandlerIMP::onTryAutoLogin(const NEAuthService::NEAuthLoginCallback& cb) {
    YXLOG_API(Info) << "Received try auto login request" << YXLOGEnd;
    m_loginCallback = cb;
    Invoker::getInstance()->execute([=]() { AuthManager::getInstance()->doTryAutoLogin(cb); });
}

void NEAuthServiceProcHandlerIMP::onLogin(const std::string& accountId,
                                          const std::string& accountToken,
                                          const NEAuthService::NEAuthLoginCallback& cb) {
    YXLOG_API(Info) << "Received login ex request, account: " << accountId
                    << ", current login status: " << AuthManager::getInstance()->getAuthStatus() << YXLOGEnd;

    if (kAuthIdle != AuthManager::getInstance()->getAuthStatus()) {
        if (kAuthLoginSuccessed == AuthManager::getInstance()->getAuthStatus()) {
            auto it = AuthManager::getInstance()->getAuthInfo();
            if (it) {
                QString strAccountId = QString::fromStdString(it->getAccountId());
                QString strToken = QString::fromStdString(it->getAccountToken());
                if (0 == strAccountId.compare(QString::fromStdString(accountId), Qt::CaseInsensitive) &&
                    0 == strToken.compare(QString::fromStdString(accountToken), Qt::CaseInsensitive)) {
                    cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
                    return;
                }
            }
        }

        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, QString(tr("Failed to login to aPaas server")).toStdString());
        return;
    }

    m_loginCallback = cb;

    YXLOG_API(Info) << "Received login request, account: " << accountId << YXLOGEnd;
    Invoker::getInstance()->execute(
        [=]() { AuthManager::getInstance()->doLogin(QString::fromStdString(accountId), QString::fromStdString(accountToken)); });
}

void NEAuthServiceProcHandlerIMP::onLogin(const std::string& appKey,
                                          const std::string& account,
                                          const std::string& token,
                                          const NS_I_NEM_SDK::NEAuthService::NEAuthLoginCallback& cb) {
    YXLOG_API(Info) << "Received login request, appkey: " << appKey << ", account: " << account
                    << ", current login status: " << AuthManager::getInstance()->getAuthStatus() << YXLOGEnd;

    if (kAuthIdle != AuthManager::getInstance()->getAuthStatus()) {
        if (kAuthLoginSuccessed == AuthManager::getInstance()->getAuthStatus()) {
            auto it = AuthManager::getInstance()->getAuthInfo();
            if (it) {
                QString strAccountId = QString::fromStdString(it->getAccountId());
                QString strToken = QString::fromStdString(it->getAccountToken());
                if (0 == strAccountId.compare(QString::fromStdString(account), Qt::CaseInsensitive) &&
                    0 == strToken.compare(QString::fromStdString(token), Qt::CaseInsensitive)) {
                    cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
                    return;
                }
            }
        }

        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, QString(tr("Failed to login to aPaas server")).toStdString());
        return;
    }

    m_loginCallback = cb;

    Invoker::getInstance()->execute([=]() { AuthManager::getInstance()->doLogin(QString::fromStdString(account), QString::fromStdString(token)); });
}

void NEAuthServiceProcHandlerIMP::onLoginAnonymous(const NEAuthService::NEAuthLoginCallback& cb) {
    YXLOG_API(Info) << "Received login Anonymous request, current login status: " << AuthManager::getInstance()->getAuthStatus() << YXLOGEnd;
    // 此接口对外已废弃，默认返回失败，roomkit暂时没有放开接口，如果需要再放开
    if (cb) {
        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, QString(tr("Failed to login to aPaas server")).toStdString());
        return;
    }

    if (kAuthIdle != AuthManager::getInstance()->getAuthStatus()) {
        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, QString(tr("Failed to login to aPaas server")).toStdString());
        return;
    }

    m_loginCallback = cb;

    Invoker::getInstance()->execute([=]() { AuthManager::getInstance()->doLoginAnoymous(); });
}

void NEAuthServiceProcHandlerIMP::onGetAccountInfo(const NEAuthService::NEGetAccountInfoCallback& cb) {
    YXLOG_API(Info) << "Received onGetAccountInfo." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        nem_sdk_interface ::AccountInfo info;
        auto authInfo = AuthManager::getInstance()->getAuthInfo();
        auto loginType = AuthManager::getInstance()->getLoginType();
        if (authInfo) {
            info.loginType = loginType;
            info.username = authInfo->getUsername();
            info.appKey = authInfo->getAppKey();
            info.accountId = authInfo->getAccountId();
            info.accountToken = authInfo->getAccountToken();
            info.accountName = authInfo->getNickname();
            info.shortMeetingId = authInfo->getShortRoomId();
            info.personalMeetingId = authInfo->getPersonalRoomId();
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", info);
        } else
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "Not logged in", info);
    });
}

void NEAuthServiceProcHandlerIMP::onLogout(bool cleanup, const NS_I_NEM_SDK::NEAuthService::NEAuthLogoutCallback& cb) {
    YXLOG_API(Info) << "Received logout request, cleanup flag: " << cleanup << YXLOGEnd;
    if (AuthManager::getInstance()->getAuthStatus() == kAuthIdle) {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        return;
    }

    m_logoutCallback = cb;

    if (cleanup) {
        ConfigManager::getInstance()->setValue("localNEAppKey", "");
        ConfigManager::getInstance()->setValue("localNEAccountId", "");
        ConfigManager::getInstance()->setValue("localNEAccountToken", "");
    }

    Invoker::getInstance()->execute([=]() { AuthManager::getInstance()->doLogout(); });
}

void NEAuthServiceProcHandlerIMP::onAuthStatusChanged(NEAuthStatus status, const NEAuthStatusExCode& error) {
    YXLOG_API(Info) << "Auth process handler, auth status changed: " << status << ", extended code: " << error.errorCode << YXLOGEnd;

    NS_I_NEM_SDK::NEErrorCode responseCode = NS_I_NEM_SDK::ERROR_CODE_FAILED;
    std::string strMessage = error.errorMessage;
    switch (status) {
        case kAuthIdle:
        case kAuthLoginProcessing:
        case kAuthLogOutFailed:
            return;
        case kAuthLoginFailed:
            responseCode = (NS_I_NEM_SDK::NEErrorCode)error.errorCode;
            strMessage = strMessage.empty() ? QString(tr("Failed to login to aPaas server")).toStdString() : strMessage;
            break;
        case kAuthInitRtcFailed:
        case kAuthInitIMFailed:
        case kAuthEnterIMFailed:
            responseCode = (NS_I_NEM_SDK::NEErrorCode)error.errorCode;
            strMessage = strMessage.empty() ? QString(tr("Failed to login")).toStdString() : strMessage;
            break;
        case kAuthLoginSuccessed: {
            connect(AuthManager::getInstance(), &AuthManager::authInfoExpired, []() {
                YXLOG(Info) << "Invoke auth info expired notification." << YXLOGEnd;
                auto* client = NEMeetingSDKIPCClient::getInstance();
                if (client) {
                    auto* authService = dynamic_cast<NEAuthServiceIPCClient*>(client->getAuthService());
                    if (authService)
                        authService->onAuthInfoExpired();
                }
            });
            responseCode = NS_I_NEM_SDK::ERROR_CODE_SUCCESS;
        } break;
        case kAuthLogOutSuccessed:
            responseCode = NS_I_NEM_SDK::ERROR_CODE_SUCCESS;
            break;
        default:
            return;
    }

    if (nullptr != m_loginCallback) {
        m_loginCallback(responseCode, strMessage);
        m_loginCallback = nullptr;
    }

    if (nullptr != m_logoutCallback) {
        m_logoutCallback(responseCode, strMessage);
        m_logoutCallback = nullptr;
    }
}
