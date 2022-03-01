/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef HTTP_MANAGER_H
#define HTTP_MANAGER_H

#include "http_request.h"
#include <list>
#include <QMutex>
#include <memory>

enum LocalError
{
    kLocalParseJsonError = 10001,
    kLocalResultContentError
};

const QString kHttpRequestId = "requestId";

using HttpRequestCallback = std::function<void(int, QJsonObject)>;
using HttpRequestProgressCallback = std::function<void(qint64, qint64)>;

Q_DECLARE_METATYPE(HttpRequestCallback)
Q_DECLARE_METATYPE(HttpRequestProgressCallback)

class HttpManager : public QObject
{
    Q_OBJECT
public:
    explicit HttpManager(QObject *parent = nullptr);
    ~HttpManager();
    void postRequest(const IHttpRequest& request, const HttpRequestCallback& callback);
    void getRequest(const IHttpRequest& request, const HttpRequestCallback& callback, const HttpRequestProgressCallback& proCallback);
    void abort();

    bool checkNetWorkOnline();

signals:

public slots:
    void handleFinished(QNetworkReply* reply);

private:
    QNetworkAccessManager* m_accessManager = nullptr;
    std::list<QNetworkReply*> m_listNetworkReply;
    QMutex mutex;
    std::atomic_bool m_bOnLine{false};
};

#endif // HTTP_MANAGER_H
