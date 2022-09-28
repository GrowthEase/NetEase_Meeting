// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEMEETINGMANAGER_H
#define NEMEETINGMANAGER_H

#include <QDebug>
#include <QJsonArray>
#include <QObject>
#include "nemeeting_sdk_interface_include.h"

USING_NS_NNEM_SDK_INTERFACE

class MeetingsStatus : public QObject {
    Q_GADGET
public:
    explicit MeetingsStatus() {}
    enum Status {
        ERROR_CODE_SUCCESS = 0,
        ERROR_CODE_FAILED = -1,
        MEETING_ERROR_FAILED_IM_LOGIN_ERROR = -2,
        MEETING_ERROR_NO_NETWORK = -3,
        MEETING_ERROR_FAILED_MEETING_ALREADY_EXIST = -4,
        MEETING_ERROR_FAILED_PARAM_ERROR = -5,
        MEETING_ERROR_ALREADY_INMEETING = -6,
        MEETING_ERROR_FAILED_LOGIN_ON_OTHER_DEVICE = -7,
        MEETING_ERROR_LOCKED_BY_HOST = -8,
        MEETING_ERROR_INVALID_ID = -9,
        MEETING_ERROR_LIMITED = -10
    };
    Q_ENUM(Status)
};

class RunningStatus : public QObject {
    Q_GADGET
public:
    explicit RunningStatus() {}
    enum Status {
        MEETING_STATUS_FAILED = MEETING_STATUS_FAILED,
        MEETING_STATUS_IDLE,
        MEETING_STATUS_WAITING,
        MEETING_STATUS_CONNECTING,
        MEETING_STATUS_INMEETING,
        MEETING_STATUS_DISCONNECTING,
    };
    Q_ENUM(Status)
    enum ExtStatus {
        MEETING_DISCONNECTING_BY_SELF = 0,
        MEETING_DISCONNECTING_REMOVED_BY_HOST = 1,
        MEETING_DISCONNECTING_CLOSED_BY_HOST = 2,
        MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE = 3,
        MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST = 4,
        MEETING_DISCONNECTING_AUTH_INFO_EXPIRED = 5,
        MEETING_DISCONNECTING_BY_SERVER = 6,
        MEETING_DISCONNECTING_BY_ROOMNOTEXIST = 7,
        MEETING_DISCONNECTING_BY_SYNCDATAERROR = 8,
        MEETING_DISCONNECTING_BY_RTCINITERROR = 9,
        MEETING_DISCONNECTING_BY_JOINCHANNELERROR = 10,
        MEETING_DISCONNECTING_BY_TIMEOUT = 11,
        MEETING_WAITING_VERIFY_PASSWORD = 20
    };
    Q_ENUM(ExtStatus)
};

