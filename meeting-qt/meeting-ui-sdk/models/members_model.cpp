/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#include "members_model.h"
#include <bitset>
MembersModel::MembersModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_bInserting(false) {}

int MembersModel::rowCount(const QModelIndex& parent) const {
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !m_pMemberMgr)
        return 0;

    auto members = m_pMemberMgr->items();

    // YXLOG(Info) << "Members model row count: " << members.size() << ", model pointer: " << this << YXLOGEnd;

    return members.size();
}

QVariant MembersModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || !m_pMemberMgr)
        return QVariant();

    auto members = m_pMemberMgr->items();

    if ((index.row() + 1) > (int)members.size())
        return QVariant();

    auto member = members.at(index.row());

    switch (role) {
        case kMemberRoleAccountId:
            return QVariant(member.accountId);
        case kMemberRoleNickname:
            return QVariant(member.nickname);
        case kMemberRoleAudio:
            return QVariant(member.audioStatus);
        case kMemberRoleVideo:
            return QVariant(member.videoStatus);
        case kMemberRoleSharing:
            return QVariant(member.sharing);
        case kMemberRoleHansUpStatus:
            return QVariant(member.handsupStatus);
        case kMemberRoleClientType:
            return QVariant(member.clientType);
        case kMemberRoleWhiteboard:
            return QVariant(member.isWhiteboardEnable);
        case kMemberWhiteboardShareOwner:
            return QVariant(member.isWhiteboardShareOwner);
    }

    return QVariant();
}

QHash<int, QByteArray> MembersModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kMemberRoleAccountId] = "accountId";
    names[kMemberRoleNickname] = "nickname";
    names[kMemberRoleAudio] = "audioStatus";
    names[kMemberRoleVideo] = "videoStatus";
    names[kMemberRoleSharing] = "sharing";
    names[kMemberRoleHansUpStatus] = "handsUpStatus";
    names[kMemberRoleClientType] = "clientType";
    names[kMemberRoleWhiteboard] = "isWhiteboardEnable";
    names[kMemberWhiteboardShareOwner] = "isWhiteboardShareOwner";
    return names;
}

MembersManager* MembersModel::manager() const {
    return m_pMemberMgr;
}

void MembersModel::setManager(MembersManager* membersManager) {
    YXLOG(Info) << "Members model set manager: " << membersManager << ", model pointer: " << this << YXLOGEnd;
    beginResetModel();

    if (m_pMemberMgr)
        membersManager->disconnect(this);

    m_pMemberMgr = membersManager;

    connect(m_pMemberMgr, &MembersManager::preItemAppended, this, [=]() {
        const int index = m_pMemberMgr->items().size();
        beginInsertRows(QModelIndex(), index, index);
    });
    connect(m_pMemberMgr, &MembersManager::postItemAppended, this, [=]() {
        // End insert row
        endInsertRows();
    });
    connect(m_pMemberMgr, &MembersManager::preItemRemoved, this, [=](int index) {
        // Begin remove rows
        beginRemoveRows(QModelIndex(), index, index);
    });
    connect(m_pMemberMgr, &MembersManager::postItemRemoved, this, [=]() {
        // End remove rows
        endRemoveRows();
    });
    connect(m_pMemberMgr, &MembersManager::dataChanged, this, [=](int index, int role) {
        // Data changed
        QModelIndex modelIndex = createIndex(index, 0);
        if (role < 0) {
            Q_EMIT dataChanged(modelIndex, modelIndex);
        } else {
            QVector<int> roles = {role};
            Q_EMIT dataChanged(modelIndex, modelIndex, roles);
        }
    });
    connect(MeetingManager::getInstance(), &MeetingManager::meetingStatusChanged, this,
            [this](NEMeeting::Status status, int /*errorCode*/, const QString& /*errorMessage*/) {
                if (status == NEMeeting::MEETING_IDLE || status == NEMeeting::MEETING_CONNECT_FAILED || status == NEMeeting::MEETING_CONNECTED ||
                    status == NEMeeting::MEETING_ENDED || status == NEMeeting::MEETING_DISCONNECTED ||
                    status == NEMeeting::MEETING_RECONNECT_FAILED) {
                    beginResetModel();
                    endResetModel();
                }
            });

#if 0
    connect(AudioManager::getInstance(), &AudioManager::userAudioStatusChanged, this,
            [=](const QString& changedAccountId, DeviceStatus deviceStatus) {
        m_pMemberMgr->items(members);
        for (std::size_t i = 0; i < members.size(); i++) {
            const auto& member = members.at(i);
            if (QString::fromStdString(member->getUserId()) == changedAccountId) {
                QModelIndex index = createIndex(i, 0);
                emit dataChanged(index, index);
                break;
            }
        }
    });

    connect(AudioManager::getInstance(), &AudioManager::handsupStatusChanged, this, [=](const QString& changedAccountId, int Status) {
        std::vector<SharedUserPtr> members;
        m_pMemberMgr->getMembersList(members);
        for (std::size_t i = 0; i < members.size(); i++) {
            const auto& member = members.at(i);
            if (QString::fromStdString(member->getUserId()) == changedAccountId) {
                QModelIndex index = createIndex(i, 0);
                emit dataChanged(index, index);
                break;
            }
        }
    });

    connect(VideoManager::getInstance(), &VideoManager::userVideoStatusChanged, this,
            [=](const QString& changedAccountId, DeviceStatus /*deviceStatus*/) {
        std::vector<SharedUserPtr> members;
        m_pMemberMgr->getMembersList(members);
        for (std::size_t i = 0; i < members.size(); i++) {
            const auto& member = members.at(i);
            if (QString::fromStdString(member->getUserId()) == changedAccountId) {
                QModelIndex index = createIndex(i, 0);
                emit dataChanged(index, index);
                break;
            }
        }
    });
#endif

    endResetModel();
}

