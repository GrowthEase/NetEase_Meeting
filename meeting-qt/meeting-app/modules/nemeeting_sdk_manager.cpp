/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nemeeting_sdk_manager.h"
#include <QElapsedTimer>
#include <future>
#include "auth_manager.h"

const int maxInitRetryTimes = 1;

#define CHECK_INIT                                                                              \
    {                                                                                           \
        QElapsedTimer time;                                                                     \
        time.start();                                                                           \
        int maxTime = 10 * 1000;                                                                \
        while (!m_bInitialized && time.elapsed() <= maxTime) {                                  \
            std::this_thread::yield();                                                          \
        }                                                                                       \
        if (!m_bInitialized) {                                                                  \
            YXLOG(Info) << "call function failed, reason is m_bInitialized false." << YXLOGEnd; \
            return;                                                                             \
        }                                                                                       \
    }

NEMeetingSDKManager::NEMeetingSDKManager(QObject* parent)
    : QObject(parent)
    , m_bAllowActive(false)
    , m_pSettingsEventHandler(new SettingsEventHandler) {}

NEMeetingSDKManager::~NEMeetingSDKManager() {
    if (m_bInitialized)
        unInitializeSync();
}

void NEMeetingSDKManager::initialize(const QString& appKey, const InitCallback& callback) {
    YXLOG(Info) << "Do initialize." << YXLOGEnd;
    if (m_bInitialized) {
        emit initializeSignal(0, "");
        if (callback)
            callback(NEErrorCode(0), "");
        return;
    }
    NEMeetingSDKConfig config;
    QString displayName = QObject::tr("NetEase Meeting");
    QByteArray byteDisplayName = displayName.toUtf8();
    QByteArray byteAppKey = appKey.toUtf8();
    config.setAppKey(byteAppKey.data());
    config.setLogSize(10);
    config.getAppInfo()->ProductName(byteDisplayName.data());
    config.getAppInfo()->OrganizationName("NetEase");
    config.getAppInfo()->ApplicationName("Meeting");
    config.setDomain("yunxin.163.com");
    config.setUseAssetServerConfig(false);
#ifdef QT_NO_DEBUG
    config.setEnableDebugLog(false);
#else
    config.setEnableDebugLog(true);
    config.setKeepAliveInterval(-1);
    config.getLoggerConfig()->LoggerLevel(NEDEBUG);
#endif
    auto pMeetingSDK = NEMeetingSDK::getInstance();
    pMeetingSDK->setLogHandler([](int level, const std::string& log) {
        switch (level) {
            case 0:
            case 1:
                YXLOG(Info) << log << YXLOGEnd;
                break;
            case 2:
                YXLOG(Warn) << log << YXLOGEnd;
                break;
            case 3:
                YXLOG(Error) << log << YXLOGEnd;
                break;
            case 4:
                YXLOG(Fatal) << log << YXLOGEnd;
                break;
            default:
                YXLOG(Info) << log << YXLOGEnd;
        }
    });
    pMeetingSDK->initialize(config, [this, callback](NEErrorCode errorCode, const std::string& errorMessage) {
        YXLOG(Info) << "Initialize callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
        auto pMeetingSDK = NEMeetingSDK::getInstance();
        auto ipcAuthService = pMeetingSDK->getAuthService();
        if (ipcAuthService)
            ipcAuthService->addAuthListener(this);

        auto ipcMeetingService = pMeetingSDK->getMeetingService();
        if (ipcMeetingService) {
            ipcMeetingService->addMeetingStatusListener(this);
            ipcMeetingService->setOnInjectedMenuItemClickListener(this);
        }

        auto ipcPreMeetingService = pMeetingSDK->getPremeetingService();
        if (ipcPreMeetingService)
            ipcPreMeetingService->registerScheduleMeetingStatusListener(this);

        pMeetingSDK->setExceptionHandler(std::bind(&NEMeetingSDKManager::onException, this, std::placeholders::_1));

        m_bInitialized = true;
        emit initializeSignal(errorCode, QString::fromStdString(errorMessage));
        if (callback)
            callback(errorCode, QString::fromStdString(errorMessage));
    });

#ifdef Q_OS_MAC
    if (m_nTryInitTimes < maxInitRetryTimes && !m_bInitialized) {
        YXLOG(Info) << "m_bInitialized: " << m_bInitialized << ", m_nTryInitTimes: " << m_nTryInitTimes << YXLOGEnd;
        QTimer::singleShot(5 * 1000, [=] {
            if (!m_bInitialized) {
                YXLOG(Info) << "Do initialize again start: "
                            << "m_bInitialized: " << m_bInitialized << ", m_nTryInitTimes: " << m_nTryInitTimes << YXLOGEnd;
                m_nTryInitTimes++;

                bool bUnInitialize = false;
                m_bInitialized = true;
                unInitialize([&bUnInitialize](NEErrorCode /*errorCode*/, const QString& /*errorMessage*/) { bUnInitialize = true; });

                QElapsedTimer time;
                time.start();
                int maxTime = 2 * 1000;
                while (1) {
                    if (bUnInitialize) {
                        break;
                    }

                    if (time.elapsed() >= maxTime) {
                        break;
                    }

                    std::this_thread::yield();
                }

                initialize(appKey, callback);
                YXLOG(Info) << "Do initialize again end" << YXLOGEnd;
            }
        });
    }
#endif
}

