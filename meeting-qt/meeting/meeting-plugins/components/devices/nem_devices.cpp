// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_devices.h"

QString NEMDevices::m_autoSelectDeviceId = "nertc-audio-device-auto";

NEMDevices::NEMDevices(QObject* parent)
    : QObject(parent)
    , m_invoker(new Invoker) {}

bool NEMDevices::selectDevice(NEMDevices::DeviceType deviceType, const QString& deviceId) {
    QByteArray byteDeviceId = deviceId.toUtf8();
    if (deviceType == DEVICE_TYPE_PLAYOUT) {
        auto result = m_devicesService->selectPlayoutDevice(byteDeviceId.data());
        if (result == nem_sdk::kNEMNoError) {
            for (int i = 0; i < m_playoutDevices.size(); i++) {
                if (deviceId == m_playoutDevices.at(i).devicePath) {
                    setCurrentPlayoutIndex(i);
                    break;
                }
            }
        }
    }
    if (deviceType == DEVICE_TYPE_RECORD) {
        auto result = m_devicesService->selectRecordDevice(byteDeviceId.data());
        if (result == nem_sdk::kNEMNoError) {
            for (int i = 0; i < m_recordDevices.size(); i++) {
                if (deviceId == m_recordDevices.at(i).devicePath) {
                    setCurrentRecordIndex(i);
                    break;
                }
            }
        }
    }
    if (deviceType == DEVICE_TYPE_CAPTURE) {
        auto result = m_devicesService->selectCaptureDevice(byteDeviceId.data());
        if (result == nem_sdk::kNEMNoError) {
            for (int i = 0; i < m_captureDevices.size(); i++) {
                if (deviceId == m_captureDevices.at(i).devicePath) {
                    setCurrentCaptureIndex(i);
                    break;
                }
            }
        }
    }
    return false;
}

NEMEngine* NEMDevices::engine() const {
    return m_engine;
}

void NEMDevices::setEngine(NEMEngine* engine) {
    if (m_engine != engine) {
        m_engine = engine;
        Q_EMIT engineChanged();
        if (m_engine != nullptr) {
            m_devicesService = m_engine->getDeviceService();
            if (m_devicesService != nullptr) {
                m_devicesService->setDeviecsEventHandler(this);
                setIsValid(true);
                std::vector<nem_sdk::NEMDeviceInfo> playoutDevices;
                m_devicesService->enumAudioDevices(nem_sdk::kAudioDeviceTypePlayout, playoutDevices);
                for (auto& device : playoutDevices) {
                    NEMDeviceInfo info;
                    info.deviceName = QString::fromStdString(device.deviceName);
                    info.devicePath = QString::fromStdString(device.devicePath);
                    info.unavailable = device.unavailable;
                    m_playoutDevices.push_back(info);
                    if (device.defaultDevice)
                        setDefaultPlayoutIndex(m_playoutDevices.size() - 1);
                }
                std::vector<nem_sdk::NEMDeviceInfo> recordDevices;
                m_devicesService->enumAudioDevices(nem_sdk::kAudioDeviceTypeRecord, recordDevices);
                for (auto& device : recordDevices) {
                    NEMDeviceInfo info;
                    info.deviceName = QString::fromStdString(device.deviceName);
                    info.devicePath = QString::fromStdString(device.devicePath);
                    info.unavailable = device.unavailable;
                    m_recordDevices.push_back(info);
                    if (device.defaultDevice) {
                        setDefaultRecordIndex(m_recordDevices.size() - 1);
                    }
                }
                std::vector<nem_sdk::NEMDeviceInfo> captureDevices;
                m_devicesService->enumCaptureDevices(nem_sdk::kVideoDeviceTypeCapture, captureDevices);
                for (auto& device : captureDevices) {
                    NEMDeviceInfo info;
                    info.deviceName = QString::fromStdString(device.deviceName);
                    info.devicePath = QString::fromStdString(device.devicePath);
                    info.unavailable = device.unavailable;
                    m_captureDevices.push_back(info);
                }

                if (m_autoSelectMode == DEFAULT_MODE) {
                    // Playout device
                    auto playoutDeviceId = m_playoutDevices.at(defaultPlayoutIndex()).devicePath;
                    QByteArray bytePlayoutId = playoutDeviceId.toUtf8();
                    m_devicesService->selectPlayoutDevice(bytePlayoutId.data());
                    setCurrentPlayoutIndex(defaultPlayoutIndex());
                    // Record device
                    auto recordDeviceId = m_recordDevices.at(defaultRecordIndex()).devicePath;
                    QByteArray byteRecordId = recordDeviceId.toUtf8();
                    m_devicesService->selectRecordDevice(byteRecordId.data());
                    setCurrentRecordIndex(defaultRecordIndex());
                }
                if (m_autoSelectMode == RECOMMENDED_MODE) {
                    QByteArray byteAutoSelectDeviceId = NEMDevices::m_autoSelectDeviceId.toUtf8();
                    m_devicesService->selectPlayoutDevice(byteAutoSelectDeviceId.data());
                    m_devicesService->selectRecordDevice(byteAutoSelectDeviceId.data());
                    std::string currentDevice;
                    {
                        m_devicesService->getCurrentSelectedDevice(nem_sdk::kAudioDeviceTypePlayout, currentDevice);
                        for (int i = 0; i < m_playoutDevices.size(); i++) {
                            if (QString::fromStdString(currentDevice) == m_playoutDevices.at(i).deviceName) {
                                setCurrentPlayoutIndex(i);
                                break;
                            }
                        }
                    }
                    {
                        currentDevice.clear();
                        m_devicesService->getCurrentSelectedDevice(nem_sdk::kAudioDeviceTypeRecord, currentDevice);
                        for (int i = 0; i < m_recordDevices.size(); i++) {
                            if (QString::fromStdString(currentDevice) == m_recordDevices.at(i).deviceName) {
                                setCurrentPlayoutIndex(i);
                                break;
                            }
                        }
                    }
                }
                if (m_captureDevices.size() > 0) {
                    QByteArray byteDeviceId = m_captureDevices[0].devicePath.toUtf8();
                    m_devicesService->selectCaptureDevice(byteDeviceId.data());
                    setCurrentCaptureIndex(0);
                }
            }
        }
    }
}