class NEMeetingManager : public QObject,
                         public NEMeetingStatusListener,
                         public NEMeetingOnInjectedMenuItemClickListener,
                         public NEScheduleMeetingStatusListener,
                         public NESettingsChangeNotifyHandler,
                         public NEAuthListener {
    Q_OBJECT
public:
    explicit NEMeetingManager(QObject* parent = nullptr);

    Q_PROPERTY(QString personalMeetingId READ personalMeetingId WRITE setPersonalMeetingId NOTIFY personalMeetingIdChanged)
    Q_PROPERTY(bool isSupportRecord READ isSupportRecord WRITE setIsSupportRecord NOTIFY isSupportRecordChanged)
    Q_PROPERTY(bool isSupportLive READ isSupportLive WRITE setIsSupportLive NOTIFY isSupportLiveChanged)
    Q_PROPERTY(bool isAudioAINS READ isAudioAINS WRITE setIsAudioAINS NOTIFY isAudioAINSChanged)
    Q_PROPERTY(bool audodeviceAutoSelectType READ audodeviceAutoSelectType WRITE setAudodeviceAutoSelectType NOTIFY audodeviceAutoSelectTypeChanged)
    Q_PROPERTY(bool softwareRender READ softwareRender WRITE setSoftwareRender NOTIFY softwareRenderChanged)
    Q_PROPERTY(bool virtualBackground READ virtualBackground WRITE setVirtualBackground NOTIFY virtualBackgroundChanged)
    Q_PROPERTY(bool beauty READ beauty WRITE setBeauty NOTIFY beautyChanged)
    Q_PROPERTY(int beautyValue READ beautyValue WRITE setBeautyValue NOTIFY beautyValueChanged)

    Q_INVOKABLE void initializeParam(const QString& strSdkLogPath, int sdkLogLevel, bool bRunAdmin, bool bPrivate);
    Q_INVOKABLE void initialize(const QString& strAppkey, int keepAliveInterval);
    Q_INVOKABLE void unInitialize();
    Q_INVOKABLE bool isInitializd();
    Q_INVOKABLE void login(const QString& appKey, const QString& accountId, const QString& accountToken, int keepAliveInterval);
    Q_INVOKABLE void loginByUsernamePassword(const QString& appKey, const QString& userName, const QString& password, int keepAliveInterval);
    Q_INVOKABLE void getAccountInfo();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void showSettings();

    Q_INVOKABLE void scheduleMeeting(const QString& meetingSubject,
                                     qint64 startTime,
                                     qint64 endTime,
                                     const QString& password,
                                     const QString& textScene,
                                     bool attendeeAudioOff,
                                     bool enableLive = false,
                                     bool enableSip = false,
                                     bool needLiveAuthentication = false,
                                     bool enableRecord = false,
                                     const QString& extraData = "",
                                     const QJsonArray& controls = QJsonArray(),
                                     const QString& strRoleBinds = "");
    Q_INVOKABLE void cancelMeeting(const qint64& meetingUniqueId);
    Q_INVOKABLE void editMeeting(const qint64& meetingUniqueId,
                                 const QString& meetingId,
                                 const QString& meetingSubject,
                                 qint64 startTime,
                                 qint64 endTime,
                                 const QString& password,
                                 const QString& textScene,
                                 bool attendeeAudioOff,
                                 bool enableLive = false,
                                 bool enableSip = false,
                                 bool needLiveAuthentication = false,
                                 bool enableRecord = false,
                                 const QString& extraData = "",
                                 const QJsonArray& controls = QJsonArray(),
                                 const QString& strRoleBinds = "");
    Q_INVOKABLE void getMeetingList();

    Q_INVOKABLE void invokeStart(const QJsonObject& object);
    Q_INVOKABLE void invokeJoin(const QJsonObject& object);

    Q_INVOKABLE void leaveMeeting(bool finish);
    Q_INVOKABLE int getMeetingStatus();
    Q_INVOKABLE void getMeetingInfo();
    Q_INVOKABLE void getHistoryMeetingItem();

    Q_INVOKABLE void subcribeAudio(const QString& accoundIdList, bool subcribe, int type);

    Q_INVOKABLE void getIsSupportLive();
    Q_INVOKABLE void getIsSupportRecord();

    Q_INVOKABLE void getVirtualBackgroundList();
    Q_INVOKABLE void setVirtualBackgroundList(const QString& vbList);

    Q_INVOKABLE void getPersonalMeetingId();

    // override virtual functions
    virtual void onMeetingStatusChanged(int status, int code) override;
    virtual void onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) override;
    virtual void onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) override;
    virtual void onInjectedMenuItemClickEx(const NEMeetingMenuItem& meeting_menu_item, const NEInjectedMenuItemClickCallback& cb) override;
    // properties
    QString personalMeetingId() const;
    void setPersonalMeetingId(const QString& personalMeetingId);

    virtual void OnAudioSettingsChange(bool status) override;
    virtual void OnVideoSettingsChange(bool status) override;
    virtual void OnOtherSettingsChange(bool status) override;
    virtual void OnAudioAINSSettingsChange(bool status) override;
    virtual void OnAudioVolumeAutoAdjustSettingsChange(bool status) override;
    virtual void OnAudioQualitySettingsChange(AudioQuality enumAudioQuality) override;
    virtual void OnAudioEchoCancellationSettingsChange(bool status) override;
    virtual void OnAudioEnableStereoSettingsChange(bool status) override;
    virtual void OnRemoteVideoResolutionSettingsChange(RemoteVideoResolution enumRemoteVideoResolution) override;
    virtual void OnMyVideoResolutionSettingsChange(LocalVideoResolution enumLocalVideoResolution) override;
    virtual void onKickOut() override;
    virtual void onAuthInfoExpired() override{};

    bool isSupportRecord() const;
    void setIsSupportRecord(bool isSupportRecord);

    bool isSupportLive() const;
    void setIsSupportLive(bool isSupportLive);

    bool isAudioAINS() const;
    void setIsAudioAINS(bool isAudioAINS);

    bool audodeviceAutoSelectType() const { return m_audodeviceAutoSelectType; }

    bool softwareRender() const { return m_softwareRender; }

    bool virtualBackground() const { return m_virtualBackground; }
    void setVirtualBackground(bool virtualBackground);

    bool beauty() const { return m_beauty; }

    int beautyValue() const { return m_beautyValue; }

