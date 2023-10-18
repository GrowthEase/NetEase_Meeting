// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEMBERSMANAGER_H
#define MEMBERSMANAGER_H

#include <QObject>
#include "controller/user_controller.h"
#include "manager/auth_manager.h"
#include "manager/meeting/audio_manager.h"
#include "manager/meeting_manager.h"
#include "room_service_interface.h"

using namespace neroom;

#define kMemberAccountId "accountId"
#define kMemberNickname "nickname"
#define kMemberAudioStatus "audioStatus"
#define kMemberVideoStatus "videoStatus"
#define kMemberSharingStatus "sharingStatus"
#define kMemberClientType "clientType"
#define kMemberAudioHandsUpStatus "audioHandsUpStatus"
#define kMemberCreatedAt "createdAt"

/**
 * @brief 房间用户类型
 */
enum NERoleType { kRoleInvaild = 0, kRoleMember, kRoleHost, kRoleManager, kRoleHiding };

typedef struct _tagMemberInfo {
    QString accountId;
    QString nickname;
    QString tag;
    int audioStatus;
    int videoStatus;
    int audioVolume;
    bool sharing;
    bool isWhiteboardEnable;
    bool isWhiteboardShareOwner;
    bool isPhoneOpen = false;
    NEMeeting::HandsUpStatus handsupStatus = NEMeeting::HAND_STATUS_DOWN;
    int clientType;
    NERoleType roleType;
    NEMeeting::NetWorkQualityType netWorkQualityType = NEMeeting::NETWORKQUALITY_GOOD;
    qint64 createdAt;
} MemberInfo;

class MembersManager : public QObject {
    Q_OBJECT

private:
    explicit MembersManager(QObject* parent = nullptr);
    ~MembersManager();

public:
    enum ViewMode {
        /// @brief 自动模式
        VIEW_MODE_AUTO = -1,
        /// @brief 演讲者视图
        VIEW_MODE_FOCUS,
        /// @brief 演讲者视图，子列表包含自己
        VIEW_MODE_FOCUS_WITH_SELF,
        /// @brief 画廊视图
        VIEW_MODE_GALLERY,
        /// @brief 白板视图
        VIEW_MODE_WHITEBOARD
    };
    Q_ENUM(ViewMode)
    SINGLETONG(MembersManager)

    Q_PROPERTY(bool isGalleryView READ isGalleryView WRITE setIsGalleryView NOTIFY isGalleryViewChanged)
    Q_PROPERTY(bool isWhiteboardView READ isWhiteboardView WRITE setIsWhiteboardView NOTIFY isWhiteboardViewChanged)
    Q_PROPERTY(QString hostAccountId READ hostAccountId WRITE setHostAccountId NOTIFY hostAccountIdChanged)
    Q_PROPERTY(int galleryViewPageSize READ galleryViewPageSize WRITE setGalleryViewPageSize NOTIFY galleryViewPageSizeChanged)
    Q_PROPERTY(int netWorkQualityType READ netWorkQualityType NOTIFY netWorkQualityTypeChanged)
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(int handsUpCount READ handsUpCount NOTIFY handsUpCountChange)
    Q_PROPERTY(NEMeeting::HandsUpType handsUpType READ handsUpType WRITE setHandsUpType)
    Q_PROPERTY(bool handsUpStatus READ handsUpStatus WRITE setHandsUpStatus)
    Q_PROPERTY(bool isManagerRole READ isManagerRole WRITE setIsManagerRole NOTIFY isManagerRoleChanged)
    Q_PROPERTY(bool includeSelf READ includeSelf WRITE setIncludeSelf NOTIFY includeSelfChanged)
    Q_PROPERTY(ViewMode viewMode READ viewMode NOTIFY viewModeChanged)

    Q_INVOKABLE QString getNicknameByAccountId(const QString& accountId);
    Q_INVOKABLE bool getMyHandsupStatus();
    Q_INVOKABLE bool isManagerRoleEx(const QString& accountId);

