// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nemeeting_manager.h"
#include <QDebug>
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QUrl>
#include <future>
#include <iostream>

NEMeetingManager::NEMeetingManager(QObject* parent)
    : QObject(parent)
    , m_initialized(false)
    , m_initSuc(true) {
    // connect(this, &NEMeetingManager::unInitializeSignal, this, []() { qApp->exit(); });
    connect(this, &NEMeetingManager::initializeSignal, this, [this](int errorCode, const QString& errorMessage) {
        if (0 == errorCode) {
            NEMeetingKit::getInstance()->getSettingsService()->GetAudioController()->isTurnOnMyAudioAINSWhenInMeetingEnabled(
                [this](NEErrorCode errorCode, const std::string& errorMessage, const bool bEnable) {
                    qInfo() << "isTurnOnMyAudioAINSWhenInMeetingEnabled callback, error code: " << errorCode
                            << ", error message: " << QString::fromStdString(errorMessage) << ", bEnable: " << bEnable;
                    if (0 != errorCode)
                        return;
                    if (bEnable != m_bAudioAINS) {
                        m_bAudioAINS = bEnable;
                        Q_EMIT isAudioAINSChanged();
                    }
                });

            NEMeetingKit::getInstance()->getSettingsService()->GetAudioController()->isMyAudioDeviceAutoSelectType(
                [this](NEErrorCode errorCode, const std::string& errorMessage, const AudioDeviceAutoSelectType type) {
                    qInfo() << "isMyAudioDeviceAutoSelectType callback, error code: " << errorCode
                            << ", error message: " << QString::fromStdString(errorMessage) << ", type: " << type;
                    if (0 != errorCode)
                        return;
                    bool btype = AudioDeviceAutoSelectType_Available == type;
                    if (btype != m_audodeviceAutoSelectType) {
                        m_audodeviceAutoSelectType = btype;
                        Q_EMIT audodeviceAutoSelectTypeChanged(m_audodeviceAutoSelectType);
                    }

                    [[maybe_unused]] auto tmp = std::async(std::launch::async, [this]() {
                        NEMeetingKit::getInstance()->getSettingsService()->GetVirtualBackgroundController()->isVirtualBackgroundEnabled(
                            [this](NEErrorCode errorCode, const std::string& errorMessage, const bool& virtualBackground) {
                                qInfo() << "isVirtualBackgroundEnabled callback, error code: " << errorCode
                                        << ", error message: " << QString::fromStdString(errorMessage);
                                if (ERROR_CODE_SUCCESS == errorCode) {
                                    m_virtualBackground = virtualBackground;
                                    emit virtualBackgroundChanged(m_virtualBackground);
                                } else {
                                    emit error(errorCode, QString::fromStdString(errorMessage));
                                }
                            });
                    });

                    std::thread tmp1([=]() {
                        NEMeetingKit::getInstance()->getSettingsService()->GetBeautyFaceController()->isBeautyFaceEnabled(
                            [=](NEErrorCode errorCode, const std::string& errorMessage, const bool& enabled) {
                                qInfo() << "isBeautyFaceEnabled callback, error code: " << errorCode
                                        << ", error message: " << QString::fromStdString(errorMessage) << ", enabled: " << enabled;
                                if (ERROR_CODE_SUCCESS == errorCode) {
                                    m_beauty = enabled;
                                    emit beautyChanged(m_beauty);
                                } else {
                                    emit error(errorCode, QString::fromStdString(errorMessage));
                                }
                            });
                    });
                    tmp1.detach();
                    std::thread tmp2([=]() {
                        NEMeetingKit::getInstance()->getSettingsService()->GetBeautyFaceController()->getBeautyFaceValue(
                            [this](NEErrorCode errorCode, const std::string& errorMessage, const int& beautyValue) {
                                qInfo() << "getBeautyFaceValue callback, error code: " << errorCode
                                        << ", error message: " << QString::fromStdString(errorMessage) << ", beautyValue: " << beautyValue;
                                if (ERROR_CODE_SUCCESS == errorCode) {
                                    m_beautyValue = beautyValue;
                                    emit beautyValueChanged(m_beautyValue);
                                } else {
                                    emit error(errorCode, QString::fromStdString(errorMessage));
                                }
                            });
                    });
                    tmp2.detach();
                });
        }
    });

#ifdef Q_OS_WIN32
    NEMeetingKit::getInstance()->isSoftwareRender([this](int errorCode, const std::string& errorMessage, const bool& bSoftware) {
        qInfo() << "isSoftwareRender callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage)
                << ", bSoftware: " << bSoftware;
        if (0 == errorCode) {
            if (m_softwareRender != bSoftware) {
                m_softwareRender = bSoftware;
                Q_EMIT softwareRenderChanged(m_softwareRender);
            }
        }
    });
#endif
}

void NEMeetingManager::initializeParam(const QString& strSdkLogPath, int sdkLogLevel, bool bRunAdmin, bool bPrivate) {
    m_strSdkLogPath = strSdkLogPath;
    m_sdkLogLevel = sdkLogLevel;
    m_bRunAdmin = bRunAdmin;
    m_bPrivate = bPrivate;
}

void NEMeetingManager::initialize(const QString& strAppkey, [[maybe_unused]] int keepAliveInterval) {
    unInitialize();
    if (m_initialized) {
        emit initializeSignal(0, "");
        return;
    }

    m_initSuc = true;
    NEMeetingKitConfig config;
    QString displayName = QObject::tr("NetEase Meeting");
    QByteArray byteDisplayName = displayName.toUtf8();
    config.getAppInfo()->ProductName(byteDisplayName.data());
    config.getAppInfo()->OrganizationName("NetEase");
    config.getAppInfo()->ApplicationName("MeetingSample");
    config.setDomain("yunxin.163.com");
    config.setAppKey(strAppkey.toStdString());
#ifdef _DEBUG
    config.setKeepAliveInterval(-1);
#else
    if (13566 != keepAliveInterval) {
        config.setKeepAliveInterval(keepAliveInterval);
    }
#endif

    config.getLoggerConfig()->LoggerPath(m_strSdkLogPath.toStdString());
    config.getLoggerConfig()->LoggerLevel((NELogLevel)m_sdkLogLevel);
    config.setRunAdmin(m_bRunAdmin);
    config.setUseAssetServerConfig(m_bPrivate);

    auto pMeetingSDK = NEMeetingKit::getInstance();
    // level value: DEBUG = 0, INFO = 1, WARNING=2, ERROR=3, FATAL=4
    pMeetingSDK->setLogHandler([](int level, const std::string& log) {
        switch (level) {
            case 0:
                qDebug() << log.c_str();
                break;
            case 1:
                qInfo() << log.c_str();
                break;
            case 2:
                qWarning() << log.c_str();
                break;
            case 3:
                qCritical() << log.c_str();
                break;
            case 4:
                qFatal("%s", log.c_str());
                break;
            default:
                qInfo() << log.c_str();
        }
    });
    pMeetingSDK->initialize(config, [this](NEErrorCode errorCode, const std::string& errorMessage) {
        qInfo() << "Initialize callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
        if (ERROR_CODE_FAILED != errorCode) {
            auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
            if (ipcMeetingService) {
                ipcMeetingService->addMeetingStatusListener(this);
                ipcMeetingService->setOnInjectedMenuItemClickListener(this);
            }
            auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
            if (ipcPreMeetingService) {
                ipcPreMeetingService->registerScheduleMeetingStatusListener(this);
            }
            auto settingsService = NEMeetingKit::getInstance()->getSettingsService();
            if (settingsService) {
                settingsService->setNESettingsChangeNotifyHandler(this);
            }

            auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
            if (ipcAuthService) {
                ipcAuthService->addAuthListener(this);
            }

            NEMeetingKit::getInstance()->queryKitVersion(
                []([[maybe_unused]] NEErrorCode errorCode, [[maybe_unused]] const std::string& errorMessage, const std::string& version) {
                    qInfo() << "sdk version: " << QString::fromStdString(version);
                });
            m_initialized = true;
        }
        m_initSuc = ERROR_CODE_SUCCESS == errorCode;
        emit initializeSignal(errorCode, QString::fromStdString(errorMessage));
    });
}

