// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "http_manager.h"
#include <QDebug>
#include <QHostInfo>
#include <QNetworkConfigurationManager>
#include <QUuid>
#include <mutex>

HttpManager::HttpManager(QObject* parent)
    : QObject(parent)
    , m_accessManager(new QNetworkAccessManager(parent)) {
    connect(m_accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
}

HttpManager::~HttpManager() {
    disconnect(m_accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
    // QNetworkAccessManager will destroy by parent automatically.
}

void HttpManager::postRequest(const IHttpRequest& request, const HttpRequestCallback& callback) {
    if (m_accessManager->networkAccessible() != QNetworkAccessManager::Accessible)
        m_accessManager->setNetworkAccessible(QNetworkAccessManager::Accessible);

    invokeRequest(request, Methods::POST, callback);
}

void HttpManager::getRequest(const IHttpRequest& request,
                             const HttpRequestCallback& callback,
                             const HttpRequestProgressCallback& proCallback,
                             bool isDownload) {
    if (m_accessManager->networkAccessible() != QNetworkAccessManager::Accessible)
        m_accessManager->setNetworkAccessible(QNetworkAccessManager::Accessible);

    QString requestId = QUuid::createUuid().toString();
    QVariant callbackVariant;
    callbackVariant.setValue(callback);

    auto* accessManager = new QNetworkAccessManager(this);
    connect(accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
    QNetworkReply* reply = accessManager->get(request);
    reply->setProperty("requestId", requestId);
    reply->setProperty("callback", callbackVariant);
    reply->setProperty("displayDetails", request.displayDetails());
    reply->setProperty("isDownload", isDownload);
    m_listNetworkReply.push_back(reply);

    connect(reply, &QNetworkReply::readyRead, this, [this, request]() {
        QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
        QFile* pFile = request.getFile();
        if (!reply || !pFile) {
            return;
        }
        pFile->write(reply->readAll());
    });
    connect(reply, &QNetworkReply::downloadProgress, this, [proCallback](qint64 bytesReceived, qint64 bytesTotal) {
        if (proCallback) {
            proCallback(bytesReceived, bytesTotal);
        }
    });

    if (request.displayDetails()) {
        auto headers = request.rawHeaderList();
        QString header;
        for (auto it : headers) {
            header.append(it.data()).append(":").append(request.rawHeader(it).data()).append(" ");
        }
        YXLOG(Info) << "[HTTP] Get new request, url\r\n\tpath -" << request.url().toString().toStdString() << "\r\n\thead -"
                    << (ConfigManager::getInstance()->getLocalDebugLevel() ? header.toStdString() : "") << "\r\n\tuuid -" << requestId.toStdString()
                    << YXLOGEnd;
    }
}

void HttpManager::handleFinished(QNetworkReply* reply) {
    auto requestId = reply->property("requestId").toString();
    auto userCallback = reply->property("callback").value<HttpRequestCallback>();
    auto displayDetails = reply->property("displayDetails").toBool();
    auto isDownload = reply->property("isDownload").toBool();

    if (QNetworkAccessManager::PostOperation == reply->operation() || QNetworkAccessManager::GetOperation == reply->operation()) {
        do {
            QJsonObject errorResponse;
            auto code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            auto responseContent = reply->readAll();

            if (displayDetails) {
                qInfo() << "[HTTP] Response\r\n\tcode -" << code << "\r\n\tbody -" << QString(responseContent) << "\r\n\tuuid -" << requestId;
            }

            if (reply->error() != QNetworkReply::NoError) {
                errorResponse["msg"] = tr("Failed to connect to server, please try agine.");
                userCallback(reply->error(), errorResponse);
                break;
            }

            if (isDownload) {
                userCallback(reply->error(), errorResponse);
            } else {
                QJsonParseError error;
                QJsonDocument document = QJsonDocument::fromJson(responseContent, &error);
                if (error.error != QJsonParseError::NoError || !document.isObject()) {
                    qInfo() << "[HTTP] Failed to parse json object:" << kLocalParseJsonError << responseContent;
                    userCallback(kLocalParseJsonError, QJsonObject());
                    break;
                }

                QJsonObject responseObject = document.object();
                code = responseObject["code"].toInt();
                if (0 != code && 200 != code) {
                    qInfo() << "[HTTP] Server response error: " << code << responseObject;
                    userCallback(code, responseObject);
                    break;
                }

                // successfully
                QJsonObject result = responseObject["data"].toObject();
                if (result.isEmpty()) {
                    result = responseObject["ret"].toObject();
                }
                userCallback(code, result);
            }
        } while (false);
    } /*else if (QNetworkAccessManager::GetOperation == reply->operation()) {
        do {
            QJsonObject errorResponse;
            auto code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            if (displayDetails) {
                qInfo() << "[HTTP] Response\r\n\tcode -" << code << "\r\n\turl -" << reply->url().toString() << "\r\n\tuuid -" << requestId;
            }

            if (reply->error() != QNetworkReply::NoError) {
                errorResponse["msg"] = tr("Failed to connect to server, please try agine.");
            }
            userCallback(reply->error(), errorResponse);
        } while (false);
    }*/

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
    QNetworkConfigurationManager mgr;
    if (!mgr.isOnline()) {
        return false;
    }

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

    auto req = request;
    req.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    QNetworkReply* reply = nullptr;
    auto* accessManager = new QNetworkAccessManager(this);
    connect(accessManager, &QNetworkAccessManager::finished, this, &HttpManager::handleFinished);
    switch (method) {
        case Methods::GET:
            reply = accessManager->get(request);
            break;
        case Methods::POST:
            reply = accessManager->post(request, request.getParams());
            break;
        case Methods::PUT:
            reply = accessManager->put(request, request.getParams());
            break;
        case Methods::DELETE:
            reply = accessManager->deleteResource(request);
            break;
        default:
            break;
    }
    reply->setProperty("requestId", requestId);
    reply->setProperty("callback", callbackVariant);
    reply->setProperty("displayDetails", req.displayDetails());
    //    m_listNetworkReply.push_back(reply);

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
