/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "members_manager.h"
#include "../../models/members_model.h"
#include "manager/global_manager.h"
#include "manager/meeting/whiteboard_manager.h"

MembersManager::MembersManager(QObject* parent)
    : QObject(parent) {
    m_membersController = MeetingManager::getInstance()->getUserController();

    auto globalConfig = GlobalManager::getInstance()->getGlobalConfig();
    auto galleryViewPageSize = globalConfig->getGalleryPageSize();
    setGalleryViewPageSize(galleryViewPageSize);

    connect(this, &MembersManager::afterUserJoined, this, &MembersManager::onAfterUserJoinedUI);
    connect(this, &MembersManager::afterUserLeft, this, &MembersManager::onAfterUserLeftUI);

    connect(&m_refreshTime, &QTimer::timeout, this, [this]() { getMembersPaging(m_pageSize, m_currentPage); });
    m_refreshTime.setSingleShot(true);
}

MembersManager::~MembersManager() {
    this->disconnect();
}

QString MembersManager::getNicknameByAccountId(const QString& accountId) {
    if (m_membersController == nullptr)
        return QString();
    QByteArray byteAccountId = accountId.toUtf8();
    auto memberInfo = GlobalManager::getInstance()->getInRoomService()->getUserInfoById(byteAccountId.data());
    return memberInfo == nullptr ? "" : QString::fromStdString(memberInfo->getDisplayName());
}

void MembersManager::onBeforeUserJoin(const std::string& /*accountId*/, uint32_t /*memberCount*/) {
    // emit beforeUserJoin(QString::fromStdString(accountId), memberCount);
}

void MembersManager::onAfterUserJoined(const std::string& accountId, bool bNotify) {
#if 0
    emit afterUserJoined(QString::fromStdString(accountId), bNotify);
#else
    m_invoker.execute([=]() {
        if (m_membersController) {
            auto member = GlobalManager::getInstance()->getInRoomService()->getUserInfoById(accountId);
            if (member) {
                if (kRoleHiding != member->getRoleType()) {
                    Q_EMIT preItemAppended();
                    MemberInfo info;
                    info.accountId = QString::fromStdString(member->getUserId());
                    info.audioStatus = member->getAudioStatus();
                    info.videoStatus = member->getVideoStatus();
                    info.handsupStatus = (NEMeeting::HandsUpStatus)member->getRaiseHandDetail().status;
                    info.nickname = QString::fromStdString(member->getDisplayName());
                    info.sharing = member->getScreenSharing();
                    info.isWhiteboardEnable = member->getWhiteBoardInteractStatus() == kNERoomWhiteBoardInteractionStatusOpen;
                    info.isWhiteboardShareOwner = info.accountId == WhiteboardManager::getInstance()->whiteboardSharerAccountId();
                    m_items.append(info);
                    Q_EMIT postItemAppended();
                }
            }
        }
        setCount(m_items.size());
        emit afterUserJoined(QString::fromStdString(accountId), bNotify);
    });
#endif
}

void MembersManager::onBeforeUserLeave(const std::string& accountId, uint32_t memberIndex) {
    m_ptrLeaveUsr = GlobalManager::getInstance()->getInRoomService()->getUserInfoById(accountId);
    emit beforeUserLeave(QString::fromStdString(accountId), memberIndex);
}

void MembersManager::onAfterUserLeft(const std::string& accountId, bool bNotify) {
#if 0
    emit afterUserLeft(QString::fromStdString(accountId));
#else
    m_invoker.execute([=]() {
        for (int i = 0; i < m_items.size(); i++) {
            QString qstrAccountId = QString::fromStdString(accountId);
            if (m_items.at(i).accountId == qstrAccountId) {
                Q_EMIT preItemRemoved(i);
                m_items.remove(i);
                Q_EMIT postItemRemoved();
                break;
            }
        }
        setCount(m_items.size());
        emit afterUserLeft(QString::fromStdString(accountId), bNotify);
    });
#endif
}

