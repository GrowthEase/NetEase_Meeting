/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef LOCALSOCKET_H
#define LOCALSOCKET_H

#include <QObject>
#include <QLocalSocket>
#include <QLocalServer>

class LocalSocket : public QObject
{
    Q_OBJECT
public:
    static QString SOCKET_SERVER_NAME;

    explicit LocalSocket(QObject *parent = nullptr);
    ~LocalSocket();

    bool listen();
    bool connectToServer();
    bool notify(const QString& data);

signals:
    void loginWithSSO(const QString& ssoAppKey, const QString& ssoToken);

public slots:
    void newConnectionHandler();
    void readyReadHandler();

private:
    std::unique_ptr<QLocalServer> m_localServer = nullptr;
    std::unique_ptr<QLocalSocket> m_localSocket = nullptr;
};

#endif // LOCALSOCKET_H