    void initMemberList(const SharedMemberPtr& localMember, const std::list<SharedMemberPtr>& remoteMemberList);
    void resetManagerList();
    void onUserJoined(const SharedMemberPtr& member, bool bNotify = true);
    void onUserLeft(const SharedMemberPtr& member);
    void onHostChanged(const std::string& hostAccountId);
    void onManagerChanged(const std::string& managerAccountId, bool bAdd);
    void onMemberNicknameChanged(const std::string& accountId, const std::string& nickname);
    void onNetworkQuality(const std::string& accountId, NERoomRtcNetWorkQuality up, NERoomRtcNetWorkQuality down);
    void onHandsUpStatusChanged(const std::string& accountId, NEMeeting::HandsUpStatus handsUpStatus);
    void onPhoneStatusChanged(const std::string& accountId, bool open);
    void onRoleChanged(const std::string& accountId, const std::string& beforeRole, const std::string& afterRole);

    std::shared_ptr<NEMeetingUserController> getUserController();

    QVector<MemberInfo> items() const;
    bool getPrimaryMember(MemberInfo& memberInfo);
    bool getMemberByAccountId(const QString& accountId, MemberInfo& memberInfo);
    QVector<MemberInfo> getMembersByRoleType(const QVector<NERoleType>& roleType = QVector<NERoleType>{kRoleMember, kRoleHost, kRoleManager});

    bool isGalleryView() const;
    void setIsGalleryView(bool isGalleryView);

    bool isWhiteboardView() const;
    void setIsWhiteboardView(bool isWhiteboardView);

    QString hostAccountId() const;
    void setHostAccountId(const QString& hostAccountId);

    int galleryViewPageSize() const;
    void setGalleryViewPageSize(const int& galleryViewPageSize);

    NEMeeting::HandsUpType handsUpType() const;
    void setHandsUpType(NEMeeting::HandsUpType type);

    int netWorkQualityType() const;

    uint32_t count() const;
    void setCount(const uint32_t& count);

    bool handsUpStatus() const;
    void setHandsUpStatus(bool handsUp);

    int handsUpCount() const;
    void setHandsUpCount(int count);

    void resetWhiteboardDrawEnable();
    void updateWhiteboardOwner(const QString& whiteboardOwner, bool isSharing);

    void updateMembersPaging();

    static NERoleType getRoleType(const std::string& strRoleType);

    bool isManagerRole();
    void setIsManagerRole(bool isManagerRole);

    bool isOpenRemoteVideo() const;

    bool includeSelf() const;
    void setIncludeSelf(bool includeSelf);

    ViewMode viewMode() const { return m_lastViewMode; }
    void setViewMode(ViewMode viewMode);

public slots:
    void getMembersPaging(quint32 pageSize, quint32 pageNumber, ViewMode viewMode);
    void getMembersPaging(quint32 pageSize, quint32 pageNumber);
    void getGalleryViewPaging(quint32 pageSize, quint32 pageNumber);
    void setAsHost(const QString& accountId);
    void setAsManager(const QString& accountId, const QString& nickname);
    void setAsMember(const QString& accountId, const QString& nickname);
    void setAsFocus(const QString& accountId, bool set);
    void kickMember(const QString& accountId);
    bool getPhoneStatus(const QString& accountId);

private:
    void pagingFocusView(quint32 pageSize, quint32 pageNumber);
    void pagingSharingView(quint32 pageSize, quint32 pageNumber);
    void pagingWhiteboardView(quint32 pageSize, quint32 pageNumber);
    void pagingGalleryView(quint32 pageSize, quint32 pageNumber);
    QJsonObject memberToJsonObject(const MemberInfo& member) const;
    void convertPropertiesToMember(const std::map<std::string, std::string>& properties, MemberInfo& info);
    // getUsersByRoleType
    NEMeeting::NetWorkQualityType netWorkQualityType(NERoomRtcNetWorkQuality up, NERoomRtcNetWorkQuality down) const;

signals:
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void dataChanged(int index, int role);

