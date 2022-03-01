/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#include "auth_manager.h"
#include <QFile>
#include <QObject>
#include "device_manager.h"
#include "global_manager.h"

AuthManager::AuthManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NEAuthStatus>();
    qRegisterMetaType<NEAuthStatusExCode>();
    qRegisterMetaType<AccountInfoPtr>();
    connect(this, &AuthManager::login, this, &AuthManager::onLoginUI);
    connect(this, &AuthManager::logout, this, &AuthManager::onLogoutUI);
    connect(this, &AuthManager::authInfoExpired, this, &AuthManager::onAuthInfoExpiredUI);
}

AuthManager::~AuthManager() {}

bool AuthManager::initialize() {
    m_authService = GlobalManager::getInstance()->getAuthService();

    if (m_authService == nullptr)
        return false;
    m_authService->addAuthListener(this);

    return true;
}

void AuthManager::release() {
    if (m_authService)
        m_authService->removeAuthListener(this);
}

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

    return m_authService->loginWithToken(accountId.toStdString(), accountToken.toStdString()) == kNENoError;
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

    return m_authService->loginWithAccount(username.toStdString(), password.toStdString());
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

    return m_authService->loginWithSSOToken(ssoToken.toStdString());
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
    if (localNEAppKey.toString().isEmpty() || localNEAccountId.toString().isEmpty() || localNEAccountToken.toString().isEmpty()) {
        cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "");
        YXLOG(Info) << "Failed to try auto login, cache info is empty"
                    << ", appkey: " << localNEAppKey.toString().toStdString() << ", account ID: " << localNEAccountId.toString().toStdString()
                    << ", account token: " << localNEAccountToken.toString().toStdString() << YXLOGEnd;
        return false;
    }

    auto localLoginType = ConfigManager::getInstance()->getValue("localNELoginType", nem_sdk_interface::kLoginTypeUnknown);
    m_loginType = (nem_sdk_interface::NELoginType)(localLoginType.toInt());
    return m_authService->loginWithToken(localNEAccountId.toString().toStdString(), localNEAccountToken.toString().toStdString());
}

bool AuthManager::doLoginAnoymous() {
    // m_authService->loginByAnonymous();
    return true;
}

void AuthManager::doLogout(bool bExit) {
    m_logoutExit = bExit;
    m_authService->logout();
}

AccountInfoPtr AuthManager::getAuthInfo() {
    return m_authService->getAccountInfo();
}

NEAuthStatus AuthManager::getAuthStatus() {
    return m_authService->getAuthStatus();
}

void AuthManager::onAuthStatusChanged(NEAuthStatus authStatus, const NEAuthStatusExCode& result) {
    AccountInfoPtr authAccountInfo = getAuthInfo();
    emit login(authStatus, authAccountInfo);
    if (authStatus == kAuthLoginSuccessed) {
        setAuthNickName(QString::fromStdString(authAccountInfo->getNickname()));
        setAuthAccountId(QString::fromStdString(authAccountInfo->getAccountId()));
        if (!authAccountInfo->getPersonalRoomId().empty()) {
            ConfigManager::getInstance()->setValue("localNELoginType", m_loginType);
            ConfigManager::getInstance()->setValue("localNEAppKey", authAccountInfo->getAppKey().c_str());
            ConfigManager::getInstance()->setValue("localNEAccountId", authAccountInfo->getAccountId().c_str());
            ConfigManager::getInstance()->setValue("localNEAccountToken", authAccountInfo->getAccountToken().c_str());
        }
    } else if (authStatus == kAuthLogOutSuccessed || authStatus == kAuthLogOutFailed) {
        emit logout();
        setAuthAccountId("");
        setAuthNickName("");
        if (autoLoginMode() || m_logoutExit) {
            m_logoutExit = false;
            qApp->exit();
        }
    }
    if (authStatus == kAuthLoginFailed) {
        ConfigManager::getInstance()->setValue("localNELoginType", kLoginTypeUnknown);
        ConfigManager::getInstance()->setValue("localNEAppKey", "");
        ConfigManager::getInstance()->setValue("localNEAccountId", "");
        ConfigManager::getInstance()->setValue("localNEAccountToken", "");
    }

    emit authStatusChanged(authStatus, result);
}

void AuthManager::onAuthInfoChanged(const AccountInfoPtr authInfo) {
    if (authInfo)
        setAuthAccountId(QString::fromStdString(authInfo->getAccountId()));
    else
        setAuthAccountId("");
}

void AuthManager::onAuthInfoExpired() {
    YXLOG(Info) << "Auth information expired." << YXLOGEnd;
    emit authInfoExpired();
}

void AuthManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    YXLOG(Error) << "Auth manager got error message, code: " << errorCode << ", message: " << errorMessage << YXLOGEnd;
    emit error(errorCode, QString::fromStdString(errorMessage));
}

QString AuthManager::authAccountId() const {
    if (m_authService->getAccountInfo() == nullptr) {
        return "";
    }
    return QString::fromStdString(m_authService->getAccountInfo()->getAccountId());
}

void AuthManager::setAuthAccountId(const QString& authAccountId) {
    m_authAccountId = authAccountId;
    emit authAccountIdChanged();
}

QString AuthManager::authAppKey() const {
    if (m_authService->getAccountInfo() == nullptr) {
        return "";
    }
    return QString::fromStdString(m_authService->getAccountInfo()->getAppKey());
}

void AuthManager::setAuthAppKey(const QString& authAppKey) {
    m_authAppKey = authAppKey;
}

void AuthManager::setAutoLoginInfo(const QString& accountId, const QString& accountToken) {
    m_autoLoginInfo.accountId = accountId;
    m_autoLoginInfo.accountToken = accountToken;
    setAutoLoginMode(true);
}

void AuthManager::onLoginUI(NEAuthStatus authStatus, const AccountInfoPtr& /*authAccountInfo*/) {
    YXLOG(Info) << "On login UI callback, status: " << authStatus << YXLOGEnd;
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
