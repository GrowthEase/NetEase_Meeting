/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef MEMBERSMANAGER_H
#define MEMBERSMANAGER_H

#include <QObject>
#include "controller/user_ctrl_interface.h"
#include "manager/auth_manager.h"
#include "manager/meeting/audio_manager.h"
#include "manager/meeting_manager.h"
#include "room_service_interface.h"

using namespace neroom;

#define kMemberAccountId "accountId"
#define kMemberNickanme "nickname"
#define kMemberAudioStatus "audioStatus"
#define kMemberVideoStatus "videoStatus"
#define kMemberSharingStatus "sharingStatus"
#define kMemberClientType "clientType"
#define kMemberAudioHandsUpStatus "audioHandsUpStatus"

typedef struct _tagMemberInfo {
    QString accountId;
    QString nickname;
    int audioStatus;
    int videoStatus;
    bool sharing;
    bool isWhiteboardEnable;
    bool isWhiteboardShareOwner;
    NEMeeting::HandsUpStatus handsupStatus;
    int clientType;
} MemberInfo;

class MembersManager : public QObject {
    Q_OBJECT

private:
    explicit MembersManager(QObject* parent = nullptr);
    ~MembersManager();

public:
    SINGLETONG(MembersManager)

    Q_PROPERTY(bool isGalleryView READ isGalleryView WRITE setIsGalleryView NOTIFY isGalleryViewChanged)
    Q_PROPERTY(bool isWhiteboardView READ isWhiteboardView WRITE setIsWhiteboardView NOTIFY isWhiteboardViewChanged)
    Q_PROPERTY(QString hostAccountId READ hostAccountId WRITE setHostAccountId NOTIFY hostAccountIdChanged)
    Q_PROPERTY(int galleryViewPageSize READ galleryViewPageSize WRITE setGalleryViewPageSize NOTIFY galleryViewPageSizeChanged)
    Q_PROPERTY(int netWorkQualityType READ netWorkQualityType NOTIFY netWorkQualityTypeChanged)
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(int audioHandsUpCount READ audioHandsUpCount)

    Q_INVOKABLE QString getNicknameByAccountId(const QString& accountId);

    void onBeforeUserJoin(const std::string& accountId, uint32_t memberCount);
    void onAfterUserJoined(const std::string& accountId, bool bNotify);
    void onBeforeUserLeave(const std::string& accountId, uint32_t memberIndex);
    void onAfterUserLeft(const std::string& accountId, bool bNotify);
    void onHostChanged(const std::string& hostAccountId);
    void onMemberNicknameChanged(const std::string& accountId, const std::string& nickname);
    void onNetworkQuality(const std::string& accountId, NENetWorkQuality up, NENetWorkQuality down);

    QVector<MemberInfo> items() const;
    SharedUserPtr getPrimaryMember();
    SharedUserPtr getMemberByAccountId(const QString& accountId);

    bool isGalleryView() const;
    void setIsGalleryView(bool isGalleryView);

    bool isWhiteboardView() const;
    void setIsWhiteboardView(bool isWhiteboardView);

    QString hostAccountId() const;
    void setHostAccountId(const QString& hostAccountId);

    int galleryViewPageSize() const;
    void setGalleryViewPageSize(const int& galleryViewPageSize);

    int netWorkQualityType() const;

    uint32_t count() const;
    void setCount(const uint32_t& count);

    int audioHandsUpCount() const;

    void resetWhiteboardDrawEnable();

public slots:
    void getMembersPaging(quint32 pageSize, quint32 pageNumber);
    void setAsHost(const QString& accountId);
    void setAsFocus(const QString& accountId, bool set);
    void kickMember(const QString& accountId);

private:
    void pagingFocusView(quint32 pageSize, quint32 pageNumber);
    void pagingWhiteboardView(quint32 pageSize, quint32 pageNumber);
    void pagingGalleryView(quint32 pageSize, quint32 pageNumber);
    NEMeeting::NetWorkQualityType netWorkQualityType(NENetWorkQuality up, NENetWorkQuality down) const;

signals:
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void dataChanged(int index, int role);

    void beforeUserJoin(const QString& accountId, int memberCount);
    void afterUserJoined(const QString& accountId, bool bNotify);
    void beforeUserLeave(const QString& accountId, int memberIndex);
    void afterUserLeft(const QString& accountId, bool bNotify);
    void userJoinNotify(const QString& nickname);
    void userLeftNotify(const QString& nickname);
    void membersChanged(const QJsonObject& primaryMember, const QJsonArray& secondaryMembers, quint32 realPage, quint32 realCount);
    void netWorkQualityTypeChanged(int netWorkQualityType);
    void nicknameChanged(const QString& accountId, const QString& nickname);
    // binding values
    void isGalleryViewChanged();
    void isWhiteboardViewChanged();
    void hostAccountIdChanged();
    void galleryViewPageSizeChanged();
    void hostAccountIdChangedSignal(const QString& hostAccountId, const QString& oldhostAccountId);
    void countChanged();
public slots:
    void onBeforeUserJoinUI(const QString& accountId, int memberCount);
    void onAfterUserJoinedUI(const QString& accountId, bool bNotify);
    void onBeforeUserLeaveUI(const QString& accountId, int memberIndex);
    void onAfterUserLeftUI(const QString& accountId, bool bNotify);
    void onHostChangedUI(const QString& hostAccountId);
    void handleAudioStatusChanged(const QString& accountId, int status);
    void handleVideoStatusChanged(const QString& accountId, int status);
    void handleHandsupStatusChanged(const QString& accountId, NEMeeting::HandsUpStatus status);
    void handleMeetingStatusChanged(NEMeeting::Status status, int errorCode, const QString& errorMessage);
    void handleWhiteboardDrawEnableChanged(const QString& sharedAccountId, bool enable);
    void handleNicknameChanged(const QString& accountId, const QString& nickname);
    void handleShareAccountIdChanged();

private:
    INERoomUserController* m_membersController = nullptr;
    uint32_t m_pageSize = 4;
    uint32_t m_currentPage = 1;
    int m_galleryViewPageSize = 16;
    bool m_isGalleryView = false;
    bool m_isWhiteboardView = false;
    QString m_hostAccountId;
    QTimer m_refreshTime;
    SharedUserPtr m_ptrLeaveUsr = nullptr;
    uint32_t m_count = 0;
    int m_nAudioHandsUpCount = 0;
    Invoker m_invoker;
    // 上层用来维护成员列表的数据结构，尽量保证不直接调用 Native SDK 接口导致冲突
    QVector<MemberInfo> m_items;
};

#endif  // MEMBERSMANAGER_H
