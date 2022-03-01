/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "live_members_model.h"

#define MAX_LIVE_MEMBERS_COUNT 4

LiveMembersModel::LiveMembersModel(QObject* parent)
    : QAbstractListModel(parent) {
    qInfo() << "LiveMembersModel::LiveMembersModel";
    initManagerConnect();
}

int LiveMembersModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid())
        return 0;

    return m_members.size();
}

QVariant LiveMembersModel::data(const QModelIndex& index, int role) const {
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
        case kMemberRoleNumber:
            return QVariant(member.number);
    }

    return QVariant();
}

QHash<int, QByteArray> LiveMembersModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kMemberRoleAccountId] = "accountId";
    names[kMemberRoleNickname] = "nickname";
    names[kMemberRoleChecked] = "checkState";
    names[kMemberRoleNumber] = "number";

    return names;
}

void LiveMembersModel::setChecked(int row) {
    if (row >= m_members.count()) {
        return;
    }

    int tempNumber = 0;
    int tempCount = 0;

    LiveMemberInfo& info = m_members[row];
    if (info.checkState == DisableChecked) {
        return;
    } else if (info.checkState == Unchecked) {
        info.checkState = Checked;
        m_liveMemberCount++;
        emit liveMemberCountChanged();
        info.number = m_liveMemberCount;

        QModelIndex modelIndex = createIndex(row, 0);
        emit dataChanged(modelIndex, modelIndex);

    } else {
        info.checkState = Unchecked;
        tempNumber = info.number;
        info.number = 0;
        tempCount = m_liveMemberCount;
        m_liveMemberCount--;
        emit liveMemberCountChanged();

        QModelIndex modelIndex = createIndex(row, 0);
        emit dataChanged(modelIndex, modelIndex);
    }

    if (info.checkState == Checked && m_liveMemberCount == MAX_LIVE_MEMBERS_COUNT) {
        //勾选第四个成员、将其他未选的按钮置成不可选状态
        for (int index = 0; index < m_members.count(); index++) {
            if (m_members[index].checkState == Unchecked) {
                m_members[index].checkState = DisableChecked;

                QModelIndex modelIndex = createIndex(index, 0);
                emit dataChanged(modelIndex, modelIndex);
            }
        }
    } else if (info.checkState == Unchecked) {
        if (tempNumber < tempCount) {
            //取消勾选非尾部的成员
            for (int index = 0; index < m_members.count(); index++) {
                if (m_members[index].checkState == Checked && m_members[index].number > tempNumber) {
                    m_members[index].number--;

                    QModelIndex modelIndex = createIndex(index, 0);
                    emit dataChanged(modelIndex, modelIndex);
                }
            }
        }

        if (tempCount == MAX_LIVE_MEMBERS_COUNT) {
            //已勾选四个成员中，取消勾选一个、将其他不可选的按钮置成未选状态
            for (int index = 0; index < m_members.count(); index++) {
                if (m_members[index].checkState == DisableChecked) {
                    m_members[index].checkState = Unchecked;

                    QModelIndex modelIndex = createIndex(index, 0);
                    emit dataChanged(modelIndex, modelIndex);
                }
            }
        }
    }
}

int LiveMembersModel::getliveMemberCount() {
    return m_liveMemberCount;
}

QJsonArray LiveMembersModel::getCheckedUserlist() {
    QVector<LiveMemberInfo> vec = m_members;
    std::sort(vec.begin(), vec.end(), [](LiveMemberInfo i, LiveMemberInfo j) { return i.number < j.number; });

    QJsonArray array;

    for (int i = 0; i < vec.count(); i++) {
        if (vec[i].checkState == Checked) {
            QJsonObject obj;
            obj.insert("accountId", vec[i].accountId);
            array.push_back(obj);
        }
    }

    return array;
}

bool LiveMembersModel::updateLiveMembers(QJsonArray array) {
    if (array.isEmpty()) {
        return false;
    }

    m_liveMemberCount = 0;

    QVector<QString> vecUsers;
    for (int i = 0; i < array.size(); i++) {
        const QString uid = array[i].toVariant().toString();
        if (std::find_if(m_members.begin(), m_members.end(), [uid](const LiveMemberInfo& obj) { return obj.accountId == uid; }) != m_members.end()) {
            vecUsers << uid;
        }
    }

    for (int i = 0; i < m_members.count(); i++) {
        if (vecUsers.contains(m_members[i].accountId)) {
            m_members[i].checkState = Checked;
            m_liveMemberCount++;
            m_members[i].number = vecUsers.indexOf(m_members[i].accountId) + 1;
        } else {
            if (vecUsers.count() == MAX_LIVE_MEMBERS_COUNT) {
                m_members[i].checkState = DisableChecked;
            } else {
                m_members[i].checkState = Unchecked;
            }
            m_members[i].number = 0;
        }

        QModelIndex modelIndex = createIndex(i, 0);
        emit dataChanged(modelIndex, modelIndex);
    }

    if (vecUsers.count() != array.count()) {
        emit liveMemberCountChanged();
    }

    return true;
}

