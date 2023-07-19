// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_authenticate.h"
#include <QDebug>
#include <string>

NEMAuthenticate::NEMAuthenticate(QObject* parent)
    : QObject(parent)
    , m_invoker(new Invoker) {}

bool NEMAuthenticate::authByPassword(const QString& username, const QString& password) {
    if (!isValid())
        return false;
    QByteArray byteUsername = username.toUtf8();
    QByteArray bytePassword = password.toUtf8();
    m_authService->loginByPassword(byteUsername.data(), bytePassword.data());
    return true;
}

bool NEMAuthenticate::authByNEToken(const QString& appKey, const QString& accountId, const QString& accountToken) {
    if (!isValid())
        return false;
    QByteArray byteAppKey = appKey.toUtf8();
    QByteArray byteAccountId = accountId.toUtf8();
    QByteArray byteAccountToken = accountToken.toUtf8();

    nem_sdk::LoginParam loginParam;
    loginParam.appKey = byteAppKey.data();
    loginParam.accountId = byteAccountId.data();
    loginParam.accountToken = byteAccountToken.data();
    m_authService->loginByNEAccount(loginParam);
    return true;
}

bool NEMAuthenticate::authBySSO(const QString& ssoToken) {
    if (!isValid())
        return false;
    QByteArray byteSSOToken = ssoToken.toUtf8();
    m_authService->loginBySSOToken(byteSSOToken.data());
    return true;
}

bool NEMAuthenticate::signOut() {
    if (!isValid())
        return false;
    if (m_authService != nullptr)
        m_authService->logout();
    return true;
}

NEMAuthenticate::NEMAuthType NEMAuthenticate::authType() const {
    return m_authType;
}

void NEMAuthenticate::setAuthType(const NEMAuthType& loginType) {
    if (m_authType != loginType) {
        m_authType = loginType;
        Q_EMIT authTypeChanged();
    }
}

NEMEngine* NEMAuthenticate::engine() const {
    return m_engine;
}

void NEMAuthenticate::setEngine(NEMEngine* engine) {
    if (m_engine == engine || engine == nullptr)
        return;
    m_engine = engine;

    m_authService = m_engine->getAuthService();
    if (m_authService != nullptr) {
        m_authService->setEventHandler(this);
        setIsValid(m_authService != nullptr);
    }

    Q_EMIT engineChanged();
}

NEMAccount* NEMAuthenticate::account() const {
    return m_account;
}

void NEMAuthenticate::setAccount(NEMAccount* account) {
    if (m_account != account) {
        m_account = account;
        setAccountInfo();
        Q_EMIT accountChanged();
    }
}

bool NEMAuthenticate::isValid() const {
    return m_isValid;
}

void NEMAuthenticate::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

NEMAuthenticate::NEMAuthState NEMAuthenticate::state() const {
    return m_state;
}

void NEMAuthenticate::setState(const NEMAuthState& state) {
    if (m_state != state) {
        m_state = state;
        Q_EMIT stateChanged();

        switch (state) {
            case AUTH_STATE_LOGGEDIN:
                if (m_account)
                    setAccountInfo();
                break;
            default:
                if (m_account)
                    setAccountInfo(true);
                break;
        }
    }
}

void NEMAuthenticate::onAuthStatusChanged(nem_sdk::AuthStatus authStatus, const nem_sdk::AuthStatusExCode& result) {
    m_invoker->execute([=]() {
        switch (authStatus) {
            case nem_sdk::kAuthIdle:
            case nem_sdk::kAuthLogOutSuccessed:
                setState(AUTH_STATE_IDLE);
                break;
            case nem_sdk::kAuthLoginProcessing:
                setState(AUTH_STATE_PROCESSING);
                break;
            case nem_sdk::kAuthLoginSuccessed:
                setState(AUTH_STATE_LOGGEDIN);
                break;
            case nem_sdk::kAuthLoginFailed:
            case nem_sdk::kAuthInitRtcFailed:
            case nem_sdk::kAuthInitIMFailed:
            case nem_sdk::kAuthEnterIMFailed:
            case nem_sdk::kAuthLogOutFailed:
                setState(AUTH_STATE_FAILED);
                break;
            default:
                break;
        }
        setErrorCode(result.errorCode);
        setErrorMessage(QString::fromStdString(result.errorMessage.c_str()));
    });
}

void NEMAuthenticate::onAuthInfoChanged(const nem_sdk::AccountInfoPtr authInfo) {
    if (authInfo != nullptr && m_account != nullptr) {
        setAccountInfo();
    }
}

void NEMAuthenticate::onAuthInfoExpired() {
    if (m_account != nullptr) {
        setAccountInfo(true);
    }
}

void NEMAuthenticate::onError(uint32_t errorCode, const std::string& errorMessage) {
    setErrorCode(errorCode);
    setErrorMessage(QString::fromStdString(errorMessage.c_str()));
}

void NEMAuthenticate::setAccountInfo(bool cleanup) {
    if (!cleanup && isValid()) {
        auto authInfo = m_authService->getAccountInfo();
        if (authInfo) {
            m_account->setAccountName(QString::fromStdString(authInfo->getUsername()));
            m_account->setAccountId(QString::fromStdString(authInfo->getAccountId()));
            m_account->setDisplayName(QString::fromStdString(authInfo->getNickname()));
            m_account->setPersonalId(QString::fromStdString(authInfo->getPersonalMeetingId()));
            m_account->setShortPersonalId(QString::fromStdString(authInfo->getShortMeetingNum()));
            m_account->setIsValid(true);
        }
    } else {
        m_account->setAccountName("");
        m_account->setAccountId("");
        m_account->setDisplayName("");
        m_account->setPersonalId("");
        m_account->setShortPersonalId("");
        m_account->setIsValid(false);
    }
}

QString NEMAuthenticate::errorMessage() const {
    return m_errorMessage;
}

void NEMAuthenticate::setErrorMessage(const QString& errorMessage) {
    if (m_errorMessage != errorMessage) {
        m_errorMessage = errorMessage;
        Q_EMIT errorMessageChanged();
    }
}

int NEMAuthenticate::errorCode() const {
    return m_errorCode;
}

void NEMAuthenticate::setErrorCode(int errorCode) {
    if (m_errorCode != errorCode) {
        m_errorCode = errorCode;
        Q_EMIT errorCodeChanged();
    }
}
