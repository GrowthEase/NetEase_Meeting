/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef _MACX_HELPERS_H_
#define _MACX_HELPERS_H_

#include <QQuickWindow>
#include <QScreen>
#include <QGuiApplication>

class MacXHelpers : public QObject
{
    Q_OBJECT
public:
    struct CaptureTargetInfo {
        uint32_t    id = 0;
        int         pid = 0;
        std::string title;
    };
    typedef std::vector<CaptureTargetInfo> CaptureTargetInfoList;
    MacXHelpers() {}

public slots:
    bool openFolder(const QString& folder);
    int getDisplayId(int screenIndex);
    int getWindowId(WId wid);
    void hideTitleBar(QQuickWindow* window);
    static void setAppPolicy();

    bool isWindow(uint32_t winId) const;
    bool isMinimized(uint32_t winId) const;
    QRectF getWindowRect(uint32_t winId) const;
    QPixmap getCapture(uint32_t winId) const;
    bool getCaptureWindowList(CaptureTargetInfoList* windows) const;
    bool getWindowInfo(uint32_t winId, bool& isWindow, bool& isMinimized, QRectF& rect) const;
    void setForegroundWindow(uint32_t winId) const;
    void setForegroundWindow(int pId) const;
    void sharedOutsideWindow(WId wid, uint32_t winId, bool bFullScreen);
    std::string getModuleName(uint32_t& winId);
    bool isPptPlaying(uint32_t& winId, bool& bKeynote, const QScreen* pScreen) const;
    int getDisplayIdByWinId(uint32_t winId) const;
    bool getDisplayRect(uint32_t winId, QRectF& rect, QRectF& availableRect) const;
};

#endif // _MACX_HELPERS_H_