bool LiveMembersModel::getLiveMemberIsSharing() {
    QString accountId = ShareManager::getInstance()->shareAccountId();
    if (accountId.isEmpty() || m_liveMemberCount <= 0) {
        return false;
    }

    for (int i = 0; i < m_members.count(); i++) {
        if (m_members[i].checkState == Checked && m_members[i].accountId == accountId) {
            return true;
        }
    }

    return false;
}

void LiveMembersModel::initManagerConnect() {
    beginResetModel();

    connect(MembersManager::getInstance(), &MembersManager::afterUserJoined, this, [=](const QString& accountId, bool bNotify) {
        SharedUserPtr member = MembersManager::getInstance()->getMemberByAccountId(accountId);
        if (member.get() == nullptr) {
            return;
        }

        //判断该成员是否满足直播条件
        if (!isLiveMember(member)) {
            return;
        }

        beginInsertRows(QModelIndex(), m_members.size(), m_members.size());
        addLiveMember(QString::fromStdString(member->getDisplayName()), QString::fromStdString(member->getUserId()));
        endInsertRows();
    });

    connect(MembersManager::getInstance(), &MembersManager::beforeUserLeave, this, [=](const QString& accountId, int /*memberIndex*/) {
        for (int index = 0; index < m_members.count(); index++) {
            if (m_members[index].accountId == accountId) {
                if (m_members[index].checkState == Checked) {
                    //更新序号
                    updateCheckNumber(m_members[index].number);
                    //更新选中状态
                    updateCheckState(Unchecked);
                    m_liveMemberCount--;
                    emit liveMemberCountChanged();
                }

                if (accountId == m_shareAccountId) {
                    m_shareAccountId = "";
                }

                beginRemoveRows(QModelIndex(), index, index);
                m_members.remove(index);
                endRemoveRows();

                return;
            }
        }
    });

    connect(MeetingManager::getInstance(), &MeetingManager::meetingStatusChanged, this,
            [this](NEMeeting::Status status, int /*errorCode*/, const QString& /*errorMessage*/) {
                if (status == NEMeeting::MEETING_ENDED || status == NEMeeting::MEETING_KICKOUT_BY_HOST ||
                    status == NEMeeting::MEETING_MULTI_SPOT_LOGIN || status == NEMeeting::MEETING_DISCONNECTED) {
                    beginResetModel();
                    m_members.clear();
                    m_liveMemberCount = 0;
                    emit liveMemberCountChanged();
                    endResetModel();
                }
            });

    connect(VideoManager::getInstance(), &VideoManager::userVideoStatusChanged, this,
            [=](const QString& changedAccountId, NEMeeting::DeviceStatus deviceStatus) {
                bool bFound = false;
                int index = 0;
                for (index = 0; index < m_members.count(); index++) {
                    if (changedAccountId == m_members[index].accountId) {
                        bFound = true;
                        break;
                    }
                }

                SharedUserPtr member = MembersManager::getInstance()->getMemberByAccountId(changedAccountId);
                if (member.get() == nullptr) {
                    return;
                }

                if (deviceStatus == NEMeeting::DEVICE_ENABLED) {
                    //如果成员摄像头打开，则加入直播列表
                    if (!bFound) {
                        beginInsertRows(QModelIndex(), m_members.size(), m_members.size());
                        addLiveMember(QString::fromStdString(member->getDisplayName()), QString::fromStdString(member->getUserId()));
                        endInsertRows();
                    }
                } else {
                    //如果成员摄像头关闭、并且未共享屏幕，则在直播列表中移除
                    QString accountId = ShareManager::getInstance()->shareAccountId();
                    if (bFound && (accountId.isEmpty() || (accountId != changedAccountId))) {
                        if (m_members[index].checkState == Checked) {
                            //更新序号
                            updateCheckNumber(m_members[index].number);
                            //更新选中状态
                            updateCheckState(Unchecked);

                            m_liveMemberCount--;
                            emit liveMemberCountChanged();
                        }

                        qInfo() << "m_liveMemberCount: " << m_liveMemberCount;

                        beginRemoveRows(QModelIndex(), index, index);
                        m_members.remove(index);
                        endRemoveRows();
                    }
                }
            });

    connect(ShareManager::getInstance(), &ShareManager::shareAccountIdChanged, this, [=] {
        QString accountId = ShareManager::getInstance()->shareAccountId();

        if (accountId.isEmpty()) {
            accountId = m_shareAccountId;
            emit liveMemberShareStatusChanged(false);
        }

        SharedUserPtr member = MembersManager::getInstance()->getMemberByAccountId(accountId);
        if (member.get() == Q_NULLPTR) {
            return;
        }

        bool bFound = false;
        int index = 0;
        for (index = 0; index < m_members.count(); index++) {
            if (accountId == m_members[index].accountId) {
                bFound = true;
                break;
            }
        }

        if (!bFound) {
            if (member->getScreenSharing()) {
                //开启屏幕共享，则加入直播成员列表
                beginInsertRows(QModelIndex(), m_members.size(), m_members.size());
                m_shareAccountId = QString::fromStdString(member->getUserId());
                addLiveMember(QString::fromStdString(member->getDisplayName()), QString::fromStdString(member->getUserId()));
                emit liveMemberShareStatusChanged(true);
                endInsertRows();
            }
        } else {
            //如果成员摄像头关闭、并且未共享屏幕，则在直播列表中移除
            if (member->getVideoStatus() != NEMeeting::DEVICE_ENABLED && !member->getScreenSharing()) {
                if (m_members[index].checkState == Checked) {
                    //更新序号
                    updateCheckNumber(m_members[index].number);
                    //更新选中状态
                    updateCheckState(Unchecked);
                    m_liveMemberCount--;
                    emit liveMemberCountChanged();
                }

                m_shareAccountId = "";
                beginRemoveRows(QModelIndex(), index, index);
                m_members.remove(index);
                endRemoveRows();
            } else if (member->getScreenSharing()) {
                emit liveMemberShareStatusChanged(true);
            }
        }
    });

    connect(MembersManager::getInstance(), &MembersManager::nicknameChanged, this, [=](const QString& accountId, const QString& nickname) {
        bool bFound = false;
        int index = 0;
        for (index = 0; index < m_members.count(); index++) {
            if (accountId == m_members[index].accountId) {
                bFound = true;
                break;
            }
        }
        if (true == bFound) {
            m_members[index].nickName = nickname;
            QModelIndex modelIndex = createIndex(index, 0);
            emit dataChanged(modelIndex, modelIndex);
        }
    });

    endResetModel();
}

