/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "local_socket.h"
#include <QUrl>
#include <QUrlQuery>

QString LocalSocket::SOCKET_SERVER_NAME = "NEMEETING_LOCAL_SOCKET_FLAG";

const QString kSSOToken = "ssoToken";
const QString kSSOAppKey = "appKey";

LocalSocket::LocalSocket(QObject *parent)
    : QObject(parent)
    , m_localServer(new QLocalServer)
    , m_localSocket(new QLocalSocket)
{

}

LocalSocket::~LocalSocket()
{
    if (m_localServer->isListening())
    {
        m_localServer->close();
    }

    if (m_localSocket->isOpen())
    {
        m_localSocket->disconnectFromServer();
    }
}

bool LocalSocket::listen()
{
    if (!m_localServer)
        return false;

    connect(m_localServer.get(), &QLocalServer::newConnection, this, &LocalSocket::newConnectionHandler);
    return m_localServer->listen(LocalSocket::SOCKET_SERVER_NAME);
}

bool LocalSocket::connectToServer()
{
    if (!m_localSocket)
        return false;

    m_localSocket->connectToServer(LocalSocket::SOCKET_SERVER_NAME, QIODevice::ReadWrite);
    return m_localSocket->waitForConnected(500);
}

bool LocalSocket::notify(const QString &data)
{
    if (!m_localSocket)
        return false;
    m_localSocket->open(QIODevice::ReadWrite);
    m_localSocket->write(data.toStdString().c_str());
    m_localSocket->flush();
    return m_localSocket->waitForBytesWritten(500);
}

void LocalSocket::newConnectionHandler()
{
    QLocalSocket* socket = m_localServer->nextPendingConnection();
    connect(socket, SIGNAL(readyRead()), this, SLOT(readyReadHandler()));
    connect(socket, SIGNAL(disconnected()), socket, SLOT(deleteLater()));
}

void LocalSocket::readyReadHandler()
{
    auto* socket = dynamic_cast<QLocalSocket*>(sender());
    if (socket)
    {
        QTextStream stream(socket);
        auto arguments = stream.readAll();
        QUrl url(arguments);
        QUrlQuery urlQuery(url.query());
        qInfo() << arguments;
        emit loginWithSSO(urlQuery.queryItemValue(kSSOAppKey), urlQuery.queryItemValue(kSSOToken));
    }
}
