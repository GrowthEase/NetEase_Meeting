/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef __SCREENSAVER_H__
#define __SCREENSAVER_H__

#include <QtGlobal>

class ScreenSaver : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool screenSaverEnabled READ screenSaverEnabled WRITE setScreenSaverEnabled)

public:
    explicit ScreenSaver(QObject *parent = Q_NULLPTR);
    virtual ~ScreenSaver();

    bool screenSaverEnabled() const;
    void setScreenSaverEnabled(bool enabled);

private slots:
    void activityTimeout();

private:
    QTimer* m_pTimer = nullptr;
};

#endif // __SCREENSAVER_H__
