// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nemeeting_sdk_manager.h"
#include <QElapsedTimer>
#include <future>
#include "auth_manager.h"
#include "base/nem_auth_requests.h"
#include "config_manager.h"
#include "history_manager.h"
#ifdef _WIN32
#include <windows.h>
#include "third_party/neplauncher/include/NEPLauncher.h"

QString g_strToken = "";
bool __stdcall NEP_Init_CALLBACK(LPCSTR msg, uint64_t len, int serviceType) {
    if (16 == serviceType) {
        g_strToken = QString::fromStdString(std::string(msg));
        // YXLOG(Info) << "NEP_Init_CALLBACK, token: " << g_strToken.toStdString() << YXLOGEnd;
        return true;
    }
    return false;
};
#endif

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

const int maxInitRetryTimes = 2;

NEMeetingSDKManager::NEMeetingSDKManager(AuthManager* authManager, HistoryManager* historyManager, QObject* parent)
    : QObject(parent)
    , m_pAuthManager(authManager)
    , m_pHistoryManager(historyManager)
    , m_bAudioAINSEnabled(true)
    , m_bAllowActive(false)
    , m_pSettingsEventHandler(new SettingsEventHandler(this))
    , m_httpManager(new HttpManager(this)) {
    if (ConfigManager::getInstance()->getValue("localMicAINSStatusExTmp", "").toString().isEmpty()) {
        ConfigManager::getInstance()->setValue("localMicAINSStatusExTmp", "defalut");
    }

#ifdef _WIN32
    connect(this, &NEMeetingSDKManager::gotAccountInfo, this, &NEMeetingSDKManager::onGotAccountInfo);
#endif
}

NEMeetingSDKManager::~NEMeetingSDKManager() {
    if (m_bInitialized)
        unInitializeSync();
}

void NEMeetingSDKManager::onGotAccountInfo() {
    YXLOG(Info) << "onGotAccountInfo. " << YXLOGEnd;
    dealwithNEPLauncher(true);
}

void NEMeetingSDKManager::dealwithNEPLauncher(bool bLogin) {
#ifdef _WIN32
    static bool bStartNEPLauncher = false;
    const QString szBusinessId = "7892606f9ad821ad914443b8ea737fd6";
    const QString szProductId = "YD00173223826784";
    if (!bLogin) {
        // 登出
        if (bStartNEPLauncher) {
            if (!NEP_SetRoleInfo(szBusinessId.toStdWString().c_str(), m_NEAccountId.toStdWString().c_str(), m_NEAccountId.toStdWString().c_str(),
                                 m_NEUsername.toStdWString().c_str(), 0, L"", 0, 2, "")) {
                YXLOG(Warn) << "NEP_SetRoleInfo logout failed!" << YXLOGEnd;
            } else {
                YXLOG(Info) << "NEP_SetRoleInfo logout succ." << YXLOGEnd;
            }
        }
    } else {
        // 手机号登入
        if (!ConfigManager::getInstance()->getSSOLogin()) {
            if (!bStartNEPLauncher) {
                if (!NEP_Init(szProductId.toStdWString().c_str(), &NEP_Init_CALLBACK)) {
                    YXLOG(Warn) << "NEP_Init failed!" << YXLOGEnd;
                    return;
                } else {
                    YXLOG(Info) << "NEP_Init succ." << YXLOGEnd;
                }
                bStartNEPLauncher = true;
            }

            if (!NEP_SetRoleInfo(szBusinessId.toStdWString().c_str(), m_NEAccountId.toStdWString().c_str(), m_NEAccountId.toStdWString().c_str(),
                                 m_NEUsername.toStdWString().c_str(), 0, L"", 0, 1, "")) {
                YXLOG(Warn) << "NEP_SetRoleInfo login failed!" << YXLOGEnd;
            } else {
                YXLOG(Info) << "NEP_SetRoleInfo login succ." << YXLOGEnd;
                QElapsedTimer time;
                time.start();
                int maxTime = 5 * 1000;
                while (time.elapsed() <= maxTime && g_strToken.isEmpty()) {
                    std::this_thread::yield();
                }
                if (!g_strToken.isEmpty()) {
                    YXLOG(Info) << "request g_strToken." << YXLOGEnd;
                    nem_auth::NEPLauncherToken request(m_NEAccountId, m_NEAccountToken, g_strToken);
                    m_httpManager->postRequest(request, [](int code, const QJsonObject& response) {
                        if (code == 0) {
                            YXLOG(Info) << "NEPLauncherToken postRequest succ." << YXLOGEnd;
                        }
                    });
                }
            }
        }
    }
#endif
}