void NEMeetingManager::unInitialize() {
    qInfo() << "Do uninitialize, initialize flag: " << m_initialized;

    if (!m_initialized) {
        emit unInitializeSignal(ERROR_CODE_SUCCESS, "");
        qInfo() << "Uninitialized successfull";
        return;
    }

    NEMeetingKit::getInstance()->setExceptionHandler(nullptr);
    NEMeetingKit::getInstance()->unInitialize([&](NEErrorCode errorCode, const std::string& errorMessage) {
        qInfo() << "Uninitialize callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
        m_initialized = false;
        emit unInitializeSignal(errorCode, QString::fromStdString(errorMessage));
        qInfo() << "Uninitialized successfull";
    });
}

bool NEMeetingManager::isInitializd() {
    return NEMeetingKit::getInstance()->isInitialized();
}

void NEMeetingManager::login(const QString& appKey, const QString& accountId, const QString& accountToken, int keepAliveInterval) {
    qInfo() << "Login to apaas server, appkey: " << appKey << ", account ID: " << accountId << ", token: " << accountToken
            << ", keepAliveInterval: " << keepAliveInterval;

    initialize(appKey, keepAliveInterval);
    QElapsedTimer time;
    time.start();
    while (!m_initialized) {
        if (!m_initSuc)
            return;
        if (time.elapsed() > 30 * 1000) {
            m_initialized = true;
            emit loginSignal(-1, tr("Initialization timeout"));
            return;
        }
        std::this_thread::yield();
    }

    std::this_thread::sleep_for(std::chrono::seconds(1));
    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
    if (ipcAuthService) {
        QByteArray byteAppKey = appKey.toUtf8();
        QByteArray byteAccountId = accountId.toUtf8();
        QByteArray byteAccountToken = accountToken.toUtf8();
        ipcAuthService->login(
            byteAppKey.data(), byteAccountId.data(), byteAccountToken.data(), [this](NEErrorCode errorCode, const std::string& errorMessage) {
                qInfo() << "Login callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
                emit loginSignal(errorCode, QString::fromStdString(errorMessage));
            });
    }
}

void NEMeetingManager::loginByUsernamePassword(const QString& appKey, const QString& userName, const QString& password, int keepAliveInterval) {
    qInfo() << "Login to apaas server, appkey: " << appKey << ", userName: " << userName << ", password: " << password
            << ", keepAliveInterval: " << keepAliveInterval;

    initialize(appKey, keepAliveInterval);
    QElapsedTimer time;
    time.start();
    while (!m_initialized) {
        if (!m_initSuc)
            return;
        if (time.elapsed() > 30 * 1000) {
            m_initialized = true;
            emit loginSignal(-1, tr("Initialization timeout"));
            return;
        }
        std::this_thread::yield();
    }

    std::this_thread::sleep_for(std::chrono::seconds(1));
    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->loginWithNEMeeting(
            userName.toUtf8().data(), password.toUtf8().data(), [this](NEErrorCode errorCode, const std::string& errorMessage) {
                qInfo() << "Login callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
                emit loginSignal(errorCode, QString::fromStdString(errorMessage));
            });
    }
}

void NEMeetingManager::getAccountInfo() {
    qInfo() << "getAccountInfo";
    while (!m_initialized) {
        if (!m_initSuc)
            return;
        std::this_thread::yield();
    }
    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->getAccountInfo([=](NEErrorCode errorCode, const std::string& errorMessage, const AccountInfo& authInfo) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                setPersonalMeetingId(QString::fromStdString(authInfo.personalMeetingId));
            }
        });
    }
}

