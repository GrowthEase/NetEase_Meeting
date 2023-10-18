// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "video_manager.h"
#include "manager/settings_manager.h"
#include "providers/frame_provider.h"
#include "providers/video_render.h"
#include "providers/video_window.h"
#include "share_manager.h"

#ifdef Q_OS_MACX
#include "components/auth_checker.h"
#endif

VideoFrameDelegate::VideoFrameDelegate(QObject* parent)
    : QObject(parent) {}

DelegatePtr VideoManager::m_videoFrameDelegate = nullptr;
QVideoFrameFormat::ColorRange VideoManager::m_colorRange = QVideoFrameFormat::ColorRange_Video;
QVideoFrameFormat::ColorSpace VideoManager::m_colorSpace = QVideoFrameFormat::ColorSpace::ColorSpace_AdobeRgb;
QVideoFrameFormat::ColorTransfer VideoManager::m_colorTransfer = QVideoFrameFormat::ColorTransfer::ColorTransfer_Unknown;

VideoManager::VideoManager(QObject* parent)
    : QObject(parent) {
    m_videoFrameDelegate = std::make_unique<VideoFrameDelegate>();
    m_videoController = std::make_shared<NEMeetingVideoController>();
    qRegisterMetaType<NEMeeting::DeviceStatus>();
}

bool VideoManager::hasCameraPermission() {
#ifdef Q_OS_WIN32
    return true;
#else
    return checkAuthCamera();
#endif
}

void VideoManager::openSystemCameraSettings() {
#ifdef Q_OS_MACX
    openCameraSettings();
#endif
}