bool NEMDevices::isValid() const {
    return m_isValid;
}

void NEMDevices::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

void NEMDevices::onAudioDeviceChanged(const std::string& deviceId, nem_sdk::AudioDeviceType deviceType, nem_sdk::DeviceState deviceState) {
    m_invoker->execute([=]() {
        if (deviceState == nem_sdk::kDeviceAdded) {
            auto queryType = deviceType == nem_sdk::kAudioDeviceTypePlayout ? DEVICE_TYPE_PLAYOUT : DEVICE_TYPE_RECORD;
            auto deviceInfo = getDeviceInfo(queryType, QString::fromStdString(deviceId));
            if (deviceType == nem_sdk::kAudioDeviceTypePlayout) {
                if (!deviceInfo.devicePath.isEmpty() && !deviceInfo.deviceName.isEmpty()) {
                    Q_EMIT prePlayoutItemAppended();
                    m_playoutDevices.append(deviceInfo);
                    Q_EMIT postPlayoutItemAppended();
                }
            }
            if (deviceType == nem_sdk::kAudioDeviceTypeRecord) {
                if (!deviceInfo.devicePath.isEmpty() && !deviceInfo.deviceName.isEmpty()) {
                    Q_EMIT preRecordItemAppended();
                    m_recordDevices.append(deviceInfo);
                    Q_EMIT postRecordItemAppended();
                }
            }
        }
        if (deviceState == nem_sdk::kDeviceRemoved) {
            if (deviceType == nem_sdk::kAudioDeviceTypePlayout) {
                for (int i = 0; i < m_playoutDevices.size(); i++) {
                    if (m_playoutDevices.at(i).devicePath == QString::fromStdString(deviceId)) {
                        Q_EMIT prePlayoutItemRemoved(i);
                        m_playoutDevices.remove(i);
                        Q_EMIT postPlayoutItemRemoved();
                        break;
                    }
                }
            }
            if (deviceType == nem_sdk::kAudioDeviceTypeRecord) {
                for (int i = 0; i < m_recordDevices.size(); i++) {
                    if (m_recordDevices.at(i).devicePath == QString::fromStdString(deviceId)) {
                        Q_EMIT preRecordItemRemoved(i);
                        m_recordDevices.remove(i);
                        Q_EMIT postRecordItemRemoved();
                        break;
                    }
                }
            }
        }
    });
}

void NEMDevices::onAudioDefualtDeviceChanged(const std::string& deviceId, nem_sdk::AudioDeviceType deviceType) {
    m_invoker->execute([=]() {
        if (deviceType == nem_sdk::kAudioDeviceTypePlayout) {
            // setDefaultPlayoutDeviceId(QString::fromStdString(deviceId));
        }
        if (deviceType == nem_sdk::kAudioDeviceTypeRecord) {
            // setDefaultRecordDeviceId(QString::fromStdString(deviceId));
        }
    });
}