void NEMeetingSDKManager::initialize(const QString& appKey, const InitCallback& callback) {
    YXLOG(Info) << "Do initialize." << YXLOGEnd;
    if (m_bInitialized) {
        emit initializeSignal(0, "");
        if (callback)
            callback(NEErrorCode(0), "");
        return;
    }
    setIsSupportLive(ConfigManager::getInstance()->getSSOLogin());
    NEMeetingKitConfig config;
    QString displayName = QObject::tr("NetEase Meeting");
    QByteArray byteDisplayName = displayName.toUtf8();
    QByteArray byteAppKey = appKey.toUtf8();
    config.setAppKey(byteAppKey.data());
    config.getAppInfo()->ProductName(byteDisplayName.data());
    config.getAppInfo()->OrganizationName("NetEase");
    config.getAppInfo()->ApplicationName("Meeting");
    config.setDomain("yunxin.163.com");
    config.setRunAdmin(false);
    config.setUseAssetServerConfig(ConfigManager::getInstance()->getPrivate());
    config.setLanguage(NEMeetingLanguage::kNEAutomatic);
#ifdef QT_NO_DEBUG
#else
    config.getLoggerConfig()->LoggerLevel(NEDEBUG);
#endif

    auto pMeetingSDK = NEMeetingKit::getInstance();
    pMeetingSDK->setLogHandler([this](int level, const std::string& log) {
        if (m_bInitialized) {
            return;  // 暂时去掉日志打印
        }
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
    pMeetingSDK->setExceptionHandler(std::bind(&NEMeetingSDKManager::onException, this, std::placeholders::_1));
    pMeetingSDK->initialize(config, [this, callback](NEErrorCode errorCode, const std::string& errorMessage) {
        YXLOG(Info) << "Initialize callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
        auto pMeetingSDK = NEMeetingKit::getInstance();
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

        auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
        if (ipcSettingsService)
            ipcSettingsService->setNESettingsChangeNotifyHandler(m_pSettingsEventHandler.get());

        m_bInitialized = true;
        emit initializeSignal(errorCode, QString::fromStdString(errorMessage));
        if (callback)
            callback(errorCode, QString::fromStdString(errorMessage));

        Invoker::getInstance()->execute([=]() { onInitMeetingSettings(); });
        // QMetaObject::invokeMethod(this, "onInitMeetingSettings", Qt::AutoConnection);
    });

    if (m_nTryInitTimes < maxInitRetryTimes && !m_bInitialized) {
        YXLOG(Info) << "m_bInitialized: " << m_bInitialized << ", m_nTryInitTimes: " << m_nTryInitTimes << YXLOGEnd;
#ifdef _DEBUG
        constexpr int kInterval = 60 * 60 * 1000;
#else
        constexpr int kInterval = 14 * 1000;
#endif
        QTimer::singleShot(kInterval, this, [=] {
            if (!m_bInitialized) {
                YXLOG(Info) << "Do initialize again start, m_bInitialized: " << m_bInitialized << ", m_nTryInitTimes: " << m_nTryInitTimes
                            << YXLOGEnd;
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
                YXLOG(Info) << "Do initialize again end." << YXLOGEnd;
                if (m_nTryInitTimes == maxInitRetryTimes) {
                    QTimer::singleShot(15 * 1000, this, [=, &bUnInitialize] {
                        YXLOG(Info) << "m_nTryInitTimes == maxInitRetryTimes == " << maxInitRetryTimes << YXLOGEnd;
                        m_bInitialized = true;
                        m_nTryInitTimes = 0;
                        unInitialize([&bUnInitialize](NEErrorCode /*errorCode*/, const QString& /*errorMessage*/) { bUnInitialize = true; });
                        emit initializeSignal(-1, tr("init sdk failed."));
                        if (callback)
                            callback(NEErrorCode(-1), tr("init sdk failed."));
                    });
                }
            }
        });
    }
}

void NEMeetingSDKManager::unInitialize(const UnInitCallback& callback) {
    YXLOG(Info) << "Do uninitialize, initialize flag: " << m_bInitialized << YXLOGEnd;

    if (!m_bInitialized)
        return;

    m_bInitialized = false;

    emit unInitializeFeedback();

    auto pMeetingSDK = NEMeetingKit::getInstance();
    pMeetingSDK->setExceptionHandler(nullptr);

    auto ipcMeetingService = pMeetingSDK->getMeetingService();
    if (ipcMeetingService) {
        ipcMeetingService->addMeetingStatusListener(nullptr);
        ipcMeetingService->setOnInjectedMenuItemClickListener(nullptr);
    }

    auto ipcPreMeetingService = pMeetingSDK->getPremeetingService();
    if (ipcPreMeetingService)
        ipcPreMeetingService->unRegisterScheduleMeetingStatusListener(nullptr);

    auto ipcAuthService = pMeetingSDK->getAuthService();
    if (ipcAuthService)
        ipcAuthService->removeAuthListener(this);

    auto ipcSettingsService = pMeetingSDK->getSettingsService();
    if (ipcSettingsService)
        ipcSettingsService->setNESettingsChangeNotifyHandler(nullptr);

    NEMeetingKit::getInstance()->unInitialize([this, callback](NEErrorCode errorCode, const std::string& errorMessage) {
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
    unInitialize([&bRet, &error, this](NEErrorCode errorCode, const QString& /*errorMessage*/) {
        error = errorCode;
        bRet = true;
        m_nTryInitTimes = 0;
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
    NEMeetingKit::getInstance()->activeWindow([](NEErrorCode /*errorCode*/, const std::string& /*errorMessage*/) {});
}

void NEMeetingSDKManager::loginByPassword(const QString& appKey, const QString& username, const QString& password) {
    YXLOG(Info) << "Request login by password." << YXLOGEnd;
    if (m_bInitialized)
        unInitializeSync();

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto asyncRet = std::async(std::launch::async, [this, username, password, appKey]() {
                auto authService = NEMeetingKit::getInstance()->getAuthService();
                if (authService) {
                    authService->loginWithNEMeeting(username.toStdString(), password.toStdString(),
                                                    [=](NEErrorCode errorCode, const std::string& errorMessage) {
                                                        YXLOG(Info) << "Login with netease meeting account callback, error code: " << errorCode
                                                                    << ", error message: " << errorMessage << YXLOGEnd;
                                                        if (ERROR_CODE_SUCCESS == errorCode) {
                                                        }
                                                        emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                                                    });
                }
            });
        } else {
            emit error((int)errorCode, errorMessage);
        }
    });
}

void NEMeetingSDKManager::loginBySSOToken(const QString& appKey, const QString& ssoUser, const QString& ssoToken) {
    YXLOG(Info) << "Request login by SSO token." << YXLOGEnd;
#if 0
    CHECK_INIT;
#endif

    if (m_bInitialized)
        unInitializeSync();

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto asyncRet = std::async(std::launch::async, [this, appKey, ssoToken]() {
                auto authService = NEMeetingKit::getInstance()->getAuthService();
                if (authService) {
                    authService->loginWithSSOToken(ssoToken.toStdString(), [=](NEErrorCode errorCode, const std::string& errorMessage) {
                        YXLOG(Info) << "Login with SSO token account callback, error code: " << errorCode << ", error message: " << errorMessage
                                    << YXLOGEnd;
                        if (ERROR_CODE_SUCCESS == errorCode) {
                        }
                        emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                    });
                }
            });
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

    auto appKey = ConfigManager::getInstance()->getAPaasAppKey();

    auto accountId = ConfigManager::getInstance()->getValue("localNEAccountId", "").toString();
    auto appKeyTmp = ConfigManager::getInstance()->getValue("localNEAppKey", "").toString();
    if (accountId.isEmpty() || appKey != appKeyTmp) {
        YXLOG(Info) << "Request try auto login, but the cache information does not exist." << YXLOGEnd;
        emit tryAutoLoginSignal(-1, "");
        return;
    }

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            Invoker::getInstance()->execute([=]() {
                auto authService = NEMeetingKit::getInstance()->getAuthService();
                if (authService) {
                    YXLOG(Info) << "tryAutoLogin." << YXLOGEnd;
                    authService->tryAutoLogin([=](NEErrorCode errorCode, const std::string& errorMessage) {
                        YXLOG(Info) << "Try auto login callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                        Q_EMIT tryAutoLoginSignal(errorCode, QString::fromStdString(errorMessage));
                    });
                }
            });
        } else {
            emit error((int)errorCode, errorMessage);
            // emit tryAutoLoginSignal((int)errorCode, errorMessage);
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
        YXLOG(Info) << "Login to apaas server, login type: " << loginType << YXLOGEnd;
    }
#if 0
    CHECK_INIT;
#endif

    if (m_bInitialized)
        unInitializeSync();

    initialize(appKey, [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto asyncRet = std::async(std::launch::async, [this, appKey, accountId, accountToken]() {
                auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
                if (ipcAuthService) {
                    QByteArray byteAccountId = accountId.toUtf8();
                    QByteArray byteAccountToken = accountToken.toUtf8();

                    QString lastAccountId = ConfigManager::getInstance()->getValue("localNEAccountId", "").toString();
                    if (lastAccountId != byteAccountId) {
                        m_bUseNewAccountId = true;
                    } else {
                        m_bUseNewAccountId = false;
                    }

                    ipcAuthService->login(byteAccountId.data(), byteAccountToken.data(), [=](NEErrorCode errorCode, const std::string& errorMessage) {
                        YXLOG(Info) << "Login callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
                        if (ERROR_CODE_SUCCESS == errorCode) {
                        }

                        emit loginSignal(errorCode, QString::fromStdString(errorMessage));
                    });
                }
            });
        } else {
            emit error((int)errorCode, errorMessage);
        }
    });
}

void NEMeetingSDKManager::logout(bool cleanup /* = false*/) {
    YXLOG(Info) << "Logout from apaas server, cleanup:" << cleanup << YXLOGEnd;

    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
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
                setPersonalShortMeetingNum("");
                setPersonalMeetingId("");
                setDisplayName("");
                m_builtinMenuItems.clear();
                m_bConfigInitialized = false;
            }
            emit logoutSignal(errorCode, QString::fromStdString(errorMessage));
            dealwithNEPLauncher(false);
        });
    }
}

