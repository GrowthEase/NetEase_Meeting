// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef INVITEMANAGER_H
#define INVITEMANAGER_H

#include <QObject>
#include "controller/sip_controller.h"
#include "manager/global_manager.h"
#include "utils/singleton.h"

class InviteManager : public QObject {
    Q_OBJECT
public:
    SINGLETONG(InviteManager)

    Q_INVOKABLE void getInviteList();
    Q_INVOKABLE void addSip(const QString& number, const QString& address);

    std::list<NEInvitation> getSipList() const;

signals:
    void sipChanged();
    void error(int errorCode, const QString& errorMessage);

private:
    explicit InviteManager(QObject* parent = nullptr);

private:
    std::shared_ptr<NESipController> m_sipController = nullptr;

private:
    std::list<NEInvitation> m_list;
};

#endif  // INVITEMANAGER_H
