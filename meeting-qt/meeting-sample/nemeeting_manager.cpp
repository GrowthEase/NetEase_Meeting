/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nemeeting_manager.h"
#include <QDesktopServices>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#include <future>
#include <iostream>

NEMeetingManager::NEMeetingManager(QObject* parent)
    : QObject(parent)
    , m_initialized(false)
    , m_initSuc(true) {
   // connect(this, &NEMeetingManager::unInitializeSignal, this, []() { qApp->exit(); });
}

void NEMeetingManager::initializeParam(const QString& strSdkLogPath, int sdkLogLevel, bool bRunAdmin) {
    m_strSdkLogPath = strSdkLogPath;
    m_sdkLogLevel = sdkLogLevel;
    m_bRunAdmin = bRunAdmin;
}

void NEMeetingManager::initialize(const QString& strAppkey, int keepAliveInterval) {
    if (m_initialized) {
        emit initializeSignal(0, "");
        return;
    }

    m_initSuc = true;
    NEMeetingSDKConfig config;
    QString displayName = QObject::tr("NetEase Meeting");
    QByteArray byteDisplayName = displayName.toUtf8();
    config.setLogSize(10);
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

    auto pMeetingSDK = NEMeetingSDK::getInstance();
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
            auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
            if (ipcMeetingService) {
                ipcMeetingService->addMeetingStatusListener(this);
                ipcMeetingService->setOnInjectedMenuItemClickListener(this);
            }
            auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
            if (ipcPreMeetingService) {
                ipcPreMeetingService->registerScheduleMeetingStatusListener(this);
            }
            auto settingsService = NEMeetingSDK::getInstance()->getSettingsService();
            if (settingsService) {
                settingsService->setNESettingsChangeNotifyHandler(this);
            }

            NEMeetingSDK::getInstance()->querySDKVersion([](NEErrorCode errorCode, const std::string& errorMessage, const std::string& version){
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

    NEMeetingSDK::getInstance()->setExceptionHandler(nullptr);
    NEMeetingSDK::getInstance()->unInitialize([&](NEErrorCode errorCode, const std::string& errorMessage) {
        qInfo() << "Uninitialize callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
        m_initialized = false;
        emit unInitializeSignal(errorCode, QString::fromStdString(errorMessage));
        qInfo() << "Uninitialized successfull";
    });
}

bool NEMeetingManager::isInitializd() {
    return NEMeetingSDK::getInstance()->isInitialized();
}

void NEMeetingManager::login(const QString& appKey, const QString& accountId, const QString& accountToken, int keepAliveInterval) {
    qInfo() << "Login to apaas server, appkey: " << appKey << ", account ID: " << accountId << ", token: " << accountToken << ", keepAliveInterval: " << keepAliveInterval;

    initialize(appKey, keepAliveInterval);
    while (!m_initialized) {
        if (!m_initSuc) return;
        std::this_thread::yield();
    }

    std::this_thread::sleep_for(std::chrono::seconds(1));
    auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
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

void NEMeetingManager::getAccountInfo() {
    qInfo() << "Get account info";
    while (!m_initialized) {
        if (!m_initSuc) return;
        std::this_thread::yield();
    }
    auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->getAccountInfo([=](NEErrorCode errorCode, const std::string& errorMessage, const AccountInfo& authInfo) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                setPersonalMeetingId(QString::fromStdString(authInfo.personalMeetingId));
            }
        });
    }
}

void NEMeetingManager::logout() {
    qInfo() << "Logout from apaas server";

    auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->logout(true, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Logout callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit logoutSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::showSettings() {
    qInfo() << "Post show settings request";

    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();
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
                                       bool attendeeAudioOff,
                                       bool enableLive,
                                       bool needLiveAuthentication,
                                       bool enableRecord) {
    QString strPassword = password.isEmpty() ? "null" : "no null";
    while (!m_initialized) {
        if (!m_initSuc) return;
        std::this_thread::yield();
    }
    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
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

        ipcPreMeetingService->scheduleMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage, const NEMeetingItem& item) {
            qInfo() << "Schedule meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit scheduleSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::cancelMeeting(const qint64& meetingUniqueId) {
    qInfo() << "cancel a meeting with meeting uniqueId:" << meetingUniqueId;
    while (!m_initialized) {
        if (!m_initSuc) return;
        std::this_thread::yield();
    }
    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
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
                                   bool attendeeAudioOff,
                                   bool enableLive,
                                   bool needLiveAuthentication,
                                   bool enableRecord) {
    QString strPassword = password.isEmpty() ? "null" : "no null";
    qInfo() << "Edit a meeting with meeting subject:" << meetingSubject << ", meetingUniqueId: " << meetingUniqueId << ", meetingId: " << meetingId
            << ", startTime: " << startTime << ", endTime: " << endTime << ", attendeeAudioOff: " << attendeeAudioOff
            << ", password: " << strPassword;

    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
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

        ipcPreMeetingService->editMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Edit meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit editSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::getMeetingList() {
    qInfo() << "Get meeting list from IPC client.";

    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
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
                            << ", mute after member join: " << item.setting.attendeeAudioOff;
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
                    jsonArray.push_back(object);
                }
                emit getScheduledMeetingList(errorCode, jsonArray);
            } else {
                emit getScheduledMeetingList(errorCode, jsonArray);
            }
        });
    }
}