void NEMeetingSDKManager::showSettings() {
    YXLOG(Info) << "Post show settings request." << YXLOGEnd;
    CHECK_INIT
    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->showSettingUIWnd(NESettingsUIWndConfig(), [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Show settings wnd callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit showSettingsSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::invokeStart(const QString& meetingId,
                                      const QString& nickname,
                                      const QString& password,
                                      bool audio,
                                      bool video,
                                      bool enableRecord) {
    m_bAllowActive = true;
    YXLOG(Info) << "Start a meeting with meeting ID:" << meetingId.toStdString() << ", nickname: " << nickname.toStdString() << ", audio: " << audio
                << ", video: " << video << ", password: " << password.toStdString() << YXLOGEnd;

    CHECK_INIT

    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
#ifdef _WIN32
        if (!ConfigManager::getInstance()->getSSOLogin()) {
            YXLOG(Info) << "request g_strToken." << YXLOGEnd;
            nem_auth::NEPLauncherToken request(m_NEAccountId, m_NEAccountToken, g_strToken);
            m_httpManager->postRequest(request, [](int code, const QJsonObject& response) {
                if (code == 0) {
                    YXLOG(Info) << "NEPLauncherToken postRequest succ." << YXLOGEnd;
                }
            });
        }
#endif
        auto lastmeetingId = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString();
        auto lastshortmeetingId = ConfigManager::getInstance()->getValue("localLastMeetingshortId", "").toString();
        QByteArray byteNickname = "";
        QByteArray byteMeetingId = meetingId.toUtf8();
        QByteArray bytePassword = password.toUtf8();
        // 当前会议与上次会议一致时，优先使用上次会议中昵称
        if (byteMeetingId == lastmeetingId || (lastshortmeetingId == byteMeetingId && meetingId != "")) {
            byteNickname = ConfigManager::getInstance()->getValue("localLastModifyNickname", "").toString().toUtf8();
            if (byteNickname == "") {
                byteNickname = nickname.toUtf8();
            }
        } else {
            byteNickname = nickname.toUtf8();
        }

        NEStartMeetingParams params;
        params.meetingNum = byteMeetingId.data();
        params.displayName = byteNickname.data();
        params.password = bytePassword.data();

        NEStartMeetingOptions options;
        options.noAudio = !audio;
        options.noVideo = !video;
        options.noCloudRecord = !enableRecord;
        //        options.noWhiteboard = true;
        //        options.noRename = true;
        options.meetingIdDisplayOption = kDisplayAll;
        options.audioAINSEnabled = m_bAudioAINSEnabled;
        options.noMuteAllVideo = false;
        //        if(m_pAuthManager && m_pAuthManager->phoneNumber().isEmpty()) {
        //            options.noSip = false;
        //        }
        options.noSip = false;
        options.showMeetingRemainingTip = true;

        NEMeetingMenuItem menuItem;
#ifdef Q_OS_WIN32
        QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/" + "feedback.png").toUtf8();
        menuItem.itemImage = byteImage.data();
        QByteArray byteImage2 = QString(QGuiApplication::applicationDirPath() + "/" + "feedback_upload.png").toUtf8();
        menuItem.itemImage2 = byteImage2.data();
#else
        QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback.png").toUtf8();
        menuItem.itemImage = byteImage.data();
        QByteArray byteImage2 = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback_upload.png").toUtf8();
        menuItem.itemImage2 = byteImage2.data();
#endif
        YXLOG(Info) << "Set feedback item icon: " << menuItem.itemImage << YXLOGEnd;
        menuItem.itemId = 101;
        menuItem.itemTitle = tr("Feedback").toStdString();
        menuItem.itemTitle2 = menuItem.itemTitle;
        std::vector<int> menuItemsId;
        std::atomic_bool getItemsFinish;
        getItemsFinish = !m_builtinMenuItems.empty();
        if (!getItemsFinish) {
            ipcMeetingService->getBuiltinMenuItems(menuItemsId, [&](int code, const std::string& msg, std::vector<NEMeetingMenuItem> items) {
                m_builtinMenuItems = items;
                getItemsFinish = true;
            });

            while (!getItemsFinish) {
                std::this_thread::yield();
            }
        }

        for (auto& item : m_builtinMenuItems) {
            if (item.itemId == kWhiteboardMenuId) {
                options.full_more_menu_items_.emplace_back(item);
            } else {
                options.full_toolbar_menu_items_.emplace_back(item);
            }
        }
        options.full_toolbar_menu_items_.emplace_back(menuItem);

        ipcMeetingService->startMeeting(params, options, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Start meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            QString qstrErrorMessage = QString::fromStdString(errorMessage);
            if (qstrErrorMessage == "IM disconnect") {
                qstrErrorMessage = tr("Failed to connect to server, please try agine.");
            }
            emit startSignal(errorCode, qstrErrorMessage);
        });
    }
}

void NEMeetingSDKManager::invokeJoin(const QString& meetingId, const QString& nickname, bool audio, bool video, bool anonJoinMode /* = false*/) {
    m_bAllowActive = true;
    m_inviteMeetingId = "";

    YXLOG(Info) << "Join a meeting with meeting ID:" << meetingId.toStdString() << ", nickname: " << nickname.toStdString() << ", audio: " << audio
                << ", video: " << video << YXLOGEnd;

    auto task = [=](NEErrorCode errorCode, const QString& errorMessage) {
        if (errorCode == ERROR_CODE_SUCCESS) {
            auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
            if (ipcMeetingService) {
#ifdef _WIN32
                if (!ConfigManager::getInstance()->getSSOLogin()) {
                    YXLOG(Info) << "request g_strToken." << YXLOGEnd;
                    nem_auth::NEPLauncherToken request(m_NEAccountId, m_NEAccountToken, g_strToken);
                    m_httpManager->postRequest(request, [](int code, const QJsonObject& response) {
                        if (code == 0) {
                            YXLOG(Info) << "NEPLauncherToken postRequest succ." << YXLOGEnd;
                        }
                    });
                }
#endif
                auto lastmeetingId = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString();
                auto lastshortmeetingId = ConfigManager::getInstance()->getValue("localLastMeetingshortId", "").toString();
                QByteArray byteNickname = "";
                QByteArray byteMeetingId = meetingId.toUtf8();
                if ((byteMeetingId == lastmeetingId || byteMeetingId == lastshortmeetingId) &&
                    ConfigManager::getInstance()->getValue("localNELoginType") != kLoginTypeSSOToken && !anonJoinMode && !m_bUseNewAccountId) {
                    byteNickname = ConfigManager::getInstance()->getValue("localLastModifyNickname", "").toString().toUtf8();
                    if (byteNickname == "") {
                        byteNickname = nickname.toUtf8();
                    }
                } else {
                    byteNickname = nickname.toUtf8();
                }

                YXLOG(Info) << "Join meeting byteNickname: " << byteNickname.toStdString() << YXLOGEnd;

                if (m_bUseNewAccountId) {
                    m_bUseNewAccountId = false;
                    ConfigManager::getInstance()->setValue("localLastModifyNickname", "");
                    ConfigManager::getInstance()->setValue("localLastNickname", "");
                }

                NEJoinMeetingParams params;
                params.meetingNum = byteMeetingId.data();
                params.displayName = byteNickname.data();

                NEJoinMeetingOptions options;
                options.noAudio = !audio;
                options.noVideo = !video;
                //                options.noWhiteboard = true;
                //                options.noRename = true;
                options.meetingIdDisplayOption = kDisplayAll;
                options.audioAINSEnabled = m_bAudioAINSEnabled;
                options.noMuteAllVideo = false;
                //                if(m_pAuthManager && m_pAuthManager->phoneNumber().isEmpty()) {
                //                    options.noSip = false;
                //                }
                options.noSip = false;
                options.showMeetingRemainingTip = true;

                NEMeetingMenuItem menuItem;
#ifdef Q_OS_WIN32
                QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/" + "feedback.png").toUtf8();
                menuItem.itemImage = byteImage.data();
                QByteArray byteImage2 = QString(QGuiApplication::applicationDirPath() + "/" + "feedback_upload.png").toUtf8();
                menuItem.itemImage2 = byteImage2.data();
#else
                QByteArray byteImage = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback.png").toUtf8();
                menuItem.itemImage = byteImage.data();
                QByteArray byteImage2 = QString(QGuiApplication::applicationDirPath() + "/../Resources/feedback_upload.png").toUtf8();
                menuItem.itemImage2 = byteImage2.data();
#endif
                YXLOG(Info) << "Set feedback item icon: " << menuItem.itemImage << YXLOGEnd;
                menuItem.itemId = 101;
                menuItem.itemTitle = tr("Feedback").toStdString();
                menuItem.itemTitle2 = menuItem.itemTitle;
                std::vector<int> menuItemsId;
                std::atomic_bool getItemsFinish;
                getItemsFinish = !m_builtinMenuItems.empty();
                if (!getItemsFinish) {
                    ipcMeetingService->getBuiltinMenuItems(menuItemsId, [&](int code, const std::string& msg, std::vector<NEMeetingMenuItem> items) {
                        m_builtinMenuItems = items;
                        getItemsFinish = true;
                    });

                    while (!getItemsFinish) {
                        std::this_thread::yield();
                    }
                }
                for (auto& item : m_builtinMenuItems) {
                    if (item.itemId == kWhiteboardMenuId) {
                        options.full_more_menu_items_.emplace_back(item);
                    } else {
                        options.full_toolbar_menu_items_.emplace_back(item);
                    }
                }
                options.full_toolbar_menu_items_.emplace_back(menuItem);

                ipcMeetingService->joinMeeting(params, options, [this, meetingId](NEErrorCode errorCode, const std::string& errorMessage) {
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
        auto taskAsync = [task](NEErrorCode errorCode, const QString& errorMessage) {
            auto asyncRet = std::async(std::launch::async, [task, errorCode, errorMessage]() { task(errorCode, errorMessage); });
        };
        initialize(defaultKey.toString(), taskAsync);
    } else {
        task(ERROR_CODE_SUCCESS, "");
    }
}

void NEMeetingSDKManager::getAccountInfo() {
    YXLOG(Info) << "getAccountInfo." << YXLOGEnd;
    CHECK_INIT
    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
    if (ipcAuthService) {
        ipcAuthService->getAccountInfo([this](NEErrorCode errorCode, const std::string& errorMessage, AccountInfo info) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                YXLOG(Info) << "getAccountInfo callback, personal meeting ID: " << info.personalMeetingId
                            << ", short meeting ID: " << info.shortMeetingNum << ", display name: " << info.accountName
                            << ", login type: " << info.loginType << ", username: " << info.username << YXLOGEnd;
                setNEUsername(QString::fromStdString(info.username));
                setNEAppKey(QString::fromStdString(info.appKey));
                setNEAccountId(QString::fromStdString(info.accountId));
                setNEAccountToken(QString::fromStdString(info.accountToken));
                setNELoginType(info.loginType);
                setPersonalShortMeetingNum(QString::fromStdString(info.shortMeetingNum));
                setPersonalMeetingId(QString::fromStdString(info.personalMeetingId));
                setDisplayName(QString::fromStdString(info.accountName));
                if (m_pAuthManager) {
                    m_pAuthManager->setAPaasAccountId(neAccountId());
                    m_pAuthManager->setAPaasAccountToken(neAccountToken());
                    m_pAuthManager->setAppUserNick(neUsername());
                    m_pAuthManager->setPersonalMeetingId(personalMeetingId());
                    m_pAuthManager->setPersonalShortMeetingNum(personalShortMeetingNum());
                    m_pAuthManager->setCurDisplayCompany(
                        (nem_sdk_interface::kLoginTypeNEAccount == info.loginType && m_pAuthManager->phoneNumber().isEmpty())
                            ? tr("Enterprise Edition")
                            : tr("Free Edition"));
                }

                QString logPathEx = qApp->property("logPath").toString();
                if (logPathEx.isEmpty())
                    logPathEx = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
                do {
                    if (logPathEx.endsWith("/")) {
                        logPathEx = logPathEx.left(logPathEx.size() - 1);
                    } else if (logPathEx.endsWith("\\")) {
                        logPathEx = logPathEx.left(logPathEx.size() - 1);
                    } else {
                        break;
                    }
                } while (true);

                logPathEx.append("_Files/").append(QString::fromStdString(info.accountId)).append("/db/");
                m_pHistoryManager->init(logPathEx);

                emit gotAccountInfo();
            } else {
                emit error(errorCode, QString::fromStdString(errorMessage));
            }
        });
    }
}

void NEMeetingSDKManager::getMeetingUserList() {
    YXLOG(Info) << "Post getMeetingUserList request." << YXLOGEnd;
    CHECK_INIT

    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        ipcMeetingService->getCurrentMeetingInfo([this](NEErrorCode errorCode, const std::string& errorMessage, NEMeetingInfo info) {
            if (errorCode == ERROR_CODE_SUCCESS) {
                QJsonArray array;
                for (auto user : info.userList) {
                    if (user.userId == m_NEAccountId.toStdString()) {
                        continue;
                    }
                    QJsonObject obj;
                    obj["accountId"] = QString::fromStdString(user.userId);
                    obj["nickname"] = QString::fromStdString(user.userName);
                    array.append(obj);
                }
                emit getMeetingUserListSignal(array);
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

QString NEMeetingSDKManager::personalShortMeetingNum() const {
    return m_shortPersonalMeetingId;
}

void NEMeetingSDKManager::setPersonalShortMeetingNum(const QString& shortMeetingNum) {
    m_shortPersonalMeetingId = shortMeetingNum;
    emit personalShortMeetingNumChanged();
}

void NEMeetingSDKManager::onKickOut() {
    YXLOG(Info) << "Received onKickOut." << YXLOGEnd;
    emit kickOut();
    dealwithNEPLauncher(false);
}

void NEMeetingSDKManager::onAuthInfoExpired() {
    YXLOG(Info) << "Received auth information expired notification." << YXLOGEnd;
    ConfigManager::getInstance()->setValue("localUserId", "");
    ConfigManager::getInstance()->setValue("localUserToken", "");
    emit authInfoExpired();
    dealwithNEPLauncher(false);
}

void NEMeetingSDKManager::onMeetingStatusChanged(int status, int code) {
    YXLOG(Info) << "Received meeting status changed event, status: " << status << ", code: " << code << YXLOGEnd;
    QMetaObject::invokeMethod(this, "onMeetingStatusChangedUI", Qt::AutoConnection, Q_ARG(int, status), Q_ARG(int, code));
    emit meetingStatusChanged(status, code);
}

void NEMeetingSDKManager::onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) {
    YXLOG(Info) << "Scheduled meeting status changed, unique meeting ID: " << uniqueMeetingId << ", meeting status: " << meetingStatus << YXLOGEnd;
    // getMeetingList();
    QMetaObject::invokeMethod(this, "onGetMeetingListUI", Qt::AutoConnection);
}

void NEMeetingSDKManager::onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) {
    YXLOG(Info) << "onInjectedMenuItemClick Received menu item clicked event, item GUID: " << meeting_menu_item.itemGuid
                << ", ID: " << meeting_menu_item.itemId << ", title: " << meeting_menu_item.itemTitle << YXLOGEnd;
    if (meeting_menu_item.itemId == 101) {
        Q_EMIT feedback();
    }
}

void NEMeetingSDKManager::onInjectedMenuItemClickEx(const NEMeetingMenuItem& meeting_menu_item, const NEInjectedMenuItemClickCallback& cb) {
    YXLOG(Info) << "onInjectedMenuItemClickEx Received menu item clicked event, item GUID: " << meeting_menu_item.itemGuid
                << ", ID: " << meeting_menu_item.itemId << ", title: " << meeting_menu_item.itemTitle << YXLOGEnd;
    if (meeting_menu_item.itemId == 101) {
        Q_EMIT feedback();
    }
}

void NEMeetingSDKManager::onDockClicked() {
    if (4 != m_nCurrentMeetingStatus) {
        emit showWindow();
    }

    if (!m_bInitialized || !m_bAllowActive)
        return;

    YXLOG(Info) << "Request active window, send command to IPC module." << YXLOGEnd;
    NEMeetingKit::getInstance()->activeWindow([](NEErrorCode /*errorCode*/, const std::string& /*errorMessage*/) {});
}

void NEMeetingSDKManager::onGetMeetingListUI() {
    YXLOG(Info) << "Get meeting list from UI thread." << YXLOGEnd;
    getMeetingList();
}

void NEMeetingSDKManager::onInitMeetingSettings() {
    YXLOG(Info) << "onInitMeetingSettings." << YXLOGEnd;
    if (ConfigManager::getInstance()->getValue("localMicAINSStatusExTmp", "").toString() == "defalut") {
        NEMeetingKit::getInstance()->getSettingsService()->GetAudioController()->setTurnOnMyAudioAINSWhenInMeeting(
            true, [](NEErrorCode errorCode, const std::string& errorMessage) {
                qInfo() << "setTurnOnMyAudioAINSWhenInMeeting callback, error code: " << errorCode
                        << ", error message: " << QString::fromStdString(errorMessage);
            });
    }

    if (!ConfigManager::getInstance()->getValue("enableBeauty", false).toBool()) {
        NEMeetingKit::getInstance()->getSettingsService()->GetBeautyFaceController()->enableBeautyFace(
            true, [=](NEErrorCode errorCode, const std::string& errorMessage, const bool& enabled) {
                qInfo() << "enableBeautyFace callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage)
                        << ", enabled: " << enabled;
            });
    }

    if (!ConfigManager::getInstance()->contains("localEnableUnmuteBySpace")) {
        NEMeetingKit::getInstance()->getSettingsService()->GetOtherController()->enableUnmuteBySpace(
            true, [](NEErrorCode errorCode, const std::string& errorMessage) {
                qInfo() << "enableUnmuteBySpace callback, error code: " << errorCode << ", error message: " << QString::fromStdString(errorMessage);
            });
    }

    if (!ConfigManager::getInstance()->contains("audioRecordDeviceUseLastSelected")) {
        auto settingsService = NEMeetingKit::getInstance()->getSettingsService();
        if (!settingsService)
            return;
        auto audioController = settingsService->GetAudioController();
        if (!audioController)
            return;
        audioController->setMyAudioDeviceUseLastSelected(true, [](NEErrorCode errorCode, const std::string& errorMessage) {
            qInfo() << "setMyAudioDeviceUseLastSelected callback, error code: " << errorCode
                    << ", error message: " << QString::fromStdString(errorMessage);
        });
    }
}

void NEMeetingSDKManager::onInviteByLink(const QString& meetingId) {
    YXLOG(Info) << "onInviteByLink meetingId: " << meetingId.toStdString() << YXLOGEnd;
    if (m_NEAccountId.isEmpty()) {
        // not login, save inviteMeetingId
        m_inviteMeetingId = meetingId;
        QTimer::singleShot(500, [this] { emit inviteFailed(); });
    } else {
        // already login, join meeting
        if (m_nCurrentMeetingStatus == 4 && !m_currentMeetingId.isEmpty()) {
            NEMeetingKit::getInstance()->activeWindow([](NEErrorCode /*errorCode*/, const std::string& /*errorMessage*/) {});
            inviteFailed(meetingId == m_currentMeetingId);
            return;
        }
        invokeJoin(meetingId, m_pAuthManager->appUserNick(), false, false);
    }
}

std::string NEMeetingSDKManager::covertStatusToString(RunningStatus::Status status) const {
    switch (status) {
        case MEETING_STATUS_FAILED:
            return "MEETING_STATUS_FAILED";
        case MEETING_STATUS_IDLE:
            return "MEETING_STATUS_IDLE";
        case MEETING_STATUS_WAITING:
            return "MEETING_STATUS_WAITING";
        case MEETING_STATUS_CONNECTING:
            return "MEETING_STATUS_CONNECTING";
        case MEETING_STATUS_INMEETING:
            return "MEETING_STATUS_INMEETING";
        case MEETING_STATUS_DISCONNECTING:
            return "MEETING_STATUS_DISCONNECTING";
        default:
            return "MEETING_STATUS_UNKNOWN";
    }
    return "MEETING_STATUS_UNKNOWN";
}

void NEMeetingSDKManager::onMeetingStatusChangedUI(int status, int code) {
    YXLOG(Info) << "Meeting status changed UI, status: " << covertStatusToString(static_cast<RunningStatus::Status>(status)) << ", code: " << code
                << YXLOGEnd;
    m_nCurrentMeetingStatus = status;
    if (m_nCurrentMeetingStatus == RunningStatus::Status::MEETING_STATUS_INMEETING) {
        setLastMeetingDuration(0);
        m_meetingDurationClock = QDateTime::currentSecsSinceEpoch();
        auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
        if (ipcMeetingService) {
            ipcMeetingService->getCurrentMeetingInfo([this](NEErrorCode errorCode, const std::string& errorMessage, NEMeetingInfo info) {
                if (errorCode == ERROR_CODE_SUCCESS) {
                    m_currentMeetingId = QString::fromStdString(info.meetingNum);
                }
            });
        }
    } else {
        m_currentMeetingId = "";
    }
    if (m_nCurrentMeetingStatus == RunningStatus::Status::MEETING_STATUS_DISCONNECTING) {
        setLastMeetingDuration(QDateTime::currentSecsSinceEpoch() - m_meetingDurationClock);
    }
}

void NEMeetingSDKManager::onException(const NEException& exception) {
    // if (m_bInitialized) {
    YXLOG(Error) << "Received exception, error code: " << exception.ExceptionCode() << ", error message: " << exception.ExceptionMessage()
                 << YXLOGEnd;
    qApp->exit(0);
    // }
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

bool NEMeetingSDKManager::isSupportLive() const {
    return m_bSupportLive;
}

void NEMeetingSDKManager::setIsSupportLive(bool isSupportLive) {
    YXLOG(Info) << "setIsSupportLive: " << isSupportLive << YXLOGEnd;
    m_bSupportLive = isSupportLive;
    Q_EMIT isSupportLiveChanged();
}

qint64 NEMeetingSDKManager::lastMeetingDuration() const {
    return m_nLastMeetingDuration;
}

void NEMeetingSDKManager::setLastMeetingDuration(qint64 lastMeetingDuration) {
    m_nLastMeetingDuration = lastMeetingDuration;
    Q_EMIT lastMeetingDurationChanged();
}

void NEMeetingSDKManager::setAudioAINSEnabled(bool bAudioAINSEnabled) {
    m_bAudioAINSEnabled = bAudioAINSEnabled;
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
    YXLOG(Info) << "OnAudioSettingsChange, status: " << status << YXLOGEnd;
    emit audioSettingsChanged(status);
}

void SettingsEventHandler::OnVideoSettingsChange(bool status) {
    YXLOG(Info) << "OnVideoSettingsChange, status: " << status << YXLOGEnd;
    emit videoSettingsChanged(status);
}

void SettingsEventHandler::OnAudioAINSSettingsChange(bool status) {
    YXLOG(Info) << "OnAudioAINSSettingsChange, status: " << status << YXLOGEnd;
    if (!ConfigManager::getInstance()->getValue("localMicAINSStatusExTmp", "").toString().isEmpty()) {
        ConfigManager::getInstance()->setValue("localMicAINSStatusExTmp", "setting");
    }
    if (m_pNEMeetingSDKManager) {
        m_pNEMeetingSDKManager->setAudioAINSEnabled(status);
    }
}

void SettingsEventHandler::OnAudioVolumeAutoAdjustSettingsChange(bool status) {
    YXLOG(Info) << "OnAudioVolumeAutoAdjustSettingsChange, status: " << status << YXLOGEnd;
}

void SettingsEventHandler::OnAudioQualitySettingsChange(AudioQuality enumAudioQuality) {
    YXLOG(Info) << "OnAudioQualitySettingsChange, enumAudioQuality: " << (int)enumAudioQuality << YXLOGEnd;
}

void SettingsEventHandler::OnAudioEchoCancellationSettingsChange(bool status) {
    YXLOG(Info) << "OnAudioEchoCancellationSettingsChange, status: " << status << YXLOGEnd;
}

void SettingsEventHandler::OnAudioEnableStereoSettingsChange(bool status) {
    YXLOG(Info) << "OnAudioEnableStereoSettingsChange, status: " << status << YXLOGEnd;
}

void SettingsEventHandler::OnRemoteVideoResolutionSettingsChange(RemoteVideoResolution enumRemoteVideoResolution) {
    YXLOG(Info) << "OnRemoteVideoResolutionSettingsChange, enumRemoteVideoResolution: " << (int)enumRemoteVideoResolution << YXLOGEnd;
}

void SettingsEventHandler::OnMyVideoResolutionSettingsChange(LocalVideoResolution enumLocalVideoResolution) {
    YXLOG(Info) << "OnMyVideoResolutionSettingsChange, enumLocalVideoResolution: " << (int)enumLocalVideoResolution << YXLOGEnd;
}

void SettingsEventHandler::OnOtherSettingsChange(bool status) {
    YXLOG(Info) << "OnOtherSettingsChange, status: " << status << YXLOGEnd;
}

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
    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        NEMeetingItem item;
        item.subject = meetingSubject.toUtf8().data();
        item.startTime = startTime;
        item.endTime = endTime;
        item.password = password.toUtf8().data();
        if (attendeeAudioOff) {
            NEMeetingControl control;
            control.type = kControlTypeAudio;
            control.attendeeOff = kAttendeeOffAllowSelfOn;
            item.setting.controls.push_back(control);
        }
        item.setting.cloudRecordOn = enableRecord;
        item.enableLive = enableLive;
        item.liveWebAccessControlLevel = needLiveAuthentication ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_TOKEN;
        item.noSip = false;
        //        if(m_pAuthManager && m_pAuthManager->phoneNumber().isEmpty()) {
        //            item.noSip = false;
        //        }

        ipcPreMeetingService->scheduleMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage, const NEMeetingItem& item) {
            YXLOG(Info) << "Schedule meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            QString strMsg = QString::fromStdString(errorMessage);
            if (errorCode == 3412) {
                strMsg = tr("Meeting duration too long!");
            }
            emit scheduleSignal(errorCode, strMsg);
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
    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        NEMeetingItem item;
        item.meetingId = meetingUniqueId;
        item.meetingNum = meetingId.toUtf8().data();
        item.subject = meetingSubject.toUtf8().data();
        item.startTime = startTime;
        item.endTime = endTime;
        item.password = password.toUtf8().data();
        NEMeetingControl control;
        control.type = kControlTypeAudio;
        control.attendeeOff = attendeeAudioOff ? kAttendeeOffAllowSelfOn : kAttendeeOffNone;
        item.setting.controls.push_back(control);
        item.setting.cloudRecordOn = enableRecord;
        item.enableLive = enableLive;
        item.liveWebAccessControlLevel = needLiveAuthentication ? LIVE_ACCESS_APP_TOKEN : LIVE_ACCESS_TOKEN;
        item.noSip = false;
        //        if(m_pAuthManager && m_pAuthManager->phoneNumber().isEmpty()) {
        //            item.noSip = false;
        //        }

        ipcPreMeetingService->editMeeting(item, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Edit meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            QString strMsg = QString::fromStdString(errorMessage);
            if (errorCode == 3412) {
                strMsg = tr("Meeting duration too long!");
            }
            emit editSignal(errorCode, strMsg);
        });
    }
}
void NEMeetingSDKManager::cancelMeeting(const qint64& meetingUniqueId) {
    YXLOG(Info) << "cancel a meeting with meeting uniqueId:" << meetingUniqueId << YXLOGEnd;

    CHECK_INIT
    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        ipcPreMeetingService->cancelMeeting(meetingUniqueId, [this](NEErrorCode errorCode, const std::string& errorMessage) {
            YXLOG(Info) << "Cancel meeting callback, error code: " << errorCode << ", error message: " << errorMessage << YXLOGEnd;
            emit cancelSignal(errorCode, QString::fromStdString(errorMessage));
        });
    }
}

void NEMeetingSDKManager::getMeetingList() {
    YXLOG(Info) << "[NEMeetingSDKManager] Get meeting list." << YXLOGEnd;

    CHECK_INIT
    auto ipcPreMeetingService = NEMeetingKit::getInstance()->getPremeetingService();
    if (ipcPreMeetingService) {
        std::list<NEMeetingItemStatus> status;
        status.push_back(MEETING_INIT);
        status.push_back(MEETING_STARTED);
        status.push_back(MEETING_ENDED);
        ipcPreMeetingService->getMeetingList(
            status, [this](NEErrorCode errorCode, const std::string& errorMessage, std::list<NEMeetingItem>& meetingItems) {
                YXLOG(Info) << "[NEMeetingSDKManager] Get meeting list callback, error code: " << errorCode << ", error message: " << errorMessage
                            << YXLOGEnd;
                initConfig();
                QJsonArray jsonArray;
                if (errorCode == ERROR_CODE_SUCCESS) {
                    for (auto& item : meetingItems) {
                        YXLOG(Info) << "Got meeting list, unique meeting ID: " << item.meetingId << ", meeting ID: " << item.meetingNum
                                    << ", topic: " << item.subject << ", start time: " << item.startTime << ", end time: " << item.endTime
                                    << ", create time: " << item.createTime << ", update time: " << item.updateTime << ", status: " << item.status
                                    << ", mute after member join: " << item.setting.attendeeAudioOff << "LiveAuthLevel"
                                    << item.liveWebAccessControlLevel << ", enableRecord: " << item.setting.cloudRecordOn
                                    << ", inviteUrl: " << item.inviteUrl << ", enableLive: " << item.enableLive << YXLOGEnd;
                        QJsonObject object;
                        object["uniqueMeetingId"] = item.meetingId;
                        object["meetingId"] = QString::fromStdString(item.meetingNum);
                        object["password"] = QString::fromStdString(item.password);
                        object["topic"] = QString::fromStdString(item.subject);
                        object["startTime"] = item.startTime;
                        object["endTime"] = item.endTime;
                        object["createTime"] = item.createTime;
                        object["updateTime"] = item.updateTime;
                        object["status"] = item.status;
                        bool attendeeAudioOff = false;
                        for (auto control : item.setting.controls) {
                            if (control.type == kControlTypeAudio) {
                                attendeeAudioOff = control.attendeeOff != kAttendeeOffNone;
                            }
                        }
                        object["attendeeAudioOff"] = attendeeAudioOff;
                        object["enableLive"] = item.enableLive;
                        object["liveAccess"] = item.liveWebAccessControlLevel == LIVE_ACCESS_APP_TOKEN;
                        object["liveUrl"] = QString::fromStdString(item.liveUrl);
                        object["inviteUrl"] = QString::fromStdString(item.inviteUrl);
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
    auto ipcAuthService = NEMeetingKit::getInstance()->getAuthService();
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

void NEMeetingSDKManager::getIsSupportLive() {
    YXLOG(Info) << "[NEMeetingSDKManager] Get is support livestream." << YXLOGEnd;
    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->GetLiveController()->isLiveEnabled(
            [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportLive(enable); });
    }
}

void NEMeetingSDKManager::getIsSupportRecord() {
    YXLOG(Info) << "getIsSupportRecord." << YXLOGEnd;
    auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
    if (ipcSettingsService) {
        ipcSettingsService->GetRecordController()->isCloudRecordEnabled(
            [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportRecord(enable); });
    }
}

void NEMeetingSDKManager::getNeedResumeMeeting() {
    QString lastMeetingId = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString();
    int lastMeetingStatus = ConfigManager::getInstance()->getValue("lastMeetingStatus", "").toInt();
    int lastExceptionTime = ConfigManager::getInstance()->getValue("lastExceptionTime", "").toInt();
    qint64 timestamp = QDateTime::currentDateTime().toSecsSinceEpoch();

    YXLOG(Info) << "lastMeetingId:" << lastMeetingId.toStdString() << YXLOGEnd;
    YXLOG(Info) << "lastMeetingStatus:" << lastMeetingStatus << YXLOGEnd;
    YXLOG(Info) << "lastExceptionTime:" << lastExceptionTime << YXLOGEnd;
    YXLOG(Info) << "currentTimestamp:" << timestamp << YXLOGEnd;

    if ((timestamp <= lastExceptionTime + 15 * 60) && (lastMeetingStatus == 4 || lastMeetingStatus == 3)) {
        emit resumeMeetingSignal(lastMeetingId);
        ConfigManager::getInstance()->setValue("lastMeetingStatus", 1);
    }
}

void NEMeetingSDKManager::addHistoryInfo() {
    YXLOG(Info) << "addHistoryInfo." << YXLOGEnd;
    CHECK_INIT

    auto ipcMeetingService = NEMeetingKit::getInstance()->getMeetingService();
    if (ipcMeetingService) {
        YXLOG(Info) << "Post getCurrentMeetingInfo request." << YXLOGEnd;
        ipcMeetingService->getCurrentMeetingInfo([this](NEErrorCode errorCode, const std::string& errorMessage, NEMeetingInfo info) {
            YXLOG(Info) << "getCurrentMeetingInfo meetingCreatorName: " << info.meetingCreatorName << YXLOGEnd;
            // Invoker::getInstance()->execute([=]() {
            if (errorCode == ERROR_CODE_SUCCESS) {
                HistoryMeetingInfo historyMeetingInfo;
                historyMeetingInfo.isCollect = false;
                historyMeetingInfo.meetingID = QString::fromStdString(info.meetingNum);
                historyMeetingInfo.meetingUniqueID = info.meetingId;
                historyMeetingInfo.meetingSuject = QString::fromStdString(info.subject);
                historyMeetingInfo.meetingCreator = QString::fromStdString(info.meetingCreatorName);
                historyMeetingInfo.meetingJoinTime = QDateTime::currentDateTime().toMSecsSinceEpoch();
                historyMeetingInfo.meetingStartTime = info.startTime;
                m_pHistoryManager->addHistoryMeeting(historyMeetingInfo);
            }
            //});
        });
    }
}

int NEMeetingSDKManager::getCurrentMeetingStatus() const {
    return m_nCurrentMeetingStatus;
}

QString NEMeetingSDKManager::getInviteMeetingId() const {
    return m_inviteMeetingId;
}

void NEMeetingSDKManager::initConfig() {
    if (m_bConfigInitialized)
        return;
    auto asyncRet = std::async(std::launch::async, [this]() {
        auto ipcSettingsService = NEMeetingKit::getInstance()->getSettingsService();
        if (ipcSettingsService) {
            auto audioController = ipcSettingsService->GetAudioController();
            if (audioController) {
                YXLOG(Info) << "getIsTurnOnMyAudioAINSWhenInMeetingEnabled." << YXLOGEnd;
                audioController->isTurnOnMyAudioAINSWhenInMeetingEnabled([this, ipcSettingsService](NEErrorCode code, const std::string& message,
                                                                                                    bool enable) {
                    setAudioAINSEnabled(enable);
                    std::async(std::launch::async, [this, ipcSettingsService]() {
                        if (ipcSettingsService->GetLiveController()) {
                            m_bConfigInitialized = true;
                            YXLOG(Info) << "[NEMeetingSDKManager] Init config get is support livestream." << YXLOGEnd;
                            ipcSettingsService->GetLiveController()->isLiveEnabled(
                                [this, ipcSettingsService](NEErrorCode code, const std::string& message, bool enable) {
                                    setIsSupportLive(enable);
                                    std::async(std::launch::async, [this, ipcSettingsService]() {
                                        if (ipcSettingsService->GetRecordController()) {
                                            YXLOG(Info) << "getIsSupportRecord." << YXLOGEnd;
                                            ipcSettingsService->GetRecordController()->isCloudRecordEnabled(
                                                [this](NEErrorCode code, const std::string& message, bool enable) { setIsSupportRecord(enable); });
                                        }
                                    });
                                });
                        }
                    });
                });
            }
        }
    });
}

QString NEMeetingSDKManager::getThirdPartyCopyrightFile() const {
#ifdef Q_OS_WIN32
    return QGuiApplication::applicationDirPath() + "/" + "THIRD_PARTY_COPYRIGHT.txt";
#else
    return QGuiApplication::applicationDirPath() + "/../Resources/THIRD_PARTY_COPYRIGHT.txt";
#endif
}
