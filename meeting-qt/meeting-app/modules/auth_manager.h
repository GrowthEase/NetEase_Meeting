/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QJsonArray>
#include <QObject>
#include <QTimer>
#include "base/http_manager.h"

class AuthManager : public QObject {
    Q_OBJECT
public:
    explicit AuthManager(QObject* parent = nullptr);
    ~AuthManager();

    Q_PROPERTY(QString authCodeInternal READ authCodeInternal WRITE setAuthCodeInternal NOTIFY authCodeInternalChanged)
    Q_PROPERTY(QString phonePrefix READ phonePrefix WRITE setPhonePrefix NOTIFY phonePrefixChanged)
    Q_PROPERTY(QString phoneNumber READ phoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged)
    Q_PROPERTY(QString appUserOpenId READ appUserOpenId WRITE setAppUserOpenId NOTIFY appUserOpenIdChanged)
    Q_PROPERTY(QString appUserId READ appUserId WRITE setAppUserId NOTIFY appUserIdChanged)
    Q_PROPERTY(QString appUserToken READ appUserToken WRITE setAppUserToken NOTIFY appUserTokenChanged)
    Q_PROPERTY(QString appUserNick READ appUserNick WRITE setAppUserNick NOTIFY appUserNickChanged)
    Q_PROPERTY(QString aPaasAccountId READ aPaasAccountId WRITE setAPaasAccountId NOTIFY aPaasAccountIdChanged)
    Q_PROPERTY(QString aPaasAccountToken READ aPaasAccountToken WRITE setAPaasAccountToken NOTIFY aPaasAccountTokenChanged)
    Q_PROPERTY(QString aPaasAppKey READ aPaasAppKey WRITE setAPaasAppKey NOTIFY aPaasAppKeyChanged)
    Q_PROPERTY(bool resetPasswordFlag READ resetPasswordFlag WRITE setResetPasswordFlag NOTIFY resetPasswordFlagChanged)
    Q_PROPERTY(QString paasServerAddress READ paasServerAddress)
    Q_PROPERTY(QString paasApiVersion READ paasApiVersion)
    Q_PROPERTY(QString curDisplayCompany READ curDisplayCompany WRITE setCurDisplayCompany NOTIFY curDisplayCompanyChanged)
    Q_PROPERTY(QString curDisplayVersion READ curDisplayVersion WRITE setCurDisplayVersion NOTIFY curDisplayVersionChanged)
    Q_PROPERTY(QString maxDuration READ maxDuration WRITE setMaxDuration NOTIFY maxDurationChanged)
    Q_PROPERTY(QString maxMemberCount READ maxMemberCount WRITE setMaxMemberCount NOTIFY maxMemberCountChanged)
    Q_PROPERTY(QString extraInfo READ extraInfo WRITE setExtraInfo NOTIFY extraInfoChanged)

    QString authCodeInternal() const;
    void setAuthCodeInternal(const QString& authCodeInternal);

    QString phonePrefix() const;
    void setPhonePrefix(const QString& phonePrefix);

    QString phoneNumber() const;
    void setPhoneNumber(const QString& phoneNumber);

    QString appUserId() const;
    void setAppUserId(const QString& appUserId);

    QString appUserToken() const;
    void setAppUserToken(const QString& appUserToken);

    QString appUserNick() const;
    void setAppUserNick(const QString& appUserNick);

    QString aPaasAccountId() const;
    void setAPaasAccountId(const QString& aPaasAccountId);

    QString aPaasAccountToken() const;
    void setAPaasAccountToken(const QString& aPaasAccountToken);

    QString aPaasAppKey() const;
    void setAPaasAppKey(const QString& aPaasAppKey);

    QString appUserOpenId() const;
    void setAppUserOpenId(const QString& appUserOpenId);

    bool resetPasswordFlag() const;
    void setResetPasswordFlag(bool resetPasswordFlag);

    QString paasServerAddress() const;
    QString paasApiVersion() const { return m_paasApiVersion; }

    QString curDisplayVersion() const;
    void setCurDisplayVersion(const QString& curDisplayVersion);

    QString maxDuration() const;
    void setMaxDuration(const QString& maxDuration);

