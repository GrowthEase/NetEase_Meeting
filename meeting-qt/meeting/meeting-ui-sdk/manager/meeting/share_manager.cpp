// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "share_manager.h"
#include "../auth_manager.h"
#include "members_manager.h"

#ifdef Q_OS_MACX
#include "components/auth_checker.h"
#endif

ShareManager::ShareManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<NERoomScreenShareStatus>();

    connect(this, &ShareManager::screenCaptureStatusChanged, this, &ShareManager::onScreenCaptureStatusChanged);

    m_shareController = std::make_shared<NEMeetingScreenShareController>();

    connect(qApp, &QGuiApplication::screenAdded, [=](QScreen* addedScreen) {
        connect(addedScreen, &QScreen::virtualGeometryChanged, [=]() { emit screenSizeChanged(); });
        emit screenAdded(addedScreen->name());
    });
    connect(qApp, &QGuiApplication::screenRemoved, [=](QScreen* removedScreen) {
        disconnect(removedScreen, &QScreen::virtualGeometryChanged, this, nullptr);
        emit screenRemoved(removedScreen->name());
    });

    if (ConfigManager::getInstance()->contains("enableShareSystemSound")) {
        m_shareSystemSound = ConfigManager::getInstance()->getValue("enableShareSystemSound", false).toBool();
        emit shareSystemSoundChanged();
    }
}

bool ShareManager::isExistScreen(const QString& name) const {
    QList<QScreen*> screens = QGuiApplication::screens();
    for (auto& it : screens) {
        if (it->name() == name) {
            return true;
        }
    }

    return false;
}

ShareManager::~ShareManager() {}

void ShareManager::requestRecordPermission() {
#if defined(Q_OS_MACX)
    showScreenRecordingPrompt();
#endif
}

bool ShareManager::hasRecordPermission() {
#ifdef Q_OS_WIN32
    return true;
#else
    return checkAuthRecordScreen();
#endif
}

void ShareManager::openSystemSettings() {
#ifdef Q_OS_MACX
    openRecordSettings();
#endif
}

void ShareManager::onRoomUserScreenShareStatusChanged(const std::string& usdrId, NERoomScreenShareStatus status) {
    QMetaObject::invokeMethod(this, "onSharingStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(usdrId)),
                              Q_ARG(NERoomScreenShareStatus, status));
}

void ShareManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    emit error(errorCode, QString::fromStdString(errorMessage));
}

void ShareManager::addExcludeShareWindow(QQuickWindow* pShareWindow) {
    YXLOG(Info) << "[ScreenCapture] add exclude share window: " << pShareWindow->winId() << ", title: " << pShareWindow->title().toStdString()
                << YXLOGEnd;
    m_excludeShareWindowList.emplace_back(pShareWindow);
#ifdef Q_OS_WIN32
    INERoomRtcController* pRtc = MeetingManager::getInstance()->getInRoomRtcController();
    if (pRtc && !m_shareAccountId.isEmpty()) {
        std::list<void*> excludedWindowList;
        for (auto& it : m_excludeShareWindowList) {
            excludedWindowList.push_back((void*)it->winId());
        }
        pRtc->setExcludeWindowList(excludedWindowList);
    }
#endif
}

void ShareManager::removeExcludeShareWindow(QQuickWindow* pShareWindow) {
    m_excludeShareWindowList.remove(pShareWindow);
#ifdef Q_OS_WIN32
    INERoomRtcController* pRtc = MeetingManager::getInstance()->getInRoomRtcController();
    if (pRtc && !m_shareAccountId.isEmpty()) {
        std::list<void*> excludedWindowList;
        for (auto& it : m_excludeShareWindowList) {
            excludedWindowList.emplace_back((void*)it->winId());
        }
        pRtc->setExcludeWindowList(excludedWindowList);
    }
#endif
}

void ShareManager::clearExcludeShareWindow() {
    m_excludeShareWindowList.clear();
#ifdef Q_OS_WIN32
    INERoomRtcController* pRtc = MeetingManager::getInstance()->getInRoomRtcController();
    if (pRtc && !m_shareAccountId.isEmpty()) {
        std::list<void*> excludedWindowList;
        pRtc->setExcludeWindowList(excludedWindowList);
    }
#endif
}

void ShareManager::startSharingWithSourceID(quint64 sourceID, NEMeetingSourceType type) {
    std::list<void*> excludedWindowList;
    for (auto& it : m_excludeShareWindowList) {
#if defined(Q_OS_MACX)
        MacXHelpers macXHelpers;
        auto nativeWid = macXHelpers.getWindowId(it->winId());
        YXLOG(Info) << "[ScreenCapture] exclude window ID: " << nativeWid << YXLOGEnd;
        excludedWindowList.emplace_back(reinterpret_cast<void*>(nativeWid));
#else
        YXLOG(Info) << "[ScreenCapture] exclude window ID: " << it->winId() << YXLOGEnd;
        excludedWindowList.emplace_back(reinterpret_cast<void*>(it->winId()));
#endif
    }

    if (type == kNEMeetingSourceTypeScreen) {
        m_shareController->startScreenShare(sourceID, excludedWindowList, [=](int code, const std::string& msg) {
            if (code != 0)
                MeetingManager::getInstance()->onError(code, msg);
            if (code == 0 && m_shareSystemSound)
                startSystemAudioLoopbackCapture();
        });
    }

    if (type == kNEMeetingSourceTypeApp) {
        m_shareController->startAppShare(reinterpret_cast<void*>(sourceID), [=](int code, const std::string& msg) {
            MeetingManager::getInstance()->onError(code, msg);
            if (code == 0 && m_shareSystemSound)
                startSystemAudioLoopbackCapture();
        });
    }
}

