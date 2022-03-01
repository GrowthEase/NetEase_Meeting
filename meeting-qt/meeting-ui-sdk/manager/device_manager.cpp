/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "device_manager.h"
#include <QGuiApplication>

#define ENUM_DEVICE_TIMEOUT 2000

#define CHECK_INIT                                                           \
    bool bRet = true;                                                        \
    auto preRoomService = GlobalManager::getInstance()->getPreRoomService(); \
    if (!preRoomService) {                                                   \
        bRet = false;                                                        \
    }                                                                        \
                                                                             \
    auto audioController = preRoomService->getPreRoomAudioController();      \
    if (!audioController) {                                                  \
        bRet = false;                                                        \
    }                                                                        \
                                                                             \
    auto videoController = preRoomService->getPreRoomVideoController();      \
    if (!videoController) {                                                  \
        bRet = false;                                                        \
    }

#define CHECK_0 \
    CHECK_INIT  \
    if (!bRet)  \
        return 0;

#define CHECK_false \
    CHECK_INIT      \
    if (!bRet)      \
        return bRet;

#define CHECK_void \
    CHECK_INIT     \
    if (!bRet)     \
        return;

DeviceManager::DeviceManager(QObject* parent)
    : QObject(parent) {
    qRegisterMetaType<AudioDeviceType>();
    qRegisterMetaType<VideoDeviceType>();
    qRegisterMetaType<NEDeviceState>();
    connect(&m_enumPlayoutTimer, &QTimer::timeout, [this]() {
        YXLOG(Info) << "Begin to enum playout devices, old selected device path: " << m_lastSelectedPlayout.devicePath.toStdString()
                    << ", device name: " << m_lastSelectedPlayout.deviceName.toStdString() << YXLOGEnd;
        emit preDeviceListReset(DeviceTypePlayout);
        enumDevices(DeviceTypePlayout, m_lastSelectedPlayout);
        emit postDeviceListReset(DeviceTypePlayout);
    });
    m_enumPlayoutTimer.setSingleShot(true);
    connect(&m_enumRecordTimer, &QTimer::timeout, [this]() {
        YXLOG(Info) << "Begin to enum record devices, old selected device path: " << m_lastSelectedRecord.devicePath.toStdString()
                    << ", device name: " << m_lastSelectedRecord.deviceName.toStdString() << YXLOGEnd;
        emit preDeviceListReset(DeviceTypeRecord);
        enumDevices(DeviceTypeRecord, m_lastSelectedRecord);
        emit postDeviceListReset(DeviceTypeRecord);
    });
    m_enumRecordTimer.setSingleShot(true);
    connect(&m_enumCaptureTimer, &QTimer::timeout, [this]() {
        YXLOG(Info) << "Begin to enum capture devices, old selected device path: " << m_lastSelectedCapture.devicePath.toStdString()
                    << ", device name: " << m_lastSelectedCapture.deviceName.toStdString() << YXLOGEnd;
        emit preDeviceListReset(DeviceTypeCapture);
        enumDevices(DeviceTypeCapture, m_lastSelectedCapture);
        emit postDeviceListReset(DeviceTypeCapture);
    });
    m_enumCaptureTimer.setSingleShot(true);
}

bool DeviceManager::initialize() {
    connect(this, &DeviceManager::audioDeviceChangedSignal, this, &DeviceManager::onAudioDeviceStateChanged, Qt::QueuedConnection);
    connect(this, &DeviceManager::videoDeviceChangedSignal, this, &DeviceManager::onVideoDeviceStateChanged, Qt::QueuedConnection);
    connect(this, &DeviceManager::audioDefaultDeviceChangedSignal, this, &DeviceManager::onAudioDefaultDeviceChanged, Qt::QueuedConnection);
    return true;
}

void DeviceManager::release() {
    disconnect(this, 0, 0, 0);
}

void DeviceManager::resetDevicesInfo() {
    m_recordDevices.clear();
    m_playoutDevices.clear();
    m_captureDevices.clear();
    m_playoutSelectedMode = kDeviceAuto;
    m_recordSelectedMode = kDeviceAuto;
}

QVector<DEVICE_INFO>& DeviceManager::getPlayoutDevices() {
    if (m_playoutDevices.size() > 0)
        return m_playoutDevices;

    enumDevices(DeviceTypePlayout);
    return m_playoutDevices;
}

QVector<DEVICE_INFO>& DeviceManager::getRecordDevices() {
    if (m_recordDevices.size() > 0)
        return m_recordDevices;

    enumDevices(DeviceTypeRecord);
    return m_recordDevices;
}

