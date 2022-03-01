/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef MEMBERSMODEL_H
#define MEMBERSMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include "controller/user_ctrl_interface.h"
#include "manager/meeting/audio_manager.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/video_manager.h"

using namespace neroom;

class MembersModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit MembersModel(QObject* parent = nullptr);

    Q_PROPERTY(MembersManager* manager READ manager WRITE setManager)

    enum {
        kMemberRoleAccountId = Qt::UserRole,
        kMemberRoleNickname,
        kMemberRoleAudio,
        kMemberRoleVideo,
        kMemberRoleSharing,
        kMemberRoleHansUpStatus,
        kMemberRoleClientType,
        kMemberRoleWhiteboard,
        kMemberWhiteboardShareOwner
    };

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    // Members controller getter/setter
    MembersManager* manager() const;
    void setManager(MembersManager* members_manager);

private:
    MembersManager* m_pMemberMgr = nullptr;
    std::atomic_bool m_bInserting;
};

// Filter proxy model
class FilterProxyModel : public QSortFilterProxyModel {
    Q_OBJECT
public:
    FilterProxyModel(QObject* parent = 0);

    ~FilterProxyModel();

    Q_INVOKABLE void setFilterString(QString string);

    Q_INVOKABLE void setSortOrder(bool checked);

    Q_INVOKABLE void setSortModel(QAbstractItemModel* sourceModel);

protected:
    bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const override;
};

#endif  // MEMBERSMODEL_H