void MembersManager::onHostChanged(const std::string& hostAccountId) {
    if (AuthManager::getInstance()->getAuthInfo()->getAccountId() == hostAccountId) {
        AudioManager::getInstance()->setHandsUpStatus(false);
    }

    QMetaObject::invokeMethod(this, "onHostChangedUI", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(hostAccountId)));
}

void MembersManager::onMemberNicknameChanged(const std::string& accountId, const std::string& nickname) {
    YXLOG(Info) << "onMemberNicknameChanged accountId : " << accountId << ", nickname: " << nickname << YXLOGEnd;

    QMetaObject::invokeMethod(this, "handleNicknameChanged", Qt::AutoConnection, Q_ARG(QString, QString::fromStdString(accountId)),
                              Q_ARG(QString, QString::fromStdString(nickname)));
}

SharedUserPtr MembersManager::getPrimaryMember() {
    auto membersCount = m_items.size();
    auto audioController = MeetingManager::getInstance()->getInRoomAudioController();
    auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    std::string primary;
    do {
        if (!meetingInfo->getScreenSharingUserId().empty()) {
            primary = meetingInfo->getScreenSharingUserId();
            YXLOG(Info) << "Select screen sharing member as primary member: " << primary << YXLOGEnd;
            break;
        }
        if (!meetingInfo->getPinnedUserId().empty()) {
            primary = meetingInfo->getPinnedUserId();
            YXLOG(Info) << "Select focus member as primary member: " << primary << YXLOGEnd;
            break;
        }
        if (!meetingInfo->getSpeakerUserId().empty() && membersCount > 2) {
            primary = meetingInfo->getSpeakerUserId();
            YXLOG(Info) << "Select active speaker member as primary member: " << primary << YXLOGEnd;
            break;
        }
        if (!meetingInfo->getHostUserId().empty() && membersCount > 2 && meetingInfo->getHostUserId() != authInfo->getAccountId()) {
            primary = meetingInfo->getHostUserId();
            YXLOG(Info) << "Select meeting host member as primary member: " << primary << YXLOGEnd;
            break;
        }

        if (m_items.size() > 0) {
            primary = m_items.last().accountId.toStdString();
        }

        YXLOG(Info) << "Select the last member to join as primary member: " << primary << YXLOGEnd;
    } while (false);

    return GlobalManager::getInstance()->getInRoomService()->getUserInfoById(primary);
}

SharedUserPtr MembersManager::getMemberByAccountId(const QString& accountId) {
    return GlobalManager::getInstance()->getInRoomService()->getUserInfoById(accountId.toStdString());
}

void MembersManager::getMembersPaging(quint32 pageSize, quint32 pageNumber) {
    if (isWhiteboardView()) {
        pagingWhiteboardView(pageSize, pageNumber);
    } else if (isGalleryView()) {
        pagingGalleryView(pageSize, pageNumber);
    } else {
        pagingFocusView(pageSize, pageNumber);
    }
}

