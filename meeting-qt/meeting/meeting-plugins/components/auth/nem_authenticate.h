// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_AUTH_NEM_AUTHENTICATE_H_
#define MEETING_PLUGINS_COMPONENTS_AUTH_NEM_AUTHENTICATE_H_

#include <QObject>
#include <QPointer>
#include <string>
#include "include/auth_service_interface.h"
#include "nem_account.h"
#include "nem_engine.h"
#include "utils/invoker.h"

class NEMAuthenticate : public QObject, public nem_sdk::IAuthEventHandler {
    Q_OBJECT
    Q_ENUMS(NEMAuthType)
    Q_ENUMS(NEMAuthState)

public:
    enum NEMAuthType {
        AUTH_BY_PASSWORD,  // NEMeeting username and password
        AUTH_BY_SSO,       // SSO token
        AUTH_BY_NETOKEN    // NEMeeting unique account ID and token
    };

    enum NEMAuthState {
        AUTH_STATE_IDLE,        // Idle
        AUTH_STATE_PROCESSING,  // Auth processing
        AUTH_STATE_LOGGEDIN,    // Auth sccessed
        AUTH_STATE_FAILED       // Failed to auth
    };

    explicit NEMAuthenticate(QObject* parent = nullptr);

    Q_PROPERTY(NEMEngine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(NEMAccount* account READ account WRITE setAccount NOTIFY accountChanged)
    Q_PROPERTY(NEMAuthType authType READ authType WRITE setAuthType NOTIFY authTypeChanged)
    Q_PROPERTY(NEMAuthState state READ state NOTIFY stateChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(int errorCode READ errorCode NOTIFY errorCodeChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

    Q_INVOKABLE bool authByPassword(const QString& username, const QString& password);
    Q_INVOKABLE bool authByNEToken(const QString& appKey, const QString& accountId, const QString& accountToken);
    Q_INVOKABLE bool authBySSO(const QString& ssoToken);
    Q_INVOKABLE bool signOut();

    NEMAuthType authType() const;
    void setAuthType(const NEMAuthType& loginType);

    NEMEngine* engine() const;
    void setEngine(NEMEngine* engine);

    NEMAccount* account() const;
    void setAccount(NEMAccount* account);

    bool isValid() const;
    void setIsValid(bool isValid);

    NEMAuthState state() const;
    void setState(const NEMAuthState& state);

    int errorCode() const;
    void setErrorCode(int errorCode);

    QString errorMessage() const;
    void setErrorMessage(const QString& errorMessage);

Q_SIGNALS:
    void engineChanged();
    void accountChanged();
    void authTypeChanged();
    void stateChanged();
    void isValidChanged();
    void errorCodeChanged();
    void errorMessageChanged();

protected:
    void onAuthStatusChanged(nem_sdk::AuthStatus authStatus, const nem_sdk::AuthStatusExCode& result) override;
    void onAuthInfoChanged(const nem_sdk::AccountInfoPtr authInfo) override;
    void onAuthInfoExpired() override;
    void onError(uint32_t errorCode, const std::string& errorMessage) override;

private:
    void onAuthCallback();
    void setAccountInfo(bool cleanup = false);

private:
    QPointer<Invoker> m_invoker = nullptr;
    QPointer<NEMEngine> m_engine = nullptr;
    QPointer<NEMAccount> m_account = nullptr;
    nem_sdk::IAuthService* m_authService = nullptr;
    NEMAuthType m_authType = AUTH_BY_PASSWORD;
    NEMAuthState m_state = AUTH_STATE_IDLE;
    bool m_isValid = false;
    int m_errorCode = 0;
    QString m_errorMessage;
};

#endif  // MEETING_PLUGINS_COMPONENTS_AUTH_NEM_AUTHENTICATE_H_
