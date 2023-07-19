// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_DEVICES_NEM_DEVICES_H_
#define MEETING_PLUGINS_COMPONENTS_DEVICES_NEM_DEVICES_H_

#include <QObject>
#include <QPointer>
#include <string>
#include <vector>
#include "include/devices_service_interface.h"
#include "nem_engine.h"
#include "utils/invoker.h"

typedef struct _tagNEMDeviceInfo {
    QString deviceName;
    QString devicePath;
    bool unavailable;
} NEMDeviceInfo;

class NEMDevices : public QObject, public nem_sdk::IDevicesEventHandler {
    Q_OBJECT
    Q_ENUMS(DeviceType)
    Q_ENUMS(AutoSelectMode)

public:
    explicit NEMDevices(QObject* parent = nullptr);

    enum DeviceType { DEVICE_TYPE_UNKNOWN, DEVICE_TYPE_PLAYOUT, DEVICE_TYPE_RECORD, DEVICE_TYPE_CAPTURE };

    enum AutoSelectMode {
        DEFAULT_MODE,     // Default device first
        RECOMMENDED_MODE  // Recommended device first
    };

    static QString m_autoSelectDeviceId;

    Q_PROPERTY(NEMEngine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool isValid READ isValid WRITE setIsValid NOTIFY isValidChanged)
    Q_PROPERTY(int defaultPlayoutIndex READ defaultPlayoutIndex WRITE setDefaultPlayoutIndex NOTIFY defaultPlayoutIndexChanged)
    Q_PROPERTY(int defaultRecordIndex READ defaultRecordIndex WRITE setDefaultRecordIndex NOTIFY defaultRecordIndexChanged)
    Q_PROPERTY(int currentPlayoutIndex READ currentPlayoutIndex WRITE setCurrentPlayoutIndex NOTIFY currentPlayoutIndexChanged)
    Q_PROPERTY(int currentRecordIndex READ currentRecordIndex WRITE setCurrentRecordIndex NOTIFY currentRecordIndexChanged)
    Q_PROPERTY(int currentCaptureIndex READ currentCaptureIndex WRITE setCurrentCaptureIndex NOTIFY currentCaptureIndexChanged)
    Q_PROPERTY(AutoSelectMode autoSelectMode READ autoSelectMode WRITE setAutoSelectMode NOTIFY autoSelectModeChanged)

    Q_INVOKABLE bool selectDevice(DeviceType deviceType, const QString& deviceId);

    NEMEngine* engine() const;
    void setEngine(NEMEngine* engine);

    bool isValid() const;
    void setIsValid(bool isValid);

    QVector<NEMDeviceInfo> getDevices(DeviceType deviceType) const;

    int defaultPlayoutIndex() const;
    void setDefaultPlayoutIndex(int defaultPlayoutIndex);

    int defaultRecordIndex() const;
    void setDefaultRecordIndex(int defaultRecordIndex);

    int currentPlayoutIndex() const;
    void setCurrentPlayoutIndex(int currentPlayoutIndex);

    int currentRecordIndex() const;
    void setCurrentRecordIndex(int currentRecordIndex);

    int currentCaptureIndex() const;
    void setCurrentCaptureIndex(int currentCaptureIndex);

    AutoSelectMode autoSelectMode() const;
    void setAutoSelectMode(const AutoSelectMode& autoSelectMode);

Q_SIGNALS:
    void engineChanged();
    void isValidChanged();
    void defaultPlayoutIndexChanged();
    void defaultRecordIndexChanged();
    void currentPlayoutIndexChanged();
    void currentRecordIndexChanged();
    void currentCaptureIndexChanged();
    void autoSelectModeChanged();

    void prePlayoutItemAppended();
    void postPlayoutItemAppended();
    void prePlayoutItemRemoved(int index);
    void postPlayoutItemRemoved();

    void preRecordItemAppended();
    void postRecordItemAppended();
    void preRecordItemRemoved(int index);
    void postRecordItemRemoved();

    void preCaptureItemAppended();
    void postCaptureItemAppended();
    void preCaptureItemRemoved(int index);
    void postCaptureItemRemoved();

protected:
    void onAudioDeviceChanged(const std::string& deviceId, nem_sdk::AudioDeviceType deviceType, nem_sdk::DeviceState deviceState) override;
    void onAudioDefualtDeviceChanged(const std::string& deviceId, nem_sdk::AudioDeviceType deviceType) override;
    void onVideoDeviceChanged(const std::string& deviceId, nem_sdk::VideoDeviceType deviceType, nem_sdk::DeviceState deviceState) override;
    void onLocalVolumeIndication(int volume) override;
    void onRemoteVolumeIndication(int volume) override;

private:
    NEMDeviceInfo getDeviceInfo(DeviceType deviceType, const QString& deviceId);

private:
    QPointer<Invoker> m_invoker = nullptr;
    nem_sdk::IDeviceService* m_devicesService = nullptr;
    NEMEngine* m_engine = nullptr;
    bool m_isValid = false;

    AutoSelectMode m_autoSelectMode = DEFAULT_MODE;

    int m_defaultPlayoutIndex = 0;
    int m_defaultRecordIndex = 0;
    int m_currentPlayoutIndex = 0;
    int m_currentRecordIndex = 0;
    int m_currentCaptureIndex = 0;

    QVector<NEMDeviceInfo> m_playoutDevices;
    QVector<NEMDeviceInfo> m_recordDevices;
    QVector<NEMDeviceInfo> m_captureDevices;
};

#endif  // MEETING_PLUGINS_COMPONENTS_DEVICES_NEM_DEVICES_H_
