// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

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
        case kMemberRoleAudioVolume:
            return QVariant(member.audioVolume);
        case kMemberRoleTag:
            return QVariant(member.tag);
        case kMemberRoleType:
            return QVariant(member.roleType);
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
    names[kMemberRoleAudioVolume] = "audioVolume";
    names[kMemberRoleTag] = "tag";
    names[kMemberRoleType] = "roleType";
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
    std::bitset<9> left;
    std::bitset<9> right;
    int index = 8;

    // sort by host account id
    QVariant leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleAccountId);
    QVariant rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleAccountId);
    auto accidLeft = leftData.toString();
    auto accidRight = rightData.toString();
    if (accidLeft == MembersManager::getInstance()->hostAccountId())
        left[index] = 1;
    if (accidRight == MembersManager::getInstance()->hostAccountId())
        right[index] = 1;
    if (left[index] == 1 || right[index] == 1) {
        return left[index] > right[index];
    }

    index--;
    if (index < 0) {
        return false;
    }

    // sort by manager account id
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleType);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleType);
    auto roleLeft = static_cast<NERoleType>(leftData.toInt());
    auto roleRight = static_cast<NERoleType>(rightData.toInt());
    if (roleLeft == kRoleManager) {
        left[index] = 1;
        if (accidLeft == AuthManager::getInstance()->authAccountId())
            left[index] = 2;
    }
    if (roleRight == kRoleManager) {
        right[index] = 1;
        if (accidLeft == AuthManager::getInstance()->authAccountId())
            right[index] = 2;
    }

    if (left[index] >= 1 || right[index] >= 1) {
        return left[index] > right[index];
    }

    index--;
    if (index < 0) {
        return false;
    }

    // sort by auth account id
    if (accidLeft == AuthManager::getInstance()->authAccountId())
        left[index] = 1;
    if (accidRight == AuthManager::getInstance()->authAccountId())
        right[index] = 1;
    if (left[index] == 1 || right[index] == 1) {
        return left[index] > right[index];
    }

    index--;
    if (index < 0) {
        return false;
    }

    // sort by hangup status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleHansUpStatus);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleHansUpStatus);
    auto handsupLeft = leftData.toUInt();
    auto handsupRight = rightData.toUInt();
    if (handsupLeft == 1)
        left[index] = 1;
    if (handsupRight == 1)
        right[index] = 1;

    index--;
    if (index < 0) {
        return false;
    }

    // sort by sharing status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleSharing);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleSharing);
    auto bShareLeft = leftData.toBool();
    auto bShareRight = rightData.toBool();
    if (bShareLeft)
        left[index] = 1;
    if (bShareRight)
        right[index] = 1;

    index--;
    if (index < 0) {
        return false;
    }

    // sort by whiteboard status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberWhiteboardShareOwner);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberWhiteboardShareOwner);
    auto whiteboardLeft = leftData.toBool();
    auto whiteboardRight = rightData.toBool();
    if (whiteboardLeft)
        left[index] = 1;
    if (whiteboardRight)
        right[index] = 1;

    index--;
    if (index < 0) {
        return false;
    }

    // sort by videso status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleVideo);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleVideo);
    auto videoEnableLeft = leftData.toUInt() == 1;
    auto videoEnableRight = rightData.toUInt() == 1;
    if (videoEnableLeft == 1)
        left[index] = 1;
    if (videoEnableRight == 1)
        right[index] = 1;

    index--;
    if (index < 0) {
        return false;
    }

    // sort by audio status
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleAudio);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleAudio);
    auto audioEnableLeft = leftData.toUInt() == 1;
    auto audioEnableRight = rightData.toUInt() == 1;
    if (audioEnableLeft == 1)
        left[index] = 1;
    if (audioEnableRight == 1)
        right[index] = 1;

    index--;
    if (index < 0) {
        return false;
    }

    // sort by nickname
    leftData = sourceModel()->data(source_left, MembersModel::kMemberRoleNickname);
    rightData = sourceModel()->data(source_right, MembersModel::kMemberRoleNickname);
    auto nickLeft = leftData.toString();
    auto nickRight = rightData.toString();
    if (nickLeft < nickRight) {
        left[index] = 1;
    } else {
        right[index] = 1;
    }

    return left.to_ulong() > right.to_ulong();
}

/******************** FilterProxyModel **************************/
