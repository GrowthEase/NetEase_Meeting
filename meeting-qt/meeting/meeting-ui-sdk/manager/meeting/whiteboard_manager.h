// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef WHITEBOARDMANAGER_H
#define WHITEBOARDMANAGER_H

#include <QObject>
#include "controller/whiteboard_ctrl_interface.h"
#include "manager/meeting_manager.h"

using namespace neroom;

class MeetingWhiteboardView : public INEWhiteboardView {
public:
    virtual void onLogin(const std::string& webScript) override;
    virtual void onAuth(const std::string& webScript) override;
    virtual void onLogout(const std::string& webScript) override;
    virtual void onDrawEnableChanged(const std::string& webScript) override;
    virtual void onToolConfigChanged(const std::string& webScript) override;
};

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
    Q_INVOKABLE void login();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void auth();
    Q_INVOKABLE void setEnableDraw(bool enable);
    Q_INVOKABLE bool hasDrawPrivilege();

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
    void sendMessageToWeb(const QString& webScript);

private:
    explicit WhiteboardManager(QObject* parent = nullptr);
    ~WhiteboardManager();

private:
    bool m_whiteboardSharing = false;
    bool m_whiteboardDrawEnable = false;
    QString m_whiteboardSharerAccountId = "";
    bool m_bAutoOpenWhiteboard = false;
    MeetingWhiteboardView* m_meetingWhiteboardView = nullptr;
};

#endif  // WHITEBOARDMANAGER_H