void MembersManager::setAsHost(const QString& accountId) {
    QByteArray byteAccountId = accountId.toUtf8();
    m_membersController->makeHost(byteAccountId.data(), std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void MembersManager::setAsFocus(const QString& accountId, bool set) {
    QByteArray byteAccountId = accountId.toUtf8();
    MeetingManager::getInstance()->getInRoomVideoController()->pinVideo(accountId.toStdString(), set, std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void MembersManager::kickMember(const QString& accountId) {
    QByteArray byteAccountId = accountId.toUtf8();
    m_membersController->removeUser(byteAccountId.data(), std::bind(&MeetingManager::onError, MeetingManager::getInstance(), std::placeholders::_1, std::placeholders::_2));
}

void MembersManager::pagingFocusView(quint32 pageSize, quint32 pageNumber) {
    std::vector<SharedUserPtr> members;
    GlobalManager::getInstance()->getInRoomService()->getUsersByRoleType(members);
    if (members.size() == 0)
        return;

    SharedUserPtr primaryMemberPtr = getPrimaryMember();
    if (primaryMemberPtr == nullptr)
        return;

    std::vector<SharedUserPtr> secondaryMembers;
    auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
    std::string strSharingAccountId = meetingInfo->getScreenSharingUserId();
    if (strSharingAccountId.empty()) {
        for (auto& member : members) {
            if (member->getUserId() == primaryMemberPtr->getUserId())
                continue;
            secondaryMembers.push_back(member);
        }
    } else {
        auto authInfo = AuthManager::getInstance()->getAuthInfo();
        if (authInfo && (strSharingAccountId != authInfo->getAccountId())) {
            auto it = std::find_if(members.begin(), members.end(),
                                   [strSharingAccountId](const SharedUserPtr& accountId) { return accountId->getUserId() == strSharingAccountId; });
            if (members.end() != it) {
                secondaryMembers.push_back(*it);
                for (auto& member : members) {
                    if (*it == member)
                        continue;
                    secondaryMembers.push_back(member);
                }
            } else {
                secondaryMembers = members;
            }
        } else {
            secondaryMembers = members;
        }
    }

    uint32_t pageCount =
        secondaryMembers.size() <= pageSize ? 1 : secondaryMembers.size() / pageSize + (secondaryMembers.size() % pageSize == 0 ? 0 : 1);
    m_currentPage = pageNumber > pageCount ? pageCount : pageNumber;
    m_pageSize = pageSize;

    QJsonArray pagedMembers;
    int begin = (m_currentPage - 1) * pageSize;
    int end = begin + pageSize > secondaryMembers.size() ? secondaryMembers.size() : begin + pageSize;
    YXLOG(Info) << "Get members from cache list: " << begin << " to " << end << ", current page: " << m_currentPage << ", page count: " << pageCount
                << ", page size: " << m_pageSize << YXLOGEnd;
    for (int i = begin; i < end; i++) {
        auto member_item = secondaryMembers[i];
        QJsonObject member;
        member[kMemberAccountId] = QString::fromStdString(member_item->getUserId());
        member[kMemberNickanme] = QString::fromStdString(member_item->getDisplayName());
        member[kMemberAudioStatus] = member_item->getAudioStatus();
        member[kMemberVideoStatus] = member_item->getVideoStatus();
        member[kMemberSharingStatus] = member_item->getScreenSharing();
        member[kMemberAudioHandsUpStatus] = member_item->getRaiseHandDetail().status;
        member[kMemberClientType] = member_item->getClientType();
        pagedMembers.push_back(member);
    }

    QJsonObject primaryMember;
    primaryMember[kMemberAccountId] = QString::fromStdString(primaryMemberPtr->getUserId());
    primaryMember[kMemberNickanme] = QString::fromStdString(primaryMemberPtr->getDisplayName());
    primaryMember[kMemberAudioStatus] = primaryMemberPtr->getAudioStatus();
    primaryMember[kMemberVideoStatus] = primaryMemberPtr->getVideoStatus();
    primaryMember[kMemberSharingStatus] = primaryMemberPtr->getScreenSharing();
    primaryMember[kMemberAudioHandsUpStatus] = primaryMemberPtr->getRaiseHandDetail().status;
    primaryMember[kMemberClientType] = primaryMemberPtr->getClientType();

    YXLOG(Debug) << "-------------------------------------------------" << YXLOGEnd;
    YXLOG(Debug) << "Focus view, primary member: " << primaryMemberPtr->getUserId() << YXLOGEnd;
    for (int i = 0; i < pagedMembers.size(); i++) {
        const QJsonObject& member = pagedMembers.at(i).toObject();
        YXLOG(Debug) << "Secondary members: " << i << ", member info: " << member[kMemberAccountId].toString().toStdString() << YXLOGEnd;
    }
    YXLOG(Debug) << "-------------------------------------------------" << YXLOGEnd;

    emit membersChanged(primaryMember, pagedMembers, m_currentPage, secondaryMembers.size());
}

void MembersManager::pagingWhiteboardView(quint32 pageSize, quint32 pageNumber) {
    std::vector<SharedUserPtr> members;
    GlobalManager::getInstance()->getInRoomService()->getUsersByRoleType(members);

    if (members.size() == 0)
        return;

    std::vector<SharedUserPtr> secondaryMembers;
    SharedUserPtr whiteboardShareMember;
    for (auto& member : members) {
        if (member->getUserId() == WhiteboardManager::getInstance()->whiteboardSharerAccountId().toStdString()) {
            whiteboardShareMember = member;
        } else {
            secondaryMembers.push_back(member);
        }
    }

    if (whiteboardShareMember != nullptr) {
        secondaryMembers.insert(secondaryMembers.begin(), whiteboardShareMember);
    }

    uint32_t pageCount =
        secondaryMembers.size() <= pageSize ? 1 : secondaryMembers.size() / pageSize + (secondaryMembers.size() % pageSize == 0 ? 0 : 1);
    m_currentPage = pageNumber > pageCount ? pageCount : pageNumber;
    m_pageSize = pageSize;

    QJsonArray pagedMembers;
    int begin = (m_currentPage - 1) * pageSize;
    int end = begin + pageSize > secondaryMembers.size() ? secondaryMembers.size() : begin + pageSize;

    for (int i = begin; i < end; i++) {
        auto member_item = secondaryMembers[i];
        QJsonObject member;
        member[kMemberAccountId] = QString::fromStdString(member_item->getUserId());
        member[kMemberNickanme] = QString::fromStdString(member_item->getDisplayName());
        member[kMemberAudioStatus] = member_item->getAudioStatus();
        member[kMemberVideoStatus] = member_item->getVideoStatus();
        member[kMemberSharingStatus] = member_item->getScreenSharing();
        pagedMembers.push_back(member);
    }

    emit membersChanged(QJsonObject(), pagedMembers, m_currentPage, members.size());
}

void MembersManager::pagingGalleryView(quint32 pageSize, quint32 pageNumber) {
    std::vector<SharedUserPtr> members;
    GlobalManager::getInstance()->getInRoomService()->getUsersByRoleType(members);

    if (members.size() == 0)
        return;

    std::vector<SharedUserPtr> secondaryMembers;
    auto authInfo = AuthManager::getInstance()->getAuthInfo();
    for (auto& member : members) {
        secondaryMembers.push_back(member);
    }

    uint32_t pageCount =
        secondaryMembers.size() <= pageSize ? 1 : secondaryMembers.size() / pageSize + (secondaryMembers.size() % pageSize == 0 ? 0 : 1);
    m_currentPage = pageNumber > pageCount ? pageCount : pageNumber;
    m_pageSize = pageSize;

    QJsonArray pagedMembers;
    int begin = (m_currentPage - 1) * pageSize;
    int end = begin + pageSize > secondaryMembers.size() ? secondaryMembers.size() : begin + pageSize;
    YXLOG(Info) << "Get members from cache list: " << begin << " to " << end << ", current page: " << m_currentPage << ", page count: " << pageCount
                << ", page size: " << m_pageSize << YXLOGEnd;
    for (int i = begin; i < end; i++) {
        auto member_item = secondaryMembers[i];
        QJsonObject member;
        member[kMemberAccountId] = QString::fromStdString(member_item->getUserId());
        member[kMemberNickanme] = QString::fromStdString(member_item->getDisplayName());
        member[kMemberAudioStatus] = member_item->getAudioStatus();
        member[kMemberVideoStatus] = member_item->getVideoStatus();
        member[kMemberSharingStatus] = member_item->getScreenSharing();
        pagedMembers.push_back(member);
    }

    //    QJsonObject selfMember;
    //    auto& firstMember = members.front();
    //    selfMember[kMemberAccountId] = QString::fromStdString(firstMember->getAccountId());
    //    selfMember[kMemberAvRoomUid] = (qint64)firstMember->getAvRoomUid();
    //    selfMember[kMemberNickanme] = QString::fromStdString(firstMember->getNickname());
    //    selfMember[kMemberAudioStatus] = firstMember->getAudioStatus();
    //    selfMember[kMemberVideoStatus] = firstMember->getVideoStatus();
    //    selfMember[kMemberSharingStatus] = firstMember->getSharingStatus();
    //    pagedMembers.push_front(selfMember);

    YXLOG(Debug) << "-------------------------------------------------" << YXLOGEnd;
    for (int i = 0; i < pagedMembers.size(); i++) {
        const QJsonObject& member = pagedMembers.at(i).toObject();
        YXLOG(Debug) << "Gallery view members: " << i << ", member info: " << member[kMemberAccountId].toString().toStdString() << YXLOGEnd;
    }
    YXLOG(Debug) << "-------------------------------------------------" << YXLOGEnd;

    emit membersChanged(QJsonObject(), pagedMembers, m_currentPage, members.size());
}

void MembersManager::onBeforeUserJoinUI(const QString& accountId, int memberCount) {}

void MembersManager::onAfterUserJoinedUI(const QString& accountId, bool bNotify) {
    if (m_refreshTime.isActive())
        m_refreshTime.stop();
    m_refreshTime.start(500);
    QByteArray byteAccountId = accountId.toUtf8();
    QString strAccountid = AuthManager::getInstance()->authAccountId();
    QByteArray strid = strAccountid.toUtf8();
    auto member = GlobalManager::getInstance()->getInRoomService()->getUserInfoById(byteAccountId.data());
    if (member && accountId != strid.data() && bNotify)
        emit userJoinNotify(QString::fromStdString(member->getDisplayName()));
    emit countChanged();
}

void MembersManager::onBeforeUserLeaveUI(const QString& /*accountId*/, int /*memberIndex*/) {}

void MembersManager::onAfterUserLeftUI(const QString& accountId, bool bNotify) {
    if (m_refreshTime.isActive())
        m_refreshTime.stop();
    m_refreshTime.start(500);
    QString strAccountId = AuthManager::getInstance()->authAccountId();
    QByteArray byteAccountId = strAccountId.toUtf8();
    if (m_ptrLeaveUsr && byteAccountId.data() != accountId) {
        if (bNotify) {
            emit userLeftNotify(QString::fromStdString(m_ptrLeaveUsr->getDisplayName()));
        }
        m_ptrLeaveUsr = nullptr;
    }
    emit countChanged();
}

void MembersManager::onHostChangedUI(const QString& hostAccountId) {
    emit hostAccountIdChangedSignal(hostAccountId, m_hostAccountId);
    setHostAccountId(hostAccountId);
}

void MembersManager::handleAudioStatusChanged(const QString& accountId, int status) {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.accountId == accountId) {
                int statusTmp = item.audioStatus;
                item.audioStatus = status;
                m_items[i] = item;
                if ((1 == statusTmp && 1 != status) || (1 != statusTmp && 1 == status)) {
                    Q_EMIT dataChanged(i, MembersModel::kMemberRoleAudio);
                }
                break;
            }
        }
    }
}

void MembersManager::handleVideoStatusChanged(const QString& accountId, int status) {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.accountId == accountId) {
                int statusTmp = item.videoStatus;
                item.videoStatus = status;
                m_items[i] = item;
                if ((1 == statusTmp && 1 != status) || (1 != statusTmp && 1 == status)) {
                    Q_EMIT dataChanged(i, MembersModel::kMemberRoleVideo);
                }
                break;
            }
        }
    }
}

