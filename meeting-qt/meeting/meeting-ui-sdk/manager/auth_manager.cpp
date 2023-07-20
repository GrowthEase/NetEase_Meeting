// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "auth_manager.h"
#include <QFile>
#include <QObject>
#include "device_manager.h"
#include "global_manager.h"

AuthManager::AuthManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NEAuthStatus>();
    qRegisterMetaType<NEAuthStatusExCode>();
    qRegisterMetaType<NEAccountInfo>();
    connect(this, &AuthManager::login, this, &AuthManager::onLoginUI);
    connect(this, &AuthManager::logout, this, &AuthManager::onLogoutUI);
    connect(this, &AuthManager::authInfoExpired, this, &AuthManager::onAuthInfoExpiredUI);
}

AuthManager::~AuthManager() {}

bool AuthManager::initialize() {
    m_authController = std::make_shared<NEMeeingAuthController>();
    return true;
}

void AuthManager::release() {}

bool AuthManager::autoLogin() {
    return doLogin(m_autoLoginInfo.accountId, m_autoLoginInfo.accountToken);
}

void AuthManager::autoLogout() {
    doLogout();
}

bool AuthManager::doLogin(const QString& accountId, const QString& accountToken) {
    if (getAuthStatus() == kAuthLoginSuccessed) {
        YXLOG(Info) << "Logged in currently" << YXLOGEnd;
        Q_EMIT authStatusChanged(kAuthLoginSuccessed, 0);
        return true;
    }

    if (getAuthStatus() == kAuthLoginProcessing) {
        YXLOG(Info) << "Login in progress" << YXLOGEnd;
        return false;
    }

    m_loginType = nem_sdk_interface::kLoginTypeNEAccount;
    return m_authController->loginWithToken(accountId.toStdString(), accountToken.toStdString()) == kNENoError;
}

bool AuthManager::doAnonymousLogin(const neroom::NECallback<>& callback) {
    if (getAuthStatus() == kAuthLoginSuccessed) {
        YXLOG(Info) << "Logged in currently" << YXLOGEnd;
        Q_EMIT authStatusChanged(kAuthLoginSuccessed, 0);
        if (callback) {
            callback(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        }
        return true;
    }

    if (getAuthStatus() == kAuthLoginProcessing) {
        YXLOG(Info) << "Login in progress" << YXLOGEnd;
        if (callback) {
            callback(NS_I_NEM_SDK::ERROR_CODE_FAILED, "");
        }
        return false;
    }
    m_loginType = nem_sdk_interface::kLoginTypeNEAccount;
    return m_authController->anonymousLogin(callback);
}

bool AuthManager::doLoginWithPassword(const QString& username, const QString& password) {
    if (getAuthStatus() == kAuthLoginSuccessed) {
        YXLOG(Info) << "Logged in currently" << YXLOGEnd;
        Q_EMIT authStatusChanged(kAuthLoginSuccessed, 0);
        return true;
    }

    if (getAuthStatus() == kAuthLoginProcessing) {
        YXLOG(Info) << "Login in progress" << YXLOGEnd;
        return false;
    }

    m_loginType = nem_sdk_interface::kLoginTypeNEPassword;
    return m_authController->loginWithAccount(username.toStdString(), password.toStdString());
}

bool AuthManager::doLoginWithSSOToken(const QString& ssoToken) {
    if (getAuthStatus() == kAuthLoginSuccessed) {
        YXLOG(Info) << "Logged in currently" << YXLOGEnd;
        Q_EMIT authStatusChanged(kAuthLoginSuccessed, 0);
        return true;
    }

    if (getAuthStatus() == kAuthLoginProcessing) {
        YXLOG(Info) << "Login in progress" << YXLOGEnd;
        return false;
    }

    m_loginType = nem_sdk_interface::kLoginTypeSSOToken;
    return m_authController->loginWithSSOToken(ssoToken.toStdString());
}

bool AuthManager::doTryAutoLogin(const nem_sdk_interface::NEAuthService::NEAuthLoginCallback& cb) {
    if (getAuthStatus() == kAuthLoginSuccessed) {
        YXLOG(Info) << "Logged in currently" << YXLOGEnd;
        Q_EMIT authStatusChanged(kAuthLoginSuccessed, 0);
        return true;
    }

    if (getAuthStatus() == kAuthLoginProcessing) {
        YXLOG(Info) << "Login in progress" << YXLOGEnd;
        return false;
    }

    auto localNEAppKey = ConfigManager::getInstance()->getValue("localNEAppKey", "");
    auto localNEAccountId = ConfigManager::getInstance()->getValue("localNEAccountId", "");
    auto localNEAccountToken = ConfigManager::getInstance()->getValue("localNEAccountToken", "");
    if (/*localNEAppKey.toString().isEmpty() || */ localNEAccountId.toString().isEmpty() || localNEAccountToken.toString().isEmpty()) {
        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "");
        YXLOG(Info) << "Failed to try auto login, cache info is empty"
                    << ", appkey: " << localNEAppKey.toString().toStdString() << ", account ID: " << localNEAccountId.toString().toStdString()
                    << ", account token: " << localNEAccountToken.toString().toStdString() << YXLOGEnd;
        return false;
    }

    auto localLoginType = ConfigManager::getInstance()->getValue("localNELoginType", nem_sdk_interface::kLoginTypeUnknown);
    m_loginType = (nem_sdk_interface::NELoginType)(localLoginType.toInt());
    return m_authController->loginWithToken(localNEAccountId.toString().toStdString(), localNEAccountToken.toString().toStdString());
}

