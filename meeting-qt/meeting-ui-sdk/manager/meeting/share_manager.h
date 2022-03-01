/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef SHAREMANAGER_H
#define SHAREMANAGER_H

#include <QObject>
#include <list>
#include "controller/sharing_ctrl_interface.h"
#include "manager/meeting_manager.h"

using namespace neroom;

#ifdef Q_OS_WIN32
#include "components/windows_helpers.h"
#elif defined Q_OS_MACX
#include "components/macx_helpers.h"
#endif

Q_DECLARE_METATYPE(NERoomScreenShareStatus)

class ShareManager : public QObject {
    Q_OBJECT
public:
    SINGLETONG(ShareManager)
    ~ShareManager();

    Q_PROPERTY(QString shareAccountId READ shareAccountId WRITE setShareAccountId NOTIFY shareAccountIdChanged)
    Q_PROPERTY(bool paused READ paused WRITE setPaused NOTIFY pausedChanged)
    Q_PROPERTY(bool ownerSharing READ ownerSharing WRITE setOwnerSharing NOTIFY ownerSharingChanged)
    Q_PROPERTY(bool appMinimized READ appMinimized WRITE setAppMinimized NOTIFY appMinimizedChanged)
    Q_PROPERTY(bool shareSystemSound READ shareSystemSound WRITE setShareSystemSound NOTIFY shareSystemSoundChanged)
    Q_PROPERTY(bool smoothPriority READ smoothPriority WRITE setSmoothPriority NOTIFY smoothPriorityChanged)

    Q_INVOKABLE bool hasRecordPermission();
    Q_INVOKABLE void openSystemSettings();
    Q_INVOKABLE void sharedOutsideWindow(QQuickWindow* pWindow, int borderWidth);

    void onRoomUserScreenShareStatusChanged(const std::string& usdrId, NERoomScreenShareStatus status);
    void onError(uint32_t errorCode, const std::string& errorMessage);

    void setMainWindow(QWindow* pWindow) { m_pMainWindow = pWindow; }
    QWindow* getMainWindow() const { return m_pMainWindow; }

    QString shareAccountId() const;
    void setShareAccountId(const QString& shareAccountId);
    bool paused() const;
    bool ownerSharing() const;
    bool appMinimized() const;
    bool shareSystemSound() const;
    bool smoothPriority() const;

signals:
    void error(int errorCode, const QString& errorMessage);
    void sharingStatusChaged(const QString& sharingAccountId, bool isSharing);
    void screenAdded(const QString& addedScreen);
    void screenRemoved(const QString& removedScreen);
    void screenSizeChanged();

    // Binding values
    void shareAccountIdChanged();
    void pausedChanged(bool paused);
    void ownerSharingChanged(bool ownerSharing);
    void appMinimizedChanged(bool appMinimized);

    void closeScreenShareByHost();

    void shareSystemSoundChanged();
    void smoothPriorityChanged();

private:
    explicit ShareManager(QObject* parent = nullptr);
    QWindow* getSharedOutsideWindow();
    void dealwithPause(const QString& sharingAccountId, bool isSharing, bool isPause);
    void switchAppSharing(quint32 id);
    void switchMonitorShare(const uint32_t& monitor_id, const std::list<void*>& excludedWindowList = std::list<void*>());

public slots:
    void addShareWindow(QQuickWindow* pShareWindow);
    void removeShareWindow(QQuickWindow* pShareWindow);
    void clearShareWindow();
    void startScreenSharing(quint32 screenIndex);
    void startAppSharing(quint32 id);
    void stopScreenSharing(const QString& accountId);
    void pauseScreenSharing();
    void resumeScreenSharing();
    void startSystemAudioLoopbackCapture();
    void stopSystemAudioLoopbackCapture();
    void fixScreenSharingPos();
    void onSharingStatusChangedUI(const QString& userId, NERoomScreenShareStatus status);
    void setPaused(bool paused);
    void setOwnerSharing(bool ownerSharing);
    void setAppMinimized(bool appMinimized);
    void setShareSystemSound(bool shareSystemSound);
    void setSmoothPriority(bool smoothPriority);
    void switchSystemSound(bool shareSystemSound);

public slots:
    void onAppSharingPause();

private:
    INEScreenShareController* m_shareController = nullptr;
    QString m_shareAccountId;
    quint32 m_currentScreenIndex = -1;
    bool m_paused = false;         // sdk的暂停状态
    bool m_pausedEx = false;       // 是否是是UI的暂停，不是sdk的状态
    bool m_bMiniRestored = false;  // 是否是最小化恢复
    bool m_ownerSharing = false;   // 是否是自己发起的共享
    quint32 m_shareAppId = 0;
    std::list<QQuickWindow*> m_shareWindowList;
    QTimer m_timer;
    QRectF m_latestAppRect;
    QRectF m_latestOutsideRect;
    bool m_bMinimized = false;
    QWindow* m_pMainWindow = nullptr;
    QWindow* m_pSharedOutsideWindow = nullptr;
    int m_borderWidth = 0;
    int m_pausedCount = 0;
#ifdef Q_OS_WIN32
    std::unique_ptr<WindowsHelpers> m_pHelper = nullptr;
#elif defined Q_OS_MACX
    std::unique_ptr<MacXHelpers> m_pHelper = nullptr;
#endif
    bool m_bPpt = false;
    bool m_bPptPlay = false;
    bool m_bPowerpnt = false;
    bool m_bLatestFullScreen = false;
    bool m_bLatestForegroundWindow = false;
    bool m_shareSystemSound = false;
    bool m_smoothPriority = false;
};

#endif  // SHAREMANAGER_H