private:
    void pushSubmenus(std::vector<NEMeetingMenuItem>& items_list, int MenuIdIndex);

signals:
    void error(int errorCode, const QString& errorMessage);
    void initializeSignal(int errorCode, const QString& errorMessage);
    void unInitializeSignal(int errorCode, const QString& errorMessage);
    void loginSignal(int errorCode, const QString& errorMessage);
    void logoutSignal(int errorCode, const QString& errorMessage);
    void showSettingsSignal(int errorCode, const QString& errorMessage);
    void startSignal(int errorCode, const QString& errorMessage);
    void joinSignal(int errorCode, const QString& errorMessage);
    void leaveSignal(int errorCode, const QString& errorMessage);
    void finishSignal(int errorCode, const QString& errorMessage);
    void getCurrentMeetingInfo(const QJsonObject& meetingBaseInfo, const QJsonArray& meetingUserList);
    void getHistoryMeetingInfo(qint64 meetingUniqueId,
                               const QString& meetingId,
                               const QString& shortMeetingId,
                               const QString& subject,
                               const QString& password,
                               const QString& nickname,
                               const QString& sipId);
    void meetingStatusChanged(int meetingStatus, int extCode);
    void meetingInjectedMenuItemClicked(int itemIndex, const QString& itemGuid, const QString& itemTitle, const QString& itemImagePath);
    void personalMeetingIdChanged();
    void scheduleSignal(int errorCode, const QString& errorMessage);
    void cancelSignal(int errorCode, const QString& errorMessage);
    void editSignal(int errorCode, const QString& errorMessage);
    void getScheduledMeetingList(int errorCode, const QJsonArray& meetingList);
    void deviceStatusChanged(int type, bool status);
    void isSupportRecordChanged();
    void isSupportLiveChanged();
    void isAudioAINSChanged();

    void audodeviceAutoSelectTypeChanged(bool audodeviceAutoSelectType);
    void softwareRenderChanged(bool softwareRender);
    void virtualBackgroundChanged(bool virtualBackground);
    void virtualBackgroundList(const QString& vbList);
    void getPersonalMeetingIdChanged(const QString& message);

    void beautyChanged(bool beauty);

    void beautyValueChanged(int beautyValue);

public slots:
    void onGetMeetingListUI();

    bool checkAudio();
    void setCheckAudio(bool checkAudio);

    bool checkVideo();
    void setCheckVideo(bool checkVideo);

    // bool checkDuration();
    // void setCheckDuration(bool checkDuration);

    void setAudodeviceAutoSelectType(bool audodeviceAutoSelectType);
    void setSoftwareRender(bool softwareRender);

    void setBeauty(bool beauty);
    void setBeautyValue(int beautyValue);

private:
    std::atomic_bool m_initialized;
    std::atomic_bool m_initSuc;
    QString m_personalMeetingId;
    bool m_bSupportRecord = false;
    bool m_bSupportLive = false;
    bool m_bAudioAINS = false;
    QString m_strSdkLogPath;
    int m_sdkLogLevel = NEINFO;
    bool m_bRunAdmin = true;
    bool m_bPrivate = false;
    bool m_audodeviceAutoSelectType = true;
    bool m_softwareRender = false;
    bool m_virtualBackground = true;
    bool m_beauty = false;
    int m_beautyValue = 0;
};

#endif  // NEMEETINGMANAGER_H