void NEMeetingManager::logout() {
    qInfo() << "logout";

    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->logout(true, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Logout callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit logoutSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::showSettings() {
    qInfo() << "showSettings";

    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->showSettingUIWnd(NESettingsUIWndConfig(), [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Show settings wnd callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit showSettingsSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::scheduleMeeting(const QString& meetingSubject,
                                       qint64 startTime,
                                       qint64 endTime,
                                       const QString& password,
                                       const QString& textScene,
                                       bool attendeeAudioOff,
                                       bool enableLive,
                                       bool enableSip,
                                       bool needLiveAuthentication,
                                       bool enableRecord,
                                       const QString& extraData,
                                       const QJsonArray& controls,
                                       const QString& strRoleBinds) {
    qInfo() << "scheduleMeeting: "
            << "controls " << controls << ", strRoleBinds " << strRoleBinds;

    QString strPassword = password.isEmpty() ? "null" : "no null";
    while (!m_initialized) {
        if (!m_initSuc)
            return;
        std::this_thread::yield();
    }
    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        NEMeetingItem item;
        item.subject = meetingSubject.toUtf8().data();
        item.startTime = startTime;
        item.endTime = endTime;
        item.password = password.toUtf8().data();
        item.setting.attendeeAudioOff = attendeeAudioOff;
        item.enableLive = enableLive;
        item.liveWebAccessControlLevel = needLiveAuthentication ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_TOKEN;
        item.setting.cloudRecordOn = enableRecord;
        item.extraData = extraData.toStdString();
        item.noSip = !enableSip;

        for (auto it : controls) {
            QJsonObject obj = it.toObject();
            NEMeetingControl control;

            if (obj["attendeeOff"].toBool()) {
                if (obj["allowSelfOn"].toBool()) {
                    control.attendeeOff = kAttendeeOffAllowSelfOn;
                } else {
                    control.attendeeOff = kAttendeeOffNotAllowSelfOn;
                }
            } else {
                control.attendeeOff = kAttendeeOffNone;
            }

            control.type = static_cast<NEControlType>(obj["type"].toInt());
            item.setting.controls.push_back(control);
        }

        if (!textScene.isEmpty()) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(textScene.toUtf8(), &err);
            if (err.error != QJsonParseError::NoError) {
                emit error(-1, "error scene");
                return;
            }

            QJsonArray array = doc.array();

            for (int i = 0; i < array.size(); i++) {
                QJsonObject obj = array[i].toObject();

                NEMeetingRoleConfiguration config;
                config.maxCount = obj["maxCount"].toInt();
                config.roleType = (NEMeetingRoleType)obj["roleType"].toInt();

                QJsonArray users = obj["userList"].toArray();

                for (auto user : users) {
                    std::string userId = user.toString().toStdString();
                    config.userList.push_back(userId);
                }

                item.setting.scene.roleTypes.push_back(config);
            }
        }

        if (!strRoleBinds.isEmpty()) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(strRoleBinds.toUtf8(), &err);
            if (err.error != QJsonParseError::NoError) {
                emit error(-1, "error roleBinds");
                return;
            }

            QJsonObject roleBindsObj = doc.object();
            QJsonObject* pRoleBindsObj = reinterpret_cast<QJsonObject*>(&roleBindsObj);
            QJsonObject::const_iterator it = pRoleBindsObj->constBegin();
            QJsonObject::const_iterator end = pRoleBindsObj->constEnd();
            while (it != end) {
                auto key = it.key().toStdString();
                auto value = static_cast<NEMeetingRoleType>(it.value().toInt());
                item.roleBinds[key] = value;
                qInfo() << "key: " << QString::fromStdString(key);
                qInfo() << "value: " << value;
                it++;
            }
        }

        ipcPreMeetingService->scheduleMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage, const NEMeetingItem& item) {
            qInfo() << "Schedule meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit scheduleSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::cancelMeeting(const qint64& meetingUniqueId) {
    qInfo() << "cancel a meeting with meeting uniqueId:" << meetingUniqueId;
    while (!m_initialized) {
        if (!m_initSuc)
            return;
        std::this_thread::yield();
    }
    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        ipcPreMeetingService->cancelMeeting(meetingUniqueId, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Cancel meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit cancelSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::editMeeting(const qint64& meetingUniqueId,
                                   const QString& meetingId,
                                   const QString& meetingSubject,
                                   qint64 startTime,
                                   qint64 endTime,
                                   const QString& password,
                                   const QString& textScene,
                                   bool attendeeAudioOff,
                                   bool enableLive,
                                   bool enableSip,
                                   bool needLiveAuthentication,
                                   bool enableRecord,
                                   const QString& extraData,
                                   const QJsonArray& controls,
                                   const QString& strRoleBinds) {
    QString strPassword = password.isEmpty() ? "null" : "no null";
    qInfo() << "Edit a meeting with meeting subject:" << meetingSubject << ", meetingUniqueId: " << meetingUniqueId << ", meetingId: " << meetingId
            << ", startTime: " << startTime << ", endTime: " << endTime << ", attendeeAudioOff: " << attendeeAudioOff << ", password: " << strPassword
            << ", textScene: " << textScene << ", strRoleBinds " << strRoleBinds;

    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        NEMeetingItem item;
        item.meetingUniqueId = meetingUniqueId;
        item.meetingId = meetingId.toUtf8().data();
        item.subject = meetingSubject.toUtf8().data();
        item.startTime = startTime;
        item.endTime = endTime;
        item.password = password.toUtf8().data();
        item.setting.attendeeAudioOff = attendeeAudioOff;
        item.enableLive = enableLive;
        item.liveWebAccessControlLevel = needLiveAuthentication ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_TOKEN;
        item.setting.cloudRecordOn = enableRecord;
        item.extraData = extraData.toStdString();
        item.noSip = !enableSip;
        for (auto it : controls) {
            QJsonObject obj = it.toObject();
            NEMeetingControl control;

            if (obj["attendeeOff"].toBool()) {
                if (obj["allowSelfOn"].toBool()) {
                    control.attendeeOff = kAttendeeOffAllowSelfOn;
                } else {
                    control.attendeeOff = kAttendeeOffNotAllowSelfOn;
                }
            } else {
                control.attendeeOff = kAttendeeOffNone;
            }

            control.type = static_cast<NEControlType>(obj["type"].toInt());
            item.setting.controls.push_back(control);
        }

        if (!textScene.isEmpty()) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(textScene.toUtf8(), &err);
            if (err.error != QJsonParseError::NoError) {
                emit error(-1, "error scene");
                return;
            }

            QJsonArray array = doc.array();

            for (int i = 0; i < array.size(); i++) {
                QJsonObject obj = array[i].toObject();

                NEMeetingRoleConfiguration config;
                config.maxCount = obj["maxCount"].toInt();
                config.roleType = (NEMeetingRoleType)obj["roleType"].toInt();

                QJsonArray users = obj["userList"].toArray();

                for (auto user : users) {
                    std::string userId = user.toString().toStdString();
                    config.userList.push_back(userId);
                }

                item.setting.scene.roleTypes.push_back(config);
            }
        }

        if (!strRoleBinds.isEmpty()) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(strRoleBinds.toUtf8(), &err);
            if (err.error != QJsonParseError::NoError) {
                emit error(-1, "error roleBinds");
                return;
            }

            QJsonObject roleBindsObj = doc.object();
            QJsonObject* pRoleBindsObj = reinterpret_cast<QJsonObject*>(&roleBindsObj);
            QJsonObject::const_iterator it = pRoleBindsObj->constBegin();
            QJsonObject::const_iterator end = pRoleBindsObj->constEnd();
            while (it != end) {
                auto key = it.key().toStdString();
                auto value = static_cast<NEMeetingRoleType>(it.value().toInt());
                item.roleBinds[key] = value;
                qInfo() << "key: " << QString::fromStdString(key);
                qInfo() << "value: " << value;
                it++;
            }
        }

        ipcPreMeetingService->editMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Edit meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit editSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::getMeetingList() {
    qInfo() << "Get meeting list from IPC client.";

    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        std::list<NEMeetingItemStatus> status;
        status.push_back(MEETING_INIT);
        status.push_back(MEETING_STARTED);
        status.push_back(MEETING_ENDED);
        ipcPreMeetingService->getMeetingList(
            status, [this](NEErrorCode errorCode, const std::string& errorMessage, std::list<NEMeetingItem>& meetingItems) {
                qInfo() << "GetMeetingList callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
                QJsonArray jsonArray;
                if (errorCode == ERROR_CODE_SUCCESS) {
                    for (auto& item : meetingItems) {
                        qInfo() << "Got meeting list, unique meeting ID: " << item.meetingUniqueId
                                << ", meeting ID: " << QString::fromStdString(item.meetingId) << ", topic: " << QString::fromStdString(item.subject)
                                << ", start time: " << item.startTime << ", end time: " << item.endTime << ", create time: " << item.createTime
                                << ", update time: " << item.updateTime << ", status: " << item.status
                                << ", mute after member join: " << item.setting.attendeeAudioOff
                                << ", extraData: " << QString::fromStdString(item.extraData) << ", controls:" << item.setting.controls.size();
                        QJsonObject object;
                        object["uniqueMeetingId"] = item.meetingUniqueId;
                        object["meetingId"] = QString::fromStdString(item.meetingId);
                        object["topic"] = QString::fromStdString(item.subject);
                        object["startTime"] = item.startTime;
                        object["endTime"] = item.endTime;
                        object["createTime"] = item.createTime;
                        object["updateTime"] = item.updateTime;
                        object["status"] = item.status;
                        object["password"] = QString::fromStdString(item.password);
                        object["attendeeAudioOff"] = item.setting.attendeeAudioOff;
                        object["enableLive"] = item.enableLive;
                        object["liveAccess"] = item.liveWebAccessControlLevel == LIVE_ACCESS_APP_TOKEN;
                        object["liveUrl"] = QString::fromStdString(item.liveUrl);
                        object["recordEnable"] = item.setting.cloudRecordOn;
                        object["extraData"] = QString::fromStdString(item.extraData);
                        object["enableSip"] = !item.noSip;

                        for (auto it : item.setting.controls) {
                            QJsonObject obj;
                            if (it.attendeeOff == kAttendeeOffNone) {
                                obj["attendeeOff"] = false;
                                obj["allowSelfOn"] = false;
                            } else if (it.attendeeOff == kAttendeeOffAllowSelfOn) {
                                obj["attendeeOff"] = true;
                                obj["allowSelfOn"] = true;
                            } else if (it.attendeeOff == kAttendeeOffNotAllowSelfOn) {
                                obj["attendeeOff"] = true;
                                obj["allowSelfOn"] = false;
                            }
                            obj["type"] = it.type;
                            if (it.type == kControlTypeAudio) {
                                object["audioControl"] = obj;
                            } else if (it.type == kControlTypeVideo) {
                                object["videoControl"] = obj;
                            }

                            qInfo() << "obj:" << obj;
                        }

                        QJsonObject roleBindsObj;
                        qInfo() << "item.roleBinds: " << item.roleBinds.size();
                        for (auto iter = item.roleBinds.begin(); iter != item.roleBinds.end(); iter++) {
                            QString userId = QString::fromStdString(iter->first);
                            roleBindsObj[userId] = iter->second;
                            qInfo() << "userId111:" << userId;
                            qInfo() << "role111:" << iter->second;
                        }
                        object["roleBinds"] = QString(QJsonDocument(roleBindsObj).toJson());

                        jsonArray.push_back(object);
                    }
                    emit getScheduledMeetingList(errorCode, jsonArray);
                } else {
                    emit getScheduledMeetingList(errorCode, jsonArray);
                }
            });
    }
}

void NEMeetingManager::invokeStart(const QJsonObject& object) {
    QString meetingId;
    QString nickname;
    QString tag;
    QString textScene;
    QString password;
    int timeOut = 0;
    bool audio = false;
    bool video = false;
    bool enableChatroom = true;
    bool enableInvitation = true;
    bool enableScreenShare = true;
    bool enableView = true;
    bool autoOpenWhiteboard = false;
    bool rename = true;
    int displayOption = 0;
    bool enableRecord = false;
    bool openWhiteboard = false;
    bool audioAINS = true;
    bool sip = false;
    bool showMemberTag = false;
    QString extraData;
    QJsonArray controls;
    bool enableMuteAllVideo = false;
    bool enableMuteAllAudio = true;
    QString strRoleBinds;
    bool showRemainingTip = false;
    bool enableFileMessage = false;
    bool enableImageMessage = false;

    if (object.contains("meetingId")) {
        meetingId = object["meetingId"].toString();
    }
    if (object.contains("nickname")) {
        nickname = object["nickname"].toString();
    }
    if (object.contains("tag")) {
        tag = object["tag"].toString();
    }
    if (object.contains("textScene")) {
        textScene = object["textScene"].toString();
    }
    if (object.contains("password")) {
        password = object["password"].toString();
    }
    if (object.contains("timeOut")) {
        timeOut = object["timeOut"].toInt();
    }
    if (object.contains("audio")) {
        audio = object["audio"].toBool();
    }
    if (object.contains("video")) {
        video = object["video"].toBool();
    }
    if (object.contains("enableChatroom")) {
        enableChatroom = object["enableChatroom"].toBool();
    }
    if (object.contains("enableInvitation")) {
        enableInvitation = object["enableInvitation"].toBool();
    }
    if (object.contains("enableScreenShare")) {
        enableScreenShare = object["enableScreenShare"].toBool();
    }
    if (object.contains("enableView")) {
        enableView = object["enableView"].toBool();
    }
    if (object.contains("autoOpenWhiteboard")) {
        autoOpenWhiteboard = object["autoOpenWhiteboard"].toBool();
    }
    if (object.contains("openWhiteboard")) {
        openWhiteboard = object["openWhiteboard"].toBool();
    }
    if (object.contains("rename")) {
        rename = object["rename"].toBool();
    }
    if (object.contains("displayOption")) {
        displayOption = object["displayOption"].toInt();
    }
    if (object.contains("enableRecord")) {
        enableRecord = object["enableRecord"].toBool();
    }
    if (object.contains("audioAINS")) {
        audioAINS = object["audioAINS"].toBool();
    }
    if (object.contains("sip")) {
        sip = object["sip"].toBool();
    }
    if (object.contains("showMemberTag")) {
        showMemberTag = object["showMemberTag"].toBool();
    }
    if (object.contains("extraData")) {
        extraData = object["extraData"].toString();
    }
    if (object.contains("controls")) {
        controls = object["controls"].toArray();
    }
    if (object.contains("enableMuteAllVideo")) {
        enableMuteAllVideo = object["enableMuteAllVideo"].toBool();
    }
    if (object.contains("enableMuteAllAudio")) {
        enableMuteAllAudio = object["enableMuteAllAudio"].toBool();
    }
    if (object.contains("strRoleBinds")) {
        strRoleBinds = object["strRoleBinds"].toString();
    }
    if (object.contains("showRemainingTip")) {
        showRemainingTip = object["showRemainingTip"].toBool();
    }
    if (object.contains("enableFileMessage")) {
        enableFileMessage = object["enableFileMessage"].toBool();
    }
    if (object.contains("enableImageMessage")) {
        enableImageMessage = object["enableImageMessage"].toBool();
    }

    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        QByteArray byteMeetingId = meetingId.toUtf8();
        QByteArray byteNickname = nickname.toUtf8();

        NEStartMeetingParams params;
        params.meetingId = byteMeetingId.data();
        params.displayName = byteNickname.data();
        params.tag = tag.toStdString();
        params.password = password.toStdString();
        params.extraData = extraData.toStdString();

        for (auto it : controls) {
            QJsonObject obj = it.toObject();
            NEMeetingControl control;

            if (obj["attendeeOff"].toBool()) {
                if (obj["allowSelfOn"].toBool()) {
                    control.attendeeOff = kAttendeeOffAllowSelfOn;
                } else {
                    control.attendeeOff = kAttendeeOffNotAllowSelfOn;
                }
            } else {
                control.attendeeOff = kAttendeeOffNone;
            }

            control.type = static_cast<NEControlType>(obj["type"].toInt());
            params.controls.push_back(control);
        }

        if (!textScene.isEmpty()) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(textScene.toUtf8(), &err);
            if (err.error != QJsonParseError::NoError) {
                emit error(-1, "error scene");
                return;
            }

            QJsonArray array = doc.array();

            for (int i = 0; i < array.size(); i++) {
                QJsonObject obj = array[i].toObject();

                NEMeetingRoleConfiguration config;
                config.maxCount = obj["maxCount"].toInt();
                config.roleType = (NEMeetingRoleType)obj["roleType"].toInt();

                QJsonArray users = obj["userList"].toArray();

                for (const auto& user : qAsConst(users)) {
                    std::string userId = user.toString().toStdString();
                    config.userList.push_back(userId);
                }

                params.scene.roleTypes.push_back(config);
            }
        }

        if (!strRoleBinds.isEmpty()) {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(strRoleBinds.toUtf8(), &err);
            if (err.error != QJsonParseError::NoError) {
                emit error(-1, "error roleBinds");
                return;
            }

            QJsonObject roleBindsObj = doc.object();
            QJsonObject* pRoleBindsObj = reinterpret_cast<QJsonObject*>(&roleBindsObj);
            QJsonObject::const_iterator it = pRoleBindsObj->constBegin();
            QJsonObject::const_iterator end = pRoleBindsObj->constEnd();
            while (it != end) {
                auto key = it.key().toStdString();
                auto value = static_cast<NEMeetingRoleType>(it.value().toInt());
                params.roleBinds[key] = value;
                qInfo() << "key: " << QString::fromStdString(key);
                qInfo() << "value: " << value;
                it++;
            }
        }

        NEStartMeetingOptions options;
        options.noAudio = !audio;
        options.noVideo = !video;
        options.noChat = !enableChatroom;
        options.noInvite = !enableInvitation;
        options.noRename = !rename;
        options.noWhiteboard = !openWhiteboard;
        options.noScreenShare = enableScreenShare;
        options.noView = enableView;
        options.audioAINSEnabled = audioAINS;
        options.showMemberTag = showMemberTag;
        options.noSip = !sip;
        options.noMuteAllVideo = !enableMuteAllVideo;
        options.noMuteAllAudio = !enableMuteAllAudio;
        if (autoOpenWhiteboard) {
            options.defaultWindowMode = WHITEBOARD_MODE;
        }

        options.noCloudRecord = !enableRecord;
        options.meetingIdDisplayOption = (NEShowMeetingIdOption)displayOption;
        options.joinTimeout = timeOut;
        options.showMeetingRemainingTip = showRemainingTip;
        options.chatroomConfig.enableFileMessage = enableFileMessage;
        options.chatroomConfig.enableImageMessage = enableImageMessage;

        // pushSubmenus(options.full_more_menu_items_, kFirstinjectedMenuId);
        ipcMeetingService->startMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Start meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit startSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::invokeJoin(const QJsonObject& object) {
    bool anonymous = false;
    QString meetingId;
    QString nickname;
    QString tag;
    QString password;
    int timeOut = 0;
    bool audio = false;
    bool video = false;
    bool enableChatroom = true;
    bool enableInvitation = true;
    bool enableScreenShare = true;
    bool enableView = true;
    bool autoOpenWhiteboard = false;
    bool rename = true;
    int displayOption = 0;
    bool enableRecord = false;
    bool openWhiteboard = false;
    bool audioAINS = true;
    bool sip = false;
    bool showMemberTag = false;
    bool enableMuteAllVideo = false;
    bool enableMuteAllAudio = true;
    bool showRemainingTip = false;
    bool enableFileMessage = false;
    bool enableImageMessage = false;

    if (object.contains("anonymous")) {
        anonymous = object["anonymous"].toBool();
    }

    if (object.contains("meetingId")) {
        meetingId = object["meetingId"].toString();
    }
    if (object.contains("nickname")) {
        nickname = object["nickname"].toString();
    }
    if (object.contains("tag")) {
        tag = object["tag"].toString();
    }
    if (object.contains("password")) {
        password = object["password"].toString();
    }
    if (object.contains("timeOut")) {
        timeOut = object["timeOut"].toInt();
    }
    if (object.contains("audio")) {
        audio = object["audio"].toBool();
    }
    if (object.contains("video")) {
        video = object["video"].toBool();
    }
    if (object.contains("enableChatroom")) {
        enableChatroom = object["enableChatroom"].toBool();
    }
    if (object.contains("enableInvitation")) {
        enableInvitation = object["enableInvitation"].toBool();
    }
    if (object.contains("enableScreenShare")) {
        enableScreenShare = object["enableScreenShare"].toBool();
    }
    if (object.contains("enableView")) {
        enableView = object["enableView"].toBool();
    }
    if (object.contains("autoOpenWhiteboard")) {
        autoOpenWhiteboard = object["autoOpenWhiteboard"].toBool();
    }
    if (object.contains("openWhiteboard")) {
        openWhiteboard = object["openWhiteboard"].toBool();
    }
    if (object.contains("rename")) {
        rename = object["rename"].toBool();
    }
    if (object.contains("displayOption")) {
        displayOption = object["displayOption"].toInt();
    }
    if (object.contains("enableRecord")) {
        enableRecord = object["enableRecord"].toBool();
    }
    if (object.contains("audioAINS")) {
        audioAINS = object["audioAINS"].toBool();
    }
    if (object.contains("sip")) {
        sip = object["sip"].toBool();
    }
    if (object.contains("showMemberTag")) {
        showMemberTag = object["showMemberTag"].toBool();
    }
    if (object.contains("enableMuteAllVideo")) {
        enableMuteAllVideo = object["enableMuteAllVideo"].toBool();
    }
    if (object.contains("enableMuteAllAudio")) {
        enableMuteAllAudio = object["enableMuteAllAudio"].toBool();
    }
    if (object.contains("showRemainingTip")) {
        showRemainingTip = object["showRemainingTip"].toBool();
    }
    if (object.contains("enableFileMessage")) {
        enableFileMessage = object["enableFileMessage"].toBool();
    }
    if (object.contains("enableImageMessage")) {
        enableImageMessage = object["enableImageMessage"].toBool();
    }

    while (!m_initialized) {
        if (!m_initSuc)
            return;
        std::this_thread::yield();
    }

    QTimer::singleShot(500, this, [=] {
        qInfo() << "start Join a meeting";
        auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
        if (ipcMeetingService) {
            QByteArray byteMeetingId = meetingId.toUtf8();
            QByteArray byteNickname = nickname.toUtf8();

            NEJoinMeetingParams params;
            params.meetingId = byteMeetingId.data();
            params.displayName = byteNickname.data();
            params.password = password.toUtf8().data();
            params.tag = tag.toUtf8().data();

            NEJoinMeetingOptions options;
            options.noAudio = !audio;
            options.noVideo = !video;
            options.noChat = !enableChatroom;
            options.noInvite = !enableInvitation;
            options.noRename = !rename;
            options.noWhiteboard = !openWhiteboard;
            options.noScreenShare = enableScreenShare;
            options.noView = enableView;
            options.audioAINSEnabled = audioAINS;
            options.showMemberTag = showMemberTag;
            options.noSip = !sip;
            options.noMuteAllVideo = !enableMuteAllVideo;
            options.noMuteAllAudio = !enableMuteAllAudio;
            options.showMeetingRemainingTip = showRemainingTip;
            if (autoOpenWhiteboard) {
                options.defaultWindowMode = WHITEBOARD_MODE;
            }

            options.meetingIdDisplayOption = (NEShowMeetingIdOption)displayOption;
            options.joinTimeout = timeOut;
            options.chatroomConfig.enableFileMessage = enableFileMessage;
            options.chatroomConfig.enableImageMessage = enableImageMessage;

            // pushSubmenus(options.full_more_menu_items_, kFirstinjectedMenuId);

            if (anonymous) {
                qInfo() << "do anonymousJoinMeeting";
                ipcMeetingService->anonymousJoinMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
                    qInfo() << "anonymous Join meeting callback, error code: " << errorCode
                            << ", error message: " << QString::fromStdString(errorMessage);
                    emit joinSignal(errorCode, QString::fromStdString(errorMessage));
                });
            } else {
                qInfo() << "do joinMeeting";
                ipcMeetingService->joinMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
                    qInfo() << "Join meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
                    emit joinSignal(errorCode, QString::fromStdString(errorMessage));
                });
            }
        }
    });
}

