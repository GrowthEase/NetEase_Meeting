// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "auth_controller.h"
#include "manager/global_manager.h"
#include "modules/http/http_manager.h"
#include "modules/http/http_request.h"

NEMeeingAuthController::NEMeeingAuthController() {
    auto authService = GlobalManager::getInstance()->getAuthService();
    if (authService) {
        authService->addAuthListener(this);
    }
}

NEMeeingAuthController::~NEMeeingAuthController() {}

bool NEMeeingAuthController::loginWithToken(const std::string& accountId, const std::string& accountToken) {
    m_settings = QJsonObject();
    m_authStatus = kAuthLoginProcessing;
    m_accountInfo.accountId = accountId;
    m_accountInfo.accountToken = accountToken;
    GetUserInfoRequest request;
    HttpManager::getInstance()->getRequest(request, [=](int code, const QJsonObject& response) {
        if (200 == code) {
            m_accountInfo.username = response["nickname"].toString().toStdString();
            m_accountInfo.personalRoomId = response["privateMeetingNum"].toString().toStdString();
            m_accountInfo.shortRoomId = response["shortMeetingNum"].toString().toStdString();
            if (response.contains("settings")) {
                m_settings = response["settings"].toObject();
            }
            doLoginRoom(m_accountInfo.accountId, m_accountInfo.accountToken);
        } else {
            NEAuthStatusExCode codeEx;
            codeEx.errorCode = code;
            m_authStatus = kAuthLoginFailed;
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginFailed, code);
        }
    });
    return true;
}

bool NEMeeingAuthController::loginWithSSOToken(const std::string& ssoToken) {
    m_authStatus = kAuthLoginProcessing;
    return true;
}

bool NEMeeingAuthController::loginWithAccount(const std::string& username, const std::string& password) {
    m_settings = QJsonObject();
    m_authStatus = kAuthLoginProcessing;
    LoginRequest request(QString::fromStdString(username), QString::fromStdString(password));
    HttpManager::getInstance()->postRequest(request, [=](int code, const QJsonObject& response) {
        if (code == 200) {
            m_accountInfo.accountId = response["userUuid"].toString().toStdString();
            m_accountInfo.accountToken = response["userToken"].toString().toStdString();
            m_accountInfo.username = response["nickname"].toString().toStdString();
            m_accountInfo.personalRoomId = response["privateMeetingNum"].toString().toStdString();
            m_accountInfo.shortRoomId = response["shortMeetingNum"].toString().toStdString();
            if (response.contains("settings")) {
                m_settings = response["settings"].toObject();
            }
            doLoginRoom(m_accountInfo.accountId, m_accountInfo.accountToken);
        } else {
            NEAuthStatusExCode codeEx;
            codeEx.errorCode = code;
            m_authStatus = kAuthLoginFailed;
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginFailed, code);
        }
    });
    return true;
}

bool NEMeeingAuthController::anonymousLogin(const neroom::NECallback<>& callback) {
    m_settings = QJsonObject();
    m_authStatus = kAuthLoginProcessing;
    AnonymousLoginRequest request;
    HttpManager::getInstance()->postRequest(request, [=](int code, const QJsonObject& response) {
        if (code == 200) {
            m_accountInfo.accountId = response["userUuid"].toString().toStdString();
            m_accountInfo.accountToken = response["userToken"].toString().toStdString();
            if (response.contains("settings")) {
                m_settings = response["settings"].toObject();
            }
            doLoginRoom(m_accountInfo.accountId, m_accountInfo.accountToken, callback);
        } else {
            NEAuthStatusExCode codeEx;
            codeEx.errorCode = code;
            m_authStatus = kAuthLoginFailed;
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginFailed, code);
            if (callback) {
                callback(code, response["msg"].toString().toStdString());
            }
        }
    });
    return true;
}

bool NEMeeingAuthController::logout() {
    auto authService = GlobalManager::getInstance()->getAuthService();
    if (!authService) {
        return false;
    }
    authService->logout([this](int code, const std::string& msg) {
        YXLOG(Info) << "logout, code: " << code << "msg: " << msg << YXLOGEnd;
        if (code == 0) {
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLogOutSuccessed);
        } else {
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLogOutFailed);
        }
        m_authStatus = kAuthIdle;
        m_settings = QJsonObject();
    });

    return true;
}

NEAuthStatus NEMeeingAuthController::getAuthStatus() {
    return m_authStatus;
}

NEAccountInfo NEMeeingAuthController::getAccountInfo() {
    return m_accountInfo;
}

void NEMeeingAuthController::raiseExpiredCb() {}

bool NEMeeingAuthController::saveAccountSettings(const QJsonObject& settings, const neroom::NECallback<>& callback) {
    SaveSettingsRequest request(settings);
    HttpManager::getInstance()->postRequest(request, [=](int code, const QJsonObject& response) {

    });
    return true;
}

QJsonObject NEMeeingAuthController::getAccountSettings() const {
    return m_settings;
}

void NEMeeingAuthController::onAuthEvent(NEAuthEvent authEvent) {
    YXLOG(Info) << "onAuthEvent, authEvent:" << (int)authEvent << YXLOGEnd;
    switch (authEvent) {
        case neroom::NEAuthEvent::kAuthKickOut:
            AuthManager::getInstance()->onAuthStatusChanged(kAuthIMKickOut);
            m_authStatus = kAuthIdle;
            m_settings = QJsonObject();
            break;
        case neroom::NEAuthEvent::kAuthLoggedIn:
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginSuccessed);
            m_authStatus = kAuthLoginSuccessed;
            break;
        case neroom::NEAuthEvent::kAuthLoggedOut:
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginFailed);
            m_authStatus = kAuthIdle;
            m_settings = QJsonObject();
            break;
        default:
            break;
    }
}

bool NEMeeingAuthController::doLoginRoom(const std::string& account, const std::string& token, const neroom::NECallback<>& callback) {
    YXLOG(Info) << "doLoginRoom, account: " << account << YXLOGEnd;
    auto authService = GlobalManager::getInstance()->getAuthService();
    if (!authService) {
        return false;
    }
    authService->login(account, token, [=](int code, const std::string& msg) {
        YXLOG(Info) << "login res, code: " << code << ", msg:" << msg << YXLOGEnd;
        if (code == 0) {
            m_authStatus = kAuthLoginSuccessed;
        } else {
            NEAuthStatusExCode codeEx;
            codeEx.errorCode = code;
            codeEx.errorMessage = msg;
            m_authStatus = kAuthLoginFailed;
            m_settings = QJsonObject();
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginFailed, code);
        }

        if (callback) {
            callback(code, msg);
        }
    });

    return true;
}