void AuthManager::doLogout(bool bExit) {
    YXLOG(Info) << "doLogout, bExit: " << bExit << ", anonymousLogin: " << m_anonymousLogin << YXLOGEnd;
    m_logoutExit = bExit;
    if (m_authController)
        m_authController->logout();
}

NEAccountInfo AuthManager::getAuthInfo() {
    if (m_authController == nullptr) {
        return NEAccountInfo();
    }
    return m_authController->getAccountInfo();
}

NEAuthStatus AuthManager::getAuthStatus() {
    if (m_authController == nullptr) {
        return kAuthIdle;
    }
    return m_authController->getAuthStatus();
}

void AuthManager::onAuthStatusChanged(NEAuthStatus authStatus, const NEAuthStatusExCode& result) {
    auto authAccountInfo = getAuthInfo();
    emit login(authStatus, authAccountInfo);
    if (authStatus == kAuthLoginSuccessed) {
        setAuthNickName(QString::fromStdString(authAccountInfo.displayName));
        setAuthAccountId(QString::fromStdString(authAccountInfo.accountId));
        ConfigManager::getInstance()->setValue("localNELoginType", m_loginType);
        ConfigManager::getInstance()->setValue("localNEAppKey", GlobalManager::getInstance()->globalAppKey());
        ConfigManager::getInstance()->setValue("localNEAccountId", authAccountInfo.accountId.c_str());
        ConfigManager::getInstance()->setValue("localNEAccountToken", authAccountInfo.accountToken.c_str());
    } else if (authStatus == kAuthLogOutSuccessed || authStatus == kAuthLogOutFailed) {
        emit logout();
        setAuthAccountId("");
        setAuthNickName("");
        if (m_anonymousLogin) {
            m_anonymousLogin = false;
        }
        if (autoLoginMode() || m_logoutExit) {
            YXLOG(Info) << "Auth logout exit." << YXLOGEnd;
            m_logoutExit = false;
            Invoker::getInstance()->execute([]() {
                YXLOG(Info) << "qApp exit." << YXLOGEnd;
                qApp->exit();
            });
        }
    }
    if (authStatus == kAuthLoginFailed) {
        //        ConfigManager::getInstance()->setValue("localNELoginType", kLoginTypeUnknown);
        //        ConfigManager::getInstance()->setValue("localNEAppKey", "");
        //        ConfigManager::getInstance()->setValue("localNEAccountId", "");
        //        ConfigManager::getInstance()->setValue("localNEAccountToken", "");
    }

    emit authStatusChanged(authStatus, result);
}

