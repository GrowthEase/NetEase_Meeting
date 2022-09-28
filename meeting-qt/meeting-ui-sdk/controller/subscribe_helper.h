// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef SUBSCRIBEHELPER_H
#define SUBSCRIBEHELPER_H

#include <QObject>
#include <QTimer>

typedef enum { High = 0, Low = 1, None = 2 } Quality;

enum SubscribeTimestamp { kSubscribeUnsubscribed = -1, kSubscribeWaitForUnsub };

typedef struct tagSubscribeInfo {
    tagSubscribeInfo()
        : quality(None)
        , videoStarted(false)
        , timestamp(kSubscribeUnsubscribed) {}
    Quality quality;
    QString uuid;
    bool videoStarted;
    int64_t timestamp;
} SubscribeInfo;

class SubscribeHelper {
public:
    SubscribeHelper();
    ~SubscribeHelper();

    void reset();
    void init();
    bool subscribe(const std::string& userId, bool highQuality, const QString& uuid);
    void unsubscribe(const std::string& userId, const QString& uuid);
    bool removeVideoState(const std::string& userId);
    void updateVideoState(const std::string& userId, bool started);

private:
    std::recursive_mutex m_subscribeLock;
    std::map<std::string, SubscribeInfo> m_subscribeList;
    QTimer m_checkTimer;
};

#endif  // SUBSCRIBEHELPER_H