void NEMeetingSDKManager::unInitialize(const UnInitCallback& callback) {
    YXLOG(Info) << "Do uninitialize, initialize flag: " << m_bInitialized << YXLOGEnd;

    if (!m_bInitialized)
        return;

    m_bInitialized = false;

    NEMeetingSDK::getInstance()->setExceptionHandler(nullptr);

    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
    if (ipcMeetingService)
        ipcMeetingService->addMeetingStatusListener(nullptr);

    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
    if (ipcPreMeetingService)
        ipcPreMeetingService->unRegisterScheduleMeetingStatusListener(this);

    NEMeetingSDK::getInstance()->unInitialize([this, callback](NEErrorCode errorCode, const std::string& errorMessage) {
        YXLOG(Info) << "Uninitialize callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
        if (callback)
            callback(errorCode, QString::fromStdString(errorMessage));
        emit unInitializeSignal(errorCode, QString::fromStdString(errorMessage));
    });
}

bool NEMeetingSDKManager::unInitializeSync() {
    YXLOG(Info) << "unInitializeSync." << YXLOGEnd;
    bool bRet = false;
    NEErrorCode error = ERROR_CODE_SUCCESS;
    unInitialize([&bRet, &error](NEErrorCode errorCode, const QString& /*errorMessage*/) {
        error = errorCode;
        bRet = true;
    });
    while (!bRet) {
        std::this_thread::yield();
    }

    m_bInitialized = !(error == ERROR_CODE_SUCCESS);
    return error == ERROR_CODE_SUCCESS;
}

void NEMeetingSDKManager::activeWindow() {
    if (!m_bInitialized || !m_bAllowActive)
        return;

    YXLOG(Info) << "Request active meeting window." << YXLOGEnd;

    NEMeetingSDK::getInstance()->activeWindow([](NEErrorCode /*errorCode*/, const std::string& /*errorMessage*/) {

    });
}

void NEMeetingSDKManager::loginByPassword(const QString& appKey, const QString& username, const QString& password) {
    YXLOG(Info) << "Request login by password." << YXLOGEnd;
    if (m_bInitialized)
        unInitializeSync();

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto authService = NEMeetingSDK::getInstance()->getAuthService();
            if (authService) {
                authService->loginWithNEMeeting(username.toStdString(), password.toStdString(),
                                                [=](NEErrorCode errorCode, const std::string& errorMessage) {
                                                    YXLOG(Info) << "Login with netease meeting account callback, error code: " << errorCode
                                                                << ", error message: " << errorMessage << YXLOGEnd;
                                                    emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                                                });
            }
        } else {
            emit error((int)errorCode, errorMessage);
        }
    });
}

void NEMeetingSDKManager::loginBySSOToken(const QString& appKey, const QString& ssoToken) {
    YXLOG(Info) << "Request login by SSO token." << YXLOGEnd;
#if 0
    CHECK_INIT;
#endif

    if (m_bInitialized)
        unInitializeSync();

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto authService = NEMeetingSDK::getInstance()->getAuthService();
            if (authService) {
                authService->loginWithSSOToken(ssoToken.toStdString(), [=](NEErrorCode errorCode, const std::string& errorMessage) {
                    YXLOG(Info) << "Login with SSO token account callback, error code: " << errorCode << ", error message: " << errorMessage
                                << YXLOGEnd;
                    if (ERROR_CODE_SUCCESS == errorCode) {
                        ConfigManager::getInstance()->setValue("localPaasAppKey", appKey);
                    }
                    emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                });
            }
        } else {
            emit error((int)errorCode, errorMessage);
        }
    });
}

