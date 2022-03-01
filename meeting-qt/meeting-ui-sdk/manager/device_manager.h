/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef DEVICEMANAGER_H
#define DEVICEMANAGER_H

#include <QObject>
#include "manager/global_manager.h"

using namespace neroom;

typedef struct tagDEVICE_INFO {
    QString deviceName;
    QString devicePath;
    bool defaultDevice;
    bool selectedDevice;
    bool unavailable;
    tagDEVICE_INFO()
        : deviceName("")
        , devicePath("")
        , defaultDevice(false)
        , selectedDevice(false)
        , unavailable(false) {}
} DEVICE_INFO;

enum DeviceType { DeviceTypeDefault, DeviceTypePlayout, DeviceTypeRecord, DeviceTypeCapture };

enum SelectDeviceMode {
    kDeviceAuto,     // 使用 SDK 推荐设备
    kDeviceDefault,  // 使用系统默认设备
    kDeviceUser      // 使用用户选择设备
};

enum AudioDeviceType { kAudioDeviceTypeUnknown, kAudioDeviceTypePlayout, kAudioDeviceTypeRecord };

enum VideoDeviceType { kVideoDeviceTypeUnknown, kVideoDeviceTypeCapture };

Q_DECLARE_METATYPE(AudioDeviceType)
Q_DECLARE_METATYPE(VideoDeviceType)
Q_DECLARE_METATYPE(NEDeviceState)

class DeviceManager : public QObject {
    Q_OBJECT
private:
    explicit DeviceManager(QObject* parent = nullptr);

public:
    SINGLETONG(DeviceManager)
    bool initialize();
    void release();
    void resetDevicesInfo();

    QVector<DEVICE_INFO>& getPlayoutDevices();
    QVector<DEVICE_INFO>& getRecordDevices();
    QVector<DEVICE_INFO>& getCaptureDevices();

    bool appendDevice(DeviceType deviceType, const QString& devicePath, const QString& deviceName);
    bool removeDevice(DeviceType deviceType, const QString& devicePath, const QString& deviceName);

signals:
    void preDeviceAppended(DeviceType deviceType);
    void postDeviceAppended(DeviceType deviceType);

    void preDeviceRemoved(DeviceType deviceType, int index);
    void postDeviceRemoved(DeviceType deviceType);

    void preDeviceListReset(DeviceType deviceType);
    void postDeviceListReset(DeviceType deviceType);

    void audioDeviceChangedSignal(const QString& deviceId, AudioDeviceType deviceType, NEDeviceState deviceState);
    void audioDefaultDeviceChangedSignal(const QString& deviceId, AudioDeviceType deviceType);
    void videoDeviceChangedSignal(const QString& deviceId, VideoDeviceType deviceType, NEDeviceState deviceState);

    void localAudioVolumeIndication(int volume);
    void remoteAudioVolumeIndication(int volume);

    void playoutDeviceChangedNotify(const QString& deviceName, const QString& devicePath);
    void recordDeviceChangedNotify(const QString& deviceName, const QString& devicePath);
    void captureDeviceChangedNotify(const QString& deviceName, const QString& devicePath);

    void error(int errorCode, const QString& errorMessage);

public slots:
    int currentIndex(int deviceType);
    void selectDevice(int deviceType, int index);

    unsigned int getRecordDeviceVolume();
    bool setRecordDeviceVolume(unsigned int volumeValue = 255);
    unsigned int getPlayoutDeviceVolume();
    bool setPlayoutDeviceVolume(unsigned int volumeValue = 255);

    void startMicrophoneTest(bool start = true);
    void startSpeakerTest(bool start = true);

    void onAudioDeviceStateChanged(const QString& deviceId, AudioDeviceType deviceType, NEDeviceState deviceState);
    void onAudioDefaultDeviceChanged(const QString& deviceId, AudioDeviceType deviceType);
    void onVideoDeviceStateChanged(const QString& deviceId, VideoDeviceType deviceType, NEDeviceState deviceState);

    int getDeviceCount(int deviceType);
    void getCurrentSelectedDevice();

public:
    void onPlayoutDeviceChanged(const std::string& deviceId, NEDeviceState deviceState);
    void onRecordDeviceChanged(const std::string& deviceId, NEDeviceState deviceState);
    void onDefualtPlayoutDeviceChanged(const std::string& deviceId);
    void onDefualtRecordDeviceChanged(const std::string& deviceId);
    void onCameraDeviceChanged(const std::string& deviceId, NEDeviceState deviceState);
    void onLocalVolumeIndication(int volume);
    void onRemoteVolumeIndication(int volume);

    QString userSelectPlayout() const;
    void setUserSelectPlayout(const QString& userSelectPlayout);

    QString userSelectRecord() const;
    void setUserSelectRecord(const QString& userSelectRecord);

private:
    void selectRecordDevice(const QString& devicePath);
    void selectPlayoutDevice(const QString& devicePath);

private:
    bool enumDevices(DeviceType deviceType, const DEVICE_INFO& oldSelectedDevice = DEVICE_INFO());

private:
    QVector<DEVICE_INFO> m_playoutDevices;
    QVector<DEVICE_INFO> m_recordDevices;
    QVector<DEVICE_INFO> m_captureDevices;

    DEVICE_INFO m_lastSelectedPlayout;
    DEVICE_INFO m_lastSelectedRecord;
    DEVICE_INFO m_lastSelectedCapture;

    SelectDeviceMode m_recordSelectedMode = kDeviceAuto;
    SelectDeviceMode m_playoutSelectedMode = kDeviceAuto;

    QTimer m_enumPlayoutTimer;
    QTimer m_enumRecordTimer;
    QTimer m_enumCaptureTimer;
};

#endif  // DEVICEMANAGER_H