void NEMeetingManager::leaveMeeting(bool finish) {
    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        ipcMeetingService->leaveMeeting(finish, [=](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Leave meeting finish: " << finish << ", error code: " << errorCode
                    << ", error message: " << QString::fromStdString(errorMessage);
            if (finish)
                emit finishSignal(errorCode, QString::fromStdString(errorMessage));
            else
                emit leaveSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

int NEMeetingManager::getMeetingStatus() {
    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        return ipcMeetingService->getMeetingStatus();
    }

    return MEETING_STATUS_IDLE;
}

void NEMeetingManager::getMeetingInfo() {
    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        ipcMeetingService->getCurrentMeetingInfo([this](NEErrorCode errorCode, const std::string& errorMessage, const NEMeetingInfo& meetingInfo) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                QJsonObject obj;
                obj["meetingUniqueId"] = meetingInfo.meetingUniqueId;
                obj["meetingId"] = QString::fromStdString(meetingInfo.meetingId);
                obj["shortMeetingId"] = QString::fromStdString(meetingInfo.shortMeetingId);
                obj["subject"] = QString::fromStdString(meetingInfo.subject);
                obj["password"] = QString::fromStdString(meetingInfo.password);
                obj["isHost"] = meetingInfo.isHost;
                obj["isLocked"] = meetingInfo.isLocked;
                obj["scheduleStartTime"] = QString::number(meetingInfo.scheduleStartTime);
                obj["scheduleEndTime"] = QString::number(meetingInfo.scheduleEndTime);
                obj["startTime"] = QString::number(meetingInfo.startTime);
                obj["sipId"] = QString::fromStdString(meetingInfo.sipId);
                obj["duration"] = meetingInfo.duration;
                obj["hostUserId"] = QString::fromStdString(meetingInfo.hostUserId);
                obj["extraData"] = QString::fromStdString(meetingInfo.extraData);

                QJsonArray users;
                for (const auto& user : qAsConst(meetingInfo.userList)) {
                    QJsonObject userObj;
                    userObj["userId"] = QString::fromStdString(user.userId);
                    userObj["userName"] = QString::fromStdString(user.userName);
                    userObj["tag"] = QString::fromStdString(user.tag);
                    users << userObj;
                }

                emit getCurrentMeetingInfo(obj, users);

            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
    }
}

void NEMeetingManager::getHistoryMeetingItem() {
    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->getHistoryMeetingItem(
            [this](NEErrorCode errorCode, const std::string& errorMessage, const std::list<NEHistoryMeetingItem> listItem) {
                if (errorCode == ERROR_CODE_SUCCESS) {
                    if (!listItem.empty()) {
                        auto item = listItem.front();
                        emit getHistoryMeetingInfo(item.meetingUniqueId, QString::fromStdString(item.meetingId),
                                                   QString::fromStdString(item.shortMeetingId), QString::fromStdString(item.subject),
                                                   QString::fromStdString(item.password), QString::fromStdString(item.nickname),
                                                   QString::fromStdString(item.sipId));
                    } else {
                        qInfo() << "getHistoryMeetingItem is empty.";
                    }
                } else
                    emit error(errorCode, QString::fromStdString(errorMessage));
            });
    }
}

void NEMeetingManager::onMeetingStatusChanged(int status, int code) {
    qInfo() << "Meeting status changed, status:" << status << ", code:" << code;
    emit meetingStatusChanged(status, code);
}

void NEMeetingManager::onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) {
    qInfo() << "Meeting injected menu item clicked, item index: " << meeting_menu_item.itemId
            << ", guid: " << QString::fromStdString(meeting_menu_item.itemGuid) << ", title: " << QString::fromStdString(meeting_menu_item.itemTitle)
            << ", image path: " << QString::fromStdString(meeting_menu_item.itemImage);

    QDesktopServices::openUrl(QUrl(QString::fromStdString("https://www.google.com.hk/search?q=" + meeting_menu_item.itemTitle)));

    emit meetingInjectedMenuItemClicked(meeting_menu_item.itemId, QString::fromStdString(meeting_menu_item.itemGuid),
                                        QString::fromStdString(meeting_menu_item.itemTitle), QString::fromStdString(meeting_menu_item.itemImage));
}

