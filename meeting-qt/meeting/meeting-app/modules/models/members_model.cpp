// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "members_model.h"

MembersModel::MembersModel(QObject* parent)
    : QAbstractListModel(parent) {}

int MembersModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid())
        return 0;

    return m_members.size();
}

QVariant MembersModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid())
        return QVariant();

    if (index.row() + 1 > m_members.size())
        return QVariant();

    auto member = m_members.at(index.row());

    switch (role) {
        case kMemberRoleAccountId:
            return QVariant(member.accountId);
        case kMemberRoleNickname:
            return QVariant(member.nickName);
        case kMemberRoleChecked:
            return QVariant(member.checkState);
    }

    return QVariant();
}

QHash<int, QByteArray> MembersModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kMemberRoleAccountId] = "accountId";
    names[kMemberRoleNickname] = "nickname";
    names[kMemberRoleChecked] = "checkState";

    return names;
}

void MembersModel::initData(const QJsonArray& userList) {
    qInfo() << "initData: " << userList;
    beginResetModel();
    m_members.clear();
    MemberInfo info;
    info.accountId = "";
    info.nickName = tr("none");
    info.checkState = Checked;
    m_members.push_back(info);
    for (auto user : userList) {
        auto userObj = user.toObject();
        info.accountId = userObj["accountId"].toString();
        info.nickName = userObj["nickname"].toString();
        info.checkState = Unchecked;
        m_members.push_back(info);
    }
    endResetModel();
}

void MembersModel::setChecked(bool checked, int row) {
    if (row == 0 && m_members.count() > 1 && checked) {
        m_members[0].checkState = Checked;
        QModelIndex modelIndex = createIndex(0, 0);
        emit dataChanged(modelIndex, modelIndex);

        for (int index = 1; index < m_members.count(); index++) {
            m_members[index].checkState = Unchecked;
            QModelIndex modelIndex = createIndex(index, 0);
            emit dataChanged(modelIndex, modelIndex);
        }
        return;
    }

    if (row < m_members.count()) {
        m_members[row].checkState = checked ? Checked : Unchecked;
        QModelIndex modelIndex = createIndex(row, 0);
        emit dataChanged(modelIndex, modelIndex);

        if (m_members[row].checkState == Checked) {
            m_members[0].checkState = Unchecked;
            QModelIndex modelIndex = createIndex(0, 0);
            emit dataChanged(modelIndex, modelIndex);
        }
    }
}

QStringList MembersModel::getCheckedUserList() const {
    QStringList userList;
    if (m_members.count() < 2) {
        return userList;
    }

    for (int i = 1; i < m_members.count(); i++) {
        if (m_members[i].checkState == Checked) {
            userList.push_back(m_members[i].nickName);
        }
    }
    return userList;
}