bool LiveMembersModel::isLiveMember(const SharedUserPtr& member) {
    if (member->getVideoStatus() != NEMeeting::DEVICE_ENABLED && member->getScreenSharing() == false) {
        return false;
    }

    // 如果在成员列表中已经存在，则不允许再次插入
    for (auto& insideMember : m_members) {
        if (insideMember.accountId == QString::fromStdString(member->getUserId()))
            return false;
    }

    return true;
}

void LiveMembersModel::addLiveMember(const QString& nickName, const QString& accountId) {
    LiveMemberInfo info;
    info.checkState = Unchecked;
    info.nickName = nickName;
    info.accountId = accountId;

    if (m_liveMemberCount == 4) {
        info.checkState = DisableChecked;
    }

    m_members.push_back(info);
}

void LiveMembersModel::updateCheckState(bool bDisableChecked) {
    if (bDisableChecked) {
        if (m_liveMemberCount == MAX_LIVE_MEMBERS_COUNT) {
            for (int i = 0; i < m_members.count(); i++) {
                if (m_members[i].checkState == Unchecked) {
                    m_members[i].checkState = DisableChecked;
                    QModelIndex modelIndex = createIndex(i, 0);
                    emit dataChanged(modelIndex, modelIndex);
                }
            }
        }
    } else {
        if (m_liveMemberCount == MAX_LIVE_MEMBERS_COUNT) {
            for (int i = 0; i < m_members.count(); i++) {
                if (m_members[i].checkState == DisableChecked) {
                    m_members[i].checkState = Unchecked;
                    QModelIndex modelIndex = createIndex(i, 0);
                    emit dataChanged(modelIndex, modelIndex);
                }
            }
        }
    }
}

void LiveMembersModel::updateCheckNumber(int number) {
    if (number == m_liveMemberCount) {
        return;
    }

    for (int i = 0; i < m_members.count(); i++) {
        if (m_members[i].number > number) {
            m_members[i].number--;
            QModelIndex modelIndex = createIndex(i, 0);
            emit dataChanged(modelIndex, modelIndex);
        }
    }
}