void NEMeetingSDKManager::tryAutoLogin() {
    YXLOG(Info) << "Request try auto login." << YXLOGEnd;
#if 0
    CHECK_INIT;
#endif

    if (m_bInitialized)
        unInitializeSync();

    auto appKey = ConfigManager::getInstance()->getValue("localPaasAppKey", "").toString();
    if (appKey.isEmpty()) {
        emit tryAutoLoginSignal(-1, "");
        return;
    }

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            std::async(std::launch::async, [this]() {
#ifdef Q_OS_MACX
                std::this_thread::sleep_for(std::chrono::milliseconds(300));
#endif
                auto authService = NEMeetingSDK::getInstance()->getAuthService();
                if (authService) {
                    authService->tryAutoLogin([=](NEErrorCode errorCode, const std::string& errorMessage) {
                        YXLOG(Info) << "Try auto login callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                        Q_EMIT tryAutoLoginSignal(errorCode, QString::fromStdString(errorMessage));
                    });
                }
            });
        } else {
            emit error((int)errorCode, errorMessage);
        }
    });
}

void NEMeetingSDKManager::login(const QString& appKey,
                                const QString& accountId,
                                const QString& accountToken,
                                LoginType loginType /* = kLoginTypeDefault*/) {
    if (ConfigManager::getInstance()->getLocalDebugLevel()) {
        YXLOG(Debug) << "Login to apaas server, appkey: " << appKey.toStdString() << ", account ID: " << accountId.toStdString()
                     << ", token: " << accountToken.toStdString() << ", login type: " << loginType << YXLOGEnd;
    } else {
        YXLOG(Info) << "Login to apaas server, appkey: " << appKey.toStdString() << ", login type: " << loginType << YXLOGEnd;
    }
#if 0
    CHECK_INIT;
#endif

    if (m_bInitialized)
        unInitializeSync();

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
            if (ipcAuthService) {
                QByteArray byteAccountId = accountId.toUtf8();
                QByteArray byteAccountToken = accountToken.toUtf8();
                ipcAuthService->login(byteAccountId.data(), byteAccountToken.data(), [=](NEErrorCode errorCode, const std::string& errorMessage) {
                    YXLOG(Info) << "Login callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                    emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                });
            }
        } else {
            emit error((int)errorCode, errorMessage);
        }
    });
}

