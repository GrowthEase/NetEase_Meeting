/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEMEETINGSDKMANAGER_H
#define NEMEETINGSDKMANAGER_H

#include <QJsonArray>
#include <QJsonObject>
#include <QObject>

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
        MEETING_STATUS_FAILED,
        MEETING_STATUS_IDLE,
        MEETING_STATUS_WAITING,
        MEETING_STATUS_CONNECTING,
        MEETING_STATUS_INMEETING,
        MEETING_STATUS_DISCONNECTING,
    };
    Q_ENUM(Status)
    enum ExtStatus {
        MEETING_DISCONNECTING_BY_SELF = 0,
        MEETING_DISCONNECTING_REMOVED_BY_HOST,
        MEETING_DISCONNECTING_CLOSED_BY_HOST,
        MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE,
        MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST,
        MEETING_DISCONNECTING_AUTH_INFO_EXPIRED,
        MEETING_DISCONNECTING_BY_SERVER,
        MEETING_WAITING_VERIFY_PASSWORD = 20,
    };
    Q_ENUM(ExtStatus)
};

class SettingsEventHandler : public QObject, public NESettingsChangeNotifyHandler {
    Q_OBJECT
public:
    SettingsEventHandler(QObject* parent = nullptr)
        : QObject(parent) {}
    ~SettingsEventHandler() {}

    virtual void OnAudioSettingsChange(bool status) override;
    virtual void OnVideoSettingsChange(bool status) override;
    virtual void OnOtherSettingsChange(bool status) override;

signals:
    void audioSettingsChanged(bool status);
    void videoSettingsChanged(bool status);
};