QVector<DEVICE_INFO>& DeviceManager::getCaptureDevices() {
    if (m_captureDevices.size() > 0)
        return m_captureDevices;

    enumDevices(DeviceTypeCapture);
    return m_captureDevices;
}

int DeviceManager::getDeviceCount(int deviceType) {
    if (deviceType == DeviceTypePlayout)
        return m_playoutDevices.size();
    else if (deviceType == DeviceTypeRecord)
        return m_recordDevices.size();
    else if (deviceType == DeviceTypeCapture)
        return m_captureDevices.size();
    return 0;
}

void DeviceManager::getCurrentSelectedDevice() {
    CHECK_void;
    NEAudioDeviceInfo audioInfo;
    memset(&audioInfo, 0x00, sizeof(audioInfo));
    audioController->getDefaultPlayoutDevice(audioInfo);
    if (!audioInfo.deviceName.empty())
        emit playoutDeviceChangedNotify(QString::fromStdString(audioInfo.deviceName), QString::fromStdString(audioInfo.deviceId));

    NEAudioDeviceInfo videoInfo;
    memset(&videoInfo, 0x00, sizeof(videoInfo));
    audioController->getDefaultRecordDevice(videoInfo);
    if (!videoInfo.deviceName.empty())
        emit recordDeviceChangedNotify(QString::fromStdString(videoInfo.deviceName), QString::fromStdString(videoInfo.deviceId));
}

void DeviceManager::onPlayoutDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) {
    emit audioDeviceChangedSignal(QString::fromStdString(deviceId), kAudioDeviceTypePlayout, deviceState);
}

void DeviceManager::onRecordDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) {
    emit audioDeviceChangedSignal(QString::fromStdString(deviceId), kAudioDeviceTypeRecord, deviceState);
}

void DeviceManager::onDefualtPlayoutDeviceChanged(const std::string& deviceId) {
    emit audioDefaultDeviceChangedSignal(QString::fromStdString(deviceId), kAudioDeviceTypePlayout);
}

void DeviceManager::onDefualtRecordDeviceChanged(const std::string& deviceId) {
    emit audioDefaultDeviceChangedSignal(QString::fromStdString(deviceId), kAudioDeviceTypeRecord);
}

void DeviceManager::onCameraDeviceChanged(const std::string& deviceId, NEDeviceState deviceState) {
    emit videoDeviceChangedSignal(QString::fromStdString(deviceId), kVideoDeviceTypeCapture, deviceState);
}

void DeviceManager::onLocalVolumeIndication(int volume) {
    emit localAudioVolumeIndication(volume);
}

void DeviceManager::onRemoteVolumeIndication(int volume) {
    emit remoteAudioVolumeIndication(volume);
}

void DeviceManager::selectRecordDevice(const QString& devicePath) {}

void DeviceManager::selectPlayoutDevice(const QString& devicePath) {}

bool DeviceManager::appendDevice(DeviceType deviceType, const QString& devicePath, const QString& deviceName) {
    if (deviceType == DeviceTypePlayout) {
        for (auto& device : m_playoutDevices) {
            auto existDeviceName = device.deviceName;
            auto existDevicePath = device.devicePath;
            if (existDeviceName == deviceName && existDevicePath == devicePath) {
                YXLOG(Info) << "Playout device: " << devicePath.toStdString() << " has already in device list." << YXLOGEnd;
                return false;
            }
            preDeviceAppended(deviceType);
            DEVICE_INFO info;
            info.deviceName = deviceName;
            info.devicePath = devicePath;
            info.defaultDevice = false;
            m_playoutDevices.append(info);
            postDeviceAppended(deviceType);
        }
    } else if (deviceType == DeviceTypeRecord) {
        for (auto& device : m_recordDevices) {
            auto existDeviceName = device.deviceName;
            auto existDevicePath = device.devicePath;
            if (existDeviceName == deviceName && existDevicePath == devicePath) {
                YXLOG(Info) << "Record device: " << devicePath.toStdString() << " has already in device list." << YXLOGEnd;
                return false;
            }
            preDeviceAppended(deviceType);
            DEVICE_INFO info;
            info.deviceName = deviceName;
            info.devicePath = devicePath;
            info.defaultDevice = false;
            m_recordDevices.append(info);
            postDeviceAppended(deviceType);
        }
    } else if (deviceType == DeviceTypeCapture) {
        for (auto& device : m_captureDevices) {
            auto existDeviceName = device.deviceName;
            auto existDevicePath = device.devicePath;
            if (existDeviceName == deviceName && existDevicePath == devicePath) {
                YXLOG(Info) << "Capture device: " << devicePath.toStdString() << " has already in device list." << YXLOGEnd;
                return false;
            }
            preDeviceAppended(deviceType);
            DEVICE_INFO info;
            info.deviceName = deviceName;
            info.devicePath = devicePath;
            info.defaultDevice = false;
            m_captureDevices.append(info);
            postDeviceAppended(deviceType);
        }
    }

    return true;
}

