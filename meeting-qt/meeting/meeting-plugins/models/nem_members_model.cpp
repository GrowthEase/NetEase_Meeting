// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_members_model.h"

NEMMembersModel::NEMMembersModel(QObject* parent)
    : QAbstractListModel(parent) {}

int NEMMembersModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid() || !m_membersController)
        return 0;
    return m_membersController->items().size();
}

QVariant NEMMembersModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || !m_membersController)
        return QVariant();

    if (index.row() > m_membersController->items().size())
        return QVariant();

    const auto member = m_membersController->items().at(index.row());

    switch (role) {
        case AccountId:
            return QVariant(member.accountId);
        case AvRoomUid:
            return QVariant(member.avRoomUid);
        case Nickname:
            return QVariant(member.nickname);
        case AudioStatus:
            return QVariant(member.audioStatus);
        case VideoStatus:
            return QVariant(member.videoStatus);
        case HandsupStatus:
            return QVariant(member.videoStatus);  // TODO(Dylan)
        case ShareStatus:
            return QVariant(member.sharing);
        case LiveStatus:
            return QVariant(member.videoStatus);  // TODO(Dylan)
        case ClientType:
            return QVariant(member.videoStatus);  // TODO(Dylan)
    }

    return QVariant();
}

QHash<int, QByteArray> NEMMembersModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[AccountId] = "accountId";
    names[AvRoomUid] = "uid";
    names[Nickname] = "nickname";
    names[AudioStatus] = "audioStatus";
    names[VideoStatus] = "videoStatus";
    names[HandsupStatus] = "handsupStatus";
    names[ShareStatus] = "shareStatus";
    names[LiveStatus] = "clientType";
    return names;
}

NEMMembersController* NEMMembersModel::membersController() const {
    return m_membersController;
}

void NEMMembersModel::setMembersController(NEMMembersController* membersController) {
    beginResetModel();

    if (m_membersController)
        m_membersController->disconnect(this);

    m_membersController = membersController;
    Q_EMIT membersControllerChanged();

    if (m_membersController) {
        connect(m_membersController, &NEMMembersController::preItemAppended, this, [=]() {
            const int index = m_membersController->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });
        connect(m_membersController, &NEMMembersController::postItemAppended, this, [=]() {
            // End insert rows
            endInsertRows();
        });
        connect(m_membersController, &NEMMembersController::preItemRemoved, this, [=](int index) {
            // Begin remove rows
            beginRemoveRows(QModelIndex(), index, index);
        });
        connect(m_membersController, &NEMMembersController::postItemRemoved, this, [=]() {
            // End remove rows
            endRemoveRows();
        });
        connect(m_membersController, &NEMMembersController::dataChanged, this, [=](int index) {
            // Data changed
            QModelIndex modelIndex = createIndex(index, 0);
            Q_EMIT dataChanged(modelIndex, modelIndex);
        });
    }

    endResetModel();
}