void NEMeetingManager::onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) {
    qInfo() << "Scheduled meeting status changed, unique meeting ID:" << uniqueMeetingId << meetingStatus;
    QMetaObject::invokeMethod(this, "onGetMeetingListUI", Qt::AutoConnection);
}

void NEMeetingManager::onInjectedMenuItemClickEx(const NEMeetingMenuItem& meeting_menu_item, const NEInjectedMenuItemClickCallback& cb) {
    qInfo() << "Meeting injected menu item clicked, item index: " << meeting_menu_item.itemId
            << ", guid: " << QString::fromStdString(meeting_menu_item.itemGuid) << ", title: " << QString::fromStdString(meeting_menu_item.itemTitle)
            << ", image path: " << QString::fromStdString(meeting_menu_item.itemImage)
            << ", title2: " << QString::fromStdString(meeting_menu_item.itemTitle2)
            << ", image path2: " << QString::fromStdString(meeting_menu_item.itemImage2)
            << ", itemVisibility: " << (int)meeting_menu_item.itemVisibility << ", itemCheckedIndex: " << meeting_menu_item.itemCheckedIndex;

    if ((kFirstinjectedMenuId + 1) == meeting_menu_item.itemId || (kFirstinjectedMenuId + 50 + 1) == meeting_menu_item.itemId) {
        cb(meeting_menu_item.itemId, meeting_menu_item.itemGuid, 1 == meeting_menu_item.itemCheckedIndex ? 2 : 1);
    } else {
        cb(meeting_menu_item.itemId, meeting_menu_item.itemGuid, meeting_menu_item.itemCheckedIndex);
    }

    emit meetingInjectedMenuItemClicked(
        meeting_menu_item.itemId, QString::fromStdString(meeting_menu_item.itemGuid),
        QString::fromStdString(1 == meeting_menu_item.itemCheckedIndex ? meeting_menu_item.itemTitle : meeting_menu_item.itemTitle2),
        QString::fromStdString(meeting_menu_item.itemImage));
}