/******************** FilterProxyModel **************************/
FilterProxyModel::FilterProxyModel(QObject* parent)
    : QSortFilterProxyModel(parent) {
    setSortOrder(true);
    setFilterRole(MembersModel::kMemberRoleNickname);
    setSortRole(MembersModel::kMemberRoleNickname);
    sort(0);
    setDynamicSortFilter(true);
}

FilterProxyModel::~FilterProxyModel() {}

void FilterProxyModel::setFilterString(QString string) {
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
    this->setFilterFixedString(string);
}

void FilterProxyModel::setSortOrder(bool checked) {
    if (checked) {
        this->sort(0, Qt::DescendingOrder);
    } else {
        this->sort(0, Qt::AscendingOrder);
    }
}

void FilterProxyModel::setSortModel(QAbstractItemModel* sourceModel) {
    setSourceModel(sourceModel);
}

bool FilterProxyModel::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const {
    std::bitset<8> left;
    std::bitset<8> right;

    // sort by host account id
    QVariant leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleAccountId);
    QVariant rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleAccountId);
    auto accidLeft = leftData.toString();
    auto accidRight = rightData.toString();
    if (accidLeft == MembersManager::getInstance()->hostAccountId())
        left[7] = 1;
    if (accidRight == MembersManager::getInstance()->hostAccountId())
        right[7] = 1;
    if (left[7] == 1 || right[7] == 1) {
        return left[7] > right[7];
    }

    // sort by auth account id
    if (accidLeft == AuthManager::getInstance()->authAccountId())
        left[6] = 1;
    if (accidRight == AuthManager::getInstance()->authAccountId())
        right[6] = 1;
    if (left[6] == 1 || right[6] == 1) {
        return left[6] > right[6];
    }

    // sort by sharing status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleSharing);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleSharing);
    auto bShareLeft = leftData.toBool();
    auto bShareRight = rightData.toBool();
    if (bShareLeft)
        left[5] = 1;
    if (bShareRight)
        right[5] = 1;

    // sort by hangup status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleHansUpStatus);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleHansUpStatus);
    auto handsupLeft = leftData.toUInt();
    auto handsupRight = rightData.toUInt();
    if (handsupLeft == 1)
        left[4] = 1;
    if (handsupRight == 1)
        right[4] = 1;

    // sort by audio status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleAudio);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleAudio);
    auto audioEnableLeft = leftData.toUInt() == 1;
    auto audioEnableRight = rightData.toUInt() == 1;
    if (audioEnableLeft == 1)
        left[3] = 1;
    if (audioEnableRight == 1)
        right[3] = 1;

    // sort by nickname
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleNickname);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleNickname);
    auto nickLeft = leftData.toString();
    auto nickRight = rightData.toString();
    if (nickLeft < nickRight) {
        left[2] = 1;
    } else {
        right[2] = 1;
    }

    return left.to_ulong() > right.to_ulong();
}

/******************** FilterProxyModel **************************/