    QString maxMemberCount() const;
    void setMaxMemberCount(const QString& maxMemberCount);

    QString curDisplayCompany() const;
    void setCurDisplayCompany(const QString& curDisplayCompany);

    QString extraInfo() const;
    void setExtraInfo(const QString& extraInfo);

signals:
    /**
     * @brief error
     * 统一错误入口
     * @param resCode   错误代码
     * @param object    错误内容的 json 格式数据
     */
    void error(int resCode, const QJsonObject& result);
    /**
     * @brief gotAuthCode
     * 获取到验证码的信号
     * @param phoneNumber   获取验证码的手机号
     */
    void gotAuthCode(const QString& phoneNumber);
    /**
     * @brief verifiedAuthCode
     * 验证验证码是否有效信号，能收到此信号证明验证码验证通过
     * @param authCodeInternal  验证成功后的内部请求码，用于后续请求，如注册、重置密码等
     */
    void verifiedAuthCode(const QString& authCodeInternal);
    /**
     * @brief registeredAccount
     * 注册账号返回后的信号
     */
    void registeredAccount();
    /**
     * @brief loggedIn
     * 登录成功后收到的信号
     * @param userId                视频会议的应用帐号ID
     * @param meetingToken          视频会议的接口校验token，可用于im协议访问视频会议服务器
     * @param imAccid               公有云IM通信ID
     * @param imToken               公有云IM通信ID的密码
     * @param personalMeetingId     个人会议室-视频会议码
     */
    void loggedIn(const QString& userId);
    /**
     * @brief loggedOut
     * 登出信号
     */
    void loggedOut(bool needsLogout, bool cleanup);
    /**
     * @brief changedPassword
     * 修改密码成功后收到的信号
     */
    void verifiedPassword();
    /**
     * @brief resetPasswordSig
     * 重置密码成功后收到的信号
     */
    void resetPasswordSig();
    /**
     * @brief updatedProfile
     * 更新昵称成功后收到的信号
     */
    void updatedProfile();
    /**
     * @brief loginWithSSO
     * SSO 登录信号
     * @param ssoAppKey
     * @param ssoToken
     */
    void loginWithSSO(const QString& ssoAppKey, const QString& ssoToken);
    /**
     * @brief gotAccountApps
     * 在线获取 app 列表
     * @param accountApps
     */
    void gotAccountApps(const QJsonArray& accountApps);
    /**
     * @brief switchedApp
     * 切换企业成功通知
     * @param appInfo
     */
    void switchedApp(const QJsonObject& appInfo);

    // binding values
    void authCodeInternalChanged();
    void aPassAccountId();
    void phonePrefixChanged();
    void phoneNumberChanged();
    void appUserOpenIdChanged();
    void appUserIdChanged();
    void appUserTokenChanged();
    void appUserNickChanged();
    void aPaasAccountIdChanged();
    void aPaasAccountTokenChanged();
    void aPaasAppKeyChanged();
    void resetPasswordFlagChanged();
    void loginTypeChanged();
    void curDisplayCompanyChanged();
    void curDisplayVersionChanged();
    void maxDurationChanged();
    void maxMemberCountChanged();
    void extraInfoChanged();

public slots:
    /**
     * @brief getAuthCode
     * 获取验证码
     * @param phonePrefix   国家前缀
     * @param phoneNumber   手机号
     * @param scene         场景，见 GetAuthCodeScene
     */
    void getAuthCode(const QString& phonePrefix, const QString& phoneNumber, int scene);
    /**
     * @brief verifyAuthCode
     * 验证验证码是否有效
     * @param phonePrefix    国家前缀
     * @param phoneNumber    手机号
     * @param code           收到的验证码
     * @param scene          验证场景
     */
    void verifyAuthCode(const QString& phonePrefix, const QString& phoneNumber, const QString& code, int scene);
    /**
     * @brief registerAccount
     * 注册账号
     * @param phonePreFix       国家前缀
     * @param phoneNumber       手机号
     * @param nickname          昵称
     * @param password          密码
     */
    void registerAccount(const QString& phonePrefix, const QString& phoneNumber, const QString& nickname, const QString& password);
    /**
     * @brief registerNEAccount
     * @param phoneNumber
     * @param verifyCode
     * @param nickname
     * @param password
     * @param appKey
     */
    void registerNEAccount(const QString& phoneNumber, const QString& verifyCode, const QString& nickname, const QString& password);
    /**
     * @brief loginToHttp
     * 登录到 HTTP 服务器
     * @param loginType         登录类型，见 LoginType
     * @param phonePreFix       国家前缀
     * @param phoneNumber       手机号
     * @param authValue         不同登录类型所需的不通数据，loginType为0，传meetingToken值； loginType为1，传短信校验码； loginType为1，传登陆密码
     * @param cacheUserId       如果使用 token 登录，这里传递本地缓存的 userId
     */
    void loginToHttp(int loginType,
                     const QString& phonePrefix,
                     const QString& phoneNumber,
                     const QString& authValue,
                     const QString& cacheUserId = "");