QString NEMeetingManager::personalMeetingId() const {
    return m_personalMeetingId;
}

void NEMeetingManager::setPersonalMeetingId(const QString& personalMeetingId) {
    m_personalMeetingId = personalMeetingId;
    emit personalMeetingIdChanged();
}

void NEMeetingManager::OnAudioSettingsChange(bool status) {
    qInfo() << "OnAudioSettingsChange: " << status;
    emit deviceStatusChanged(1, status);
}

void NEMeetingManager::OnVideoSettingsChange(bool status) {
    qInfo() << "OnVideoSettingsChange: " << status;
    emit deviceStatusChanged(2, status);
}

void NEMeetingManager::OnAudioAINSSettingsChange(bool status) {
    qInfo() << "OnAudioAINSSettingsChange: " << status;
    emit deviceStatusChanged(3, status);
    if (status != m_bAudioAINS) {
        m_bAudioAINS = status;
        Q_EMIT isAudioAINSChanged();
    }
}

void NEMeetingManager::OnAudioVolumeAutoAdjustSettingsChange(bool status) {
    qInfo() << "OnAudioVolumeAutoAdjustSettingsChange: " << status;
}

void NEMeetingManager::OnAudioQualitySettingsChange(AudioQuality enumAudioQuality) {
    qInfo() << "OnAudioQualitySettingsChange: " << (int)enumAudioQuality;
}

void NEMeetingManager::OnAudioEchoCancellationSettingsChange(bool status) {
    qInfo() << "OnAudioEchoCancellationSettingsChange: " << status;
}

void NEMeetingManager::OnAudioEnableStereoSettingsChange(bool status) {
    qInfo() << "OnAudioEnableStereoSettingsChange: " << status;
}

void NEMeetingManager::OnRemoteVideoResolutionSettingsChange(RemoteVideoResolution enumRemoteVideoResolution) {
    qInfo() << "OnRemoteVideoResolutionSettingsChange: " << (int)enumRemoteVideoResolution;
}

void NEMeetingManager::OnMyVideoResolutionSettingsChange(LocalVideoResolution enumLocalVideoResolution) {
    qInfo() << "OnMyVideoResolutionSettingsChange: " << (int)enumLocalVideoResolution;
}

void NEMeetingManager::onKickOut() {
    qInfo() << "onKickOut: ";
    emit logoutSignal(0, "");
}

void NEMeetingManager::OnOtherSettingsChange(bool status) {
    qInfo() << "OnOtherSettingsChange: " << status;
}