void MembersManager::handleHandsupStatusChanged(const QString& accountId, NEMeeting::HandsUpStatus status) {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.accountId == accountId) {
                int statusTmp = item.handsupStatus;
                item.handsupStatus = status;
                m_items[i] = item;
                if ((NEMeeting::HAND_STATUS_RAISE == statusTmp && NEMeeting::HAND_STATUS_RAISE != status) ||
                    (NEMeeting::HAND_STATUS_RAISE != statusTmp && NEMeeting::HAND_STATUS_RAISE == status)) {
                    Q_EMIT dataChanged(i, MembersModel::kMemberRoleHansUpStatus);
                }
                break;
            }
        }
    }
}

void MembersManager::handleMeetingStatusChanged(NEMeeting::Status status, int /*errorCode*/, const QString& /*errorMessage*/) {
    if (status == NEMeeting::MEETING_IDLE || status == NEMeeting::MEETING_ENDED || status == NEMeeting::MEETING_RECONNECT_FAILED ||
        status == NEMeeting::MEETING_CONNECT_FAILED || status == NEMeeting::MEETING_DISCONNECTED || status == NEMeeting::MEETING_KICKOUT_BY_HOST ||
        status == NEMeeting::MEETING_MULTI_SPOT_LOGIN)
        m_items.clear();
}

