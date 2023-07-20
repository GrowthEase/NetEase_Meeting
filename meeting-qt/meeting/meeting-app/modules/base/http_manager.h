// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef HTTP_MANAGER_H
#define HTTP_MANAGER_H

#include <QMutex>
#include <list>
#include <memory>
#include "http_request.h"

#if defined(Q_OS_WIN32)
#if defined(DELETE)
#undef DELETE
#endif
#endif

enum LocalError { kLocalParseJsonError = 10001, kLocalResultContentError };

const QString kHttpRequestId = "requestId";

using HttpRequestCallback = std::function<void(int, QJsonObject)>;
using HttpRequestProgressCallback = std::function<void(qint64, qint64)>;

Q_DECLARE_METATYPE(HttpRequestCallback)
Q_DECLARE_METATYPE(HttpRequestProgressCallback)

class HttpManager : public QObject {
    Q_OBJECT
public:
    enum class Methods { GET, POST, PUT, DELETE };
    explicit HttpManager(QObject* parent = nullptr);
    ~HttpManager();
    void postRequest(const IHttpRequest& request, const HttpRequestCallback& callback);
    void getRequest(const IHttpRequest& request,
                    const HttpRequestCallback& callback,
                    const HttpRequestProgressCallback& proCallback = HttpRequestProgressCallback(),
                    bool isDownload = false);
    void abort();

    bool checkNetWorkOnline();

signals:

public slots:
    void handleFinished(QNetworkReply* reply);

private:
    void invokeRequest(const IHttpRequest& request, const Methods& method, const HttpRequestCallback& callback);

private:
    QNetworkAccessManager* m_accessManager = nullptr;
    std::list<QNetworkReply*> m_listNetworkReply;
    QMutex mutex;
    std::atomic_bool m_bOnLine{false};
};

#endif  // HTTP_MANAGER_H
