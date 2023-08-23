// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "feedback_manager.h"

static const int kUploadLogResult = 200;
#if defined(_DEBUG) || defined(DEBUG)
static const uint32_t kFiveMinutes = 10;
#else
static const uint32_t kFiveMinutes = 5 * 60;
#endif
static const char* klocalTestMeetingDuration = "localTestMeetingDuration";
static const char* kLastFeedbackVersion = "lastFeedbackVersion";
static const char* kLastFeedbackDatetime = "lastFeedbackDatetime";
static const uint32_t kAWeekDuration = 7 * 24 * 60 * 60 * 1000;

FeedbackManager::FeedbackManager(AuthManager* auth, QObject* parent)
    : QObject(parent)
    , m_authsvr(auth)
    , m_httpManager(new HttpManager(parent)) {
    qRegisterMetaType<HttpFeedbackRequest>("HttpFeedbackRequest");
    connect(&m_feedbackTimer, &QTimer::timeout, this, &FeedbackManager::onInvokeFeedback);
    connect(this, &FeedbackManager::postRequest, this, &FeedbackManager::onPostRequest);
}

FeedbackManager::~FeedbackManager() {}

void FeedbackManager::invokeNPSFeedback(int score, const QString& description) {
    m_needAudioDump = false;
    m_feedbackCategory = QJsonArray();
    m_feedbackDescription = QString::number(score).append("#").append(description);
    onFeedbackStatus(0, kUploadLogResult, "");
}

void FeedbackManager::invokeFeedback(const QJsonArray& category, const QString& description, bool needAudioDump) {
    auto ipcFeedbackService = NEMeetingKit::getInstance()->getFeedbackService();
    if (ipcFeedbackService) {
        if (m_bInitialized == false) {
            m_bInitialized = true;
            ipcFeedbackService->addListener(this);
        }
    }
    m_needAudioDump = needAudioDump;
    m_feedbackCategory = category;
    m_feedbackDescription = description;
    std::thread feedbackThread([this]() { onInvokeFeedback(); });
    feedbackThread.detach();
}

bool FeedbackManager::needsFeedback(qint64 meetingDuration) {
    // 如果会议持续时长不足 5 分钟，则无条件不弹出反馈窗口，这里为方便测试，提供本地配置缩短会议持续时长要求
    auto localTestDuration = ConfigManager::getInstance()->getValue(klocalTestMeetingDuration, 0).toUInt();
    if (localTestDuration != 0) {
        if (meetingDuration < localTestDuration) {
            YXLOG(Info) << "Meeting duration " << meetingDuration << " is less than local test duration " << localTestDuration << " seconds."
                        << YXLOGEnd;
            return false;
        }
    } else {
        if (meetingDuration < kFiveMinutes) {
            YXLOG(Info) << "Meeting duration " << meetingDuration << " is less than 5 minutes." << YXLOGEnd;
            return false;
        }
    }
    // 上次反馈与本次要反馈版本不一致且会议时长大于 5 分钟
    if (ConfigManager::getInstance()->getValue(kLastFeedbackVersion) != APPLICATION_VERSION) {
        YXLOG(Info) << "Show feedback window, last feedback version is: "
                    << ConfigManager::getInstance()->getValue(kLastFeedbackVersion).toString().toStdString()
                    << ", current version is: " << APPLICATION_VERSION << ", meeting ducation is: " << meetingDuration << YXLOGEnd;
        ConfigManager::getInstance()->setValue(kLastFeedbackVersion, APPLICATION_VERSION);
        ConfigManager::getInstance()->setValue(kLastFeedbackDatetime, QDateTime::currentDateTime().toString());
        return true;
    }
    // 上次反馈与本次要反馈的时间不是同一天
    auto lastFeedbackDateString = ConfigManager::getInstance()->getValue(kLastFeedbackDatetime).toString();
    QDateTime lastFeedbackDatetime = QDateTime::fromString(lastFeedbackDateString);
    QDateTime currentDatetime = QDateTime::currentDateTime();
    if (lastFeedbackDatetime.date() != currentDatetime.date()) {
        YXLOG(Info) << "Show feedback window, last feedback date is: " << lastFeedbackDatetime.toString().toStdString()
                    << ", current date is: " << currentDatetime.toString().toStdString() << YXLOGEnd;
        ConfigManager::getInstance()->setValue(kLastFeedbackDatetime, currentDatetime.toString());
        return true;
    }
    YXLOG(Info) << "No need to show the feedback window, last feedback version is: "
                << ConfigManager::getInstance()->getValue(kLastFeedbackVersion).toString().toStdString()
                << ", current version is: " << APPLICATION_VERSION << ", last feedback date is: " << lastFeedbackDateString.toStdString()
                << ", current date is: " << currentDatetime.toString().toStdString() << ", meeting ducation is: " << meetingDuration << YXLOGEnd;
    return false;
}

void FeedbackManager::resetFeedback() {
    auto ipcFeedbackService = NEMeetingKit::getInstance()->getFeedbackService();
    if (ipcFeedbackService) {
        if (m_bInitialized) {
            ipcFeedbackService->addListener(nullptr);
            m_bInitialized = false;
        }
    }
}