void MembersManager::handleWhiteboardDrawEnableChanged(const QString& sharedAccountId, bool enable) {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.accountId == sharedAccountId) {
                bool statusTmp = item.isWhiteboardEnable;
                item.isWhiteboardEnable = enable;
                m_items[i] = item;
                if (statusTmp != enable) {
                    Q_EMIT dataChanged(i, MembersModel::kMemberRoleWhiteboard);
                }
                break;
            }
        }
    }
}

void MembersManager::handleNicknameChanged(const QString& accountId, const QString& nickname) {
    emit nicknameChanged(accountId, nickname);
    for (int i = 0; i < m_items.size(); i++) {
        auto item = m_items.at(i);
        if (item.accountId == accountId) {
            QString statusTmp = item.nickname;
            item.nickname = nickname;
            m_items[i] = item;
            if (statusTmp != nickname) {
                Q_EMIT dataChanged(i, MembersModel::kMemberRoleNickname);
            }
            break;
        }
    }
}

void MembersManager::handleShareAccountIdChanged() {
    auto meetingInfo = MeetingManager::getInstance()->getMeetingInfo();
    if (nullptr == meetingInfo) {
        return;
    }

    if (nullptr == m_membersController) {
        return;
    }

    QString accountId = QString::fromStdString(meetingInfo->getScreenSharingUserId());
    bool sharing = !accountId.isEmpty();

    if (sharing) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.accountId == accountId) {
                item.sharing = true;
                m_items[i] = item;
                Q_EMIT dataChanged(i, MembersModel::kMemberRoleSharing);
                break;
            }
        }
    } else {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.sharing) {
                item.sharing = false;
                m_items[i] = item;
                Q_EMIT dataChanged(i, MembersModel::kMemberRoleSharing);
                break;
            }
        }
    }
}

