// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "invite_model.h"

InviteModel::InviteModel(QObject* parent)
    : QAbstractListModel(parent) {}

InviteModel::~InviteModel() {
    if (m_manager)
        disconnect(m_manager, 0, this, 0);
}

int InviteModel::rowCount(const QModelIndex& parent) const {
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.

    if (parent.isValid() || !m_manager)
        return 0;

    return m_manager->getInstance()->getSipList().size();
}

QVariant InviteModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid())
        return QVariant();

    auto indexTmp = index.row();
    auto inviteInfo = m_manager->getInstance()->getSipList();
    if (indexTmp < 0 || indexTmp >= (int)inviteInfo.size()) {
        return QVariant();
    }
    auto info = std::next(inviteInfo.begin(), indexTmp);
    switch (role) {
        case ksipNum:
            return QVariant(info->sipNum);
        default:
            break;
    }

    return QVariant();
}

QHash<int, QByteArray> InviteModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[ksipNum] = "sipNum";
    return names;
}

InviteManager* InviteModel::manager() const {
    return m_manager;
}

void InviteModel::setManager(InviteManager* manager) {
    beginResetModel();

    if (m_manager)
        m_manager->disconnect(this);

    m_manager = manager;

    if (m_manager) {
        connect(m_manager, &InviteManager::sipChanged, this, [=]() {
            beginResetModel();
            endResetModel();
        });
    }

    endResetModel();
}