void ShareManager::stopScreenSharing(const QString& accountId) {
    auto callback = [this](int code, const std::string& msg) {
        if (0 != code) {
            MeetingManager::getInstance()->onError(code, msg);
        } else {
            stopScreenSharing();
        }
    };

    bool ret = false;
    if (accountId == AuthManager::getInstance()->authAccountId()) {
        ret = m_shareController->stopScreenShare(callback);
    } else {
        ret = m_shareController->stopParticipantScreenShare(accountId.toStdString(), callback);
    }

    if (!ret) {
        YXLOG(Info) << "stopParticipantScreenShare failed." << YXLOGEnd;
    }
}

void ShareManager::stopScreenSharing() {
    Invoker::getInstance()->execute([this]() {
#ifdef Q_OS_WIN32
        if (m_shareSystemSound)
            stopSystemAudioLoopbackCapture();
#endif
    });
}

void ShareManager::startSystemAudioLoopbackCapture() {
    m_shareController->startSystemAudioLoopbackCapture();
}

void ShareManager::stopSystemAudioLoopbackCapture() {
    m_systemAudioLoopbackCapture = !m_shareController->stopSystemAudioLoopbackCapture();
}

void ShareManager::onSharingStatusChangedUI(const QString& userId, NERoomScreenShareStatus status) {
    YXLOG(Info) << "[ShareManager] Sharing status changed, user ID: " << userId.toStdString() << ", status: " << status << YXLOGEnd;
    if (status == kNERoomScreenShareStopByHost) {
        stopScreenSharing();
        emit closeScreenShareByHost();
        if (m_shareSystemSound) {
            stopSystemAudioLoopbackCapture();
        }
    }
    if (status == kNERoomScreenShareStatusAborted) {
        emit screenShareAborted();
        if (m_shareSystemSound) {
            stopSystemAudioLoopbackCapture();
        }
    }
    setShareAccountId(status == kNERoomScreenShareStatusStart ? userId : "");
}

QString ShareManager::shareAccountId() const {
    return m_shareAccountId;
}

void ShareManager::setShareAccountId(const QString& shareAccountId) {
    NEMeeting::Status status = MeetingManager::getInstance()->roomStatus();
    if (NEMeeting::MEETING_CONNECTED == status || NEMeeting::MEETING_RECONNECTED == status) {
    } else {
        MeetingManager::getInstance()->getMeetingController()->getRoomInfo().screenSharingUserId = shareAccountId.toStdString();
        return;
    }

    m_shareAccountId = shareAccountId;
    MeetingManager::getInstance()->getMeetingController()->getRoomInfo().screenSharingUserId = m_shareAccountId.toStdString();
    MembersManager::getInstance()->handleShareAccountIdChanged();
    emit shareAccountIdChanged();

    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    setOwnerSharing(authInfo.accountId == m_shareAccountId.toStdString());
}

bool ShareManager::ownerSharing() const {
    return m_ownerSharing;
}

void ShareManager::setOwnerSharing(bool ownerSharing) {
    if (ownerSharing != m_ownerSharing) {
        m_ownerSharing = ownerSharing;
        emit ownerSharingChanged(m_ownerSharing);
        if (!ownerSharing) {
            if (m_systemAudioLoopbackCapture) {
                stopSystemAudioLoopbackCapture();
            }
        }
    }
}

bool ShareManager::shareSystemSound() const {
    return m_shareSystemSound;
}

bool ShareManager::paused() const {
    return m_currentStatus == SCREEN_CAPTURE_STATUS_PAUSED;
}

void ShareManager::setShareSystemSound(bool shareSystemSound) {
    if (shareSystemSound != m_shareSystemSound) {
        m_shareSystemSound = shareSystemSound;
        ConfigManager::getInstance()->setValue("enableShareSystemSound", m_shareSystemSound);
        emit shareSystemSoundChanged();
    }
}

void ShareManager::switchSystemSound(bool shareSystemSound) {
    if (m_shareAccountId.isEmpty())
        return;

#ifdef Q_OS_WIN32
    if (shareSystemSound) {
        startSystemAudioLoopbackCapture();
    } else {
        stopSystemAudioLoopbackCapture();
    }
#endif
    setShareSystemSound(shareSystemSound);
}

void ShareManager::onScreenCaptureStatusChanged(ScreenCaptureStatus status) {
    YXLOG(Info) << "[ShareManager] Screen capture status changed, status: " << status << YXLOGEnd;
    if (status == SCREEN_CAPTURE_STATUS_ABORTED) {
        QMetaObject::invokeMethod(this, "onSharingStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, ""),
                                  Q_ARG(NERoomScreenShareStatus, kNERoomScreenShareStatusAborted));
        return;
    }
    m_currentStatus = status;
    Q_EMIT pausedChanged();
}
