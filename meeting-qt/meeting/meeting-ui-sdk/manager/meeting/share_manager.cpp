// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "share_manager.h"
#include "../auth_manager.h"
#include "members_manager.h"

#ifdef Q_OS_MACX
#include "components/auth_checker.h"
#endif

const int kpausedCount = 5;

ShareManager::ShareManager(QObject* parent)
    : QObject(parent) {
#ifdef Q_OS_WIN32
    m_pHelper = std::make_unique<WindowsHelpers>();
#elif defined Q_OS_MACX
    m_pHelper = std::make_unique<MacXHelpers>();
#endif

    qRegisterMetaType<NERoomScreenShareStatus>();

    m_shareController = std::make_shared<NEMeetingScreenShareController>();

    connect(qApp, &QGuiApplication::screenAdded, [=](QScreen* addedScreen) {
        connect(addedScreen, &QScreen::virtualGeometryChanged, [=]() { emit screenSizeChanged(); });
        emit screenAdded(addedScreen->name());
    });
    connect(qApp, &QGuiApplication::screenRemoved, [=](QScreen* removedScreen) {
        disconnect(removedScreen, &QScreen::virtualGeometryChanged, this, nullptr);
        emit screenRemoved(removedScreen->name());
    });

    QList<QScreen*> screens = QGuiApplication::screens();
    for (int i = 0; i < screens.size(); i++) {
        connect(screens.at(i), &QScreen::virtualGeometryChanged, [=]() { emit screenSizeChanged(); });
    }

    connect(this, &ShareManager::screenSizeChanged, [this]() { m_pausedCount = kpausedCount; });

    m_timer.setTimerType(Qt::PreciseTimer);
    m_timer.setInterval(50);
    m_timer.callOnTimeout(this, &ShareManager::onAppSharingPause);

    if (ConfigManager::getInstance()->contains("enableShareSystemSound")) {
        m_shareSystemSound = ConfigManager::getInstance()->getValue("enableShareSystemSound", false).toBool();
        emit shareSystemSoundChanged();
    }

    if (ConfigManager::getInstance()->contains("enableSmoothPriority")) {
        m_smoothPriority = ConfigManager::getInstance()->getValue("enableSmoothPriority", false).toBool();
        emit smoothPriorityChanged();
    }
}

bool ShareManager::isExistScreen(const QString& name) const {
    QList<QScreen*> screens = QGuiApplication::screens();
    for (auto& it : screens) {
        if (it->name() == name) {
            return true;
        }
    }

    return false;
}

ShareManager::~ShareManager() {
    if (m_pSharedOutsideWindow && nullptr == m_pSharedOutsideWindow->parent()) {
        delete m_pSharedOutsideWindow;
        m_pSharedOutsideWindow = nullptr;
    }
}

bool ShareManager::hasRecordPermission() {
#ifdef Q_OS_WIN32
    return true;
#else
    return checkAuthRecordScreen();
#endif
}

void ShareManager::openSystemSettings() {
#ifdef Q_OS_MACX
    openRecordSettings();
#endif
}

void ShareManager::onRoomUserScreenShareStatusChanged(const std::string& usdrId, NERoomScreenShareStatus status) {
    QMetaObject::invokeMethod(this, "onSharingStatusChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(usdrId)),
                              Q_ARG(NERoomScreenShareStatus, status));
}

void ShareManager::onError(uint32_t errorCode, const std::string& errorMessage) {
    emit error(errorCode, QString::fromStdString(errorMessage));
}

void ShareManager::addExcludeShareWindow(QQuickWindow* pShareWindow) {
    m_excludeShareWindowList.emplace_back(pShareWindow);
#ifdef Q_OS_WIN32
    INERoomRtcController* pRtc = MeetingManager::getInstance()->getInRoomRtcController();
    if (pRtc && 0 == m_shareAppId && !m_shareAccountId.isEmpty()) {
        std::list<void*> excludedWindowList;
        for (auto& it : m_excludeShareWindowList) {
            excludedWindowList.push_back((void*)it->winId());
            // qDebug() << "Add exclude window: " << GetWindowName(it->winId());
        }
        pRtc->setExcludeWindowList(excludedWindowList);
    }
#endif
}

