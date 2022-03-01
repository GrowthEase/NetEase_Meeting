/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef APPEVENTHANDLER_H
#define APPEVENTHANDLER_H

#include <QObject>
#include <QApplication>
#include <QApplicationStateChangeEvent>

class MeetingApp : public QApplication
{
    Q_OBJECT
public:
    MeetingApp(int& argc, char** argv);
    static void setBugList(const char* argv);

    virtual bool notify(QObject *, QEvent *) override;

    const QString kSSOToken = "ssoToken";
    const QString kSSOAppKey = "appKey";

signals:
    void dockClicked();
    void loginWithSSO(const QString& ssoAppKey, const QString& ssoToken);

private:
    int _prevAppState = -1;
};

#endif // APPEVENTHANDLER_H
