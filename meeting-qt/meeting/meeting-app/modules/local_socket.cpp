// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "local_socket.h"
#include <QUrl>
#include <QUrlQuery>

QString LocalSocket::SOCKET_SERVER_NAME = "NEMEETING_LOCAL_SOCKET_FLAG";

const QString kSSOAppKey = "appId";
const QString kSSOUser = "userUuid";
const QString kSSOToken = "userToken";
const QString kType = "type";
const QString kInvitation = "invitation";
const QString kMeetingId = "meetingId";

LocalSocket::LocalSocket(QObject* parent)
    : QObject(parent)
    , m_localServer(new QLocalServer)
    , m_localSocket(new QLocalSocket) {}

LocalSocket::~LocalSocket() {
    if (m_localServer->isListening()) {
        m_localServer->close();
    }

    if (m_localSocket->isOpen()) {
        m_localSocket->disconnectFromServer();
    }
}

bool LocalSocket::listen() {
    if (!m_localServer)
        return false;

    connect(m_localServer.get(), &QLocalServer::newConnection, this, &LocalSocket::newConnectionHandler);
    return m_localServer->listen(LocalSocket::SOCKET_SERVER_NAME);
}

bool LocalSocket::connectToServer() {
    YXLOG(Info) << "connectToServer..." << YXLOGEnd;
    if (!m_localSocket)
        return false;

    m_localSocket->connectToServer(LocalSocket::SOCKET_SERVER_NAME, QIODevice::ReadWrite);
    return m_localSocket->waitForConnected(500);
}

bool LocalSocket::notify(const QString& data) {
    if (!m_localSocket)
        return false;
    YXLOG(Info) << "notify data： " << data.toStdString() << YXLOGEnd;
    m_localSocket->open(QIODevice::ReadWrite);
    m_localSocket->write(data.toStdString().c_str());
    m_localSocket->flush();
    return m_localSocket->waitForBytesWritten(500);
}

void LocalSocket::newConnectionHandler() {
    YXLOG(Info) << "newConnectionHandler" << YXLOGEnd;
    QLocalSocket* socket = m_localServer->nextPendingConnection();
    connect(socket, SIGNAL(readyRead()), this, SLOT(readyReadHandler()), Qt::UniqueConnection);
    connect(socket, SIGNAL(disconnected()), socket, SLOT(deleteLater()), Qt::UniqueConnection);
}

void LocalSocket::readyReadHandler() {
    auto* socket = dynamic_cast<QLocalSocket*>(sender());
    if (socket) {
        QTextStream stream(socket);
        auto arguments = stream.readAll();
        YXLOG(Info) << "readyReadHandler arguments: " << arguments.toStdString() << YXLOGEnd;
        QUrl url(arguments);
        QUrlQuery urlQuery(url.query());
        YXLOG(Info) << "urlQuery: " << urlQuery.toString().toStdString() << YXLOGEnd;
        if (urlQuery.hasQueryItem(kType)) {
            QString type = urlQuery.queryItemValue(kType);
            if (type == kInvitation) {
                if (urlQuery.hasQueryItem(kMeetingId)) {
                    QString meetingId = urlQuery.queryItemValue(kMeetingId);
                    if (!meetingId.isEmpty()) {
                        YXLOG(Info) << "inviteByLink meetingId: " << meetingId.toStdString() << YXLOGEnd;
                        emit inviteByLink(meetingId);
                        return;
                    }
                }
            }
        }

        emit loginWithSSO(urlQuery.queryItemValue(kSSOAppKey), urlQuery.queryItemValue(kSSOUser), urlQuery.queryItemValue(kSSOToken));
    }
}