void ShareManager::removeExcludeShareWindow(QQuickWindow* pShareWindow) {
    m_excludeShareWindowList.remove(pShareWindow);
#ifdef Q_OS_WIN32
    INERoomRtcController* pRtc = MeetingManager::getInstance()->getInRoomRtcController();
    if (pRtc && 0 == m_shareAppId && !m_shareAccountId.isEmpty()) {
        std::list<void*> excludedWindowList;
        for (auto& it : m_excludeShareWindowList) {
            excludedWindowList.emplace_back((void*)it->winId());
        }
        pRtc->setExcludeWindowList(excludedWindowList);
    }
#endif
}

void ShareManager::clearExcludeShareWindow() {
    m_excludeShareWindowList.clear();
#ifdef Q_OS_WIN32
    INERoomRtcController* pRtc = MeetingManager::getInstance()->getInRoomRtcController();
    if (pRtc && 0 == m_shareAppId && !m_shareAccountId.isEmpty()) {
        std::list<void*> excludedWindowList;
        pRtc->setExcludeWindowList(excludedWindowList);
    }
#endif
}

void ShareManager::startScreenSharing(quint32 screenIndex) {
    std::list<void*> excludedWindowList;
#ifdef Q_OS_WIN32
    auto screens = QGuiApplication::screens();
    auto screen = screens.at(screenIndex);

    NERectangle sourceRectangle;
    sourceRectangle.x = screen->geometry().x();
    sourceRectangle.y = screen->geometry().y();
    sourceRectangle.width = screen->geometry().width() * screen->devicePixelRatio();
    sourceRectangle.height = screen->geometry().height() * screen->devicePixelRatio();

    NERectangle regionRectangle;

    for (auto& it : m_excludeShareWindowList) {
        excludedWindowList.emplace_back((void*)it->winId());
    }
    m_shareController->startRectShare(sourceRectangle, regionRectangle, excludedWindowList, m_smoothPriority,
                                      [this](int code, const std::string& msg) {
                                          MeetingManager::getInstance()->onError(code, msg);
                                          if (code == 0) {
#ifdef Q_OS_WIN32
                                              if (m_shareSystemSound) {
                                                  startSystemAudioLoopbackCapture();
                                              }
#endif
                                          }
                                      });
#else
    auto nativeDisplayId = m_pHelper->getDisplayId(screenIndex);
    for (auto& it : m_excludeShareWindowList) {
        excludedWindowList.emplace_back((void*)m_pHelper->getWindowId(it->winId()));
    }
    m_shareController->startScreenShare(nativeDisplayId, excludedWindowList, m_smoothPriority, [](int code, const std::string& msg) {
        if (code != 0)
            MeetingManager::getInstance()->onError(code, msg);
    });
#endif
}

void ShareManager::startAppSharing(quint32 id) {
    m_bPpt = false;
    m_bPptPlay = false;
    m_bMiniRestored = false;
    m_bLatestFullScreen = false;
    m_bLatestForegroundWindow = false;
    m_bPowerpnt = false;
#ifdef Q_OS_WIN32
    bool bIsPptPlaying = false;
    HWND hWnd = NULL;
    std::string strExe = m_pHelper->getModuleName((HWND)id);
    std::string strDst;
    bool bPpt = false;
    // 转换成小写
    std::transform(strExe.begin(), strExe.end(), std::back_inserter(strDst), ::tolower);
    YXLOG(Info) << "startAppShare by " << strExe << YXLOGEnd;
    if (strDst == "wps.exe" || strDst == "powerpnt.exe") {
        bPpt = true;
        if (strDst == "powerpnt.exe") {
            m_bPowerpnt = true;
        }
        bool bPowerpnt = false;
        bIsPptPlaying = m_pHelper->isPptPlaying(hWnd, bPowerpnt);
        // YXLOG(Info) << "startAppShare by bIsPptPlaying bPpt " << bIsPptPlaying << bPpt << YXLOGEnd;
    }

    if (!bIsPptPlaying) {
        m_pHelper->setForegroundWindow((HWND)id);
    }
#elif defined(Q_OS_MACX)
    m_pHelper->setForegroundWindow(id);
#endif

    m_shareAppId = id;
    m_pausedCount = kpausedCount;
#ifdef Q_OS_WIN32
    if ((!bIsPptPlaying && bPpt) || (bIsPptPlaying && hWnd != (HWND)id)) {
        m_bPpt = true;
    }
#elif defined(Q_OS_MACX)
    uint32_t winId = id;
    std::string strExe = m_pHelper->getModuleName(winId);
    std::string strDst;
    // 转换成小写
    std::transform(strExe.begin(), strExe.end(), std::back_inserter(strDst), ::tolower);
    if (0 == strDst.rfind("keynote", 0) || 0 == strDst.rfind("wps office", 0) || 0 == strDst.rfind("wpsoffice", 0) ||
        0 == strDst.rfind("microsoft powerpoint", 0)) {
        m_bPpt = true;
        if (0 == strDst.rfind("keynote", 0) || 0 == strDst.rfind("microsoft powerpoint", 0)) {
            m_bPowerpnt = true;
        }
        YXLOG(Info) << "startAppShare is 'keynote', 'wps office' or 'wpsoffice'." << YXLOGEnd;
    }
#endif

    m_shareController->startAppShare((void*)id, m_smoothPriority, [=](int code, const std::string& msg) {
        MeetingManager::getInstance()->onError(code, msg);
        if (code == 0) {
#ifdef Q_OS_WIN32
            if (m_shareSystemSound) {
                startSystemAudioLoopbackCapture();
            }
#endif
        } else {
            m_shareAppId = 0;
            m_pausedCount = 0;
            m_bPpt = false;
            m_bPowerpnt = false;
        }
    });
}