bool DeviceManager::removeDevice(DeviceType deviceType, const QString& devicePath, const QString& /*deviceName*/) {
    int removedIndex = -1;
    if (deviceType == DeviceTypePlayout) {
        for (int i = 0; i < m_playoutDevices.size(); i++) {
            const DEVICE_INFO& device = m_playoutDevices.at(i);
            if (devicePath == device.deviceName) {
                emit preDeviceRemoved(deviceType, i);
                if (device.selectedDevice) {
                    removedIndex = i;
                }
                emit postDeviceRemoved(deviceType);
                break;
            }
        }
    } else if (deviceType == DeviceTypeRecord) {
        for (int i = 0; i < m_playoutDevices.size(); i++) {
            const DEVICE_INFO& device = m_recordDevices.at(i);
            if (devicePath == device.deviceName) {
                emit preDeviceRemoved(deviceType, i);
                if (device.selectedDevice) {
                    removedIndex = i;
                }
                emit postDeviceRemoved(deviceType);
                break;
            }
        }
    } else if (DeviceTypePlayout == DeviceTypeCapture) {
        for (int i = 0; i < m_playoutDevices.size(); i++) {
            const DEVICE_INFO& device = m_captureDevices.at(i);
            if (devicePath == device.deviceName) {
                emit preDeviceRemoved(deviceType, i);
                if (device.selectedDevice) {
                    removedIndex = i;
                }
                emit postDeviceRemoved(deviceType);
                break;
            }
        }
    }

    return true;
}

int DeviceManager::currentIndex(int deviceType) {
    if (deviceType == DeviceTypeRecord) {
        getRecordDevices();
        for (auto i = 0; i < m_recordDevices.size(); i++) {
            const DEVICE_INFO& info = m_recordDevices.at(i);
            if (info.selectedDevice) {
                return i;
            }
        }
    } else if (deviceType == DeviceTypePlayout) {
        getPlayoutDevices();
        for (auto i = 0; i < m_playoutDevices.size(); i++) {
            const DEVICE_INFO& info = m_playoutDevices.at(i);
            if (info.selectedDevice) {
                return i;
            }
        }
    } else if (deviceType == DeviceTypeCapture) {
        getCaptureDevices();
        for (auto i = 0; i < m_captureDevices.size(); i++) {
            const DEVICE_INFO& info = m_captureDevices.at(i);
            if (info.selectedDevice) {
                return i;
            }
        }
    }

    return 0;
}

