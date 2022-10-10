// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef WHITEBOARDMANAGER_H
#define WHITEBOARDMANAGER_H

#include <QObject>
#include "controller/whiteboard_ctrl_interface.h"
#include "manager/meeting_manager.h"

using namespace neroom;

enum NERoomWhiteboardShareStatus { kNERoomWhiteboardShareStatusStart, kNERoomWhiteboardShareStatusEnd, kNERoomWhiteboardShareStatusStopByHost };
Q_DECLARE_METATYPE(NERoomWhiteboardShareStatus)
class WhiteboardManager : public QObject {
    Q_OBJECT
public:
    SINGLETONG(WhiteboardManager)

    Q_PROPERTY(bool whiteboardSharing READ whiteboardSharing WRITE setWhiteboardSharing NOTIFY whiteboardSharingChanged)
    Q_PROPERTY(bool whiteboardDrawEnable READ whiteboardDrawEnable WRITE setWhiteboardDrawEnable)
    Q_PROPERTY(
        QString whiteboardSharerAccountId READ whiteboardSharerAccountId WRITE setWhiteboardSharerAccountId NOTIFY whiteboardSharerAccountIdChanged)

    void setAutoOpenWhiteboard(bool bAutoOpenWhiteboard) { m_bAutoOpenWhiteboard = bAutoOpenWhiteboard; }
    void initWhiteboardStatus();
    void onRoomUserWhiteboardShareStatusChanged(const std::string& userId, NERoomWhiteboardShareStatus status);
    void onRoomUserWhiteboardDrawEnableStatusChanged(const std::string& userId, bool enable);

    Q_INVOKABLE void openWhiteboard(const QString& accountId = "");
    Q_INVOKABLE void closeWhiteboard(const QString& accountId);
    Q_INVOKABLE void enableWhiteboardDraw(const QString& accountId);
    Q_INVOKABLE void disableWhiteboardDraw(const QString& accountId);
    Q_INVOKABLE bool getAutoOpenWhiteboard() { return m_bAutoOpenWhiteboard; }
    Q_INVOKABLE QString getDefaultDownloadPath();
    Q_INVOKABLE void showFileInFolder(const QString& path);

    Q_INVOKABLE QString getWhiteboardUrl();
    Q_INVOKABLE QString getWhiteboardAuthInfo();
    Q_INVOKABLE QString getWhiteboardLoginMessage();
    Q_INVOKABLE QString getWhiteboardLogoutMessage();
    Q_INVOKABLE QString getWhiteboardDrawPrivilegeMessage();
    Q_INVOKABLE QString getWhiteboardToolConfigMessage();
    Q_INVOKABLE QString getWhiteboardUploadLogMessage(bool display = true);

    bool whiteboardSharing() const;
    void setWhiteboardSharing(bool whiteboardSharing);

    bool whiteboardDrawEnable() const;
    void setWhiteboardDrawEnable(bool enable);

    QString whiteboardSharerAccountId() const;
    void setWhiteboardSharerAccountId(const QString& whiteboardSharerAccountId);

public slots:
    void onRoomUserWhiteboardShareStatusChangedUI(const QString& userId, NERoomWhiteboardShareStatus status);
    void onRoomUserWhiteboardDrawEnableStatusChangedUI(const QString& userId, bool enable);

signals:
    void whiteboardSharingChanged();
    void whiteboardDrawEnableChanged(const QString& sharedAccountId, bool enable);
    void whiteboardCloseByHost();
    void whiteboardSharerAccountIdChanged();

private:
    explicit WhiteboardManager(QObject* parent = nullptr);

private:
    bool m_whiteboardSharing = false;
    bool m_whiteboardDrawEnable = false;
    QString m_whiteboardSharerAccountId = "";
    bool m_bAutoOpenWhiteboard = false;
};

#endif  // WHITEBOARDMANAGER_H