void ShareManager::switchAppSharing(quint32 id) {
#ifdef Q_OS_WIN32
    m_pHelper->setForegroundWindow((HWND)id);
#elif defined(Q_OS_MACX)
    m_pHelper->setForegroundWindow(id);
#endif
    if (m_shareController->switchAppShare((void*)id, m_smoothPriority)) {
        YXLOG(Info) << "switchAppSharing failed." << YXLOGEnd;
    } else {
#ifdef Q_OS_WIN32
        if (m_shareSystemSound) {
            startSystemAudioLoopbackCapture();
        }
#endif
    }
}

void ShareManager::switchMonitorShare(const uint32_t& monitor_id, const std::list<void*>& excludedWindowList) {
    if (m_shareController->switchMonitorShare(monitor_id, excludedWindowList, m_smoothPriority)) {
        YXLOG(Info) << "switchMonitorSharing failed." << YXLOGEnd;
    } else {
#ifdef Q_OS_WIN32
        if (m_shareSystemSound) {
            startSystemAudioLoopbackCapture();
        }
#endif
    }
}

bool ShareManager::isAppShared() const {
    return 0 != m_shareAppId;
}

void ShareManager::stopScreenSharing(const QString& accountId) {
    auto callback = [this](int code, const std::string& msg) {
        if (0 != code) {
            MeetingManager::getInstance()->onError(code, msg);
        } else {
            stopScreenSharing();
        }
    };

    bool ret = false;
    if (accountId == AuthManager::getInstance()->authAccountId()) {
        ret = m_shareController->stopScreenShare(callback);
    } else {
        ret = m_shareController->stopParticipantScreenShare(accountId.toStdString(), callback);
    }

    if (!ret) {
        YXLOG(Info) << "stopParticipantScreenShare failed." << YXLOGEnd;
    }
}

void ShareManager::stopScreenSharing() {
    Invoker::getInstance()->execute([this]() {
        m_shareAppId = 0;
        m_timer.stop();
        auto pWindow = getSharedOutsideWindow();
        if (pWindow) {
#ifdef Q_OS_MACX
            pWindow->show();
#endif
            pWindow->hide();
        }

#ifdef Q_OS_WIN32
        if (m_shareSystemSound) {
            stopSystemAudioLoopbackCapture();
        }
#endif
    });
}

void ShareManager::pauseScreenSharing() {
    // G2 bug
    if (m_shareController->pauseShare()) {
        setPaused(true);
    }
}

void ShareManager::resumeScreenSharing() {
    // G2 bug
    if (m_shareController->resumeShare()) {
        setPaused(false);
    }
}

void ShareManager::startSystemAudioLoopbackCapture() {
    m_shareController->startSystemAudioLoopbackCapture();
}

void ShareManager::stopSystemAudioLoopbackCapture() {
    m_systemAudioLoopbackCapture = !m_shareController->stopSystemAudioLoopbackCapture();
}