    /**
     * @brief loginByPassword
     * 使用账号密码登录网易会议服务器
     * @param username
     * @param password
     */
    void loginByPassword(const QString& username, const QString& password);
    /**
     * @brief loginByVerifyCode
     * 使用验证码登录
     * @param phoneNumber
     * @param verifyCode
     */
    void loginByVerifyCode(const QString& phoneNumber, const QString& verifyCode);
    /**
     * @brief getAccountApps
     * 获取当前账号下所有应用信息（企业）
     * @param appKey
     * @param accountId
     * @param accountToken
     */
    void getAccountApps(const QString& appKey, const QString& accountId, const QString& accountToken);
    /**
     * @brief getAccountAppInfo
     * 获取当前账号下的应用信息
     * @param appKey
     * @param accountId
     * @param accountToken
     */
    void getAccountAppInfo(const QString& appKey, const QString& accountId, const QString& accountToken);
    /**
     * @brief switchApp
     * 通知服务器要切换到哪个企业下，未来再使用该账号登录时将连接该企业
     * @param appKey
     * @param accountId
     * @param accountToken
     */
    void switchApp(const QString& appKey, const QString& accountId, const QString& accountToken);
    /**
     * @brief logout
     * 删除本地登录状态
     */
    void logout(bool needsLogout = true, bool cleanup = false);
    /**
     * @brief verifyPassword
     * 修改密码
     * @param oldPassword       旧密码
     */
    void verifyPassword(const QString& oldPassword, const QString& userId, const QString& token);
    /**
     * @brief resetPassword
     * 重置密码
     * @param phonePrefix   国家前缀
     * @param phoneNumber   手机号
     * @param newPassword   新密码
     */
    void resetPassword(const QString& appKey, const QString& accountId, const QString& accountToken, const QString& newPassword);
    /**
     * @brief resetPasswordByVerifyCode
     * 通过短信验证码修改密码
     * @param phoneNumber
     * @param verifyCode
     * @param newPassword
     */
    void resetPasswordByVerifyCode(const QString& phoneNumber, const QString& verifyCode, const QString& newPassword);
    /**
     * @brief updateProfile
     * 更新昵称信息
     * @param nickname          要更新的昵称
     */
    void updateProfile(const QString& nickname, const QString& appKey, const QString& userId, const QString& token);
    /**
     * @brief resetAuthInfo
     */
    void resetAuthInfo();

private:
    void onLoginCallback(int code, const QJsonObject& response, bool registerMode);

private:
    /* ------------------------------------------- */
    QString m_curDisplayCompany;
    QString m_curDisplayVersion;
    QString m_maxDuration;
    QString m_maxMemberCount;
    QString m_extraInfo;
    QJsonArray m_accountApps;
    /* ------------------------------------------- */
    std::shared_ptr<HttpManager> m_httpManager;
    QString m_authCodeInternal;
    QString m_phonePrefix;
    QString m_phoneNumber;
    QString m_appUserOpenId;
    QString m_appUserId;
    QString m_appUserToken;
    QString m_appUserNick;
    QString m_aPaasAccountId;
    QString m_aPaasAccountToken;
    QString m_aPaasAppKey;
    bool m_resetPasswordFlag = false;
    QString m_paasServerAddress = "https://meeting-api-test.netease.im/";
    QString m_paasApiVersion = "v1";
};

#endif  // AUTHMANAGER_H
