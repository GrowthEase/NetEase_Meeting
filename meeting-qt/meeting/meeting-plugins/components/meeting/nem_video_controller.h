// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_MEETING_NEM_VIDEO_CONTROLLER_H_
#define MEETING_PLUGINS_COMPONENTS_MEETING_NEM_VIDEO_CONTROLLER_H_

#include <QObject>
#include <QPointer>
#include <string>
#include <vector>
#include "meeting/video_ctrl_interface.h"
#include "providers/nem_frame_provider.h"

typedef struct _tagCanvas {
    QString accountId;
} Canvas;

class FrameDelegate : public QObject {
    Q_OBJECT
public:
    explicit FrameDelegate(QObject* parent = nullptr)
        : QObject(parent) {}
    ~FrameDelegate() = default;

Q_SIGNALS:
    void newFrame(const quint64& uid, const QVideoFrame& videoFrame, const QSize& videoSize);
};

class NEMVideoController : public QObject, public nem_sdk::IVideoEventHandler {
    Q_OBJECT
    Q_ENUMS(VideoDeviceStatus)
    Q_ENUMS(VideoQuality)

public:
    explicit NEMVideoController(QObject* parent = nullptr);

    enum VideoDeviceStatus { VIDEO_DEVICE_ENABLED = 1, VIDEO_DEVICE_DISABLED_BY_SELF, VIDEO_DEVICE_DISABLED_BY_HOST, VIDEO_DEVICE_NEEDS_TO_CONFIRM };

    enum VideoQuality {
        VIDEO_QUALITY_NONE,  // none
        VIDEO_QUALITY_HIGH,  // 1280x720
        VIDEO_QUALITY_LOW    // 360x180
    };

    enum NEMVideoRotation {
        NEM_VIDEOROTATION_0 = 0,     /**< 0 */
        NEM_VIDEOROTATION_90 = 90,   /**< 90 */
        NEM_VIDEOROTATION_180 = 180, /**< 180 */
        NEM_VIDEOROTATION_270 = 270, /**< 270 */
    };

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(VideoDeviceStatus localVideoStatus READ localVideoStatus WRITE setLocalVideoStatus NOTIFY localVideoStatusChanged)

    Q_INVOKABLE bool disableLocalVideo(bool disabled);
    Q_INVOKABLE bool setupVideoCanvas(const QString& accountId, NEMFrameProvider* view);

    bool isValid() const;
    void setIsValid(bool isValid);

    nem_sdk::IVideoController* videoController() const;
    void setVideoController(nem_sdk::IVideoController* videoController);

    VideoDeviceStatus localVideoStatus() const;
    void setLocalVideoStatus(const VideoDeviceStatus& localVideoStatus);

Q_SIGNALS:
    void isValidChanged();
    void localVideoStatusChanged();

    void userVideoStatusChanged(const QString& accountId, VideoDeviceStatus status);

protected:
    void onUserVideoStatusChanged(const std::string& accountId, nem_sdk::DeviceStatus deviceStatus) override;
    void onReceivedUserVideoFrame(uint64_t avRoomUid, const nem_sdk::VideoFrame& frame) override;
    void onFocusVideoChanged(const std::string& accoundId, bool isFocus) override;
    void onRemoteUserVideoStats(const std::vector<nem_sdk::VideoStats>& videoStats) override;
    void onLocalUserVideoStats(const nem_sdk::VideoStats& videoStats) override;
    void onError(uint32_t codeCode, const std::string& errorMessage) override;

private:
    bool m_isValid = false;
    nem_sdk::IVideoController* m_videoController = nullptr;
    VideoDeviceStatus m_localVideoStatus = VIDEO_DEVICE_ENABLED;
    FrameDelegate* m_frameDelegate = nullptr;
    QMap<QString, NEMFrameProvider*> m_canvas;
};

#endif  // MEETING_PLUGINS_COMPONENTS_MEETING_NEM_VIDEO_CONTROLLER_H_