void ShareManager::onSharingStatusChangedUI(const QString& userId, NERoomScreenShareStatus status) {
    if (status == kNERoomScreenShareStopByHost) {
        stopScreenSharing();
        emit closeScreenShareByHost();
        if (m_shareSystemSound) {
            stopSystemAudioLoopbackCapture();
        }
    }

    setShareAccountId(status == kNERoomScreenShareStatusStart ? userId : "");
#ifdef Q_OS_WIN32
    if (0 != m_shareAppId) {
        setPaused(m_pHelper->isMinimized((HWND)m_shareAppId));
    } else {
        setPaused(false);
    }
#elif defined Q_OS_MACX
    setPaused(false);
#endif
}

void ShareManager::dealwithPause(const QString& sharingAccountId, bool isSharing, bool isPause) {
    if (isSharing) {
        if (0 != m_shareAppId) {
            if (!isPause) {
#ifdef Q_OS_WIN32
                bool bMinimized = m_pHelper->isMinimized((HWND)m_shareAppId);
                QRectF rectTmp = m_pHelper->getWindowRect((HWND)m_shareAppId);
#elif defined Q_OS_MACX
                bool bMinimized = m_pHelper->isMinimized((uint32_t)m_shareAppId);
                QRectF rectTmp = m_pHelper->getWindowRect((uint32_t)m_shareAppId);
#endif
                if (!m_bPptPlay) {
                    m_latestAppRect = rectTmp;
                    setAppMinimized(bMinimized);
                }
            }
            if (!m_timer.isActive()) {
                m_timer.start();
            }
        }
    } else {
        m_shareAppId = 0;
        m_timer.stop();
        auto pWindow = getSharedOutsideWindow();
        if (pWindow) {
            pWindow->hide();
        }
    }
}

QString ShareManager::shareAccountId() const {
    return m_shareAccountId;
}

void ShareManager::setShareAccountId(const QString& shareAccountId) {
    NEMeeting::Status status = MeetingManager::getInstance()->roomStatus();
    if (NEMeeting::MEETING_CONNECTED == status || NEMeeting::MEETING_RECONNECTED == status) {
    } else {
        MeetingManager::getInstance()->getMeetingController()->getRoomInfo().screenSharingUserId = shareAccountId.toStdString();
        return;
    }

    m_shareAccountId = shareAccountId;
    MeetingManager::getInstance()->getMeetingController()->getRoomInfo().screenSharingUserId = m_shareAccountId.toStdString();
    MembersManager::getInstance()->handleShareAccountIdChanged();
    emit shareAccountIdChanged();

    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    setOwnerSharing(authInfo.accountId == m_shareAccountId.toStdString());
}

bool ShareManager::paused() const {
    return m_paused;
}

void ShareManager::setPaused(bool paused) {
    if (m_paused != paused) {
        m_paused = paused;
        emit pausedChanged(m_paused);
    }

    dealwithPause(m_shareAccountId, !m_shareAccountId.isEmpty(), m_paused);
}

bool ShareManager::ownerSharing() const {
    return m_ownerSharing;
}

void ShareManager::setOwnerSharing(bool ownerSharing) {
    if (ownerSharing != m_ownerSharing) {
        m_ownerSharing = ownerSharing;
        emit ownerSharingChanged(m_ownerSharing);
        if (!ownerSharing) {
            if (m_systemAudioLoopbackCapture) {
                stopSystemAudioLoopbackCapture();
            }
        }
    }
}

bool ShareManager::appMinimized() const {
    return m_bMinimized;
}

void ShareManager::setAppMinimized(bool appMinimized) {
    if (appMinimized != m_bMinimized) {
        m_bMinimized = appMinimized;
        emit appMinimizedChanged(m_bMinimized);
    }
}

void ShareManager::sharedOutsideWindow(QQuickWindow* pWindow, int borderWidth) {
    m_pSharedOutsideWindow = qobject_cast<QWindow*>(pWindow);
    m_pSharedOutsideWindow->setParent(nullptr);
#if defined(Q_OS_WIN32)
    auto currentOwner = reinterpret_cast<HWND>(::GetWindowLongPtr((HWND)pWindow->winId(), GWLP_HWNDPARENT));
    if (currentOwner != GetDesktopWindow())
        SetWindowLongPtr((HWND)pWindow->winId(), GWLP_HWNDPARENT, (LONG_PTR)GetDesktopWindow());
#endif
    m_borderWidth = borderWidth;
}