class NEMeetingSDKManager : public QObject,
                            public NEAuthListener,
                            public NEMeetingStatusListener,
                            public NEScheduleMeetingStatusListener,
                            public NEMeetingOnInjectedMenuItemClickListener {
    Q_OBJECT
public:
    enum LoginType { kLoginTypeDefault, kLoginTypeSSO };
    Q_ENUM(LoginType)

    explicit NEMeetingSDKManager(QObject* parent = nullptr);
    ~NEMeetingSDKManager();

    using InitCallback = std::function<void(NEErrorCode, const QString&)>;
    using UnInitCallback = InitCallback;

    Q_PROPERTY(QString neAppKey READ neAppKey WRITE setNEAppKey NOTIFY neAppKeyChanged)
    Q_PROPERTY(QString neAccountId READ neAccountId WRITE setNEAccountId NOTIFY neAccountIdChanged)
    Q_PROPERTY(QString neAccountToken READ neAccountToken WRITE setNEAccountToken NOTIFY neAccountTokenChanged)
    Q_PROPERTY(QString personalMeetingId READ personalMeetingId WRITE setPersonalMeetingId NOTIFY personalMeetingIdChanged)
    Q_PROPERTY(QString prettyMeetingId READ prettyMeetingId WRITE setPrettyMeetingId NOTIFY prettyMeetingIdChanged)
    Q_PROPERTY(QString personalShortMeetingId READ personalShortMeetingId WRITE setPersonalShortMeetingId NOTIFY personalShortMeetingIdChanged)
    Q_PROPERTY(QString displayName READ displayName WRITE setDisplayName NOTIFY displayNameChanged)
    Q_PROPERTY(int neLoginType READ neLoginType WRITE setNELoginType NOTIFY neLoginTypeChanged)
    Q_PROPERTY(QString neUsername READ neUsername WRITE setNEUsername NOTIFY neUsernameChanged)
    Q_PROPERTY(bool isSupportRecord READ isSupportRecord WRITE setIsSupportRecord NOTIFY isSupportRecordChanged)

    Q_INVOKABLE void initialize(const QString& appKey, const InitCallback& callback = nullptr);
    Q_INVOKABLE void unInitialize(const UnInitCallback& callback = nullptr);
    Q_INVOKABLE bool unInitializeSync();
    Q_INVOKABLE void activeWindow();
    Q_INVOKABLE void loginByPassword(const QString& appKey, const QString& username, const QString& password);
    Q_INVOKABLE void loginBySSOToken(const QString& appKey, const QString& ssoToken);
    Q_INVOKABLE void tryAutoLogin();
    Q_INVOKABLE void login(const QString& appKey, const QString& accountId, const QString& accountToken, LoginType loginType = kLoginTypeDefault);
    Q_INVOKABLE void logout(bool cleanup = false);
    Q_INVOKABLE void showSettings();
    Q_INVOKABLE void invokeStart(const QString& meetingId, const QString& nickname, bool audio, bool video, bool enableRecord);
    Q_INVOKABLE void invokeJoin(const QString& meetingId, const QString& nickname, bool audio, bool video, bool anonJoinMode = false);
    Q_INVOKABLE void getAccountInfo();
    Q_INVOKABLE void scheduleMeeting(const QString& meetingSubject,
                                     qint64 startTime,
                                     qint64 endTime,
                                     const QString& password,
                                     bool attendeeAudioOff,
                                     bool enableLive,
                                     bool needLiveAuthentication = false,
                                     bool enableRecord = false);
    Q_INVOKABLE void editMeeting(const qint64& meetingUniqueId,
                                 const QString& meetingId,
                                 const QString& meetingSubject,
                                 qint64 startTime,
                                 qint64 endTime,
                                 const QString& password,
                                 bool attendeeAudioOff,
                                 bool enableLive,
                                 bool needLiveAuthentication = false,
                                 bool enableRecord = false);
    Q_INVOKABLE void cancelMeeting(const qint64& meetingUniqueId);
    Q_INVOKABLE void getMeetingList();
    Q_INVOKABLE void loginBySwitchAppInfo();
    Q_INVOKABLE bool getIsSupportLive();
    Q_INVOKABLE void getIsSupportRecord();

    QString personalMeetingId() const;
    void setPersonalMeetingId(const QString& personalMeetingId);

    QString prettyMeetingId() const;
    void setPrettyMeetingId(const QString& prettyMeetingId);

    QString personalShortMeetingId() const;
    void setPersonalShortMeetingId(const QString& shortMeetingId);

    QString displayName() const;
    void setDisplayName(const QString& displayName);

    QString neAppKey() const;
    void setNEAppKey(const QString& NEAppKey);

    QString neAccountId() const;
    void setNEAccountId(const QString& NEAccountId);

    QString neAccountToken() const;
    void setNEAccountToken(const QString& NEAccountToken);

    int neLoginType() const;
    void setNELoginType(const int& neLoginType);

    QString neUsername() const;
    void setNEUsername(const QString& NEUsername);

    bool isSupportRecord() const;
    void setIsSupportRecord(bool isSupportRecord);

    virtual void onKickOut() override{};
    virtual void onAuthInfoExpired() override;
    virtual void onMeetingStatusChanged(int status, int code) override;
    virtual void onScheduleMeetingStatusChanged(uint64_t uniqueMeetingId, const int& meetingStatus) override;
    virtual void onInjectedMenuItemClick(const NEMeetingMenuItem& meeting_menu_item) override;
    virtual void onInjectedMenuItemClickEx(const NEMeetingMenuItem& meeting_menu_item, const NEInjectedMenuItemClickCallback& cb) override;

signals:
    void error(int errorCode, const QString& errorMessage);
    void initializeSignal(int errorCode, const QString& errorMessage);
    void unInitializeSignal(int errorCode, const QString& errorMessage);
    void tryAutoLoginSignal(int errorCode, const QString& errorMessage);
    void loginSignal(int errorCode, const QString& errorMessage);
    void logoutSignal(int errorCode, const QString& errorMessage);
    void authInfoExpired();
    void showSettingsSignal(int errorCode, const QString& errorMessage);
    void startSignal(int errorCode, const QString& errorMessage);
    void joinSignal(int errorCode, const QString& errorMessage);
    void meetingStatusChanged(int meetingStatus, int extCode);
    void scheduleSignal(int errorCode, const QString& errorMessage);
    void editSignal(int errorCode, const QString& errorMessage);
    void cancelSignal(int errorCode, const QString& errorMessage);
    void getScheduledMeetingList(int errorCode, const QJsonArray& meetingList);
    void gotAccountInfo();
    void feedback();

signals:
    void neAppKeyChanged();
    void neAccountIdChanged();
    void neAccountTokenChanged();
    void neLoginTypeChanged();
    void personalMeetingIdChanged();
    void prettyMeetingIdChanged();
    void personalShortMeetingIdChanged();
    void displayNameChanged();
    void neUsernameChanged();
    void audioSettingsChangedNotify(const QJsonObject& audioSettings);
    void videoSettingsChangedNotify(const QJsonObject& videoSettings);
    void isSupportRecordChanged();

public slots:
    void onDockClicked();
    void onGetMeetingListUI();

private:
    void onException(const NEException& exception);
    void onSettingsChangedNotify();

private:
    QString m_switchAppKey;
    QString m_switchAccountId;
    QString m_switchAccountToken;
    /* ------------------------------------------- */

    QString m_NEUsername;
    QString m_NEAppKey;
    QString m_NEAccountId;
    QString m_NEAccountToken;
    NELoginType m_NELoginType;

    int m_nTryInitTimes =0;

    QString m_personalMeetingId;
    QString m_prettyMeetingId;
    QString m_shortPersonalMeetingId;
    QString m_displayName;
    bool m_bInitialized = false;
    bool m_bSupportRecord = true;
    std::atomic_bool m_bAllowActive;
    std::unique_ptr<SettingsEventHandler> m_pSettingsEventHandler = nullptr;
};

#endif  // NEMEETINGSDKMANAGER_H
