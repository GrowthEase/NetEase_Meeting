// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef FeedbackManager_H
#define FeedbackManager_H

#include <QTimer>
#include "utils/singleton.h"

class FeedbackManager : public QObject {
    Q_OBJECT
private:
    FeedbackManager(QObject* parent = nullptr);

public:
    SINGLETONG(FeedbackManager)

public:
    bool initialize();
    void release();
    void Uploadsources(const int& type, const std::string& path, bool needAudioDump, const NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback& cb);
    void stopAudioDump();
    bool isAudioDumping();

private:
    void addAudioDumpToSources(const std::string& zipPath);

signals:
    void uploadStatusChanged(bool uploading);

private Q_SLOTS:
    void onTimeout();

private:
    QTimer m_timer;
    int m_type;
    std::string m_path;
    NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback m_feedbackCallback;
};

#endif  // FeedbackManager_H
