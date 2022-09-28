// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef LIVEMEMBERSMODEL_H
#define LIVEMEMBERSMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>

enum CheckState {
    Unchecked,  //未选
    Checked     //已选
};

struct MemberInfo {
    QString accountId;
    QString nickName;
    CheckState checkState;

    MemberInfo() {
        checkState = Unchecked;
        nickName = "";
    }
};

class MembersModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit MembersModel(QObject* parent = nullptr);

    enum { kMemberRoleAccountId = Qt::UserRole, kMemberRoleNickname, kMemberRoleChecked };

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    virtual QHash<int, QByteArray> roleNames() const override;

public:
    Q_INVOKABLE void initData(const QJsonArray& userList);
    Q_INVOKABLE void setChecked(bool checked, int row);
    Q_INVOKABLE QStringList getCheckedUserList() const;

private:
    QVector<MemberInfo> m_members;
};

#endif  // LIVEMEMBERSMODEL_H