void DeviceManager::selectDevice(int deviceType, int index) {
    YXLOG(Info) << "Select a new device, device type: " << deviceType << ", index: " << index << YXLOGEnd;
    CHECK_void;
    emit preDeviceListReset((DeviceType)deviceType);
    if (deviceType == DeviceTypeRecord) {
        for (auto i = 0; i < m_recordDevices.size(); i++) {
            DEVICE_INFO info = m_recordDevices.at(i);
            if (info.selectedDevice) {
                info.selectedDevice = false;
                m_recordDevices.replace(i, info);
                break;
            }
        }
        DEVICE_INFO selectedDevice = m_recordDevices.at(index);
        selectedDevice.selectedDevice = true;
        QByteArray byteDevicePath = selectedDevice.devicePath.toUtf8();
        if (audioController->selectRecordDevice(byteDevicePath.data()) == kNENoError) {
            m_recordDevices.replace(index, selectedDevice);
            if (selectedDevice.devicePath != m_lastSelectedRecord.devicePath && selectedDevice.deviceName != m_lastSelectedRecord.deviceName)
                emit recordDeviceChangedNotify(selectedDevice.deviceName, selectedDevice.devicePath);
            // 记录用户选择的非默认设备
            m_lastSelectedRecord = selectedDevice;
            if (index == 0)
                m_recordSelectedMode = kDeviceDefault;
            else
                m_recordSelectedMode = kDeviceUser;
        } else {
            YXLOG(Error) << "Failed to select record device, device ID: " << byteDevicePath.data() << YXLOGEnd;
            emit error(0, tr("Failed to select record device."));
        }

    } else if (deviceType == DeviceTypePlayout) {
        for (auto i = 0; i < m_playoutDevices.size(); i++) {
            DEVICE_INFO info = m_playoutDevices.at(i);
            if (info.selectedDevice) {
                info.selectedDevice = false;
                m_playoutDevices.replace(i, info);
                break;
            }
        }
        DEVICE_INFO selectedDevice = m_playoutDevices.at(index);
        selectedDevice.selectedDevice = true;
        QByteArray byteDevicePath = selectedDevice.devicePath.toUtf8();
        if (audioController->selectPlayoutDevice(byteDevicePath.data()) == kNENoError) {
            m_playoutDevices.replace(index, selectedDevice);
            if (selectedDevice.devicePath != m_lastSelectedPlayout.devicePath && selectedDevice.deviceName != m_lastSelectedPlayout.deviceName)
                emit playoutDeviceChangedNotify(selectedDevice.deviceName, selectedDevice.devicePath);
            // 记录用户选择的非默认设备
            m_lastSelectedPlayout = selectedDevice;
            if (index == 0)
                m_playoutSelectedMode = kDeviceDefault;
            else
                m_playoutSelectedMode = kDeviceUser;
        } else {
            YXLOG(Error) << "Failed to select playout device, device ID: " << byteDevicePath.data() << YXLOGEnd;
            emit error(0, tr("Failed to select playout device."));
        }

    } else if (deviceType == DeviceTypeCapture) {
        for (auto i = 0; i < m_captureDevices.size(); i++) {
            DEVICE_INFO info = m_captureDevices.at(i);
            if (info.selectedDevice) {
                info.selectedDevice = false;
                m_captureDevices.replace(i, info);
                break;
            }
        }
        if (!m_captureDevices.empty()) {
            DEVICE_INFO selectedDevice = m_captureDevices.at(index);
            selectedDevice.selectedDevice = true;
            QByteArray byteDevicePath = selectedDevice.devicePath.toUtf8();
            if (videoController->selectCameraDevice(byteDevicePath.data()) == kNENoError) {
                m_captureDevices.replace(index, selectedDevice);
                if (selectedDevice.devicePath != m_lastSelectedCapture.devicePath && selectedDevice.deviceName != m_lastSelectedCapture.deviceName)
                    emit captureDeviceChangedNotify(selectedDevice.deviceName, selectedDevice.devicePath);
                // 记录用户选择的非默认设备
                m_lastSelectedCapture = selectedDevice;
            } else {
                YXLOG(Error) << "Failed to select capture device, device ID: " << byteDevicePath.data() << YXLOGEnd;
                emit error(0, tr("Failed to select capture device."));
            }
        }
    }
    emit postDeviceListReset((DeviceType)deviceType);
}

unsigned int DeviceManager::getRecordDeviceVolume() {
    auto preRoomService = GlobalManager::getInstance()->getPreRoomService();
    if (!preRoomService) {
        return 0;
    }

    auto audioController = preRoomService->getPreRoomAudioController();
    if (!audioController) {
        return 0;
    }

    unsigned int volumeValue = audioController->getRecordDeviceVolume();
    return volumeValue;
}

bool DeviceManager::setRecordDeviceVolume(unsigned int volumeValue) {
    auto preRoomService = GlobalManager::getInstance()->getPreRoomService();
    if (!preRoomService) {
        return false;
    }

    auto audioController = preRoomService->getPreRoomAudioController();
    if (!audioController) {
        return false;
    }

    return audioController->setRecordDeviceVolume(volumeValue) == kNENoError;
}

unsigned int DeviceManager::getPlayoutDeviceVolume() {
    auto preRoomService = GlobalManager::getInstance()->getPreRoomService();
    if (!preRoomService) {
        return 0;
    }

    auto audioController = preRoomService->getPreRoomAudioController();
    if (!audioController) {
        return 0;
    }

    unsigned int volumeValue = audioController->getPlayoutDeviceVolume();
    return volumeValue;
}

bool DeviceManager::setPlayoutDeviceVolume(unsigned int volumeValue) {
    CHECK_false;
    return audioController->setPlayoutDeviceVolume(volumeValue) == kNENoError;
}