void NEMeetingManager::pushSubmenus(std::vector<NEMeetingMenuItem>& items_list, int MenuIdIndex) {
    auto applicationPath = qApp->applicationDirPath();
#ifdef Q_OS_WIN32
    QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/" + "feedback.png").toUtf8();
    QByteArray byteImage2 = QString(QGuiApplication::applicationDirPath() + "/" + "feedback 2.png").toUtf8();
#else
    QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback.png").toUtf8();
    QByteArray byteImage2 = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback 2.png").toUtf8();
#endif

    NEMeetingMenuItem item;
    item.itemId = MenuIdIndex++;
    item.itemTitle = QString(QStringLiteral("Menu1")).toStdString();
    item.itemImage = byteImage.data();
    item.itemVisibility = NEMenuVisibility::VISIBLE_TO_HOST_ONLY;
    items_list.push_back(item);

    NEMeetingMenuItem item2;
    item2.itemId = MenuIdIndex++;
    item2.itemTitle = QString(QStringLiteral("Menu2")).toStdString();
    item2.itemImage = byteImage.data();
    item2.itemTitle2 = QString(QStringLiteral("Menu2_2")).toStdString();
    item2.itemImage2 = byteImage2.data();
    item2.itemVisibility = NEMenuVisibility::VISIBLE_TO_HOST_ONLY;
    items_list.push_back(item2);

    return;
    NEMeetingMenuItem item3;
    item3.itemId = MenuIdIndex++;
    item3.itemTitle = QString(QStringLiteral("Menu3")).toStdString();
    item3.itemImage = byteImage.data();
    item3.itemTitle2 = QString(QStringLiteral("Menu3_2")).toStdString();
    item3.itemImage2 = byteImage2.data();
    items_list.push_back(item3);

    NEMeetingMenuItem item4;
    item4.itemId = MenuIdIndex++;
    item4.itemTitle = QString(QStringLiteral("Menu4")).toStdString();
    item4.itemImage = byteImage.data();
    items_list.push_back(item4);

    NEMeetingMenuItem item5;
    item5.itemId = MenuIdIndex++;
    item5.itemTitle = QString(QStringLiteral("Menu5")).toStdString();
    item5.itemImage = byteImage.data();
    items_list.push_back(item5);

    NEMeetingMenuItem item6;
    item6.itemId = MenuIdIndex++;
    item6.itemTitle = QString(QStringLiteral("Menu6")).toStdString();
    item6.itemImage = byteImage.data();
    items_list.push_back(item6);

    NEMeetingMenuItem item7;
    item7.itemId = MenuIdIndex++;
    item7.itemTitle = QString(QStringLiteral("Menu7")).toStdString();
    item7.itemImage = byteImage.data();
    items_list.push_back(item7);
}

void NEMeetingManager::onGetMeetingListUI() {
    getMeetingList();
}

bool NEMeetingManager::checkAudio() {
    auto ipcSettingService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingService) {
        auto AudioController = ipcSettingService->GetAudioController();
        if (AudioController) {
            // std::promise<bool> promise;
            AudioController->isTurnOnMyAudioWhenJoinMeetingEnabled([this](NEErrorCode errorCode, const std::string& errorMessage, const bool& bOn) {
                if (errorCode == ERROR_CODE_SUCCESS)
                    OnAudioSettingsChange(bOn);
                else {
                    // promise.set_value(false);
                    emit error(errorCode, QString::fromStdString(errorMessage));
                }
            });

            // std::future<bool> future = promise.get_future();
            return true;  // future.get();
        }
    }
    return false;
}

void NEMeetingManager::setCheckAudio(bool checkAudio) {
    auto ipcSettingService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingService) {
        auto audioController = ipcSettingService->GetAudioController();
        if (audioController) {
            audioController->setTurnOnMyAudioWhenJoinMeeting(checkAudio, [this, checkAudio](NEErrorCode errorCode, const std::string& errorMessage) {
                if (errorCode != ERROR_CODE_SUCCESS)
                    emit error(errorCode, QString::fromStdString(errorMessage));

                OnAudioSettingsChange(checkAudio);
            });
        }
    }
}

bool NEMeetingManager::checkVideo() {
    auto ipcSettingService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingService) {
        auto videoController = ipcSettingService->GetVideoController();
        if (videoController) {
            videoController->isTurnOnMyVideoWhenJoinMeetingEnabled([this](NEErrorCode errorCode, const std::string& errorMessage, const bool& bOn) {
                if (errorCode == ERROR_CODE_SUCCESS)
                    OnVideoSettingsChange(bOn);
                else {
                    // promise.set_value(false);
                    emit error(errorCode, QString::fromStdString(errorMessage));
                }
            });

            return true;
        }
    }
    return false;
}

void NEMeetingManager::setCheckVideo(bool checkVideo) {
    auto ipcSettingService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingService) {
        auto videoController = ipcSettingService->GetVideoController();
        if (videoController) {
            videoController->setTurnOnMyVideoWhenJoinMeeting(checkVideo, [this, checkVideo](NEErrorCode errorCode, const std::string& errorMessage) {
                if (errorCode != ERROR_CODE_SUCCESS)
                    emit error(errorCode, QString::fromStdString(errorMessage));

                OnVideoSettingsChange(checkVideo);
            });
        }
    }
}

