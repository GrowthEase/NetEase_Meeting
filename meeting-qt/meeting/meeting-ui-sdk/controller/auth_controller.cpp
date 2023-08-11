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
    m_loginEvent = std::make_shared<LoginEvent>(LoginEventType::kToken);
    auto step = std::make_shared<MeetingEventStepBase>("account_info");
    GetUserInfoRequest request;
    HttpManager::getInstance()->getRequest(request, [=](int code, const QJsonObject& response) {
        step->SetResultCode(code == kHttpResSuccess ? response["code"].toInt() : code);
        step->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
        step->SetStepMessage(code == kHttpResSuccess ? response["msg"].toString().toStdString() : "");
        step->SetStepRequestID(code == kHttpResSuccess ? response["requestId"].toString().toStdString() : "");
        step->SetServerCost(code == kHttpResSuccess ? response["cost"].toInt() : 0);
        m_loginEvent->AddStep(step);
        if (kHttpResSuccess == code) {
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
            m_authStatus = kAuthIdle;
            m_settings = QJsonObject();
            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(m_loginEvent);
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
    m_loginEvent = std::make_shared<LoginEvent>(LoginEventType::kPassword);
    auto step = std::make_shared<MeetingEventStepBase>("account_info");
    LoginRequest request(QString::fromStdString(username), QString::fromStdString(password));
    HttpManager::getInstance()->postRequest(request, [=](int code, const QJsonObject& response) {
        if (m_loginEvent) {
            step->SetResultCode(code == kHttpResSuccess ? response["code"].toInt() : code);
            step->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
            step->SetStepMessage(code == kHttpResSuccess ? response["msg"].toString().toStdString() : "");
            step->SetStepRequestID(code == kHttpResSuccess ? response["requestId"].toString().toStdString() : "");
            step->SetServerCost(code == kHttpResSuccess ? response["cost"].toInt() : 0);
            m_loginEvent->AddStep(step);
        }
        if (code == kHttpResSuccess) {
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
            m_authStatus = kAuthIdle;
            m_settings = QJsonObject();
            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(m_loginEvent);
        }
    });
    return true;
}

bool NEMeeingAuthController::anonymousLogin(const neroom::NECallback<NEMeetingResponseKeys>& callback) {
    m_settings = QJsonObject();
    m_authStatus = kAuthLoginProcessing;
    m_loginEvent = std::make_shared<LoginEvent>(LoginEventType::kAnonymous);
    auto step = std::make_shared<MeetingEventStepBase>("account_info");
    AnonymousLoginRequest request;
    HttpManager::getInstance()->postRequest(request, [=](int code, const QJsonObject& response) {
        NEMeetingResponseKeys responseKyes;
        responseKyes.code = code == kHttpResSuccess ? response["code"].toInt() : code;
        responseKyes.message = code == kHttpResSuccess ? response["msg"].toString().toStdString() : "";
        responseKyes.requestID = code == kHttpResSuccess ? response["requestId"].toString().toStdString() : "";
        responseKyes.cost = code == kHttpResSuccess ? response["cost"].toInt() : 0;
        if (m_loginEvent) {
            step->SetResultCode(code == kHttpResSuccess ? response["code"].toInt() : code);
            step->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
            step->SetStepMessage(code == kHttpResSuccess ? response["msg"].toString().toStdString() : "");
            step->SetStepRequestID(code == kHttpResSuccess ? response["requestId"].toString().toStdString() : "");
            step->SetServerCost(code == kHttpResSuccess ? response["cost"].toInt() : 0);
            m_loginEvent->AddStep(step);
        }

        if (code == kHttpResSuccess) {
            m_accountInfo.accountId = response["userUuid"].toString().toStdString();
            m_accountInfo.accountToken = response["userToken"].toString().toStdString();
            if (response.contains("settings")) {
                m_settings = response["settings"].toObject();
            }
            doLoginRoom(m_accountInfo.accountId, m_accountInfo.accountToken,
                        [=](int code, const std::string& msg) { callback(code, msg, responseKyes); });
        } else {
            NEAuthStatusExCode codeEx;
            codeEx.errorCode = code;
            m_authStatus = kAuthLoginFailed;
            AuthManager::getInstance()->onAuthStatusChanged(kAuthLoginFailed, code);
            if (callback) {
                callback(code, response["msg"].toString().toStdString(), responseKyes);
            }
            m_authStatus = kAuthIdle;
            m_settings = QJsonObject();
            GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(m_loginEvent);
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
        YXLOG(Info) << "logout, code: " << code << ", msg: " << msg << YXLOGEnd;
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
    HttpManager::getInstance()->postRequest(
        request, [=](int code, const QJsonObject& response) { YXLOG(Info) << "Save account settings, result code: " << code << YXLOGEnd; });
    return true;
}

QJsonObject NEMeeingAuthController::getAccountSettings() const {
    return m_settings;
}

void NEMeeingAuthController::onAuthEvent(NEAuthEvent authEvent) {
    YXLOG(Info) << "onAuthEvent, authEvent: " << (int)authEvent << YXLOGEnd;
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
        YXLOG(Info) << "authService is null." << YXLOGEnd;
        if (callback) {
            callback(-1, "");
        }
        return false;
    }
    auto roomkitStep = std::make_shared<MeetingEventStepBase>("roomkit_login");
    authService->login(account, token, [=](int code, const std::string& msg) {
        YXLOG(Info) << "login res, code: " << code << ", msg: " << msg << YXLOGEnd;
        if (m_loginEvent) {
            roomkitStep->SetEndTime(QDateTime::currentDateTime().toMSecsSinceEpoch());
            roomkitStep->SetResultCode(code);
            roomkitStep->SetStepMessage(msg);
            m_loginEvent->AddStep(roomkitStep);
        }
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
        if (callback)
            callback(code, msg);
        GlobalManager::getInstance()->getMeetingEventReporter()->AddEvent(m_loginEvent);
    });

    return true;
}
