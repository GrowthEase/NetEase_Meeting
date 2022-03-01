/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "screen_model.h"
#include <QDebug>
#include <QGuiApplication>
#include <QScreen>
#include "../manager/meeting/share_manager.h"

#if defined(Q_OS_WIN32)
#include <QtWin>
#include "components/windows_helpers.h"
#elif defined(Q_OS_MACX)
#include "components/macx_helpers.h"
#endif

const int kScreenGridViewColumn = 4;

ScreenModel::ScreenModel(QObject* parent)
    : QAbstractListModel(parent) {
    // 当显示器数量变化的时候，重置所有数据
    connect(qApp, &QGuiApplication::screenAdded, this, [this](QScreen* screen) {
        YXLOG(Info) << "Received screen added event, screen name: " << screen->name().toStdString() << YXLOGEnd;
        beginResetModel();
        endResetModel();
    });
    connect(qApp, &QGuiApplication::screenRemoved, this, [this](QScreen* screen) {
        YXLOG(Info) << "Received screen removed event, screen name: " << screen->name().toStdString()<< YXLOGEnd;
        beginResetModel();
        endResetModel();
    });
}

ScreenModel::~ScreenModel() {
    disconnect(qApp, 0, this, 0);
}

int ScreenModel::rowCount(const QModelIndex& parent) const {
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;

    auto screensSize = QGuiApplication::screens().size();
    if (0 != screensSize % kScreenGridViewColumn) {
        screensSize += (kScreenGridViewColumn - screensSize % kScreenGridViewColumn);
    }
    return screensSize + m_vectApp.size();
}

QVariant ScreenModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid())
        return QVariant();

    auto indexTmp = index.row();
    auto screens = QGuiApplication::screens();
    auto screensSize = screens.size();
    auto screensSizeTmp = screensSize;
    if (0 != (screensSize % kScreenGridViewColumn)) {
        screensSizeTmp += (kScreenGridViewColumn - (screensSize % kScreenGridViewColumn));
    }
    if (indexTmp <= screensSize - 1) {
        auto screen = screens.at(indexTmp);
        switch (role) {
            case kScreenName:
                return QVariant(screen->name());
            case kScreenPointX:
                return QVariant(screen->geometry().x());
            case kScreenPointY:
                return QVariant(screen->geometry().y());
            case kScreenWidth:
                return QVariant(screen->geometry().width());
            case kScreenHeight:
                return QVariant(screen->geometry().height());
            case kScreenSerialNumber:
                return QVariant(screen->serialNumber());
            case kScreenType:
                return QVariant(kScreenType_Screen);
            case kScreenAppWinId:
                return QVariant(indexTmp);
            case kScreenAppWinMinimized:
                return QVariant(false);
            default:
                break;
        }
    } else if (indexTmp >= screensSize && indexTmp < screensSizeTmp) {
        if (kScreenType == role) {
            return QVariant(kScreenType_Invaild);
        }
        return QVariant(0);
    } else if ((indexTmp - screensSizeTmp) <= (int)(m_vectApp.size() - 1)) {
        auto app = m_vectApp.at(indexTmp - screensSizeTmp);
        switch (role) {
            case kScreenName:
                return QVariant(app.strTitle);
            case kScreenType:
                return QVariant(kScreenType_App);
            case kScreenAppWinId:
                return QVariant(app.winId);
            case kScreenAppWinMinimized: {
#ifdef Q_OS_WIN32
                WindowsHelpers helpers;
                return QVariant(helpers.isMinimized((HWND)app.winId));
#elif defined Q_OS_MACX
                return QVariant(false);
#endif
            }
            default:
                break;
        }
    }

    return QVariant(0);
}

QHash<int, QByteArray> ScreenModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kScreenName] = "screenName";
    names[kScreenPointX] = "screenPointX";
    names[kScreenPointY] = "screenPointY";
    names[kScreenWidth] = "screenWidth";
    names[kScreenHeight] = "screenHeight";
    names[kScreenSerialNumber] = "screenSerialNumber";
    names[kScreenType] = "screenType";
    names[kScreenAppWinId] = "screenAppWinId";
    names[kScreenAppWinMinimized] = "screenAppWinMinimized";

    return names;
}

