/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef HTTPUP_LOADER_H
#define HTTPUP_LOADER_H
USING_NS_NNEM_SDK_INTERFACE
#include <QDirIterator>
#include <QJsonArray>
#include <QObject>
#include <QStandardPaths>
#include <QSysInfo>
#include <QTimer>
#include <QUuid>
#include "auth_manager.h"
#include "base/http_manager.h"
#include "base/http_request.h"
#include "sys_info.h"
#include "utils/zipper.h"
#include "version.h"

enum class FeedbackType { kFeedbackSuggestion, kFeedbackCrash };

class FeedbackInfo {
public:
    FeedbackType feedback_type_;    //反馈类型
    QJsonArray feedback_category_;  //问题分类
    QString feedback_content_;      //要上报的反馈内容
    QString feedback_url_;          //上报的地址
    QString logs_url_;              //日志文件上传的地址
    QStringList logs_;              //要上传的日志文件列表
};
class FeedbackSessionInfo {
public:
    const FeedbackSessionInfo& operator=(const FeedbackInfo& info) {
        feedback_info_ = info;
        return *this;
    }
    FeedbackInfo feedback_info_;
    QStringList logs_backup_path_;
    QString directory_path_;
    QString zip_logs_path_;
    QString logs_url_;
};

class FeedbackUserInfo {
public:
    QString appkey = "";
    QString phonePrefix = "";
    QString phoneNumber = "";
    QString Nickname = "";
};
const QString kFeedbackMainUrl = "https://statistic.live.126.net/";
const QString kFeedbackSubUrl = "statics/report/common/form";
class HttpFeedbackRequest : public IHttpRequest {
public:
    HttpFeedbackRequest()
        : IHttpRequest(kFeedbackSubUrl, kFeedbackMainUrl) {}
    void InitFeedbackInfo(const FeedbackUserInfo& userInfo, const QJsonArray& category, const QString& description, const QString& logURL) {
        QByteArray appkey = userInfo.appkey.toUtf8();
        setRawHeader("ver", APPLICATION_VERSION);
        setRawHeader("sdktype", "meeting");
        setRawHeader("appkey", appkey.data());

        QJsonObject requestParams;
        QJsonObject event;
        QJsonObject feedback;
        feedback["app_key"] = userInfo.appkey;
        feedback["device_id"] = QString(QSysInfo::machineUniqueId());
        feedback["ver"] = APPLICATION_VERSION;
        feedback["client"] = "Meeting";
        feedback["platform"] = "PC";
        feedback["os_ver"] = QSysInfo::prettyProductName();
        feedback["manufacturer"] = SysInfo::GetSystemManufacturer();
        feedback["model"] = SysInfo::GetSystemProductName();
        feedback["country_code"] = userInfo.phonePrefix;
        feedback["phone"] = userInfo.phoneNumber;
        feedback["nickname"] = userInfo.Nickname;
        feedback["meeting_id"] = ConfigManager::getInstance()->getValue("localLastConferenceId").toString();
        feedback["channel_id"] = ConfigManager::getInstance()->getValue("localLastChannelId").toString();
        feedback["category"] = category;
        feedback["description"] = description;
        feedback["log"] = logURL;
        feedback["time"] = QDateTime::currentSecsSinceEpoch();
        event["feedback"] = feedback;
        requestParams["event"] = event;

        QByteArray byteArray = QJsonDocument(requestParams).toJson(QJsonDocument::Compact);
        YXLOG(Info) << "feedback " << QString(byteArray).toStdString() << YXLOGEnd;
        setParams(byteArray);
    }
    void InitCrashInfo(const FeedbackUserInfo& userInfo, const QString& crashUrl) {
        QByteArray appkey = userInfo.appkey.toUtf8();
        setRawHeader("ver", APPLICATION_VERSION);
        setRawHeader("sdktype", "meeting");
        setRawHeader("appkey", appkey.data());

        QJsonObject requestParams;
        QJsonObject event;
        QJsonObject feedback;
        feedback["app_key"] = userInfo.appkey;
        feedback["device_id"] = QString(QSysInfo::machineUniqueId());
        feedback["ver"] = APPLICATION_VERSION;
        feedback["platform"] = "PC";
        feedback["os_ver"] = QSysInfo::prettyProductName();
        feedback["phone"] = userInfo.phonePrefix + userInfo.phoneNumber;
        feedback["log"] = crashUrl;
        feedback["time"] = QDateTime::currentSecsSinceEpoch();
        event["crash"] = feedback;
        requestParams["event"] = event;

        QByteArray byteArray = QJsonDocument(requestParams).toJson(QJsonDocument::Compact);
        setParams(byteArray);
    }
};

class FeedbackManager : public QObject, public FeedbackServiceListener {
    Q_OBJECT
public:
    FeedbackManager(AuthManager* auth, QObject* parent = nullptr);
    ~FeedbackManager();

    Q_INVOKABLE void invokeFeedback(const QJsonArray& category, const QString& description);

public:
    virtual void onFeedbackStatus(int type, int status, std::string url) override;
signals:
    void postRequest(const HttpFeedbackRequest& request);
    void feedbackResult(int code, const QString& result);
private slots:
    void onInvokeFeedback();
    void onPostRequest(const HttpFeedbackRequest& request);

private:
    std::string ziplog(FeedbackInfo& info);
    void clean();

private:
    bool m_bInitialized = false;

    QJsonArray m_feedbackCategory;
    QString m_feedbackDescription;
    QTimer m_feedbackTimer;
    AuthManager* m_authsvr;
    std::shared_ptr<HttpManager> m_httpManager;
};

#endif  // HTTPUP_LOADER_H
