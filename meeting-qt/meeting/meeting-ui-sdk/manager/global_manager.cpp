// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "global_manager.h"
#include <QFile>
#include <QGuiApplication>
#include "meeting/audio_manager.h"
#include "meeting/members_manager.h"
#include "meeting/video_manager.h"
#include "modules/http/http_request.h"
#include "pre_meeting_manager.h"
#include "settings_manager.h"
#include "utils/invoker.h"

extern std::unordered_map<NEMeetingLanguage, std::string> g_languageMap;

GlobalManager::GlobalManager() {}

GlobalManager::~GlobalManager() {}

bool GlobalManager::initialize(const QString& appKey,
                               bool bPrivate,
                               const QString& serverUrl,
                               const QString& deviceId,
                               const NEConfigCallback& callback) {
    m_roomkitService = createNERoomKit();
    if (m_roomkitService == nullptr) {
        YXLOG(Error) << "initialize, createNERoomKit failed" << YXLOGEnd;
        callback(-1, "createNERoomKit failed");
        return false;
    }

    for (auto& it : g_languageMap) {
        if (it.second == m_language) {
            m_roomkitService->switchLanguage((NERoomLanguage)it.first);
        }
    }

    setGlobalAppKey(appKey);
    m_serverUrl = serverUrl;
    if (bPrivate) {
        initPrivate();
    }
    m_configController = std::make_shared<NEConfigController>();
    m_configController->getMeetingConfig([this, appKey, callback, bPrivate, serverUrl](int code, const QString& msg) {
        if (0 == code) {
            m_messageListener = new NEMessageListener;
            auto logPath = qApp->property("logPath").toString();
            auto logLevel = qApp->property("logLevel").toInt();
            if (logPath.isEmpty())
                logPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
            QDir sdkLogDir;
            if (!sdkLogDir.exists(logPath))
                sdkLogDir.mkpath(logPath);
            sdkLogDir.setPath(logPath);
            QByteArray byteLogDir = sdkLogDir.absolutePath().toUtf8();
            QByteArray byteAppKey = appKey.toUtf8();

            NERoomKitOptions options;
            options.appKey = byteAppKey.toStdString();
            options.logPath = byteLogDir.toStdString();
            options.logLevel = (neroom::NELogLevel)ConfigManager::getInstance()->getValue("localLogLevel", logLevel).toInt();
            options.useAssetServerConfig = bPrivate;
            options.serverUrl = serverUrl.toStdString();
            options.serverConfig.roomKitServerConfig.roomServer =
                ConfigManager::getInstance()->getValue("localServerAddressEx", LOCAL_DEFAULT_SERVER_ADDRESS).toString().toStdString();
            m_roomkitService->initialize(options, [this, callback](int code, const std::string& msg) {
                if (code == 0) {
                    //            auto version = m_globalService->getSdkVersions();
                    //            YXLOG(Info) << "version: " << version.roomKitVersion << version.imVersion << version.rtcVersion <<
                    //            version.whiteboardVersion
                    //            << YXLOGEnd;

                    auto messageService = m_roomkitService->getMessageChannelService();
                    messageService->addMessageChannelListener(m_messageListener);
                    SettingsManager::getInstance()->setAudioDeviceAutoSelectType(SettingsManager::getInstance()->audioDeviceAutoSelectType());
                }
                if (callback)
                    callback(code, QString::fromStdString(msg));
            });
        } else {
            if (callback)
                callback(code, msg);
        }
    });

    return true;
}

void GlobalManager::release() {
    m_pPreviewRoomContext = nullptr;
    if (m_messageListener) {
        auto messageService = m_roomkitService->getMessageChannelService();
        if (messageService) {
            messageService->removeMessageChannelListener(m_messageListener);
        }
        delete m_messageListener;
        m_messageListener = nullptr;
    }
    m_roomkitService->release();
    destroyNERoomKit();
    m_roomkitService = nullptr;
}

neroom::NESDKVersions GlobalManager::getVersions() const {
    static neroom::NESDKVersions version = neroom::NESDKVersions();
    if (m_roomkitService) {
        version = m_roomkitService->getSdkVersions();
    }
    return version;
}

INEAuthService* GlobalManager::getAuthService() {
    if (!m_roomkitService) {
        return nullptr;
    }
    return m_roomkitService->getAuthService();
}

INERoomService* GlobalManager::getRoomService() {
    if (!m_roomkitService) {
        return nullptr;
    }
    return m_roomkitService->getRoomService();
}

INEMessageChannelService* GlobalManager::getMessageService() {
    if (!m_roomkitService) {
        return nullptr;
    }
    return m_roomkitService->getMessageChannelService();
}

INENosService* GlobalManager::getNosService() {
    if (!m_roomkitService) {
        return nullptr;
    }
    return m_roomkitService->getNosService();
}

INEPreviewRoomContext* GlobalManager::getPreviewRoomContext() {
    if (!m_roomkitService || !m_roomkitService->isInitialized()) {
        return nullptr;
    }

    if (!m_pPreviewRoomContext) {
        bool bRet = false;
        getRoomService()->previewRoom(NEPreviewRoomParams(), NEPreviewRoomOptions(),
                                      [this, &bRet](int errorCode, const std::string& errorMsg, const INEPreviewRoomContext& context) {
                                          m_pPreviewRoomContext = const_cast<INEPreviewRoomContext*>(&context);
                                          bRet = true;
                                      });

        while (!bRet) {
            std::this_thread::yield();
        }
    }

    return m_pPreviewRoomContext;
}