void ScreenModel::startEnumTopWindow() {
    beginResetModel();
    m_vectApp.clear();
#if defined(Q_OS_WIN32)
    WindowsHelpers::CaptureTargetInfoList list;
    if (!WindowsHelpers::getCaptureWindowList(&list)) {
        YXLOG(Info) << "startEnumTopWindow, GetCaptureWindowList failed!" << YXLOGEnd;
    }
    m_vectApp.reserve(list.size());
    for (auto& it : list) {
        AppProperty appProperty;
        appProperty.winId = (uint32_t)it.id;
        appProperty.strTitle = QString::fromStdWString(it.title);
        m_vectApp.push_back(appProperty);
    }
#elif defined(Q_OS_MACX)
    MacXHelpers helpers;
    MacXHelpers::CaptureTargetInfoList list;
    if (!helpers.getCaptureWindowList(&list)) {
        YXLOG(Info) << "startEnumTopWindow, GetCaptureWindowList failed!" << YXLOGEnd;
    }
    m_vectApp.reserve(list.size());
    long mainWinId = 0;
    auto pMainWindow = ShareManager::getInstance()->getMainWindow();
    if (pMainWindow) {
        mainWinId = helpers.getWindowId(pMainWindow->winId());
    }
    for (auto& it : list) {
        if (mainWinId == it.id) {
            continue;
        }
        AppProperty appProperty;
        appProperty.winId = it.id;
        appProperty.strTitle = QString::fromStdString(it.title);
        m_vectApp.push_back(appProperty);
    }
#endif
    endResetModel();
}

bool ScreenModel::windowExist(quint32 id) {
#ifdef Q_OS_WIN32
    WindowsHelpers helpers;
    bool isWindow = helpers.isWindow((HWND)id);
#elif defined Q_OS_MACX
    MacXHelpers helpers;
    bool isWindow = helpers.isWindow((uint32_t)id);
#endif
    if (!isWindow) {
        return false;
    }

    return true;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
/// \brief ShareImageProvider::ShareImageProvider
///
ShareImageProvider::ShareImageProvider(ScreenModel::ScreenType screenType)
    : QQuickImageProvider(QQuickImageProvider::Image)
    , m_screenType(screenType) {}

QImage ShareImageProvider::requestImage(const QString& idTmp, QSize* size, const QSize& requestedSize) {
    QString id = idTmp.left(idTmp.indexOf('_'));
    uint32_t winid = id.toUInt();
    if (ScreenModel::kScreenType_Screen == m_screenType) {
        auto screens = QGuiApplication::screens();
        if (winid <= (uint32_t)(screens.size() - 1)) {
            auto screen = screens.at(id.toLong());
#ifdef Q_OS_WIN32
            QPixmap pixmap = screen->grabWindow(0);
#elif defined(Q_OS_MACX)
            QPixmap pixmap =
                screen->grabWindow(0, screen->geometry().x(), screen->geometry().y(), screen->geometry().width(), screen->geometry().height());
#endif
            return pixmap.toImage().convertToFormat(QImage::Format_ARGB32);
        }
    } else if (ScreenModel::kScreenType_App == m_screenType) {
#ifdef Q_OS_WIN32
        do {
            bool bCapture = false;
            HWND hWnd = (HWND)winid;
            WindowsHelpers helpers;
            if (!helpers.isWindow(hWnd)) {
                break;
            }

            PrintCaptureHelper captureHelper;
            if (!helpers.isMinimized(hWnd) && captureHelper.Init(hWnd)) {
                if (captureHelper.Capture()) {
                    bCapture = true;
                    HBITMAP hBitmap = captureHelper.GetBitmap();
                    return QtWin::fromHBITMAP(hBitmap).toImage().convertToFormat(QImage::Format_ARGB32);
                }
            }

            if (!bCapture) {
                // YXLOG(Info) << "PrintCaptureHelper capture failed, hWnd: " << hWnd << YXLOGEnd;
                QPixmap pixmap = helpers.getWindowIcon((HWND)winid);
                if (size) {
                    *size = pixmap.size();
                }
                return pixmap.toImage().convertToFormat(QImage::Format_ARGB32);
            }
        } while (0);

#elif defined(Q_OS_MACX)
        do {
            MacXHelpers helpers;
            if (!helpers.isWindow(winid)) {
                break;
            }
            QPixmap pixmap = helpers.getCapture(winid);
            return pixmap.toImage().convertToFormat(QImage::Format_ARGB32);
        } while (0);
#endif
    }

    QImage image(requestedSize.width() > 0 ? requestedSize.width() : 112, requestedSize.height() > 0 ? requestedSize.height() : 200, QImage::Format_ARGB32);
    image.fill(Qt::white);
    return image;
}