void NEMDevices::onVideoDeviceChanged(const std::string& deviceId, nem_sdk::VideoDeviceType deviceType, nem_sdk::DeviceState deviceState) {
    Q_UNUSED(deviceType)
    m_invoker->execute([=]() {
        m_invoker->execute([=]() {
            if (deviceState == nem_sdk::kDeviceAdded) {
                auto deviceInfo = getDeviceInfo(DEVICE_TYPE_CAPTURE, QString::fromStdString(deviceId));
                if (!deviceInfo.deviceName.isEmpty() && !deviceInfo.devicePath.isEmpty()) {
                    Q_EMIT preCaptureItemAppended();
                    m_captureDevices.append(deviceInfo);
                    Q_EMIT postCaptureItemAppended();
                }
            }
            if (deviceState == nem_sdk::kDeviceRemoved) {
                for (int i = 0; i < m_captureDevices.size(); i++) {
                    if (m_captureDevices.at(i).devicePath == QString::fromStdString(deviceId)) {
                        Q_EMIT preCaptureItemRemoved(i);
                        m_captureDevices.remove(i);
                        Q_EMIT postCaptureItemRemoved();
                        break;
                    }
                }
            }
        });
    });
}

void NEMDevices::onLocalVolumeIndication(int volume) {
    Q_UNUSED(volume)
}

void NEMDevices::onRemoteVolumeIndication(int volume) {
    Q_UNUSED(volume);
}

NEMDeviceInfo NEMDevices::getDeviceInfo(NEMDevices::DeviceType deviceType, const QString& deviceId) {
    if (m_devicesService) {
        std::vector<nem_sdk::NEMDeviceInfo> devices;
        if (deviceType == DEVICE_TYPE_CAPTURE) {
            m_devicesService->enumCaptureDevices(nem_sdk::kVideoDeviceTypeCapture, devices);
        } else {
            auto queryType = deviceType == DEVICE_TYPE_PLAYOUT ? nem_sdk::kAudioDeviceTypePlayout : nem_sdk::kAudioDeviceTypeRecord;
            m_devicesService->enumAudioDevices(queryType, devices);
        }
        for (auto& device : devices) {
            if (deviceId == QString::fromStdString(device.devicePath)) {
                NEMDeviceInfo info;
                info.deviceName = QString::fromStdString(device.deviceName);
                info.devicePath = QString::fromStdString(device.devicePath);
                info.unavailable = device.unavailable;
                return info;
            }
        }
    }
    return NEMDeviceInfo();
}

NEMDevices::AutoSelectMode NEMDevices::autoSelectMode() const {
    return m_autoSelectMode;
}

void NEMDevices::setAutoSelectMode(const AutoSelectMode& autoSelectMode) {
    m_autoSelectMode = autoSelectMode;
}

int NEMDevices::currentCaptureIndex() const {
    return m_currentCaptureIndex;
}

void NEMDevices::setCurrentCaptureIndex(int currentCaptureIndex) {
    if (m_currentCaptureIndex != currentCaptureIndex) {
        m_currentCaptureIndex = currentCaptureIndex;
        Q_EMIT currentCaptureIndexChanged();
    }
}

int NEMDevices::currentRecordIndex() const {
    return m_currentRecordIndex;
}

void NEMDevices::setCurrentRecordIndex(int currentRecordIndex) {
    if (m_currentRecordIndex != currentRecordIndex) {
        m_currentRecordIndex = currentRecordIndex;
        Q_EMIT currentRecordIndexChanged();
    }
}

int NEMDevices::currentPlayoutIndex() const {
    return m_currentPlayoutIndex;
}

void NEMDevices::setCurrentPlayoutIndex(int currentPlayoutIndex) {
    if (m_currentPlayoutIndex != currentPlayoutIndex) {
        m_currentPlayoutIndex = currentPlayoutIndex;
        Q_EMIT currentPlayoutIndexChanged();
    }
}

int NEMDevices::defaultRecordIndex() const {
    return m_defaultRecordIndex;
}

void NEMDevices::setDefaultRecordIndex(int defaultRecordIndex) {
    if (m_defaultRecordIndex != defaultRecordIndex) {
        m_defaultRecordIndex = defaultRecordIndex;
        Q_EMIT defaultRecordIndexChanged();
    }
}

int NEMDevices::defaultPlayoutIndex() const {
    return m_defaultPlayoutIndex;
}

void NEMDevices::setDefaultPlayoutIndex(int defaultPlayoutIndex) {
    if (m_defaultPlayoutIndex != defaultPlayoutIndex) {
        m_defaultPlayoutIndex = defaultPlayoutIndex;
        Q_EMIT defaultPlayoutIndexChanged();
    }
}

QVector<NEMDeviceInfo> NEMDevices::getDevices(NEMDevices::DeviceType deviceType) const {
    if (deviceType == DEVICE_TYPE_PLAYOUT)
        return m_playoutDevices;
    if (deviceType == DEVICE_TYPE_RECORD)
        return m_recordDevices;
    if (deviceType == DEVICE_TYPE_CAPTURE)
        return m_captureDevices;
    return QVector<NEMDeviceInfo>();
}
