// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef APPEVENTHANDLER_H
#define APPEVENTHANDLER_H

#include <QApplication>
#include <QApplicationStateChangeEvent>
#include <QObject>

class MeetingApp : public QApplication {
    Q_OBJECT
public:
    MeetingApp(int& argc, char** argv);
    static void setBugList(const char* argv);

    virtual bool notify(QObject*, QEvent*) override;

    const QString kSSOAppKey = "appId";
    const QString kSSOUser = "userUuid";
    const QString kSSOToken = "userToken";
signals:
    void dockClicked();
    void loginWithSSO(const QString& ssoAppKey, const QString& ssoUser, const QString& ssoToken);

private:
    int _prevAppState = -1;
};

#endif  // APPEVENTHANDLER_H
