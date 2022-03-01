/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef LIVEMEMBERSMODEL_H
#define LIVEMEMBERSMODEL_H

#include <QAbstractListModel>

#include "controller/user_ctrl_interface.h"
#include "manager/meeting/members_manager.h"
#include "manager/meeting/share_manager.h"
#include "manager/meeting/video_manager.h"

using namespace neroom;

enum CheckState {
    Unchecked,      //未选
    Checked,        //已选
    DisableChecked  //不可选
};

struct LiveMemberInfo {
    QString accountId;
    QString nickName;
    CheckState checkState;
    int number;

    LiveMemberInfo() {
        checkState = Unchecked;
        number = 0;
    }
};

class LiveMembersModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit LiveMembersModel(QObject* parent = nullptr);

    enum { kMemberRoleAccountId = Qt::UserRole, kMemberRoleNickname, kMemberRoleChecked, kMemberRoleNumber };

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void setChecked(int row);
    Q_INVOKABLE int getliveMemberCount();
    Q_INVOKABLE QJsonArray getCheckedUserlist();
    Q_INVOKABLE bool updateLiveMembers(QJsonArray array);
    Q_INVOKABLE bool getLiveMemberIsSharing();

signals:
    void liveMemberCountChanged();
    void liveMemberShareStatusChanged(bool isSharing);

private:
    void initManagerConnect();
    bool isLiveMember(const SharedUserPtr& member);
    void addLiveMember(const QString& nickName, const QString& accountId);
    void updateCheckState(bool DisableChecked);
    void updateCheckNumber(int number);

private:
    QVector<LiveMemberInfo> m_members;
    int m_liveMemberCount = 0;  //正在被推流的成员总数
    QString m_shareAccountId;   //正在共享的ID ""表示没有正在进行共享的成员
};

#endif  // LIVEMEMBERSMODEL_H
