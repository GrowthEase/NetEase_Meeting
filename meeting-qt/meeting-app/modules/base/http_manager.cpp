/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

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

    QString requestId = QUuid::createUuid().toString();
    QVariant callbackVariant;
    callbackVariant.setValue(callback);

    QNetworkReply* reply = m_accessManager->post(request, request.getParams());
    reply->setProperty("requestId", requestId);
    reply->setProperty("callback", callbackVariant);
    reply->setProperty("displayDetails", request.displayDetails());

    if (request.displayDetails()) {
        auto headers = request.rawHeaderList();
        QString header;
        for (auto it : headers) {
            header.append(it.data()).append(":").append(request.rawHeader(it).data()).append(" ");
        }

        YXLOG(Info) << "[HTTP] Post new request, url\n\tpath - " << request.url().toString().toStdString() << "\n\thead - \n"
                << (ConfigManager::getInstance()->getLocalDebugLevel() ? header.toStdString() : "") << "\n\tbody - \n\t\t" << request.getParams().toStdString() << "\n\tuuid - " << requestId.toStdString() << YXLOGEnd;
    }
}

void HttpManager::getRequest(const IHttpRequest& request, const HttpRequestCallback& callback, const HttpRequestProgressCallback& proCallback) {
    if (m_accessManager->networkAccessible() != QNetworkAccessManager::Accessible)
        m_accessManager->setNetworkAccessible(QNetworkAccessManager::Accessible);

    QString requestId = QUuid::createUuid().toString();
    QVariant callbackVariant;
    callbackVariant.setValue(callback);

    QNetworkReply* reply = m_accessManager->get(request);
    reply->setProperty("requestId", requestId);
    reply->setProperty("callback", callbackVariant);
    reply->setProperty("displayDetails", request.displayDetails());
    m_listNetworkReply.push_back(reply);

    connect(reply, &QNetworkReply::readyRead, this, [this, request]() {
        QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
        QFile* pFile = request.getFile();
        if (!reply || !pFile) {
            return;
        }
        pFile->write(reply->readAll());
    });
    connect(reply, &QNetworkReply::downloadProgress, this,
            [proCallback](qint64 bytesReceived, qint64 bytesTotal) { proCallback(bytesReceived, bytesTotal); });

    if (request.displayDetails()) {
        auto headers = request.rawHeaderList();
        QString header;
        for (auto it : headers) {
            header.append(it.data()).append(":").append(request.rawHeader(it).data()).append(" ");
        }
        YXLOG(Info) << "[HTTP] Get new request, url\r\n\tpath -" << request.url().toString().toStdString() << "\r\n\thead -" << (ConfigManager::getInstance()->getLocalDebugLevel() ? header.toStdString() : "")
                << "\r\n\tuuid -" << requestId.toStdString() << YXLOGEnd;
    }
}

void HttpManager::handleFinished(QNetworkReply* reply) {
    auto requestId = reply->property("requestId").toString();
    auto userCallback = reply->property("callback").value<HttpRequestCallback>();
    auto displayDetails = reply->property("displayDetails").toBool();

    if (QNetworkAccessManager::PostOperation == reply->operation()) {
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

            QJsonParseError error;
            QJsonDocument document = QJsonDocument::fromJson(responseContent, &error);
            if (error.error != QJsonParseError::NoError || !document.isObject()) {
                qInfo() << "[HTTP] Failed to parse json object:" << kLocalParseJsonError << responseContent;
                userCallback(kLocalParseJsonError, QJsonObject());
                break;
            }

            QJsonObject responseObject = document.object();
            int resultCode = responseObject["code"].toInt();
            if (resultCode != 200) {
                qInfo() << "[HTTP] Server response error: " << resultCode << responseObject;
                userCallback(resultCode, responseObject);
                break;
            }

            // successfully
            QJsonObject result = responseObject["ret"].toObject();
            userCallback(code, result);
        } while (false);
    } else if (QNetworkAccessManager::GetOperation == reply->operation()) {
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