uint32_t MembersManager::count() const {
    std::vector<SharedUserPtr> members;
    GlobalManager::getInstance()->getInRoomService()->getUsersByRoleType(members);
    return members.size();
}

void MembersManager::setCount(const uint32_t& count) {
    m_count = count;
}

int MembersManager::audioHandsUpCount() const {
    int iCount = 0;
    std::vector<SharedUserPtr> members;
    GlobalManager::getInstance()->getInRoomService()->getUsersByRoleType(members);
    for (auto member : members) {
        if (member->getRaiseHandDetail().status == kHandsUpRaise) {
            iCount++;
        }
    }
    return iCount;
}

void MembersManager::resetWhiteboardDrawEnable() {
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.isWhiteboardEnable) {
                item.isWhiteboardEnable = false;
                m_items[i] = item;
                Q_EMIT dataChanged(i, MembersModel::kMemberRoleWhiteboard);
            }
        }
    }
}

int MembersManager::galleryViewPageSize() const {
    return m_galleryViewPageSize;
}

void MembersManager::setGalleryViewPageSize(const int& galleryViewPageSize) {
    m_galleryViewPageSize = galleryViewPageSize;
    emit galleryViewPageSizeChanged();
}

void MembersManager::onNetworkQuality(const std::string& accountId, NENetWorkQuality up, NENetWorkQuality down) {
    // 只通知当前登录的用户网络状况
    if (AuthManager::getInstance()->authAccountId().toStdString() != accountId) {
        return;
    }

    emit netWorkQualityTypeChanged(netWorkQualityType(up, down));
}