void NEMeetingManager::invokeStart(const QString& meetingId,
                                   const QString& nickname,
                                   bool audio,
                                   bool video,
                                   bool enableChatroom /* = true*/,
                                   bool enableInvitation /* = true*/,
                                   bool autoOpenWhiteboard,
                                   bool rename,
                                   int displayOption,
                                   bool enableRecord) {
    qInfo() << "Start a meeting with meeting ID:" << meetingId << ", nickname: " << nickname << ", audio: " << audio << ", video: " << video
            << ", display id: " << displayOption;

    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        QByteArray byteMeetingId = meetingId.toUtf8();
        QByteArray byteNickname = nickname.toUtf8();

        NEStartMeetingParams params;
        params.meetingId = byteMeetingId.data();
        params.displayName = byteNickname.data();

        NEStartMeetingOptions options;
        options.noAudio = !audio;
        options.noVideo = !video;
        options.noChat = !enableChatroom;
        options.noInvite = !enableInvitation;
        options.noRename = !rename;
        if (autoOpenWhiteboard) {
            options.defaultWindowMode = WHITEBOARD_MODE;
        }

        options.noCloudRecord = !enableRecord;
        options.meetingIdDisplayOption = (NEShowMeetingIdOption)displayOption;
        // pushSubmenus(options.full_more_menu_items_, kFirstinjectedMenuId);
        ipcMeetingService->startMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Start meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit startSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::invokeJoin(const QString& meetingId,
                                  const QString& nickname,
                                  bool audio,
                                  bool video,
                                  bool enableChatroom /* = true*/,
                                  bool enableInvitation /* = true*/,
                                  bool autoOpenWhiteboard,
                                  const QString& password,
                                  bool rename,
                                  int displayOption) {
    qInfo() << "Join a meeting with meeting ID:" << meetingId << ", nickname: " << nickname << ", audio: " << audio << ", video: " << video
            << ", display id: " << displayOption;

    while (!m_initialized) {
        if (!m_initSuc) return;
        std::this_thread::yield();
    }

    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        QByteArray byteMeetingId = meetingId.toUtf8();
        QByteArray byteNickname = nickname.toUtf8();

        NEJoinMeetingParams params;
        params.meetingId = byteMeetingId.data();
        params.displayName = byteNickname.data();
        params.password = password.toUtf8().data();

        NEJoinMeetingOptions options;
        options.noAudio = !audio;
        options.noVideo = !video;
        options.noChat = !enableChatroom;
        options.noInvite = !enableInvitation;
        options.noRename = !rename;
        if (autoOpenWhiteboard) {
            options.defaultWindowMode = WHITEBOARD_MODE;
        }

        options.meetingIdDisplayOption = (NEShowMeetingIdOption)displayOption;
        // pushSubmenus(options.full_more_menu_items_, kFirstinjectedMenuId);
        ipcMeetingService->joinMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Join meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit joinSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingManager::leaveMeeting(bool finish) {
    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        ipcMeetingService->leaveMeeting(finish, [=](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "Leave meeting callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            emit leaveSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

int NEMeetingManager::getMeetingStatus() {
    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        return ipcMeetingService->getMeetingStatus();
    }

    return MEETING_STATUS_IDLE;
}

void NEMeetingManager::getMeetingInfo() {
    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
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

                QJsonArray users;
                for(auto user : meetingInfo.userList) {
                    QJsonObject userObj;
                    userObj["userId"] = QString::fromStdString(user.userId);
                    userObj["userName"] = QString::fromStdString(user.userName);
                    users << userObj;
                }

                emit getCurrentMeetingInfo(obj,users);

            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }

        });
    }
}

void NEMeetingManager::getHistoryMeetingItem() {
    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->getHistoryMeetingItem([this](NEErrorCode errorCode, const std::string& errorMessage, const std::list<NEHistoryMeetingItem> listItem) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                if (!listItem.empty()) {
                    auto item = listItem.front();
                    emit getHistoryMeetingInfo(item.meetingUniqueId, QString::fromStdString(item.meetingId), QString::fromStdString(item.shortMeetingId),
                                               QString::fromStdString(item.subject), QString::fromStdString(item.password), QString::fromStdString(item.nickname), QString::fromStdString(item.sipId));
                } else {
                    qInfo() << "getHistoryMeetingItem is empty.";
                }
            }
            else
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
    emit deviceStatusChanged(1, status);
}

void NEMeetingManager::OnVideoSettingsChange(bool status) {
    emit deviceStatusChanged(2, status);
}

void NEMeetingManager::OnOtherSettingsChange(bool status) {}

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
    auto ipcSettingService = NEMeetingSDK::getInstance()->getSettingsService();
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
    auto ipcSettingService = NEMeetingSDK::getInstance()->getSettingsService();
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
    auto ipcSettingService = NEMeetingSDK::getInstance()->getSettingsService();
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
    auto ipcSettingService = NEMeetingSDK::getInstance()->getSettingsService();
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
    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
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
    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();

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
    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();

    if (ipcSettingsService) {
        ipcSettingsService->GetLiveController()->isLiveEnabled(
            [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportLive(enable); });
    }
}

bool NEMeetingManager::isSupportLive() const
{
    return m_bSupportLive;
}

void NEMeetingManager::setIsSupportLive(bool isSupportLive)
{
    m_bSupportLive = isSupportLive;
    qInfo() << "m_bSupportLive: " << m_bSupportLive;
    Q_EMIT isSupportLiveChanged();
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