QWindow* ShareManager::getSharedOutsideWindow() {
    return m_pSharedOutsideWindow;
}

void ShareManager::onAppSharingPause() {
    bool bStop = false;
    auto pWindow = getSharedOutsideWindow();
    quint32 shareAppId = m_shareAppId;
    do {
#ifdef Q_OS_WIN32
        if (m_bPpt) {
            HWND hWnd = NULL;
            bool bPowerpnt = false;
            if (m_pHelper->isPptPlaying(hWnd, bPowerpnt) && m_bPowerpnt == bPowerpnt) {
                if (m_bPowerpnt && 100 != m_timer.interval()) {
                    m_timer.setInterval(100);
                } else if (50 != m_timer.interval()) {
                    m_timer.setInterval(50);
                }

                if (!m_bPptPlay) {
                    m_bPptPlay = true;
                    switchAppSharing(quint32(hWnd));
                    m_pHelper->setForegroundWindow(hWnd);
                    // m_pHelper->setShowWindow((HWND)m_shareAppId, SW_MINIMIZE);
                }
                shareAppId = quint32(hWnd);
            } else {
                if (50 != m_timer.interval()) {
                    m_timer.setInterval(50);
                }
                if (m_bPptPlay) {
                    m_bPptPlay = false;
                    switchAppSharing(m_shareAppId);
                }
            }
        }
        bool bWindow = m_pHelper->isWindow((HWND)m_shareAppId);
        bool bMinimized = m_pHelper->isMinimized((HWND)shareAppId) || m_pHelper->isHide((HWND)shareAppId);
#elif defined Q_OS_MACX
        MacXHelpers::FullScreenType fullScreenType = MacXHelpers::FullScreenType::kUnknown;
        if (m_bPpt) {
            uint32_t winId = 0;
            if (m_pHelper->isPptPlaying(winId, fullScreenType, getMainWindow()->screen())) {
                if (!m_bPptPlay) {
                    m_bPptPlay = true;
                }
            } else {
                if (m_bPptPlay) {
                    m_bPptPlay = false;
                }
            }
        }
        bool bWindow = false;
        bool bMinimized = true;
        QRectF rectTmp;
        m_pHelper->getWindowInfo((uint32_t)shareAppId, bWindow, bMinimized, rectTmp);
#endif
        if (!bWindow && !m_bPptPlay) {
            bStop = true;
            YXLOG(Info) << "bWindow is not exist." << YXLOGEnd;

            if (pWindow && pWindow->isVisible()) {
                pWindow->hide();
            }

            setPaused(true);
            stopScreenSharing(QString::fromStdString(AuthManager::getInstance()->getAuthInfo().accountId));
            break;
        }

        if (m_bMinimized && bMinimized == m_bMinimized) {
            break;
        }

        if (!bMinimized && m_bMinimized) {
            m_bMiniRestored = true;
        }

#if defined(Q_OS_WIN32)
        if (bMinimized) {
#else
        // Mac 下全部切换为 SDK 自动切换，这里 PPT 或 KeyNote 全屏播放时原窗口获取到是最小化状态
        // 上层只能接收到暂停、恢复等事件，不确定被共享应用到底有没有切换到播放模式
        // 为避免 SDK 切换后共享被暂停，这里根据应用自己遍历到的全屏窗口进行判断，只有不存在全屏共享应用的情况下才暂停共享
        if (bMinimized && fullScreenType == MacXHelpers::FullScreenType::kUnknown) {
#endif
            if (pWindow && pWindow->isVisible()) {
                pWindow->hide();
            }

            m_bMiniRestored = false;
            if (!m_pausedEx) {
                m_pausedEx = true;
                YXLOG(Info) << "pause screen sharing because window has been minimized." << YXLOGEnd;
                pauseScreenSharing();
            }
            setAppMinimized(true);
            break;
        } else {
            setAppMinimized(false);
        }

#ifdef Q_OS_WIN32
        // 获取被共享窗口的矩形
        QRectF rectTmp = m_pHelper->getWindowRect((HWND)shareAppId);
#elif defined Q_OS_MACX
#endif
        // 如果被共享窗口上一次获取的矩形大小与本次获取的矩形大小不一致
        if (rectTmp != m_latestAppRect) {
            // 先隐藏边框
            if (pWindow && pWindow->isVisible()) {
                pWindow->hide();
            }
            // 先暂停共享
            if (!m_pausedEx) {
                m_pausedEx = true;
                YXLOG(Info) << "pause screen sharing because window rectangle has been changed." << YXLOGEnd;
                pauseScreenSharing();
            }
            // 更新最后一次应用矩形大小
            m_latestAppRect = rectTmp;
        } else {
            m_pausedCount = kpausedCount;
            // 如果边框窗口存在，并且暂停次数与本次暂停一致
            if (pWindow && (m_bMiniRestored || m_pausedCount >= kpausedCount)) {
#ifdef Q_OS_WIN32
                QRect reTmp = m_pHelper->getWindowFrameRect((HWND)shareAppId).toRect();
                if (reTmp.width() > rectTmp.width() || reTmp.height() > rectTmp.height() || reTmp.width() < 50 || reTmp.height() < 50) {
                    reTmp = rectTmp.toRect();
                }

                QRectF fullRect, availableRect;
                if (m_pHelper->getDisplayRect((HWND)shareAppId, fullRect, availableRect, shareAppId != m_shareAppId)) {
                } else {
                    fullRect = pWindow->screen()->geometry();
                    availableRect = pWindow->screen()->availableGeometry();
                }

                bool bFullScreen = reTmp.size().width() >= fullRect.width() && reTmp.size().height() >= fullRect.height();
                bool bMaxScreen = reTmp.size().width() >= availableRect.width() || reTmp.size().height() >= availableRect.height();
                if (m_bMiniRestored || m_latestOutsideRect != rectTmp) {
                    m_latestOutsideRect = rectTmp;
                    pWindow->hide();
                    int border = bFullScreen || bMaxScreen ? 0 : m_borderWidth;
                    QRect outsideRect((int)reTmp.x() - border, (int)reTmp.y() - border, (int)reTmp.width() + border * 2,
                                      (int)reTmp.height() + border * 2);
                    int width = outsideRect.width();
                    int height = outsideRect.height();
                    // qDebug() << "outsideRect:" <<outsideRect <<" " << fullRect;
                    if (outsideRect.x() < fullRect.x())
                        outsideRect.setX(fullRect.x());
                    if (outsideRect.y() < fullRect.y())
                        outsideRect.setY(fullRect.y());
                    if (bFullScreen && width >= fullRect.width())
                        outsideRect.setWidth(fullRect.width());
                    else if (bMaxScreen && width > availableRect.width())
                        outsideRect.setWidth(availableRect.width());
                    if (bFullScreen && height >= fullRect.height())
                        outsideRect.setHeight(fullRect.height());
                    else if (bMaxScreen && height > availableRect.height())
                        outsideRect.setHeight(availableRect.height());
                    QRect adjustRect;
                    m_pHelper->adjustRectWithRatio(pWindow->screen(), outsideRect, adjustRect);
                    pWindow->setGeometry(adjustRect);
                }
                if (bFullScreen || bMaxScreen) {
                } else {
                    m_bLatestFullScreen = false;
#ifdef Q_OS_WIN32
                    bool bShareAppIdForegroundWindow = m_pHelper->getForegroundWindow((HWND)shareAppId);
                    bool bSharedOutsideForegroundWindow = m_pHelper->getForegroundWindow((HWND)pWindow->winId());
                    if (bShareAppIdForegroundWindow && !m_bLatestForegroundWindow) {
                        m_bLatestForegroundWindow = true;
                        // 这里设置边框获取焦点后，被共享应用就丢失了焦点，导致 PPT 场景下无法通过键盘快捷键翻页
                        // 目前看逻辑这里只是期望刚开始共享时激活一次边框
                        m_pHelper->setForegroundWindow((HWND)pWindow->winId());
                        // 上面位置代码看日志只会执行一次，所以这里在边框激活了再激活一次被共享应用
                        m_pHelper->setForegroundWindow((HWND)shareAppId);
                    } else if (bSharedOutsideForegroundWindow) {
                        m_pHelper->setForegroundWindow((HWND)shareAppId);
                    }

                    if (!bShareAppIdForegroundWindow && !bSharedOutsideForegroundWindow) {
                        m_bLatestForegroundWindow = false;
                    }

                    if (m_bMiniRestored && m_pHelper->getForegroundWindow((HWND)shareAppId)) {
                        pWindow->showMinimized();
                        pWindow->showNormal();
                        m_pHelper->setForegroundWindow((HWND)pWindow->winId());
                    }
#elif defined Q_OS_MACX
                    m_bLatestForegroundWindow = false;
#endif
                    m_pHelper->sharedOutsideWindow(pWindow->winId(), (HWND)shareAppId, false);
                }

                if (!pWindow->isVisible() && !bFullScreen && !bMaxScreen)
                    pWindow->show();
                if (pWindow->isVisible() && (bFullScreen || bMaxScreen))
                    pWindow->hide();
#elif defined Q_OS_MACX
                QRectF fullRect, availableRect;
                if (m_pHelper->getDisplayRect((uint32_t)shareAppId, fullRect, availableRect)) {
                } else {
                    fullRect = pWindow->screen()->virtualGeometry();
                    availableRect = pWindow->screen()->availableVirtualGeometry();
                }

                bool bFullScreen = fullRect == rectTmp || (rectTmp.width() >= fullRect.width() && rectTmp.height() >= fullRect.height());
                if (m_bMiniRestored || m_latestOutsideRect != rectTmp) {
                    m_latestOutsideRect = rectTmp;
                    QSize availableSize = availableRect.size().toSize();
                    QSize rectTmpSize = rectTmp.size().toSize();
                    bool bMaxScreen = availableSize == rectTmpSize;
                    bool bAlmostMaxScreen = rectTmpSize.width() + 10 >= availableSize.width() || rectTmpSize.height() + 10 >= availableSize.height();
                    int border = bFullScreen || bMaxScreen ? 0 : m_borderWidth;
                    QRect outsideRect((int)rectTmp.x() - border, (int)rectTmp.y() - border, (int)rectTmp.width() + border * 2,
                                      (int)rectTmp.height() + border * 2);
                    if (!bFullScreen) {
                        // outsideRect = outsideRect.intersected(availableRect.toRect());
                        if (outsideRect.width() > availableRect.width()) {
                            outsideRect.setWidth(availableRect.width());
                        }
                        if (outsideRect.height() > availableRect.height()) {
                            outsideRect.setHeight(availableRect.height());
                        }
                        if (bAlmostMaxScreen /* && !bMaxScreen*/) {
                            outsideRect = outsideRect.adjusted(2, 4, -2, -8);
                        }
                    }
                    pWindow->setGeometry(outsideRect);
                    if (!pWindow->isVisible())
                        pWindow->show();
                }
                m_pHelper->sharedOutsideWindow(pWindow->winId(), (uint32_t)shareAppId, bFullScreen);
#endif
                if (m_pausedEx) {
                    m_pausedEx = false;
                    resumeScreenSharing();
                }

                m_pausedCount = 0;
                m_bMiniRestored = false;
            }
        }
    } while (0);

    if (bStop) {
        if (pWindow && pWindow->isVisible()) {
            pWindow->hide();
        }
        m_timer.stop();
    }
}

bool ShareManager::shareSystemSound() const {
    return m_shareSystemSound;
}

void ShareManager::setShareSystemSound(bool shareSystemSound) {
    if (shareSystemSound != m_shareSystemSound) {
        m_shareSystemSound = shareSystemSound;
        ConfigManager::getInstance()->setValue("enableShareSystemSound", m_shareSystemSound);
        emit shareSystemSoundChanged();
    }
}

void ShareManager::switchSystemSound(bool shareSystemSound) {
    if (m_shareAccountId.isEmpty()) {
        return;
    }

#ifdef Q_OS_WIN32
    if (shareSystemSound) {
        startSystemAudioLoopbackCapture();
    } else {
        stopSystemAudioLoopbackCapture();
    }
#endif

    setShareSystemSound(shareSystemSound);
}

bool ShareManager::smoothPriority() const {
    return m_smoothPriority;
}

void ShareManager::setSmoothPriority(bool smoothPriority) {
    if (smoothPriority != m_smoothPriority) {
        m_smoothPriority = smoothPriority;
        ConfigManager::getInstance()->setValue("enableSmoothPriority", m_smoothPriority);
        emit smoothPriorityChanged();
    }
}