void FeedbackManager::onFeedbackStatus(int type, int status, std::string url) {
    HttpFeedbackRequest request;
    FeedbackUserInfo info;
    info.appkey = m_authsvr->aPaasAppKey();
    info.phonePrefix = m_authsvr->phonePrefix();
    info.phoneNumber = m_authsvr->phoneNumber();
    info.Nickname = m_authsvr->appUserNick();
    if (type == 0) {
        // report logs
        if (status != 200) {
            clean();
            emit feedbackResult(status, "fail to zip logs");
            emit feedbackFinished();
            return;
        }
        request.InitFeedbackInfo(info, m_feedbackCategory, m_feedbackDescription, QString::fromStdString(url));

    } else if (type == 1) {
        // report crash
        request.InitCrashInfo(info, QString::fromStdString(url));
    }

    emit postRequest(request);
    emit feedbackFinished();
}

void FeedbackManager::onInvokeFeedback() {
    m_feedbackTimer.stop();
    QString appDataDirectory = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);

    FeedbackInfo info;
    QStringList files;
    files.append("*.log");
    files.append("*.nim_mmap");
    files.append("*.mmap*");
    files.append("*.txt");
    files.append("*log*.*");
    files.append("*.crash");
    files.append("*.ips");
    files.append("*.dmp");
    files.append("*.dump");
    files.append("*.nelog");
    QDirIterator it(appDataDirectory, files, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        auto file = it.next();
        if (!file.contains("/feedback/"))
            info.logs_.push_back(file);
    }
    info.feedback_type_ = FeedbackType::kFeedbackSuggestion;
    info.feedback_category_ = m_feedbackCategory;
    info.feedback_content_ = m_feedbackDescription;
    YXLOG(Info) << "ziplog start" << YXLOGEnd;
    std::string path = ziplog(info);
    emit ziplogFinished();
    YXLOG(Info) << "ziplog end path: " << path << YXLOGEnd;
    auto ipcFeedbackService = NEMeetingKit::getInstance()->getFeedbackService();
    if (ipcFeedbackService) {
        int type = 0;
        ipcFeedbackService->feedback(type, path, m_needAudioDump,
                                     [this](NEErrorCode errorCode, const std::string& errorMessage, const std::string& url, const int& type) {});
    }
}

void FeedbackManager::onPostRequest(const HttpFeedbackRequest& request) {
    m_httpManager->postRequest(request, [this](int code, const QJsonObject& response) {
        YXLOG(Info) << "feedback " << code << " " << QString(QJsonDocument(response).toJson()).toStdString() << YXLOGEnd;
        QString res = "";
        if (code != 200) {
            res = "Fail to sync to remote";
        }
        clean(code == 200);
        emit feedbackResult(code, res);
    });
}

std::string FeedbackManager::ziplog(FeedbackInfo& info) {
    QString appDataDirectory = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QString backupDirectory = appDataDirectory + "/feedback/" + QUuid::createUuid().toString();
    QByteArray byteDirectory = backupDirectory.toUtf8();
    QDir backupDir(byteDirectory.data());
    if (!backupDir.exists()) {
        backupDir.mkpath(byteDirectory.data());
    }
    QStringList logs_backup_path_;
    // copy logs
    for (auto it : info.logs_) {
        QFile file(it);
        QString backupFile = file.fileName().replace(appDataDirectory, backupDirectory);
        QFileInfo fileInfo(backupFile);
        if (!fileInfo.absoluteDir().exists()) {
            QByteArray byteAbsoluteDir = fileInfo.absoluteDir().path().toUtf8();
            fileInfo.absoluteDir().mkpath(byteAbsoluteDir.data());
        }
        if (file.copy(backupFile)) {
            logs_backup_path_.append(backupFile);
        } else {
            break;
        }
    }

    // zip logs
    QString zip_logs_path_ = backupDirectory + "/feedback_nim_logs.zip";
    std::vector<std::string> logs_backup_path;
    for (auto it : logs_backup_path_) {
        QByteArray byteIter = it.toLocal8Bit();
        logs_backup_path.emplace_back(byteIter.data());
    }

    QByteArray byteLogsPath = zip_logs_path_.toUtf8();
    nim_tool::Zipper::Zip(byteLogsPath.data(), logs_backup_path);

    QFile file(zip_logs_path_);
    if (!file.exists())
        YXLOG(Info) << "ERROR!" << YXLOGEnd;

    return zip_logs_path_.toStdString();
}

void FeedbackManager::clean(bool cleanOldLog, bool all) {
    QString appDataDirectory = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir feedbackDir(appDataDirectory + "/feedback/");
    feedbackDir.removeRecursively();
    YXLOG(Info) << "Remove temporary directory of feedback recursively:" << feedbackDir.path().toStdString() << YXLOGEnd;

    if (cleanOldLog) {
        if (all) {
            QDir oldLogDir(appDataDirectory);
            if (oldLogDir.exists()) {
                oldLogDir.removeRecursively();
            }
            return;
        }

        QDir oldLogDir(appDataDirectory + "/app/");
        if (!oldLogDir.exists()) {
            return;
        }
        oldLogDir.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot);
        QFileInfoList fileList = oldLogDir.entryInfoList();
        foreach (QFileInfo file, fileList) {
            if (file.isFile()) {
                file.dir().remove(file.fileName());
            }
        }
        YXLOG(Info) << "Remove cleanOldLog files" << YXLOGEnd;
    }
}
