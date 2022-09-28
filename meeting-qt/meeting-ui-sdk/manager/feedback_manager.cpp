// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "feedback_manager.h"
#include "global_manager.h"
#include "meeting/audio_manager.h"
#include "utils/zipper.h"

FeedbackManager::FeedbackManager(QObject* parent)
    : QObject(parent) {
    m_timer.setInterval(3 * 60 * 1000);
    m_timer.setSingleShot(true);
    connect(&m_timer, &QTimer::timeout, this, &FeedbackManager::onTimeout);
}

bool FeedbackManager::initialize() {
    return true;
}

void FeedbackManager::release() {}

void FeedbackManager::Uploadsources(const int& type,
                                    const std::string& path,
                                    bool needAudioDump,
                                    const NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback& cb) {
    if (m_timer.isActive()) {
        m_timer.stop();
        AudioManager::getInstance()->stopAudioDump();
        addAudioDumpToSources(path);
    }

    m_type = type;
    m_path = path;
    m_feedbackCallback = cb;

    if (needAudioDump) {
        m_timer.start();
        AudioManager::getInstance()->startAudioDump();
    } else {
        GlobalManager::getInstance()->getNosService()->uploadResource(m_path, [=](int code, const std::string& msg, const std::string& url) {
            m_feedbackCallback(nem_sdk_interface::NEErrorCode(code), msg, url, m_type);
            m_feedbackCallback = nullptr;
            m_path = "";
        });
    }
}

void FeedbackManager::stopAudioDump() {
    if (!m_timer.isActive()) {
        return;
    }

    m_timer.stop();
    onTimeout();
}

void FeedbackManager::addAudioDumpToSources(const std::string& zipPath) {
    auto dumpFile = qApp->property("logPath").toString();
    if (dumpFile.isEmpty())
        dumpFile = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    dumpFile.append("/app/roomkit/NeRTC/netease_nrtc_audio.dmp");

    if (!QFile::exists(QString::fromStdString(zipPath)) || !QFile::exists(dumpFile)) {
        return;
    }

    QByteArray byteLogsPath = QString::fromStdString(zipPath).toUtf8();
    std::vector<std::string> dump;
    dump.emplace_back(dumpFile.toUtf8());
    nim_tool::Zipper::Zip(byteLogsPath.data(), dump, 6, 1);
    QFile::remove(dumpFile);
}

void FeedbackManager::onTimeout() {
    AudioManager::getInstance()->stopAudioDump();
    addAudioDumpToSources(m_path);
    GlobalManager::getInstance()->getNosService()->uploadResource(m_path, [=](int code, const std::string& msg, const std::string& url) {
        m_feedbackCallback(nem_sdk_interface::NEErrorCode(code), msg, url, m_type);
        m_feedbackCallback = nullptr;
        m_path = "";
    });
}

bool FeedbackManager::isAudioDumping() {
    return m_timer.isActive();
}
