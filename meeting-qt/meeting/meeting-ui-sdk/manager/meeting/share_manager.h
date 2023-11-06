// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef SHAREMANAGER_H
#define SHAREMANAGER_H

#include <QObject>
#include <list>
#include "controller/screenshare_controller.h"
#include "manager/meeting_manager.h"

using namespace neroom;

#ifdef Q_OS_WIN32
#include "components/windows_helpers.h"
#elif defined Q_OS_MACX
#include "components/macx_helpers.h"
#endif

/**
 * @brief 屏幕共享状态
 */
enum NERoomScreenShareStatus {
    kNERoomScreenShareStatusStart = 0,
    kNERoomScreenShareStatusEnd,
    kNERoomScreenShareStopByHost,
    kNERoomScreenShareStatusAborted
};
Q_DECLARE_METATYPE(NERoomScreenShareStatus)

enum NEMeetingSourceType { kNEMeetingSourceTypeApp, kNEMeetingSourceTypeScreen };
Q_DECLARE_METATYPE(NEMeetingSourceType)

class ShareManager : public QObject {
    Q_OBJECT
private:
    explicit ShareManager(QObject* parent = nullptr);

public:
    enum ScreenCaptureStatus {
        SCREEN_CAPTURE_STATUS_STARTED = 1,
        SCREEN_CAPTURE_STATUS_PAUSED,
        SCREEN_CAPTURE_STATUS_RESUME,
        SCREEN_CAPTURE_STATUS_STOPPED,
        SCREEN_CAPTURE_STATUS_COVERED,
        SCREEN_CAPTURE_STATUS_ABORTED,
    };
    SINGLETONG(ShareManager)
    ~ShareManager();

    Q_PROPERTY(QString shareAccountId READ shareAccountId WRITE setShareAccountId NOTIFY shareAccountIdChanged)
    Q_PROPERTY(bool shareSystemSound READ shareSystemSound WRITE setShareSystemSound NOTIFY shareSystemSoundChanged)
    Q_PROPERTY(bool ownerSharing READ ownerSharing WRITE setOwnerSharing NOTIFY ownerSharingChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)

    Q_INVOKABLE void requestRecordPermission();
    Q_INVOKABLE bool hasRecordPermission();
    Q_INVOKABLE void openSystemSettings();
    Q_INVOKABLE bool isExistScreen(const QString& name) const;

    void onRoomUserScreenShareStatusChanged(const std::string& usdrId, NERoomScreenShareStatus status);
    void onError(uint32_t errorCode, const std::string& errorMessage);

    QString shareAccountId() const;
    void setShareAccountId(const QString& shareAccountId);
    bool ownerSharing() const;
    bool shareSystemSound() const;
    bool paused() const;

signals:
    void error(int errorCode, const QString& errorMessage);
    void screenCaptureStatusChanged(ScreenCaptureStatus status);
    void sharingStatusChaged(const QString& sharingAccountId, bool isSharing);
    void shareAccountIdChanged();
    void ownerSharingChanged(bool ownerSharing);
    void closeScreenShareByHost();
    void screenShareAborted();
    void shareSystemSoundChanged();
    void pausedChanged();
    void screenAdded(const QString& addedScreen);
    void screenRemoved(const QString& removedScreen);
    void screenSizeChanged();

public slots:
    void addExcludeShareWindow(QQuickWindow* pShareWindow);
    void removeExcludeShareWindow(QQuickWindow* pShareWindow);
    void clearExcludeShareWindow();
    void startSharingWithSourceID(quint64 sourceID, NEMeetingSourceType type);
    void stopScreenSharing(const QString& accountId);
    void stopScreenSharing();
    void startSystemAudioLoopbackCapture();
    void stopSystemAudioLoopbackCapture();
    void onSharingStatusChangedUI(const QString& userId, NERoomScreenShareStatus status);
    void setOwnerSharing(bool ownerSharing);
    void setShareSystemSound(bool shareSystemSound);
    void switchSystemSound(bool shareSystemSound);
    void onScreenCaptureStatusChanged(ScreenCaptureStatus status);

private:
    std::shared_ptr<NEMeetingScreenShareController> m_shareController = nullptr;
    QString m_shareAccountId;
    std::list<QQuickWindow*> m_excludeShareWindowList;
    ScreenCaptureStatus m_currentStatus = SCREEN_CAPTURE_STATUS_STOPPED;
    bool m_ownerSharing = false;
    bool m_shareSystemSound = false;
    bool m_systemAudioLoopbackCapture = false;
};

#endif  // SHAREMANAGER_H
