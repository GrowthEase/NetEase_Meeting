// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef CONFIG_CONTROLLER_H
#define CONFIG_CONTROLLER_H

/**
 * @brief 录制信息
 */
typedef struct tagRecordProxy {
    bool enableAudioRecorder; /**< 录制音频 */
    bool enableVideoRecorder; /**< 录制视频 */
    int recordMode;           /**< 录制模式 */
} RecordProxy;

using NEConfigCallback = std::function<void(int, const QString&)>;

class NEConfigController {
public:
    NEConfigController();
    ~NEConfigController();

    void getMeetingConfig(const NEConfigCallback& callback);

    bool isBeautySupported();
    bool isLiveStreamSupported();
    bool isWhiteboardSupported();
    bool isCloudRecordSupported();
    bool isChatroomSupported();
    bool isSipSupported();
    bool isVBSupported() const { return m_bSupportVirtualBackground; }
    bool isEndTimeTipSupported() const { return m_bSupportEndTimeTip; }
    bool isImageMessageSupported() const { return m_bSupportImageMessage; }
    bool isFileMessageSupported() const { return m_bSupportFileMessage; }
    uint32_t getGalleryPageSize();
    uint32_t getFocusSwitchInterval();
    RecordProxy getRecordProxy();
    QString getlicUrl();

private:
    uint32_t m_focusSwitchInterval = 6;
    uint32_t m_galleryPageSize = 16;
    RecordProxy m_recordProxy;
    bool m_bSupportBeauty = false;
    QString m_beautyLicenseUrl = "";
    bool m_bSupportLive = false;
    bool m_bSupportWhiteboard = true;
    bool m_bSupportRecorder = false;
    bool m_bSupportChatRoom = false;
    bool m_bSupportSip = false;
    bool m_bSupportVirtualBackground = true;
    bool m_bSupportEndTimeTip = false;
    bool m_bSupportImageMessage = true;
    bool m_bSupportFileMessage = true;
};

#endif  // CONFIG_CONTROLLER_H