void NEMeetingSDKManager::logout(bool cleanup /* = false*/) {
    YXLOG(Info) << "Logout from apaas server." << YXLOGEnd;

    auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
    if (ipcAuthService) {
        // connect(this, &NEMeetingSDKManager::logoutSignal, this, [=](int errorCode, const QString& errorMessage) { unInitializeAsync(); },
        // Qt::UniqueConnection);
        ipcAuthService->logout(cleanup, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Logout callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            if (0 == errorCode) {
                setNEUsername("");
                setNEAppKey("");
                setNEAccountId("");
                setNEAccountToken("");
                setNELoginType(kLoginTypeUnknown);
                setPersonalShortMeetingId("");
                setPersonalMeetingId("");
                setDisplayName("");
            }
            emit logoutSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::showSettings() {
    YXLOG(Info) << "Post show settings request." << YXLOGEnd;
    CHECK_INIT
    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->showSettingUIWnd(NESettingsUIWndConfig(), [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Show settings wnd callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit showSettingsSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::invokeStart(const QString& meetingId, const QString& nickname, bool audio, bool video, bool enableRecord) {
    m_bAllowActive = true;
    YXLOG(Info) << "Start a meeting with meeting ID:" << meetingId.toStdString() << ", nickname: " << nickname.toStdString() << ", audio: " << audio
                << ", video: " << video << YXLOGEnd;

    CHECK_INIT
    auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        auto lastmeetingId = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString();
        auto lastshortmeetingId = ConfigManager::getInstance()->getValue("localLastMeetingshortId", "").toString();
        QByteArray byteNickname = "";
        QByteArray byteMeetingId = meetingId.toUtf8();
        //当前会议与上次会议一致时，优先使用上次会议中昵称
        if (byteMeetingId == lastmeetingId || (lastshortmeetingId == byteMeetingId && meetingId != "")) {
            byteNickname = ConfigManager::getInstance()->getValue("localLastNickname", "").toString().toUtf8();
            if (byteNickname == "") {
                byteNickname = nickname.toUtf8();
            }
        } else {
            byteNickname = nickname.toUtf8();
        }

        NEStartMeetingParams params;
        params.meetingId = byteMeetingId.data();
        params.displayName = byteNickname.data();

        NEStartMeetingOptions options;
        options.noAudio = !audio;
        options.noVideo = !video;
        options.noCloudRecord = !enableRecord;
        //        options.noWhiteboard = true;
        //        options.noRename = true;
        options.meetingIdDisplayOption = kDisplayAll;

        NEMeetingMenuItem menuItem;
#ifdef Q_OS_WIN32
        QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/" + "feedback.png").toUtf8();
        menuItem.itemImage = byteImage.data();
#else
        QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback.png").toUtf8();
        menuItem.itemImage = byteImage.data();
#endif
        YXLOG(Info) << "Set feedback item icon: " << menuItem.itemImage << YXLOGEnd;
        menuItem.itemId = 101;
        menuItem.itemTitle = tr("Feedback").toStdString();
        options.full_more_menu_items_.push_back(menuItem);

        ipcMeetingService->startMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Start meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit startSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::invokeJoin(const QString& meetingId, const QString& nickname, bool audio, bool video, bool anonJoinMode /* = false*/) {
    m_bAllowActive = true;
    YXLOG(Info) << "Join a meeting with meeting ID:" << meetingId.toStdString() << ", nickname: " << nickname.toStdString() << ", audio: " << audio
                << ", video: " << video << YXLOGEnd;

    auto task = [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto ipcMeetingService = NEMeetingSDK::getInstance()->getMeetingService();
            if (ipcMeetingService) {
                auto lastmeetingId = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString();
                auto lastshortmeetingId = ConfigManager::getInstance()->getValue("localLastMeetingshortId", "").toString();
                QByteArray byteNickname = "";
                QByteArray byteMeetingId = meetingId.toUtf8();
                if ((byteMeetingId == lastmeetingId || byteMeetingId == lastshortmeetingId) &&
                    ConfigManager::getInstance()->getValue("localNELoginType") != kLoginTypeSSOToken) {
                    byteNickname = ConfigManager::getInstance()->getValue("localLastNickname", "").toString().toUtf8();
                    if (byteNickname == "") {
                        byteNickname = nickname.toUtf8();
                    }
                } else {
                    byteNickname = nickname.toUtf8();
                }

                NEJoinMeetingParams params;
                params.meetingId = byteMeetingId.data();
                params.displayName = byteNickname.data();

                NEJoinMeetingOptions options;
                options.noAudio = !audio;
                options.noVideo = !video;
                //                options.noWhiteboard = true;
                //                options.noRename = true;
                options.meetingIdDisplayOption = kDisplayAll;

                NEMeetingMenuItem menuItem;
#ifdef Q_OS_WIN32
                QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/" + "feedback.png").toUtf8();
                menuItem.itemImage = byteImage.data();
#else
                QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback.png").toUtf8();
                menuItem.itemImage = byteImage.data();
#endif
                YXLOG(Info) << "Set feedback item icon: " << menuItem.itemImage << YXLOGEnd;
                menuItem.itemId = 101;
                menuItem.itemTitle = tr("Feedback").toStdString();
                options.full_more_menu_items_.push_back(menuItem);

                ipcMeetingService->joinMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
                    YXLOG(Info) << "Join meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                    emit joinSignal(errorCode, QString::fromStdString(errorMessage));
                });
            }
        } else {
            emit error(errorCode, errorMessage);
        }
    };

#if 0
    CHECK_INIT;
#endif

    if (anonJoinMode && m_bInitialized)
        unInitializeSync();

    if (!m_bInitialized) {
        auto defaultKey = ConfigManager::getInstance()->getValue("localAnonAppKey", LOCAL_DEFAULT_APPKEY);
        initialize(defaultKey.toString(), task);
    } else {
        task(ERROR_CODE_SUCCESS, "");
    }
}

void NEMeetingSDKManager::getAccountInfo() {
    YXLOG(Info) << "Post getAccountInfo request." << YXLOGEnd;
    CHECK_INIT
    auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->getAccountInfo([this](NEErrorCode errorCode, const std::string& errorMessage, AccountInfo info) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                YXLOG(Info) << "Get account info callback, personal meeting ID: " << info.personalMeetingId
                            << ", short meeting ID: " << info.shortMeetingId << ", display name: " << info.accountName
                            << ", login type: " << info.loginType << ", username: " << info.username << YXLOGEnd;
                setNEUsername(QString::fromStdString(info.username));
                setNEAppKey(QString::fromStdString(info.appKey));
                setNEAccountId(QString::fromStdString(info.accountId));
                setNEAccountToken(QString::fromStdString(info.accountToken));
                setNELoginType(info.loginType);
                setPersonalShortMeetingId(QString::fromStdString(info.shortMeetingId));
                setPersonalMeetingId(QString::fromStdString(info.personalMeetingId));
                setDisplayName(QString::fromStdString(info.accountName));
                emit gotAccountInfo();
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
    }
}

QString NEMeetingSDKManager::personalMeetingId() const {
    return m_personalMeetingId;
}

void NEMeetingSDKManager::setPersonalMeetingId(const QString& personalMeetingId) {
    m_personalMeetingId = personalMeetingId;
    emit personalMeetingIdChanged();

    auto prettyMeetingId = personalMeetingId.mid(0, 3).append("-").append(personalMeetingId.mid(3, 3)).append("-").append(personalMeetingId.mid(6));
    setPrettyMeetingId(prettyMeetingId);
}

QString NEMeetingSDKManager::prettyMeetingId() const {
    return m_prettyMeetingId;
}

void NEMeetingSDKManager::setPrettyMeetingId(const QString& prettyMeetingId) {
    m_prettyMeetingId = prettyMeetingId;
    emit prettyMeetingIdChanged();
}

QString NEMeetingSDKManager::personalShortMeetingId() const {
    return m_shortPersonalMeetingId;
}

void NEMeetingSDKManager::setPersonalShortMeetingId(const QString& shortMeetingId) {
    m_shortPersonalMeetingId = shortMeetingId;
    emit personalShortMeetingIdChanged();
}

void NEMeetingSDKManager::onAuthInfoExpired() {
    YXLOG(Info) << "Received auth information expired notification." << YXLOGEnd;
    ConfigManager::getInstance()->setValue("localUserId", "");
    ConfigManager::getInstance()->setValue("localUserToken", "");
    emit authInfoExpired();
}

void NEMeetingSDKManager::onMeetingStatusChanged(int status, int code) {
    YXLOG(Info) << "Received meeting status changed event, status: " << status << ", code: " << code << YXLOGEnd;
    emit meetingStatusChanged(status, code);
}

void NEMeetingSDKManager::onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) {
    YXLOG(Info) << "Scheduled meeting status changed, unique meeting ID: " << uniqueMeetingId << ", meeting status: " << meetingStatus << YXLOGEnd;
    // getMeetingList();
    QMetaObject::invokeMethod(this, "onGetMeetingListUI", Qt::AutoConnection);
}

void NEMeetingSDKManager::onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) {
    YXLOG(Info) << "Received menu item clicked event, item GUID: " << meeting_menu_item.itemGuid << ", ID: " << meeting_menu_item.itemId
                << ", title: " << meeting_menu_item.itemTitle << YXLOGEnd;
    if (meeting_menu_item.itemId == 101) {
        Q_EMIT feedback();
    }
}

void NEMeetingSDKManager::onInjectedMenuItemClickEx(const NEMeetingMenuItem& meeting_menu_item, const NEInjectedMenuItemClickCallback& cb) {}

void NEMeetingSDKManager::onDockClicked() {
    if (!m_bInitialized || !m_bAllowActive)
        return;

    YXLOG(Info) << "Request active window, send command to IPC module." << YXLOGEnd;
    NEMeetingSDK::getInstance()->activeWindow([](NEErrorCode /*errorCode*/, const std::string& /*errorMessage*/) {});
}

void NEMeetingSDKManager::onGetMeetingListUI() {
    YXLOG(Info) << "Get meeting list from UI thread." << YXLOGEnd;
    getMeetingList();
}

void NEMeetingSDKManager::onException(const NEException& exception) {
    if (m_bInitialized) {
        YXLOG(Error) << "Received exception, error code: " << exception.ExceptionCode() << ", error message: " << exception.ExceptionMessage()
                     << YXLOGEnd;
        qApp->exit(0);
    }
}

QString NEMeetingSDKManager::neUsername() const {
    return m_NEUsername;
}

void NEMeetingSDKManager::setNEUsername(const QString& NEUsername) {
    m_NEUsername = NEUsername;
    Q_EMIT neUsernameChanged();
}

bool NEMeetingSDKManager::isSupportRecord() const {
    return m_bSupportRecord;
}

void NEMeetingSDKManager::setIsSupportRecord(bool isSupportRecord) {
    YXLOG(Info) << "setIsSupportRecord: " << isSupportRecord << YXLOGEnd;
    m_bSupportRecord = isSupportRecord;
    Q_EMIT isSupportRecordChanged();
}

int NEMeetingSDKManager::neLoginType() const {
    return m_NELoginType;
}

void NEMeetingSDKManager::setNELoginType(const int& neLoginType) {
    m_NELoginType = (NELoginType)neLoginType;
    Q_EMIT neLoginTypeChanged();
}

QString NEMeetingSDKManager::neAccountToken() const {
    return m_NEAccountToken;
}

void NEMeetingSDKManager::setNEAccountToken(const QString& NEAccountToken) {
    m_NEAccountToken = NEAccountToken;
    Q_EMIT neAccountTokenChanged();
}

QString NEMeetingSDKManager::neAccountId() const {
    return m_NEAccountId;
}

void NEMeetingSDKManager::setNEAccountId(const QString& NEAccountId) {
    m_NEAccountId = NEAccountId;
    Q_EMIT neAccountIdChanged();
}

QString NEMeetingSDKManager::neAppKey() const {
    return m_NEAppKey;
}

void NEMeetingSDKManager::setNEAppKey(const QString& NEAppKey) {
    m_NEAppKey = NEAppKey;
    Q_EMIT neAppKeyChanged();
}

QString NEMeetingSDKManager::displayName() const {
    return m_displayName;
}

void NEMeetingSDKManager::setDisplayName(const QString& displayName) {
    m_displayName = displayName;
    emit displayNameChanged();
}

void SettingsEventHandler::OnAudioSettingsChange(bool status) {
    emit audioSettingsChanged(status);
}

void SettingsEventHandler::OnVideoSettingsChange(bool status) {
    emit videoSettingsChanged(status);
}

void SettingsEventHandler::OnOtherSettingsChange(bool status) {}

// 预定会议
void NEMeetingSDKManager::scheduleMeeting(const QString& meetingSubject,
                                          qint64 startTime,
                                          qint64 endTime,
                                          const QString& password,
                                          bool attendeeAudioOff,
                                          bool enableLive,
                                          bool needLiveAuthentication,
                                          bool enableRecord) {
    QString strPassword = password.isEmpty() ? "null" : "no null";
    YXLOG(Info) << "schedule a meeting with meeting subject:" << meetingSubject.toStdString() << ", startTime: " << startTime
                << ", endTime: " << endTime << ", attendeeAudioOff: " << attendeeAudioOff << ", enablelive : " << enableLive
                << ", password: " << strPassword.toStdString() << YXLOGEnd;

    CHECK_INIT
    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        NEMeetingItem item;
        item.subject = meetingSubject.toUtf8().data();
        item.startTime = startTime;
        item.endTime = endTime;
        item.password = password.toUtf8().data();
        item.setting.attendeeAudioOff = attendeeAudioOff;
        item.setting.cloudRecordOn = enableRecord;
        item.enableLive = enableLive;
        item.liveWebAccessControlLevel = needLiveAuthentication ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_TOKEN;

        ipcPreMeetingService->scheduleMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage, const NEMeetingItem& item) {
            YXLOG(Info) << "Schedule meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit scheduleSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::editMeeting(const qint64& meetingUniqueId,
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
    YXLOG(Info) << "Edit a meeting with meeting subject:" << meetingSubject.toStdString() << ", meetingUniqueId: " << meetingUniqueId
                << ", meetingId: " << meetingId.toStdString() << ", startTime: " << startTime << ", endTime: " << endTime
                << ", attendeeAudioOff: " << attendeeAudioOff << ", enablelive : " << enableLive << ", password: " << strPassword.toStdString()
                << YXLOGEnd;

    CHECK_INIT
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
        item.setting.cloudRecordOn = enableRecord;
        item.enableLive = enableLive;
        item.liveWebAccessControlLevel = needLiveAuthentication ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_TOKEN;

        ipcPreMeetingService->editMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Edit meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit editSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}
void NEMeetingSDKManager::cancelMeeting(const qint64& meetingUniqueId) {
    YXLOG(Info) << "cancel a meeting with meeting uniqueId:" << meetingUniqueId << YXLOGEnd;

    CHECK_INIT
    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        ipcPreMeetingService->cancelMeeting(meetingUniqueId, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Cancel meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit cancelSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::getMeetingList() {
    YXLOG(Info) << "Get meeting list from IPC client." << YXLOGEnd;

    CHECK_INIT
    auto ipcPreMeetingService = NEMeetingSDK::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        std::list<NEMeetingItemStatus> status;
        status.push_back(MEETING_INIT);
        status.push_back(MEETING_STARTED);
        status.push_back(MEETING_ENDED);
        ipcPreMeetingService->getMeetingList(
            status, [this](NEErrorCode errorCode, const std::string& errorMessage, std::list<NEMeetingItem>& meetingItems) {
                YXLOG(Info) << "GetMeetingList callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                QJsonArray jsonArray;
                if (errorCode == ERROR_CODE_SUCCESS) {
                    for (auto& item : meetingItems) {
                        YXLOG(Info) << "Got meeting list, unique meeting ID: " << item.meetingUniqueId << ", meeting ID: " << item.meetingId
                                    << ", topic: " << item.subject << ", start time: " << item.startTime << ", end time: " << item.endTime
                                    << ", create time: " << item.createTime << ", update time: " << item.updateTime << ", status: " << item.status
                                    << ", mute after member join: " << item.setting.attendeeAudioOff << "LiveAuthLevel"
                                    << item.liveWebAccessControlLevel << ", enableRecord: " << item.setting.cloudRecordOn << YXLOGEnd;
                        QJsonObject object;
                        object["uniqueMeetingId"] = item.meetingUniqueId;
                        object["meetingId"] = QString::fromStdString(item.meetingId);
                        object["password"] = QString::fromStdString(item.password);
                        object["topic"] = QString::fromStdString(item.subject);
                        object["startTime"] = item.startTime;
                        object["endTime"] = item.endTime;
                        object["createTime"] = item.createTime;
                        object["updateTime"] = item.updateTime;
                        object["status"] = item.status;
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

void NEMeetingSDKManager::loginBySwitchAppInfo() {
    if (ConfigManager::getInstance()->getLocalDebugLevel()) {
        YXLOG(Debug) << "Login by switch app info, appkey: " << m_switchAppKey.toStdString() << ", account ID: " << m_switchAccountId.toStdString()
                     << ", token: " << m_switchAccountToken.toStdString() << YXLOGEnd;
    } else {
        YXLOG(Info) << "Login by switch app info, appkey: " << m_switchAppKey.toStdString() << YXLOGEnd;
    }
    CHECK_INIT
    auto ipcAuthService = NEMeetingSDK::getInstance()->getAuthService();
    if (ipcAuthService) {
        QByteArray byteAppKey = m_switchAppKey.toUtf8();
        QByteArray byteAccountId = m_switchAccountId.toUtf8();
        QByteArray byteAccountToken = m_switchAccountToken.toUtf8();
        ipcAuthService->login(byteAppKey.data(), byteAccountId.data(), byteAccountToken.data(),
                              [=](NEErrorCode errorCode, const std::string& errorMessage) {
                                  YXLOG(Info) << "Login callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                                  emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                              });
    }

    m_switchAccountId = "";
    m_switchAccountToken = "";
    m_switchAppKey = "";
}

bool NEMeetingSDKManager::getIsSupportLive() {
    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();

    std::promise<bool> bShowLive;
    if (ipcSettingsService) {
        ipcSettingsService->GetLiveController()->isLiveEnabled(
            [&bShowLive](NEErrorCode code, const std::string& message, bool enable) { bShowLive.set_value(enable); });
    }

    std::future<bool> future = bShowLive.get_future();
    bool ret = future.get();

    return ret;
}

void NEMeetingSDKManager::getIsSupportRecord() {
    auto ipcSettingsService = NEMeetingSDK::getInstance()->getSettingsService();

    if (ipcSettingsService) {
        ipcSettingsService->GetRecordController()->isCloudRecordEnabled(
            [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportRecord(enable); });
    }
}