void DeviceManager::startMicrophoneTest(bool start /* = true*/) {
    CHECK_void;
    if (start) {
        audioController->startRecordDeviceTest();
    } else {
        audioController->stopRecordDeviceTest();
    }
}

void DeviceManager::startSpeakerTest(bool start) {
    CHECK_void;
    if (start) {
        QString applicationDir = qApp->applicationDirPath();
#ifdef Q_OS_MACX
        QString mediaFile = applicationDir + "/../Resources/rain.mp3";
#else
        QString mediaFile = applicationDir + "/rain.mp3";
#endif
        YXLOG(Info) << "Playout media file:" << mediaFile.toStdString() << YXLOGEnd;
        QByteArray byteFile = mediaFile.toUtf8();
        startMicrophoneTest(true);
        audioController->startPlayoutDeviceTest(byteFile.data());
    } else {
        audioController->stopPlayoutDeviceTest();
        startMicrophoneTest(false);
    }
}

void DeviceManager::onAudioDeviceStateChanged(const QString& deviceId, AudioDeviceType deviceType, NEDeviceState deviceState) {
    YXLOG(Info) << "Audio device state changed, device ID: " << deviceId.toStdString() << ", device type: " << deviceType
                << ", device state: " << deviceState << YXLOGEnd;

    if (deviceType == kAudioDeviceTypeRecord) {
        if (m_enumRecordTimer.isActive())
            m_enumRecordTimer.stop();
        m_enumRecordTimer.start(ENUM_DEVICE_TIMEOUT);
    }

    if (deviceType == kAudioDeviceTypePlayout) {
        if (m_enumPlayoutTimer.isActive())
            m_enumPlayoutTimer.stop();
        m_enumPlayoutTimer.start(ENUM_DEVICE_TIMEOUT);
    }

    if (m_enumCaptureTimer.isActive())
        m_enumCaptureTimer.stop();

    m_enumCaptureTimer.start(ENUM_DEVICE_TIMEOUT);
}

void DeviceManager::onAudioDefaultDeviceChanged(const QString& deviceId, AudioDeviceType deviceType) {
    YXLOG(Info) << "Audio default device changed, device ID: " << deviceId.toStdString() << ", device type: " << deviceType << YXLOGEnd;

    bool foundDevice = false;

    if (deviceType == kAudioDeviceTypeRecord) {
        for (auto& device : m_recordDevices) {
            if (device.devicePath == deviceId) {
                YXLOG(Info) << "Found device in current device list, device Id: " << device.devicePath.toStdString() << YXLOGEnd;
                foundDevice = true;
                break;
            }
        }

        if (foundDevice) {
            if (m_enumRecordTimer.isActive())
                m_enumRecordTimer.stop();
            m_enumRecordTimer.start(ENUM_DEVICE_TIMEOUT);
        }
    }

    if (deviceType == kAudioDeviceTypePlayout) {
        for (auto& device : m_playoutDevices) {
            if (device.devicePath == deviceId) {
                YXLOG(Info) << "Found device in current device list, device Id: " << device.devicePath.toStdString() << YXLOGEnd;
                foundDevice = true;
                break;
            }
        }

        if (foundDevice) {
            if (m_enumPlayoutTimer.isActive())
                m_enumPlayoutTimer.stop();
            m_enumPlayoutTimer.start(ENUM_DEVICE_TIMEOUT);
        }
    }
}

void DeviceManager::onVideoDeviceStateChanged(const QString& deviceId, VideoDeviceType deviceType, NEDeviceState deviceState) {
    YXLOG(Info) << "Video device state changed, device ID: " << deviceId.toStdString() << ", device type: " << deviceType
                << ", device state: " << deviceState << YXLOGEnd;

    if (m_enumCaptureTimer.isActive())
        m_enumCaptureTimer.stop();

    m_enumCaptureTimer.start(ENUM_DEVICE_TIMEOUT);
}

