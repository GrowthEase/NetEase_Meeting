// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "http_manager.h"
#include <QDebug>
#include <QHostInfo>
#include <QUuid>
#include <mutex>
#include <regex>

HttpManager* HttpManager::m_instance = nullptr;

HttpManager::HttpManager(QObject* parent)
    : QObject(parent) {}

HttpManager::~HttpManager() {
    disconnect(m_accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
    // QNetworkAccessManager will destroy by parent automatically.
}

void HttpManager::postRequest(const IHttpRequest& request, const HttpRequestCallback& callback) {
    invokeRequest(request, Methods::POST, callback);
}

void HttpManager::putRequest(const IHttpRequest& request, const HttpRequestCallback& callback) {
    invokeRequest(request, Methods::PUT, callback);
}

void HttpManager::deleteRequest(const IHttpRequest& request, const HttpRequestCallback& callback) {
    invokeRequest(request, Methods::DELETE, callback);
}

void HttpManager::getRequest(const IHttpRequest& request, const HttpRequestCallback& callback) {
    invokeRequest(request, Methods::GET, callback);
}

void HttpManager::handleFinished(QNetworkReply* reply) {
    auto requestId = reply->property("requestId").toString();
    auto userCallback = reply->property("callback").value<HttpRequestCallback>();
    auto displayDetails = reply->property("displayDetails").toBool();
    auto* accessManager = reply->manager();

    if (QNetworkAccessManager::PostOperation == reply->operation() || QNetworkAccessManager::PutOperation == reply->operation() ||
        QNetworkAccessManager::GetOperation == reply->operation() || QNetworkAccessManager::DeleteOperation == reply->operation()) {
        do {
            QJsonObject errorResponse;
            auto code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            auto responseContent = reply->readAll();

            if (displayDetails) {
                YXLOG(Info) << "[HTTP] Response\r\n\tcode -" << code << "\r\n\tbody -" << QString(responseContent).toStdString() << "\r\n\tuuid -"
                            << requestId.toStdString() << YXLOGEnd;
            }

            if (reply->error() != QNetworkReply::NoError) {
                errorResponse["msg"] = tr("Failed to connect to server, please try again.");
                userCallback(reply->error(), errorResponse);
                break;
            }

            QJsonParseError error;
            QJsonDocument document = QJsonDocument::fromJson(responseContent, &error);
            if (error.error != QJsonParseError::NoError || !document.isObject()) {
                qInfo() << "[HTTP] Failed to parse json object:" << kLocalParseJsonError << responseContent;
                userCallback(kLocalParseJsonError, QJsonObject());
                break;
            }

            QJsonObject responseObject = document.object();
            int resultCode = responseObject["code"].toInt();
            if (resultCode != 0) {
                qInfo() << "[HTTP] Server response error: " << resultCode << responseObject;
                userCallback(resultCode, responseObject);
                break;
            }

            // successfully
            QJsonObject result = responseObject["data"].toObject();
            result["requestId"] = responseObject["requestId"].toString();
            result["msg"] = responseObject["msg"].toString();
            auto costString = responseObject["cost"].toString().toStdString();
            std::regex pattern("\\d+");
            std::smatch match;
            if (std::regex_search(costString, match, pattern))
                result["cost"] = std::stoi(match.str());
            userCallback(code, result);
        } while (false);
    }

    if (reply->error() == QNetworkReply::OperationCanceledError) {
        auto it = std::find(m_listNetworkReply.begin(), m_listNetworkReply.end(), reply);
        if (it != m_listNetworkReply.end()) {
            m_listNetworkReply.erase(it);
        }
        reply->deleteLater();
        return;
    }

    QMutexLocker locker(&mutex);
    auto it = std::find(m_listNetworkReply.begin(), m_listNetworkReply.end(), reply);
    if (it != m_listNetworkReply.end()) {
        m_listNetworkReply.erase(it);
    }
    reply->deleteLater();
}

void HttpManager::abort() {
    QMutexLocker locker(&mutex);
    std::list<QNetworkReply*> listNetworkReply = m_listNetworkReply;
    if (!listNetworkReply.empty()) {
        for (auto& it : listNetworkReply) {
            if (it->isRunning()) {
                it->abort();
            }
        }
    }
}

bool HttpManager::checkNetWorkOnline() {
    // QNetworkConfigurationManager mgr;
    // if (!mgr.isOnline()) {
    //     return false;
    // }

    QEventLoop loop;
    QHostInfo::lookupHost("www.baidu.com", this, [=, &loop](QHostInfo host) {
        m_bOnLine = (host.error() == QHostInfo::NoError);
        loop.quit();
    });
    loop.exec(QEventLoop::ExcludeUserInputEvents);
    return m_bOnLine;
}

void HttpManager::invokeRequest(const IHttpRequest& request, const Methods& method, const HttpRequestCallback& callback) {
    QString requestId = QUuid::createUuid().toString();
    QVariant callbackVariant;
    callbackVariant.setValue(callback);

#if 0
    if (m_accessManager == nullptr) {
        m_accessManager = new QNetworkAccessManager(this);
        connect(m_accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
    }
#else
    m_accessManager = new QNetworkAccessManager(this);
    connect(m_accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
#endif

    auto req = request;
    req.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    QNetworkReply* reply = nullptr;
    switch (method) {
        case Methods::GET:
            reply = m_accessManager->get(req);
            break;
        case Methods::POST:
            reply = m_accessManager->post(req, req.getParams());
            break;
        case Methods::PUT:
            reply = m_accessManager->put(req, req.getParams());
            break;
        case Methods::DELETE:
            reply = m_accessManager->deleteResource(req);
            break;
        default:
            break;
    }
    reply->setProperty("requestId", requestId);
    reply->setProperty("callback", callbackVariant);
    reply->setProperty("displayDetails", req.displayDetails());

    if (req.displayDetails()) {
        auto headers = req.rawHeaderList();
        QString header;
        for (auto it : headers) {
            header.append(it.data()).append(":").append(req.rawHeader(it).data()).append(" ");
        }
        YXLOG(Info) << "[HTTP] invoke new request, method: " << static_cast<int>(method) << ", url\r\n\tpath -" << req.url().toString().toStdString()
                    << "\r\n\thead -"
                    << header.toStdString() /*(ConfigManager::getInstance()->getLocalDebugLevel() ? header.toStdString() : "")*/ << "\r\n\tuuid -"
                    << requestId.toStdString() << YXLOGEnd;
    }
}