// void AuthManager::onAuthInfoChanged(const AccountInfoPtr authInfo) {
//    if (authInfo)
//        setAuthAccountId(QString::fromStdString(authInfo->getAccountId()));
//    else
//        setAuthAccountId("");
//}

// void AuthManager::onAuthInfoExpired() {
//    YXLOG(Info) << "Auth information expired." << YXLOGEnd;
//    emit authInfoExpired();
//}

// void AuthManager::onError(uint32_t errorCode, const std::string& errorMessage) {
//    YXLOG(Error) << "Auth manager got error message, code: " << errorCode << ", message: " << errorMessage << YXLOGEnd;
//    emit error(errorCode, QString::fromStdString(errorMessage));
//}

QString AuthManager::authAccountId() const {
    return QString::fromStdString(m_authController->getAccountInfo().accountId);
}

void AuthManager::setAuthAccountId(const QString& authAccountId) {
    m_authAccountId = authAccountId;
    emit authAccountIdChanged();
}

QString AuthManager::authAppKey() const {
    return QString::fromStdString(m_authController->getAccountInfo().appKey);
}

void AuthManager::setAuthAppKey(const QString& authAppKey) {
    m_authAppKey = authAppKey;
}

void AuthManager::setAutoLoginInfo(const QString& accountId, const QString& accountToken) {
    m_autoLoginInfo.accountId = accountId;
    m_autoLoginInfo.accountToken = accountToken;
    setAutoLoginMode(true);
}

void AuthManager::onLoginUI(NEAuthStatus authStatus, const NEAccountInfo& /*authAccountInfo*/) {
    // YXLOG(Info) << "On login UI callback, status: " << authStatus << YXLOGEnd;
    //    if (authStatus == kAuthLoginSuccessed) {
    //        DeviceManager::getInstance()->getRecordDevices();
    //        DeviceManager::getInstance()->getPlayoutDevices();
    //        DeviceManager::getInstance()->getCaptureDevices();
    //    }
}

void AuthManager::onLogoutUI() {
    DeviceManager::getInstance()->resetDevicesInfo();
}

void AuthManager::onAuthInfoExpiredUI() {
    setAuthAccountId("");
}

bool AuthManager::writeLoginCache(const LoginCacheInfo& cacheInfo) {
    QJsonObject cacheJson;
    cacheJson["appKey"] = cacheInfo.cacheAppKey;
    cacheJson["accountId"] = cacheInfo.cacheAccountId;
    cacheJson["accountToken"] = cacheInfo.cacheAccountToken;

    QByteArray byteArray = QJsonDocument(cacheJson).toJson(QJsonDocument::Compact);
    return true;
}

LoginCacheInfo AuthManager::readLoginCache() const {
    return LoginCacheInfo();
}

QString AuthManager::authNickName() const {
    return m_authNickName;
}

void AuthManager::setAuthNickName(const QString& authNickName) {
    m_authNickName = authNickName;
    emit authNickNameChanged();
}

void AuthManager::saveAccountSettings(const QJsonObject& settings) {
    m_authController->saveAccountSettings(settings);
}

QJsonObject AuthManager::getAccountSettings() const {
    return m_authController->getAccountSettings();
}

bool AuthManager::isHostAccount() const {
    return m_isHostAccount;
}

void AuthManager::setIsHostAccount(bool isHostAccount) {
    if (isHostAccount != m_isHostAccount) {
        m_isHostAccount = isHostAccount;
        emit isHostAccountChanged();
    }
}

bool AuthManager::autoLoginMode() const {
    return m_autoLoginMode;
}

void AuthManager::setAutoLoginMode(bool autoLoginMode) {
    m_autoLoginMode = autoLoginMode;
    emit autoLoginModeChanged();
}

bool AuthManager::isSupportBeauty() const {
    return GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported();
}
