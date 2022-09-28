// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef HTTP_MANAGER_H
#define HTTP_MANAGER_H

#include <QMutex>
#include <QNetworkReply>
#include <list>
#include <memory>
#include "http_request.h"

enum LocalError { kLocalParseJsonError = 10001, kLocalResultContentError };

const QString kHttpRequestId = "requestId";

using HttpRequestCallback = std::function<void(int, QJsonObject)>;
using HttpRequestProgressCallback = std::function<void(qint64, qint64)>;

Q_DECLARE_METATYPE(HttpRequestCallback)
Q_DECLARE_METATYPE(HttpRequestProgressCallback)

class HttpManager : public QObject {
    Q_OBJECT
public:
    static HttpManager* getInstance() {
        static QMutex mutex;
        if (!m_instance) {
            QMutexLocker locker(&mutex);
            if (!m_instance) {
                m_instance = new HttpManager(nullptr);
            }
        }
        return m_instance;
    }

    void postRequest(const IHttpRequest& request, const HttpRequestCallback& callback);
    void putRequest(const IHttpRequest& request, const HttpRequestCallback& callback);
    void deleteRequest(const IHttpRequest& request, const HttpRequestCallback& callback);
    void getRequest(const IHttpRequest& request, const HttpRequestCallback& callback);
    void abort();
    bool checkNetWorkOnline();

signals:

public slots:
    void handleFinished(QNetworkReply* reply);

private:
    explicit HttpManager(QObject* parent = nullptr);
    ~HttpManager();

private:
    QNetworkAccessManager* m_accessManager = nullptr;
    std::list<QNetworkReply*> m_listNetworkReply;
    QMutex mutex;
    std::atomic_bool m_bOnLine{false};
    static HttpManager* m_instance;
};

#endif  // HTTP_MANAGER_H