    void afterUserJoined(const QString& accountId, const QString& nickname, bool bNotify = true);
    void afterUserLeft(const QString& accountId, const QString& nickname);
    void userJoinNotify(const QString& nickname);
    void userLeftNotify(const QString& nickname);
    void membersChanged(const QJsonObject& primaryMember, const QJsonArray& secondaryMembers, quint32 realPage, quint32 realCount, ViewMode viewMode);
    void netWorkQualityTypeChanged(int netWorkQualityType);
    void nicknameChanged(const QString& accountId, const QString& nickname);
    // binding values
    void isGalleryViewChanged();
    void isWhiteboardViewChanged();
    void hostAccountIdChanged();
    void galleryViewPageSizeChanged();
    void hostAccountIdChangedSignal(const QString& hostAccountId, const QString& oldhostAccountId);
    void managerAccountIdChanged(const QString& managerAccountId, bool bAdd);
    void countChanged();
    void handsupStatusChanged(const QString& accountId, NEMeeting::HandsUpStatus status);
    void phoneStatusChanged(const QString& accountId, bool open);
    void handsUpCountChange();
    void userReJoined(const QString& accountId);
    void isManagerRoleChanged();
    void managerUpdateSuccess(const QString& nickname, bool set);
    void includeSelfChanged();
    void viewModeChanged();

public slots:
    void onAfterUserJoinedUI(const QString& accountId, const QString& nickname, bool bNotify = true);
    void onAfterUserLeftUI(const QString& accountId, const QString& nickname);
    void onHostChangedUI(const QString& hostAccountId);
    void handleAudioStatusChanged(const QString& accountId, int status);
    void handleVideoStatusChanged(const QString& accountId, int status);
    void handleHandsupStatusChanged(const QString& accountId, NEMeeting::HandsUpStatus status);
    void handleMeetingStatusChanged(NEMeeting::Status status, int errorCode, const QString& errorMessage);
    void handleWhiteboardDrawEnableChanged(const QString& sharedAccountId, bool enable);
    void handleNicknameChanged(const QString& accountId, const QString& nickname);
    void handleShareAccountIdChanged();
    void handleAudioVolumeIndication(const QString& accountId, int volume);
    void handleRoleChanged(const QString& accountId, NERoleType roleType);
    void allowRemoteMemberHandsUp(const QString& accountId, bool bAllowHandsUp);
    void handsUp(bool bHandsUp);
    void muteRemoteVideoAndAudio(const QString& accountId, bool mute);
    void onHandsUpStatusChangedUI(const QString& accountId, NEMeeting::HandsUpStatus status);
    void onPhoneStatusChangedUI(const QString& accountId, bool open);
    void onRoleChangedUI(const QString& accountId, const QString& strRoleType);

private:
    std::shared_ptr<NEMeetingUserController> m_membersController = nullptr;
    uint32_t m_pageSize = 4;
    uint32_t m_currentPage = 1;
    int m_galleryViewPageSize = 16;
    bool m_isGalleryView = false;
    bool m_isWhiteboardView = false;
    QString m_hostAccountId;
    bool m_isManagerRole = false;
    QVector<QString> m_managerList;
    QTimer m_refreshTime;
    uint32_t m_count = 0;
    int m_nHandsUpCount = 0;
    Invoker m_invoker;
    // 上层用来维护成员列表的数据结构，尽量保证不直接调用 Native SDK 接口导致冲突
    QVector<MemberInfo> m_items;
    NEMeeting::HandsUpType m_handsUpType = NEMeeting::HAND_TYPE_DEFAULT;  // 本地举手类型
    bool m_bHandsUp = false;
    // 拉取成员信息时是否包含自己
    bool m_bIncludeSelf = false;
    QList<QString> m_openRemoteVideoitems;
    ViewMode m_lastViewMode = VIEW_MODE_FOCUS;
};

Q_DECLARE_METATYPE(NEMeeting::HandsUpStatus)

#endif  // MEMBERSMANAGER_H