INEPreviewRoomRtcController* GlobalManager::getPreviewRoomRtcController() {
    INEPreviewRoomRtcController* pPreviewRoomRtcController = nullptr;
    auto previewRoomContext = getPreviewRoomContext();
    if (previewRoomContext) {
        pPreviewRoomRtcController = previewRoomContext->getPreviewRoomRtcController();
    }

    return pPreviewRoomRtcController;
}

std::shared_ptr<NEConfigController> GlobalManager::getGlobalConfig() {
    return m_configController;
}

void GlobalManager::showSettingsWnd() {
    emit showSettingsWindow();
}

QString GlobalManager::globalAppKey() const {
    return m_globalAppKey;
}

void GlobalManager::setGlobalAppKey(const QString& globalAppKey) {
    m_globalAppKey = globalAppKey;
}

void GlobalManager::initPrivate() {
    QString privateFile = qApp->applicationDirPath() + "/xkit_server.config";
#ifdef Q_OS_MACX
    if (!QFile::exists(privateFile)) {
        // YXLOG(Warn) << "privateFile not exists: " << privateFile.toStdString() << YXLOGEnd;
        privateFile = qApp->applicationDirPath() + "/../Resources/xkit_server.config";
    }
    if (!QFile::exists(privateFile)) {
        // YXLOG(Warn) << "privateFile not exists: " << privateFile.toStdString() << YXLOGEnd;
        privateFile = qApp->applicationDirPath() + "/../../../xkit_server.config";
    }
#endif

    QFile file(privateFile);
    if (!file.open(QIODevice::ReadOnly)) {
        YXLOG(Error) << "initPrivateConfig open failed, privateFile: " << privateFile.toStdString() << ", error: " << file.errorString().toStdString()
                     << YXLOGEnd;
        return;
    }
    QJsonParseError error;
    QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error == QJsonParseError::NoError) {
        QJsonObject config = document.object();
        if (config.contains("meeting")) {
            auto meeting = config["meeting"].toObject();
            if (meeting.contains("serverUrl")) {
                m_serverUrl = meeting["serverUrl"].toString();
                if (!m_serverUrl.endsWith("/")) {
                    m_serverUrl.append("/");
                }
            }
        }
    } else {
        YXLOG(Error) << "initPrivateConfig failed, error: " << error.errorString().toStdString() << YXLOGEnd;
    }
    file.close();
}

void GlobalManager::dealMeetingStatusChanged(const QJsonObject& data) {
    int64_t meetingId = 0;
    int state = 0;
    if (data.contains("meetingId")) {
        meetingId = data["meetingId"].toVariant().toLongLong();
    }
    if (data.contains("state")) {
        state = data["state"].toInt();
    }

    PreMeetingManager::getInstance()->onScheduleRoomStatusChanged(meetingId, state);
}

void GlobalManager::dealAudioOpenRequest() {
    if (MeetingManager::getInstance()->getRoomStatus() == NEMeeting::MEETING_CONNECTED ||
        MeetingManager::getInstance()->getRoomStatus() == NEMeeting::MEETING_RECONNECTED) {
        if (MembersManager::getInstance()->handsUpStatus()) {
            MembersManager::getInstance()->handsUp(false);
            AudioManager::getInstance()->muteLocalAudio(false);
        } else {
            if (AudioManager::getInstance()->localAudioStatus() != NEMeeting::DEVICE_ENABLED) {
                AudioManager::getInstance()->onUserAudioStatusChanged(AuthManager::getInstance()->getAuthInfo().accountId,
                                                                      NEMeeting::DEVICE_NEEDS_TO_CONFIRM);
            }
        }
    }
}

void GlobalManager::dealVideoOpenRequest() {
    if (MeetingManager::getInstance()->getRoomStatus() == NEMeeting::MEETING_CONNECTED ||
        MeetingManager::getInstance()->getRoomStatus() == NEMeeting::MEETING_RECONNECTED) {
        if (MembersManager::getInstance()->handsUpStatus()) {
            MembersManager::getInstance()->handsUp(false);
        }
        if (VideoManager::getInstance()->localVideoStatus() != NEMeeting::DEVICE_ENABLED) {
            VideoManager::getInstance()->onUserVideoStatusChanged(AuthManager::getInstance()->getAuthInfo().accountId,
                                                                  NEMeeting::DEVICE_NEEDS_TO_CONFIRM);
        }
    }
}

void GlobalManager::dealMessage(const std::string& data) {
    YXLOG(Info) << "dealMessage, data: " << data << YXLOGEnd;
    QString jsonString = QString::fromStdString(data);
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError)
        return;

    auto dataObj = doc.object();
    if (dataObj.contains("type")) {
        int type = dataObj["type"].toInt();
        if (type == 100) {
            if (dataObj.contains("meetingType")) {
                NEMeetingType meetingType = static_cast<NEMeetingType>(dataObj["meetingType"].toInt());
                if (meetingType == schduleType) {
                    dealMeetingStatusChanged(dataObj);
                }
            }
        } else if (type == 101) {
            dealMeetingStatusChanged(dataObj);
        } else if (type == 1) {
            dealAudioOpenRequest();
        } else if (type == 2) {
            dealVideoOpenRequest();
        } else if (type == 3) {
            dealAudioOpenRequest();
            dealVideoOpenRequest();
        } else if (type == 200) {
            // 账号注销、违规
            emit AuthManager::getInstance()->authInfoExpired();
        }
    }
}

void NEMessageListener::onReceiveCustomMessage(const NECustomMessage& message) {
    Invoker::getInstance()->execute([message]() {
        if (message.commandId == 99 || message.commandId == 98) {
            GlobalManager::getInstance()->dealMessage(message.data);
        }
    });
}
