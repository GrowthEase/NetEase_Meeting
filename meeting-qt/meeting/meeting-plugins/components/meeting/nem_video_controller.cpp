// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_video_controller.h"
#include <QVideoFrame>
#include "libyuv.h"

NEMVideoController::NEMVideoController(QObject* parent)
    : QObject(parent)
    , m_frameDelegate(new FrameDelegate) {}

bool NEMVideoController::disableLocalVideo(bool disabled) {
    if (m_videoController) {
        return m_videoController->setLocalVideoStatus(disabled) == nem_sdk::kNEMNoError;
    }
    return false;
}

bool NEMVideoController::setupVideoCanvas(const QString& accountId, NEMFrameProvider* view) {
    if (m_videoController) {
        auto iter = m_canvas.find(accountId);
        if (iter != m_canvas.end()) {
            connect(iter.value(), &NEMFrameProvider::newFrame, view, &NEMFrameProvider::newFrame);
            return true;
        }
        m_canvas[accountId] = view;
        QByteArray byteAccountId = accountId.toUtf8();
        auto reinterpretView = reinterpret_cast<void*>(view);
        auto highQuality = view->videoQuality() == NEMFrameProvider::VIDEO_QUALITY_HIGH;
        auto result = m_videoController->setupVideoCanvas(byteAccountId.data(), reinterpretView, nullptr, highQuality);
        connect(view, &NEMFrameProvider::providerInvalidated, this, [=]() {
            // Remove from canvas list
            m_canvas.remove(accountId);
            m_videoController->setupVideoCanvas(byteAccountId.data(), nullptr, nullptr);
        });
        return result == nem_sdk::kNEMNoError;
    }
    return false;
}

bool NEMVideoController::isValid() const {
    return m_isValid;
}

void NEMVideoController::setIsValid(bool isValid) {
    if (m_isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

nem_sdk::IVideoController* NEMVideoController::videoController() const {
    return m_videoController;
}

void NEMVideoController::setVideoController(nem_sdk::IVideoController* videoController) {
    if (m_videoController != videoController) {
        m_videoController = videoController;
        if (m_videoController != nullptr) {
            m_videoController->setVideoEventHandler(this);
            setIsValid(true);
        }
    }
}

NEMVideoController::VideoDeviceStatus NEMVideoController::localVideoStatus() const {
    return m_localVideoStatus;
}

void NEMVideoController::setLocalVideoStatus(const VideoDeviceStatus& localVideoStatus) {
    if (m_localVideoStatus != localVideoStatus) {
        m_localVideoStatus = localVideoStatus;
        Q_EMIT localVideoStatusChanged();
    }
}

void NEMVideoController::onUserVideoStatusChanged(const std::string& accountId, nem_sdk::DeviceStatus deviceStatus) {
    Q_EMIT userVideoStatusChanged(QString::fromStdString(accountId), VideoDeviceStatus(deviceStatus));
}

void NEMVideoController::onReceivedUserVideoFrame(uint64_t avRoomUid, const nem_sdk::VideoFrame& frame) {
    auto frameProvider = reinterpret_cast<NEMFrameProvider*>(frame.user_data);
    if (frameProvider == nullptr)
        return;
    auto rotationWidth = frame.width;
    auto rotationHeight = frame.height;

    libyuv::RotationMode rotate_mode = libyuv::kRotateNone;
    switch (frame.rotation) {
        case NEM_VIDEOROTATION_0: {
            rotate_mode = libyuv::kRotate0;
        } break;
        case NEM_VIDEOROTATION_90: {
            rotate_mode = libyuv::kRotate90;
            rotationWidth = frame.height;
            rotationHeight = frame.width;
        } break;
        case NEM_VIDEOROTATION_180: {
            rotate_mode = libyuv::kRotate180;
        } break;
        case NEM_VIDEOROTATION_270: {
            rotate_mode = libyuv::kRotate270;
            rotationWidth = frame.height;
            rotationHeight = frame.width;
        } break;
    }

    int frameSize = static_cast<int>(frame.width * frame.height * frame.count / 2);
    QVideoFrame videoFrame(frameSize, QSize(static_cast<int>(rotationWidth), static_cast<int>(rotationHeight)), static_cast<int>(rotationWidth),
                           QVideoFrame::Format_YUV420P);

    if (videoFrame.map(QAbstractVideoBuffer::WriteOnly)) {
        auto src = reinterpret_cast<uint8_t*>(frame.data);
        auto dest = reinterpret_cast<uint8_t*>(videoFrame.bits());

        libyuv::I420Rotate(src + frame.offset[0], static_cast<int>(frame.stride[0]), src + frame.offset[1], static_cast<int>(frame.stride[1]),
                           src + frame.offset[2], static_cast<int>(frame.stride[2]), dest, static_cast<int>(rotationWidth),
                           dest + rotationWidth * rotationHeight, rotationWidth / 2,
                           dest + rotationWidth * rotationHeight + rotationWidth * rotationHeight / 4, rotationWidth / 2,
                           static_cast<int>(frame.width), static_cast<int>(frame.height), rotate_mode);

        videoFrame.setStartTime(0);
        videoFrame.unmap();

        QSize size = QSize(static_cast<int>(rotationWidth), static_cast<int>(rotationHeight));

        emit frameProvider->newFrame(videoFrame, size);
    }
}

void NEMVideoController::onFocusVideoChanged(const std::string& accoundId, bool isFocus) {}

void NEMVideoController::onRemoteUserVideoStats(const std::vector<nem_sdk::VideoStats>& videoStats) {}

void NEMVideoController::onLocalUserVideoStats(const nem_sdk::VideoStats& videoStats) {}

void NEMVideoController::onError(uint32_t codeCode, const std::string& errorMessage) {}