bool DeviceManager::enumDevices(DeviceType deviceType, const DEVICE_INFO& oldSelectedDevice) {
    YXLOG(Info) << "Enum deivces, device type: " << deviceType << ", old selected device: " << oldSelectedDevice.deviceName.toStdString() << YXLOGEnd;
    CHECK_false;
    int selectedIndex = -1;
    std::vector<NEAudioDeviceInfo> audioDeviceList;
    std::vector<NEVideoDeviceInfo> videoDeviceList;

    if (deviceType == DeviceTypeRecord) {
        m_recordDevices.clear();
        audioController->enumRecordDevices(audioDeviceList);
    } else if (deviceType == DeviceTypePlayout) {
        m_playoutDevices.clear();
        audioController->enumPlayoutDevices(audioDeviceList);
    } else if (deviceType == DeviceTypeCapture) {
        m_captureDevices.clear();
        videoController->enumCameraDevices(videoDeviceList);
    }

    for (uint32_t i = 0; i < audioDeviceList.size(); i++) {
        auto device = audioDeviceList.at(i);
        DEVICE_INFO deviceInfo;
        deviceInfo.devicePath = QString::fromStdString(device.deviceId);
        deviceInfo.deviceName = QString::fromStdString(device.deviceName) + (device.unavailable ? tr(" (Unavailable)") : "");
        deviceInfo.defaultDevice = false;
        deviceInfo.selectedDevice = false;
        deviceInfo.unavailable = device.unavailable;

        if (deviceType == DeviceTypeRecord) {
            m_recordDevices.push_back(deviceInfo);
        } else if (deviceType == DeviceTypePlayout) {
            m_playoutDevices.push_back(deviceInfo);
        }

        if (device.defaultDevice) {
            DEVICE_INFO defaultDevice;
            defaultDevice.deviceName = tr("(Default) ") + QString::fromStdString(device.deviceName);
            defaultDevice.devicePath = QString::fromStdString(device.deviceId);
            defaultDevice.unavailable = device.unavailable;
            defaultDevice.defaultDevice = device.defaultDevice;
            defaultDevice.selectedDevice = false;
            if (deviceType == DeviceTypeRecord)
                m_recordDevices.push_front(defaultDevice);
            if (deviceType == DeviceTypePlayout)
                m_playoutDevices.push_front(defaultDevice);
        }
    }

    for (uint32_t i = 0; i < videoDeviceList.size(); i++) {
        auto device = videoDeviceList.at(i);
        DEVICE_INFO deviceInfo;
        deviceInfo.devicePath = QString::fromStdString(device.deviceId);
        deviceInfo.deviceName = QString::fromStdString(device.deviceName) + (device.unavailable ? tr(" (Unavailable)") : "");
        deviceInfo.defaultDevice = false;
        deviceInfo.selectedDevice = false;
        deviceInfo.unavailable = device.unavailable;
        m_captureDevices.push_back(deviceInfo);
    }

    if (deviceType == DeviceTypeRecord) {
        for (auto i = 0; i < m_recordDevices.size(); i++) {
            if (oldSelectedDevice.devicePath == m_recordDevices[i].devicePath && oldSelectedDevice.deviceName == m_recordDevices[i].deviceName &&
                oldSelectedDevice.defaultDevice == m_recordDevices[i].defaultDevice) {
                selectedIndex = i;
            }
        }
    } else if (deviceType == DeviceTypePlayout) {
        for (auto i = 0; i < m_playoutDevices.size(); i++) {
            if (oldSelectedDevice.devicePath == m_playoutDevices[i].devicePath && oldSelectedDevice.deviceName == m_playoutDevices[i].deviceName &&
                oldSelectedDevice.defaultDevice == m_playoutDevices[i].defaultDevice) {
                selectedIndex = i;
            }
        }
    } else if (deviceType == DeviceTypeCapture) {
        for (auto i = 0; i < m_captureDevices.size(); i++) {
            if (oldSelectedDevice.devicePath == m_captureDevices[i].devicePath && oldSelectedDevice.deviceName == m_captureDevices[i].deviceName &&
                oldSelectedDevice.defaultDevice == m_captureDevices[i].defaultDevice) {
                selectedIndex = i;
            }
        }
    }

    if (deviceType == DeviceTypeRecord) {
        for (auto& device : m_recordDevices) {
            YXLOG(Info) << "Record devices: " << device.deviceName.toStdString() << ", " << device.devicePath.toStdString() << YXLOGEnd;
        }
    } else if (deviceType == DeviceTypePlayout) {
        for (auto& device : m_playoutDevices) {
            YXLOG(Info) << "Playout devices: " << device.deviceName.toStdString() << ", " << device.devicePath.toStdString() << YXLOGEnd;
        }
    } else if (deviceType == DeviceTypeCapture) {
        for (auto& device : m_captureDevices) {
            YXLOG(Info) << "Capture devices: " << device.deviceName.toStdString() << ", " << device.devicePath.toStdString() << YXLOGEnd;
        }
    }

    if (deviceType == DeviceTypeRecord) {
        if (m_recordSelectedMode == kDeviceUser) {
            bool foundDevice = false;
            for (auto i = 0; i < m_recordDevices.size(); i++) {
                auto deviceInfo = m_recordDevices.at(i);
                if (m_lastSelectedRecord.deviceName == deviceInfo.deviceName && m_lastSelectedPlayout.devicePath == deviceInfo.devicePath) {
                    foundDevice = true;
                    deviceInfo.selectedDevice = true;
                    QByteArray byteDevicePath = deviceInfo.devicePath.toUtf8();
                    m_recordDevices.replace(i, deviceInfo);
                    if (audioController->selectRecordDevice(byteDevicePath.data()) == kNENoError) {
                        if (deviceInfo.deviceName != m_lastSelectedRecord.deviceName && deviceInfo.devicePath != m_lastSelectedRecord.devicePath)
                            emit recordDeviceChangedNotify(deviceInfo.deviceName, deviceInfo.devicePath);
                        m_lastSelectedRecord = deviceInfo;
                        YXLOG(Info) << "[DeviceManager] Select " << byteDevicePath.data() << " as default record device, index: " << i << YXLOGEnd;
                        break;
                    } else {
                        YXLOG(Error) << "Failed to select record device, device ID: " << byteDevicePath.data() << YXLOGEnd;
                        emit error(0, tr("Failed to select record device."));
                        ;
                    }
                    break;
                }
            }
            if (!foundDevice)
                m_recordSelectedMode = kDeviceAuto;
        }

        if (m_recordSelectedMode == kDeviceAuto) {
            if (m_recordDevices.size() > 0 && audioController->selectRecordDevice("nertc-audio-device-auto") == kNENoError) {
                std::string deviceId;
                audioController->getSelectedRecordDevice(deviceId);
                // 从 1 开始，跳过第一个插入的默认设备
                for (int i = 1; i < m_recordDevices.size(); i++) {
                    if (m_recordDevices.at(i).devicePath == QString::fromStdString(deviceId)) {
                        auto replacedDevice = m_recordDevices.at(i);
                        replacedDevice.selectedDevice = true;
                        m_recordDevices.replace(i, replacedDevice);
                        if (replacedDevice.deviceName != m_lastSelectedRecord.deviceName &&
                            replacedDevice.devicePath != m_lastSelectedRecord.devicePath)
                            emit recordDeviceChangedNotify(replacedDevice.deviceName, replacedDevice.devicePath);
                        m_lastSelectedRecord = replacedDevice;
                        break;
                    }
                }
            } else {
                emit error(0, tr("Failed to select record device."));
                ;
            }
        }

        if (m_recordSelectedMode == kDeviceDefault) {
            if (m_recordDevices.size() > 0) {
                auto deviceInfo = m_recordDevices.at(0);
                deviceInfo.selectedDevice = true;
                QByteArray byteDevicePath = deviceInfo.devicePath.toUtf8();
                m_recordDevices.replace(0, deviceInfo);
                if (audioController->selectRecordDevice(byteDevicePath.data()) == kNENoError) {
                    if (deviceInfo.deviceName != m_lastSelectedRecord.deviceName && deviceInfo.devicePath != m_lastSelectedRecord.devicePath)
                        emit recordDeviceChangedNotify(deviceInfo.deviceName, deviceInfo.devicePath);
                    m_lastSelectedRecord = deviceInfo;
                    YXLOG(Info) << "[DeviceManager] Select " << byteDevicePath.data() << " as default record device, index: " << 0 << YXLOGEnd;
                } else {
                    YXLOG(Error) << "Failed to select record device, device ID: " << byteDevicePath.data() << YXLOGEnd;
                    emit error(0, tr("Failed to select record device."));
                    ;
                }
            }
        }
    } else if (deviceType == DeviceTypePlayout) {
        if (m_playoutSelectedMode == kDeviceUser) {
            bool foundDevice = false;
            for (auto i = 0; i < m_playoutDevices.size(); i++) {
                auto deviceInfo = m_playoutDevices.at(i);
                if (m_lastSelectedPlayout.deviceName == deviceInfo.deviceName && m_lastSelectedPlayout.devicePath == deviceInfo.devicePath) {
                    foundDevice = true;
                    deviceInfo.selectedDevice = true;
                    QByteArray byteDevicePath = deviceInfo.devicePath.toUtf8();
                    m_playoutDevices.replace(i, deviceInfo);
                    if (audioController->selectPlayoutDevice(byteDevicePath.data()) == kNENoError) {
                        if (deviceInfo.deviceName != m_lastSelectedPlayout.deviceName && deviceInfo.devicePath != m_lastSelectedPlayout.devicePath)
                            emit playoutDeviceChangedNotify(deviceInfo.deviceName, deviceInfo.devicePath);
                        m_lastSelectedPlayout = deviceInfo;
                        YXLOG(Info) << "[DeviceManager] Select " << byteDevicePath.data() << " as default playout device, index: " << i << YXLOGEnd;
                    } else {
                        YXLOG(Error) << "Failed to select playout device, device ID: " << byteDevicePath.data() << YXLOGEnd;
                        emit error(0, tr("Failed to select playout device."));
                        ;
                    }
                    break;
                }
            }
            if (!foundDevice)
                m_playoutSelectedMode = kDeviceAuto;
        }

        if (m_playoutSelectedMode == kDeviceAuto) {
            if (audioController->selectPlayoutDevice("nertc-audio-device-auto") == kNENoError) {
                std::string deviceId;
                audioController->getSelectedPlayoutDevice(deviceId);
                // 从 1 开始，跳过第一个插入的默认设备
                for (int i = 1; i < m_playoutDevices.size(); i++) {
                    if (m_playoutDevices.at(i).devicePath == QString::fromStdString(deviceId)) {
                        auto replacedDevice = m_playoutDevices.at(i);
                        replacedDevice.selectedDevice = true;
                        m_playoutDevices.replace(i, replacedDevice);
                        if (replacedDevice.deviceName != m_lastSelectedPlayout.deviceName &&
                            replacedDevice.devicePath != m_lastSelectedPlayout.devicePath)
                            emit playoutDeviceChangedNotify(replacedDevice.deviceName, replacedDevice.devicePath);
                        m_lastSelectedPlayout = replacedDevice;
                        break;
                    }
                }
            } else {
                emit error(0, tr("Failed to select record device."));
                ;
            }
        }

        if (m_playoutSelectedMode == kDeviceDefault) {
            if (m_playoutDevices.size() > 0) {
                auto deviceInfo = m_playoutDevices.at(0);
                deviceInfo.selectedDevice = true;
                QByteArray byteDevicePath = deviceInfo.devicePath.toUtf8();
                m_playoutDevices.replace(0, deviceInfo);
                if (audioController->selectPlayoutDevice(byteDevicePath.data()) == kNENoError) {
                    if (deviceInfo.deviceName != m_lastSelectedPlayout.deviceName && deviceInfo.devicePath != m_lastSelectedPlayout.devicePath)
                        emit playoutDeviceChangedNotify(deviceInfo.deviceName, deviceInfo.devicePath);
                    m_lastSelectedPlayout = deviceInfo;
                    YXLOG(Info) << "[DeviceManager] Select " << byteDevicePath.data() << " as default playout device, index: " << 0 << YXLOGEnd;
                } else {
                    YXLOG(Error) << "Failed to select playout device, device ID: " << byteDevicePath.data() << YXLOGEnd;
                    emit error(0, tr("Failed to select playout device."));
                    ;
                }
            }
        }
    }

    // 视频设备没有默认设备的概念，所以这里要减去默认设备的索引站位
    auto captureDeviceIndex = selectedIndex == -1 ? 0 : selectedIndex;
    if (deviceType == DeviceTypeCapture && m_captureDevices.size() > 0 && captureDeviceIndex <= m_captureDevices.size() - 1) {
        auto deviceInfo = m_captureDevices.at(captureDeviceIndex);
        deviceInfo.selectedDevice = true;
        QByteArray byteDevicePath = deviceInfo.devicePath.toUtf8();
        m_captureDevices.replace(captureDeviceIndex, deviceInfo);
        if (videoController->selectCameraDevice(byteDevicePath.data()) == kNENoError) {
            if (deviceInfo.deviceName != m_lastSelectedCapture.deviceName && deviceInfo.devicePath != m_lastSelectedCapture.devicePath)
                emit captureDeviceChangedNotify(deviceInfo.deviceName, deviceInfo.devicePath);
            m_lastSelectedCapture = deviceInfo;
            YXLOG(Info) << "[DeviceManager] Select " << byteDevicePath.data() << " as default video device, index: " << captureDeviceIndex
                        << YXLOGEnd;
        } else {
            YXLOG(Error) << "Failed to select capture device, device ID: " << byteDevicePath.data() << YXLOGEnd;
            emit error(0, tr("Failed to select capture device."));
            ;
        }
    }

    return true;
}