void VideoManager::onUserVideoStatusChanged(const std::string& accountId, NEMeeting::DeviceStatus deviceStatus) {
    QMetaObject::invokeMethod(this, "onUserVideoStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(NEMeeting::DeviceStatus, deviceStatus));
}

void VideoManager::onFocusVideoChanged(const std::string& accountId, bool isFocus) {
    QMetaObject::invokeMethod(this, "onFocusVideoChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(bool, isFocus));
}

bool VideoManager::subscribeRemoteVideoStream(const QString& accountId, bool highQuality, const QString& uuid) {
    auto subscribeHelper = MeetingManager::getInstance()->getSubscribeHelper();
    if (subscribeHelper) {
        return subscribeHelper->subscribe(accountId.toStdString(), highQuality ? High : Low, uuid);
    }
    return false;
}

bool VideoManager::unSubscribeRemoteVideoStream(const QString& accountId, const QString& uuid) {
    auto subscribeHelper = MeetingManager::getInstance()->getSubscribeHelper();
    if (subscribeHelper) {
        subscribeHelper->unsubscribe(accountId.toStdString(), High, uuid);
        return true;
    }
    return false;
}

bool VideoManager::unSubscribeRemoteVideoStream(const QString& accountId, bool hightQuality, const QString& uuid) {
    auto subscribeHelper = MeetingManager::getInstance()->getSubscribeHelper();
    if (subscribeHelper) {
        subscribeHelper->unsubscribe(accountId.toStdString(), hightQuality ? High : Low, uuid);
        return true;
    }
    return false;
}

bool VideoManager::setupVideoCanvas(const QString& accountId, QObject* view, bool highQuality, const QString& uuid) {
    auto subscribeHelper = MeetingManager::getInstance()->getSubscribeHelper();
    auto timestamp = std::chrono::time_point_cast<std::chrono::milliseconds>(std::chrono::system_clock::now());
    Canvas canvas;
    canvas.timestamp = timestamp.time_since_epoch().count();
    canvas.view = view;
    m_videoCanvas[accountId] = canvas;
    YXLOG(Info) << "Setup video canvas, account id: " << accountId.toStdString() << ", view: " << view
                << ", timestamp: " << timestamp.time_since_epoch().count() << YXLOGEnd;
    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    void* userData = nullptr;
    void* window = nullptr;
    if (m_videoFrameDelegate) {
        if (SettingsManager::getInstance()->customRender()) {
            connect(m_videoFrameDelegate.get(), &VideoFrameDelegate::receivedVideoFrame, qobject_cast<VideoRender*>(view),
                    &VideoRender::deliverFrame);
        } else {
            connect(m_videoFrameDelegate.get(), &VideoFrameDelegate::receivedVideoFrame, qobject_cast<FrameProvider*>(view),
                    &FrameProvider::deliverFrame);
        }
    }
    userData = m_videoFrameDelegate.get();

    m_videoCanvas[accountId].sub = false;
    if (SettingsManager::getInstance()->customRender()) {
        VideoRender* pVideoRender = qobject_cast<VideoRender*>(view);
        if (pVideoRender) {
            m_videoCanvas[accountId].sub = pVideoRender->subVideo();
        }
    } else {
        FrameProvider* pFrameProvider = qobject_cast<FrameProvider*>(view);
        if (pFrameProvider) {
            m_videoCanvas[accountId].sub = pFrameProvider->subVideo();
        }
    }

    auto userId = accountId.toStdString();
    int ret = 0;
    if (!m_videoCanvas[accountId].sub) {
        m_videoController->setupVideoCanvas(userId, userData, window);
        if (0 == ret && !((accountId.toStdString() == authInfo.accountId) || accountId.isEmpty())) {
            if (userData != nullptr || window != nullptr) {
                if (subscribeHelper)
                    subscribeHelper->subscribe(userId, highQuality ? High : Low, uuid);
            } else {
                if (subscribeHelper)
                    subscribeHelper->unsubscribe(userId, highQuality ? High : Low, uuid);
            }
        }
    } else {
        ret = m_videoController->setupSubVideoCanvas(userId, userData, window);
        if (0 == ret) {
            if (userData != nullptr || window != nullptr) {
                if (subscribeHelper)
                    subscribeHelper->subscribe(userId, SubStream, uuid);
                ret = m_videoController->subscribeRemoteVideoSubStream(userId);
            } else {
                if (subscribeHelper)
                    subscribeHelper->unsubscribe(userId, SubStream, uuid);
                ret = m_videoController->unsubscribeRemoteVideoSubStream(userId);
            }
        }
    }

    return kNENoError == ret;
}

bool VideoManager::removeVideoCanvas(const QString& accountId, QObject* view) {
    bool foundMember = false;
    QByteArray byteAccountId = accountId.toUtf8();
    auto timestamp = std::chrono::time_point_cast<std::chrono::milliseconds>(std::chrono::system_clock::now());
    auto iter = m_videoCanvas.find(accountId);
    if (iter != m_videoCanvas.end()) {
        if (iter->second.view == view) {
            foundMember = true;
            m_videoCanvas.erase(iter);
        }
    }

    if (foundMember) {
        YXLOG(Info) << "Remove video canvas, account id: " << accountId.toStdString() << ", view: " << view
                    << ", timestamp: " << timestamp.time_since_epoch().count() << YXLOGEnd;
        view->disconnect(m_videoFrameDelegate.get());

        m_videoCanvas[accountId].sub = false;
        if (SettingsManager::getInstance()->customRender()) {
            VideoRender* pVideoRender = qobject_cast<VideoRender*>(view);
            if (pVideoRender) {
                m_videoCanvas[accountId].sub = pVideoRender->subVideo();
            }
        } else {
            FrameProvider* pFrameProvider = qobject_cast<FrameProvider*>(view);
            if (pFrameProvider) {
                m_videoCanvas[accountId].sub = pFrameProvider->subVideo();
            }
        }

        if (!m_videoCanvas[accountId].sub) {
            return m_videoController->setupVideoCanvas(byteAccountId.data(), nullptr, nullptr) == kNENoError;
        } else {
            return m_videoController->setupSubVideoCanvas(byteAccountId.data(), nullptr, nullptr) == kNENoError;
        }
    }
    return foundMember;
}

void VideoManager::disableLocalVideo(bool disable) {
    if (!disable && !hasCameraPermission()) {
        emit showPermissionWnd();
        return;
    }

    if (disable && m_localVideoStatus != NEMeeting::DEVICE_ENABLED) {
        return;
    }

    if (!disable && m_localVideoStatus == NEMeeting::DEVICE_ENABLED) {
        return;
    }

    m_videoController->muteMyVideo(disable, [=](uint32_t errorCode, const std::string& errorMessage) {
        YXLOG(Info) << "muteMyVideo, disable: " << disable << ", errorCode " << errorCode << ", errorMessage: " << errorMessage << YXLOGEnd;
        if (errorCode != 0) {
            QString qstrErrorMessage = disable ? tr("mute My Video failed") : tr("unmute My Video failed");
            MeetingManager::getInstance()->onError(errorCode, qstrErrorMessage.toStdString());
        }
    });
}

void VideoManager::disableRemoteVideo(const QString& accountId, bool disable, bool bAllowOpenByself) {
    QByteArray byteAccountId = accountId.toUtf8();

    if (accountId.isEmpty()) {
        if (disable) {
            m_videoController->muteAllParticipantsVideo(bAllowOpenByself, [=](int code, const std::string& msg) {
                MeetingManager::getInstance()->onError(code, msg);
                if (code == 0) {
                    MeetingManager::getInstance()->onRoomMuteAllVideoStatusChanged(true);
                }
            });
        } else {
            m_videoController->unmuteAllParticipantsVideo([=](int code, const std::string& msg) {
                MeetingManager::getInstance()->onError(code, msg);
                if (code == 0) {
                    MeetingManager::getInstance()->onRoomMuteAllVideoStatusChanged(false);
                }
            });
        }
    } else {
        if (disable) {
            m_videoController->stopParticipantVideo(accountId.toStdString(), std::bind(&MeetingManager::onError, MeetingManager::getInstance(),
                                                                                       std::placeholders::_1, std::placeholders::_2));
        } else {
            m_videoController->askParticipantStartVideo(accountId.toStdString(), std::bind(&MeetingManager::onError, MeetingManager::getInstance(),
                                                                                           std::placeholders::_1, std::placeholders::_2));
        }
    }
}

void VideoManager::startLocalVideoPreview(QObject* view) {
    if (MeetingManager::getInstance()->getRoomStatus() == NEMeeting::MEETING_IDLE) {
        void* windowId = nullptr;
        if (SettingsManager::getInstance()->useInternalRender()) {
            VideoWindow* pWindow = qobject_cast<VideoWindow*>(view);
            if (pWindow) {
                windowId = pWindow->getWindowId();
            }
        }
        // m_videoController->setupVideoCanvas(AuthManager::getInstance()->authAccountId().toStdString(), m_videoFrameDelegate.get(), windowId);
        m_videoController->setupPreviewCanvas(m_videoFrameDelegate.get(), windowId);
        m_videoController->startVideoPreview();
    }

    if (!SettingsManager::getInstance()->useInternalRender()) {
        if (SettingsManager::getInstance()->customRender()) {
            connect(m_videoFrameDelegate.get(), &VideoFrameDelegate::receivedVideoFrame, qobject_cast<VideoRender*>(view),
                    &VideoRender::deliverFrame);
        } else {
            connect(m_videoFrameDelegate.get(), &VideoFrameDelegate::receivedVideoFrame, qobject_cast<FrameProvider*>(view),
                    &FrameProvider::deliverFrame);
        }
    }
}

void VideoManager::stopLocalVideoPreview(QObject* pProvider) {
    if (MeetingManager::getInstance()->getRoomStatus() == NEMeeting::MEETING_IDLE) {
        // m_videoController->setupVideoCanvas("", !SettingsManager::getInstance()->useInternalRender() ? qobject_cast<FrameProvider*>(pProvider) :
        // nullptr, nullptr);
        m_videoController->stopVideoPreview();
        m_videoController->setupPreviewCanvas(nullptr, nullptr);
    }

    if (!SettingsManager::getInstance()->useInternalRender()) {
        // disconnect(m_videoFrameDelegate.get(), &VideoFrameDelegate::receivedVideoFrame, qobject_cast<VideoRender*>(pProvider),
        // &VideoRender::deliverFrame);
    }
}

void VideoManager::onUserVideoStatusChangedUI(const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus) {
    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    if (authInfo.accountId == changedAccountId.toStdString()) {
        // if (m_localVideoStatus != deviceStatus) {
        emit userVideoStatusChanged(changedAccountId, deviceStatus);
        // }

        setLocalVideoStatus(deviceStatus);
    } else {
        emit userVideoStatusChanged(changedAccountId, deviceStatus);
    }
}

void VideoManager::onFocusVideoChangedUI(const QString& focusAccountId, bool isFocus) {
    setFocusAccountId(isFocus ? focusAccountId : "");
}

bool VideoManager::displayVideoStats() const {
    return m_displayVideoStats;
}

void VideoManager::setDisplayVideoStats(bool displayVideoStats) {
    m_displayVideoStats = displayVideoStats;
    emit displayVideoStatsChanged();
}

QString VideoManager::focusAccountId() const {
    return m_focusAccountId;
}

void VideoManager::setFocusAccountId(const QString& focusAccountId) {
    auto oldSpeaker = m_focusAccountId;
    m_focusAccountId = focusAccountId;
    emit focusAccountIdChanged(oldSpeaker, m_focusAccountId);
}

int VideoManager::localVideoStatus() const {
    return m_localVideoStatus;
}

void VideoManager::setLocalVideoStatus(const int& localVideoStatus) {
    if (m_localVideoStatus != localVideoStatus) {
        m_localVideoStatus = (NEMeeting::DeviceStatus)localVideoStatus;
        YXLOG(Info) << "m_localVideoStatus changed: " << m_localVideoStatus << ", localVideoStatus: " << localVideoStatus << YXLOGEnd;
        emit localVideoStatusChanged();
    }
}

void VideoManager::onReceivedUserVideoFrame(const std::string& accountId, const VideoFrame& frame, bool bSub) {
#if 0
    qDebug() << ", type: " << frame.type << ", count: " << frame.count
             << ", width: " << frame.width << ", height: " << frame.height
             << ", offset[0]: " << frame.offset[0] << ", stride[0]: " << frame.stride[0]
             << ", offset[1]: " << frame.offset[1] << ", stride[1]: " << frame.stride[1]
             << ", offset[2]: " << frame.offset[2] << ", stride[2]: " << frame.stride[2]
             << ", rotation: " << frame.rotation;
#endif
    if (nullptr == VideoManager::m_videoFrameDelegate)
        return;

    auto rotationWidth = frame.width;
    auto rotationHeight = frame.height;

    libyuv::RotationMode rotate_mode = libyuv::kRotateNone;
    switch (frame.rotation) {
        case kNEVideoRotation_0: {
            rotate_mode = libyuv::kRotate0;
        } break;
        case kNEVideoRotation_90: {
            rotate_mode = libyuv::kRotate90;
            rotationWidth = frame.height;
            rotationHeight = frame.width;
        } break;
        case kNEVideoRotation_180: {
            rotate_mode = libyuv::kRotate180;
        } break;
        case kNEVideoRotation_270: {
            rotate_mode = libyuv::kRotate270;
            rotationWidth = frame.height;
            rotationHeight = frame.width;
        } break;
    }
    QVideoFrameFormat format(QSize(rotationWidth, rotationHeight), QVideoFrameFormat::Format_YUV420P);
    format.setColorRange(VideoManager::m_colorRange);
    format.setColorSpace(VideoManager::m_colorSpace);
    format.setColorTransfer(VideoManager::m_colorTransfer);
    format.setViewport(QRect(0, 0, rotationWidth, rotationHeight));
    QVideoFrame videoFrame(format);
    if (videoFrame.map(QVideoFrame::WriteOnly)) {
        auto src = reinterpret_cast<uint8_t*>(frame.data);
        // If the aspect ratio of the original data is not a multiple of 16,
        // when mappedBytes(n) is called after frame mapping, the returned size will be expanded to the nearest multiple of 16.
        // When copying the data, bytesPerLine(n) should be used to get the actual stride that needs to be copied.
        libyuv::I420Rotate(src + frame.offset[0], frame.stride[0], src + frame.offset[1], frame.stride[1], src + frame.offset[2], frame.stride[2],
                           videoFrame.bits(0), videoFrame.bytesPerLine(0), videoFrame.bits(1), videoFrame.bytesPerLine(1), videoFrame.bits(2),
                           videoFrame.bytesPerLine(2), frame.width, frame.height, rotate_mode);
        videoFrame.setStartTime(0);
        videoFrame.unmap();
        QSize size = QSize(static_cast<int>(rotationWidth), static_cast<int>(rotationHeight));
        emit VideoManager::m_videoFrameDelegate->receivedVideoFrame(QString::fromStdString(accountId), videoFrame, size, bSub);
    }
}

void VideoManager::onRemoteUserVideoStats(const std::vector<NEVideoStats>& videoStats) {
    QJsonArray statsArray;
    for (auto& stats : videoStats) {
        QJsonObject statsObj;
        statsObj["accountId"] = QString::fromStdString(stats.userUuid);
        statsObj["layerType"] = (qint32)(stats.layerType);
        statsObj["frameRate"] = (qint32)(stats.frameRate);
        statsObj["bitRate"] = (qint32)(stats.bitRate);
        statsObj["width"] = (qint32)(stats.width);
        statsObj["height"] = (qint32)(stats.height);
        statsArray.push_back(statsObj);
    }
    emit remoteUserVideoStats(statsArray);
}

void VideoManager::onLocalUserVideoStats(const std::vector<NEVideoStats>& stats) {
    QJsonArray statsArray;
    for (auto& stats : stats) {
        QJsonObject statsObj;
        statsObj["accountId"] = QString::fromStdString(stats.userUuid);
        statsObj["layerType"] = (qint32)(stats.layerType);
        statsObj["frameRate"] = (qint32)(stats.frameRate);
        statsObj["bitRate"] = (qint32)(stats.bitRate);
        statsObj["width"] = (qint32)(stats.width);
        statsObj["height"] = (qint32)(stats.height);
        statsArray.push_back(statsObj);
    }
    emit localUserVideoStats(statsArray);
}

void VideoManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    emit error(errorCode, QString::fromStdString(errorMessage));
}

std::shared_ptr<NEMeetingVideoController> VideoManager::getVideoController() {
    return m_videoController;
}
