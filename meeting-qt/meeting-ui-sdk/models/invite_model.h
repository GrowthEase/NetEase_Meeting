// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef INVITELISTMODEL_H
#define INVITELISTMODEL_H

#include <QAbstractListModel>
#include "manager/meeting/invite_manager.h"

class InviteModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit InviteModel(QObject* parent = nullptr);
    ~InviteModel();

    enum { ksipNum = Qt::UserRole };
    Q_PROPERTY(InviteManager* manager READ manager WRITE setManager NOTIFY managerChanged)

    // Basic functionality:
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    InviteManager* manager() const;
    void setManager(InviteManager* manager);

signals:
    void managerChanged();

private:
    InviteManager* m_manager = nullptr;
};

#endif  // INVITELISTMODEL_H