void NEMeetingManager::subcribeAudio(const QString& accoundIdList, bool subcribe, int type) {
    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (!ipcMeetingService) {
        return;
    }

    if (0 == type) {
        ipcMeetingService->subscribeRemoteAudioStream(accoundIdList.toStdString(), subcribe,
                                                      [this](NEErrorCode errorCode, const std::string& errorMessage) {
                                                          if (errorCode != ERROR_CODE_SUCCESS) {
                                                              emit error(errorCode, QString::fromStdString(errorMessage));
                                                          }
                                                      });
    } else if (1 == type) {
        std::vector<std::string> vTmp;
        QStringList strList = accoundIdList.split(',');
        vTmp.reserve(strList.size());
        if (!accoundIdList.isEmpty()) {
            std::transform(strList.begin(), strList.end(), std::back_inserter(vTmp), [](const QString& str) { return str.toStdString(); });
        }
        ipcMeetingService->subscribeRemoteAudioStreams(vTmp, subcribe, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            if (errorCode != ERROR_CODE_SUCCESS) {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
    } else if (2 == type) {
        ipcMeetingService->subscribeAllRemoteAudioStreams(subcribe, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            if (errorCode != ERROR_CODE_SUCCESS) {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
    }
}

void NEMeetingManager::getIsSupportRecord() {
    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->GetRecordController()->isCloudRecordEnabled(
            [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportRecord(enable); });
    }
}

bool NEMeetingManager::isSupportRecord() const {
    return m_bSupportRecord;
}

void NEMeetingManager::setIsSupportRecord(bool isSupportRecord) {
    m_bSupportRecord = isSupportRecord;
    qInfo() << "m_bSupportRecord: " << m_bSupportRecord;
    Q_EMIT isSupportRecordChanged();
}

void NEMeetingManager::getIsSupportLive() {
    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();

    if (ipcSettingsService) {
        ipcSettingsService->GetLiveController()->isLiveEnabled(
            [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportLive(enable); });
    }
}

bool NEMeetingManager::isSupportLive() const {
    return m_bSupportLive;
}

void NEMeetingManager::setIsSupportLive(bool isSupportLive) {
    m_bSupportLive = isSupportLive;
    qInfo() << "m_bSupportLive: " << m_bSupportLive;
    Q_EMIT isSupportLiveChanged();
}

bool NEMeetingManager::isAudioAINS() const {
    return m_bAudioAINS;
}

void NEMeetingManager::setIsAudioAINS(bool isAudioAINS) {
    if (m_bAudioAINS == isAudioAINS) {
        return;
    }
    qInfo() << "setIsAudioAINS isAudioAINS: " << isAudioAINS;
    NEMeetingKit::getInstance()->getSettingsService()->GetAudioController()->setTurnOnMyAudioAINSWhenInMeeting(
        isAudioAINS, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "setTurnOnMyAudioAINSWhenInMeeting callback, error code: " << errorCode
                    << ", error message: " << QString::fromStdString(errorMessage);
            Q_EMIT isAudioAINSChanged();
        });
}

// bool NEMeetingManager::checkDuration()
//{
//    auto ipcSettingService = NEMeetingSDK::getInstance()->getSettingsService();
//    if (ipcSettingService)
//    {
//        auto otherController = ipcSettingService->GetOtherController();
//        if (otherController)
//        {
//            std::promise<bool> promise;
//            otherController->isShowMyMeetingElapseTimeEnabled([this, &promise](NEErrorCode errorCode, const std::string& errorMessage, const bool&
//            bOn){
//                if (errorCode == ERROR_CODE_SUCCESS)
//                    promise.set_value(bOn);
//                else
//                {
//                    promise.set_value(false);
//                    emit error(errorCode, QString::fromStdString(errorMessage));
//                }
//            });

//            std::future<bool> future = promise.get_future();
//            return future.get();
//        }
//    }
//    return false;
//}

// void NEMeetingManager::setCheckDuration(bool checkDuration)
//{
//    auto ipcSettingService = NEMeetingSDK::getInstance()->getSettingsService();
//    if (ipcSettingService)
//    {
//        auto otherController = ipcSettingService->GetOtherController();
//        if (otherController)
//        {
//            otherController->enableShowMyMeetingElapseTime(checkDuration, [this](NEErrorCode errorCode, const std::string& errorMessage){
//                if (errorCode != ERROR_CODE_SUCCESS)
//                   emit error(errorCode, QString::fromStdString(errorMessage));
//            });
//        }
//    }
//}

void NEMeetingManager::setAudodeviceAutoSelectType(bool audodeviceAutoSelectType) {
    if (m_audodeviceAutoSelectType == audodeviceAutoSelectType)
        return;

    m_audodeviceAutoSelectType = audodeviceAutoSelectType;
    emit audodeviceAutoSelectTypeChanged(m_audodeviceAutoSelectType);

    NEMeetingKit::getInstance()->getSettingsService()->GetAudioController()->setMyAudioDeviceAutoSelectType(
        m_audodeviceAutoSelectType ? AudioDeviceAutoSelectType_Available : AudioDeviceAutoSelectType_Default,
        [this, audodeviceAutoSelectType](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "setTurnOnMyAudioAINSWhenInMeeting callback, error code: " << errorCode
                    << ", error message: " << QString::fromStdString(errorMessage);
            if (errorCode != ERROR_CODE_SUCCESS) {
                m_audodeviceAutoSelectType = !audodeviceAutoSelectType;
                emit audodeviceAutoSelectTypeChanged(m_audodeviceAutoSelectType);
            }
        });
}

void NEMeetingManager::setSoftwareRender(bool softwareRender) {
    if (m_softwareRender == softwareRender)
        return;

    m_softwareRender = softwareRender;
    emit softwareRenderChanged(m_softwareRender);
    NEMeetingKit::getInstance()->setSoftwareRender(m_softwareRender, [this, softwareRender](NEErrorCode errorCode, const std::string& errorMessage) {
        qInfo() << "setSoftwareRender callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
        if (errorCode != ERROR_CODE_SUCCESS) {
            m_softwareRender = !m_softwareRender;
            Q_EMIT softwareRenderChanged(m_softwareRender);
        }
    });
}

void NEMeetingManager::setVirtualBackground(bool virtualBackground) {
    if (m_virtualBackground == virtualBackground)
        return;

    NEMeetingKit::getInstance()->getSettingsService()->GetVirtualBackgroundController()->enableVirtualBackground(
        virtualBackground, [this, virtualBackground](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "enableVirtualBackground callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            if (ERROR_CODE_SUCCESS == errorCode) {
                m_virtualBackground = virtualBackground;
                emit virtualBackgroundChanged(m_virtualBackground);
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
}

void NEMeetingManager::getVirtualBackgroundList() {
    NEMeetingKit::getInstance()->getSettingsService()->GetVirtualBackgroundController()->getBuiltinVirtualBackgrounds(
        [this](NEErrorCode errorCode, const std::string& errorMessage, const std::vector<NEMeetingVirtualBackground>& vbList) {
            qInfo() << "getBuiltinVirtualBackgrounds callback, error code: " << errorCode
                    << ", error message: " << QString::fromStdString(errorMessage);
            if (ERROR_CODE_SUCCESS == errorCode) {
                std::string strList;
                for (auto& it : vbList) {
                    strList.append(it.path).append("\r\n");
                }
                qInfo() << "getBuiltinVirtualBackgrounds callback, bvList:" << QString::fromStdString(strList);
                emit virtualBackgroundList(QString::fromStdString(strList));
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
}

void NEMeetingManager::setVirtualBackgroundList(const QString& vbList) {
    std::vector<NEMeetingVirtualBackground> virtualBackgrounds;
    if (!vbList.trimmed().isEmpty()) {
        for (auto& it : vbList.split(",")) {
            NEMeetingVirtualBackground vb;
            vb.path = it.toStdString();
            virtualBackgrounds.emplace_back(vb);
        }
    }
    NEMeetingKit::getInstance()->getSettingsService()->GetVirtualBackgroundController()->setBuiltinVirtualBackgrounds(
        virtualBackgrounds, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "setBuiltinVirtualBackgrounds callback, error code: " << errorCode
                    << ", error message: " << QString::fromStdString(errorMessage);
            if (ERROR_CODE_SUCCESS == errorCode) {
                emit virtualBackgroundList("");
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
}

void NEMeetingManager::getPersonalMeetingId() {
    NEMeetingKit::getInstance()->getAccountService()->getPersonalMeetingId(
        [this](NEErrorCode errorCode, const std::string& errorMessage, const std::string& meetingId) {
            qInfo() << "getPersonalMeetingId callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage)
                    << ", meetingId: " << QString::fromStdString(meetingId);
            if (ERROR_CODE_SUCCESS == errorCode) {
                emit getPersonalMeetingIdChanged(QString::fromStdString(meetingId));
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
}

void NEMeetingManager::setBeauty(bool beauty) {
    if (m_beauty == beauty)
        return;

    NEMeetingKit::getInstance()->getSettingsService()->GetBeautyFaceController()->enableBeautyFace(
        beauty, [=](NEErrorCode errorCode, const std::string& errorMessage, const bool& bSuc) {
            qInfo() << "setBeautyFaceValue callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage)
                    << ", bSuc: " << bSuc << ", beauty: " << beauty;
            if (ERROR_CODE_SUCCESS == errorCode) {
                m_beauty = beauty;
                emit beautyChanged(m_beauty);
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
}

void NEMeetingManager::setBeautyValue(int beautyValue) {
    if (m_beautyValue == beautyValue)
        return;

    NEMeetingKit::getInstance()->getSettingsService()->GetBeautyFaceController()->setBeautyFaceValue(
        beautyValue, [=](NEErrorCode errorCode, const std::string& errorMessage, const bool& bSuc) {
            qInfo() << "setBeautyFaceValue callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage)
                    << ", bSuc: " << bSuc << ", beautyValue: " << beautyValue;
            if (ERROR_CODE_SUCCESS == errorCode) {
                m_beautyValue = beautyValue;
                emit beautyValueChanged(m_beautyValue);
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
}
