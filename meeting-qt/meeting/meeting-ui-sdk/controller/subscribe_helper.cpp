// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "subscribe_helper.h"
#include "manager/meeting/video_manager.h"
#include "video_controller.h"

using namespace std::chrono;

SubscribeHelper::SubscribeHelper() {
    QObject::connect(&m_checkTimer, &QTimer::timeout, [this]() {
        std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
        for (auto& subscribe : m_subscribeList) {
            if (subscribe.second.timestamp == kSubscribeWaitForUnsub && subscribe.second.quality != None) {
                subscribe.second.timestamp = kSubscribeUnsubscribed;
                subscribe.second.quality = None;
                YXLOG(Info) << "Unsubscribe user video data, userUuid: " << subscribe.first << ", quality: " << subscribe.second.quality
                            << ", timestamp: " << subscribe.second.timestamp << YXLOGEnd;
                auto videoController = VideoManager::getInstance()->getVideoController();
                if (videoController) {
                    videoController->unsubscribeRemoteVideoStream(subscribe.first);
                }
            }
        }
    });
}

SubscribeHelper::~SubscribeHelper() {
    if (m_checkTimer.isActive()) {
        m_checkTimer.stop();
    }
}

void SubscribeHelper::reset() {
    if (m_checkTimer.isActive()) {
        m_checkTimer.stop();
    }
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    m_subscribeList.clear();
}

void SubscribeHelper::init() {
    m_checkTimer.setInterval(1000 * 10);
    m_checkTimer.start();
}

bool SubscribeHelper::subscribe(const std::string& userId, bool highQuality, const QString& uuid) {
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    auto iter = m_subscribeList.find(userId);
    if (iter != m_subscribeList.end()) {
        auto subscribeQuality = highQuality ? High : Low;
        YXLOG(Info) << "Ready to subscribe, userUuid: " << userId << ", video started: " << iter->second.videoStarted
                    << ", current quality: " << iter->second.quality << ", subscribe quality: " << subscribeQuality
                    << ", timestamp: " << iter->second.timestamp << ",uuid: " << uuid.toStdString() << YXLOGEnd;
        if (iter->second.videoStarted /* && (iter->second.quality != subscribeQuality || iter->second.timestamp == kSubscribeUnsubscribed)*/) {
            auto videoController = VideoManager::getInstance()->getVideoController();
            if (videoController) {
                videoController->subscribeRemoteVideoStream(userId, highQuality);
            }
            YXLOG(Info) << "Subscribe remote user video data, userUuid: " << iter->first << ", quality: " << (highQuality ? High : Low)
                        << ", timestamp: " << iter->second.timestamp << YXLOGEnd;
        }
        iter->second.timestamp = time_point_cast<milliseconds>(system_clock::now()).time_since_epoch().count();
        iter->second.quality = subscribeQuality;
        iter->second.uuid = uuid;
    } else {
        SubscribeInfo info;
        info.quality = highQuality ? High : Low;
        info.uuid = uuid;
        m_subscribeList[userId] = info;
    }

    return true;
}

void SubscribeHelper::unsubscribe(const std::string& userId, const QString& uuid) {
    YXLOG(Info) << "unsubscribe userId: " << userId << ", uuid: " << uuid.toStdString() << YXLOGEnd;
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    auto iter = m_subscribeList.find(userId);
    if (iter != m_subscribeList.end()) {
        if (uuid != iter->second.uuid) {
            YXLOG(Info) << "Unsubscribe return" << YXLOGEnd;
            return;
        }

        if (iter->second.timestamp > kSubscribeWaitForUnsub) {
            iter->second.timestamp = kSubscribeWaitForUnsub;
            YXLOG(Info) << "Unsubscribe restore user info, userUuid: " << userId << ", quality: " << iter->second.quality << YXLOGEnd;
        }
    }
}

bool SubscribeHelper::removeVideoState(const std::string& userId) {
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    auto iter = m_subscribeList.find(userId);
    if (iter != m_subscribeList.end()) {
        m_subscribeList.erase(iter);
        return true;
    }
    return false;
}

void SubscribeHelper::updateVideoState(const std::string& userId, bool started) {
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    auto iter = m_subscribeList.find(userId);
    if (started) {
        if (iter != m_subscribeList.end()) {
            iter->second.videoStarted = true;
            YXLOG(Info) << "Ready to subscribe, userUuid: " << userId << ", video started: " << iter->second.videoStarted
                        << ", current quality: " << iter->second.quality << ", timestamp: " << iter->second.timestamp << YXLOGEnd;
            if (iter->second.quality != None || iter->second.timestamp == kSubscribeUnsubscribed) {
                YXLOG(Info) << "Subscribe remote user video data, userUuid: " << iter->first << ", quality: " << iter->second.quality
                            << ", timestamp: " << iter->second.timestamp << YXLOGEnd;
                auto videoController = VideoManager::getInstance()->getVideoController();
                if (videoController) {
                    videoController->subscribeRemoteVideoStream(userId, iter->second.quality == High);
                }
            }
            iter->second.timestamp = time_point_cast<milliseconds>(system_clock::now()).time_since_epoch().count();
        } else {
            SubscribeInfo info;
            info.videoStarted = true;
            m_subscribeList[userId] = info;
        }
    } else {
        if (iter != m_subscribeList.end()) {
            iter->second.videoStarted = false;
            if (iter->second.quality != None && iter->second.timestamp > kSubscribeWaitForUnsub) {
                YXLOG(Info) << "Unsubscribe remote user video data, userUuid: " << userId << ", subscribed quality: " << iter->second.quality
                            << YXLOGEnd;
                auto videoController = VideoManager::getInstance()->getVideoController();
                if (videoController) {
                    videoController->unsubscribeRemoteVideoStream(userId);
                }
                iter->second.timestamp = kSubscribeUnsubscribed;
            }
        }
    }
}