QVector<MemberInfo> MembersManager::items() const {
    return m_items;
}

int MembersManager::netWorkQualityType() const {
    auto member = GlobalManager::getInstance()->getInRoomService()->getUserInfoById(AuthManager::getInstance()->authAccountId().toStdString());
    if (!member) {
        return (int)NEMeeting::NETWORKQUALITY_GOOD;
    }
    return (int)netWorkQualityType(member->getUpNetWorkQuality(), member->getDownNetWorkQuality());
}

NEMeeting::NetWorkQualityType MembersManager::netWorkQualityType(NENetWorkQuality upNetWorkQuality, NENetWorkQuality downNetWorkQuality) const {
    if ((kNetworkQualityVeryBad == upNetWorkQuality || kNetworkQualityDown == upNetWorkQuality) ||
        (kNetworkQualityVeryBad == downNetWorkQuality || kNetworkQualityDown == downNetWorkQuality)) {
        return NEMeeting::NETWORKQUALITY_BAD;
    } else if ((kNetworkQualityExcellent == upNetWorkQuality || kNetworkQualityGood == upNetWorkQuality) &&
               (kNetworkQualityExcellent == downNetWorkQuality || kNetworkQualityGood == downNetWorkQuality)) {
        return NEMeeting::NETWORKQUALITY_GOOD;
    } else {
        return NEMeeting::NETWORKQUALITY_GENERAL;
    }
}

QString MembersManager::hostAccountId() const {
    return m_hostAccountId;
}

void MembersManager::setHostAccountId(const QString& hostAccountId) {
    m_hostAccountId = hostAccountId;
    emit hostAccountIdChanged();
    auto anthInfo = AuthManager::getInstance()->getAuthInfo();
    if (anthInfo) {
        AuthManager::getInstance()->setIsHostAccount(anthInfo->getAccountId() == hostAccountId.toStdString());
    } else {
        AuthManager::getInstance()->setIsHostAccount(false);
    }

    //刷新成员列表排序
    if (m_membersController) {
        for (int i = 0; i < m_items.size(); i++) {
            auto item = m_items.at(i);
            if (item.accountId == m_hostAccountId) {
                Q_EMIT dataChanged(i, -1);
                break;
            }
        }
    }
}

bool MembersManager::isGalleryView() const {
    return m_isGalleryView;
}

void MembersManager::setIsGalleryView(bool isGellaryView) {
    m_isGalleryView = isGellaryView;
    if (isGellaryView) {
        auto globalConfig = GlobalManager::getInstance()->getGlobalConfig();
        auto galleryViewPageSize = globalConfig->getGalleryPageSize();
        setGalleryViewPageSize(galleryViewPageSize);
    }

    emit isGalleryViewChanged();
}

bool MembersManager::isWhiteboardView() const {
    return m_isWhiteboardView;
}

void MembersManager::setIsWhiteboardView(bool isWhiteboardView) {
    m_isWhiteboardView = isWhiteboardView;

    emit isWhiteboardViewChanged();
}
