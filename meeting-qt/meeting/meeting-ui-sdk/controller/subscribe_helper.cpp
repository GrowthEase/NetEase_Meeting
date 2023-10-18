// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "subscribe_helper.h"
#include "manager/meeting/video_manager.h"
#include "video_controller.h"

using namespace std::chrono;

SubscribeHelper::SubscribeHelper() {}

SubscribeHelper::~SubscribeHelper() {}

void SubscribeHelper::reset() {
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    m_subscribeList.clear();
}

void SubscribeHelper::init() {}

bool SubscribeHelper::subscribe(const std::string& userId, Quality streamType, const QString& uuid) {
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    auto iter = m_subscribeList.find(userId);
    if (iter != m_subscribeList.end()) {
        YXLOG(Info) << "Ready to subscribe, userUuid: " << userId << ", video started: " << iter->second.videoStarted
                    << ", current quality: " << stringifyQualities(iter->second.qualities) << ", subscribe type: " << streamType
                    << ", timestamp: " << iter->second.timestamp << ",uuid: " << uuid.toStdString() << YXLOGEnd;
        iter->second.timestamp = time_point_cast<milliseconds>(system_clock::now()).time_since_epoch().count();
        iter->second.qualities[uuid] = streamType;
        if (iter->second.videoStarted /* && (iter->second.quality != subscribeQuality || iter->second.timestamp == kSubscribeUnsubscribed)*/) {
            auto subscribeQuality = getSubscribeQuality(userId);
            auto videoController = VideoManager::getInstance()->getVideoController();
            if (videoController) {
                videoController->subscribeRemoteVideoStream(userId, subscribeQuality == High);
            }
            YXLOG(Info) << "Subscribe remote user video data, userUuid: " << iter->first << ", quality: " << subscribeQuality
                        << ", timestamp: " << iter->second.timestamp << YXLOGEnd;
        }
    } else {
        YXLOG(Info) << "Ready to subscribe, userUuid: " << userId << ", video started: false"
                    << ", current quality: None, subscribe type: " << streamType << ", timestamp: " << kSubscribeUnsubscribed
                    << ", uuid: " << uuid.toStdString() << YXLOGEnd;
        SubscribeInfo info;
        info.qualities[uuid] = streamType;
        m_subscribeList[userId] = info;
    }

    return true;
}

void SubscribeHelper::unsubscribe(const std::string& userId, Quality streamType, const QString& uuid) {
    YXLOG(Info) << "unsubscribe userId: " << userId << ", subscribe stream type: " << streamType << ", uuid: " << uuid.toStdString() << YXLOGEnd;
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    auto iter = m_subscribeList.find(userId);
    if (iter != m_subscribeList.end()) {
        auto qualityIter = iter->second.qualities.find(uuid);
        if (qualityIter != iter->second.qualities.end())
            iter->second.qualities.erase(qualityIter);
        auto videoController = VideoManager::getInstance()->getVideoController();
        if (!videoController)
            return;
        if (iter->second.qualities.empty()) {
            // 订阅列表为空了，直接取消订阅
            YXLOG(Info) << "Unsubscribe remote user video data because qualities map is empty, userUuid: " << userId
                        << ", stream type: " << streamType << YXLOGEnd;
            videoController->unsubscribeRemoteVideoStream(userId);
        } else {
            // 当前被取消订阅的是高清视频，并且列表不为空，证明只剩下低清视频，需要重新订阅低清视频
            auto subscribeQuality = getSubscribeQuality(userId);
            YXLOG(Info) << "Resubscribe remote user video data, userUuid: " << userId << ", quality: " << subscribeQuality
                        << ", stream type: " << streamType << YXLOGEnd;
            videoController->subscribeRemoteVideoStream(userId, subscribeQuality == High);
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
                        << ", current quality: " << stringifyQualities(iter->second.qualities) << ", timestamp: " << iter->second.timestamp
                        << YXLOGEnd;
            if (!iter->second.qualities.empty() || iter->second.timestamp == kSubscribeUnsubscribed) {
                YXLOG(Info) << "Subscribe remote user video data, userUuid: " << iter->first
                            << ", quality: " << stringifyQualities(iter->second.qualities) << ", timestamp: " << iter->second.timestamp << YXLOGEnd;
                auto subscribeQuality = getSubscribeQuality(userId);
                auto videoController = VideoManager::getInstance()->getVideoController();
                if (videoController)
                    videoController->subscribeRemoteVideoStream(userId, subscribeQuality == High);
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
            if (!iter->second.qualities.empty() && iter->second.timestamp > kSubscribeWaitForUnsub) {
                YXLOG(Info) << "Unsubscribe remote user video data, userUuid: " << userId
                            << ", subscribed quality: " << stringifyQualities(iter->second.qualities) << YXLOGEnd;
                auto videoController = VideoManager::getInstance()->getVideoController();
                if (videoController) {
                    videoController->unsubscribeRemoteVideoStream(userId);
                }
                iter->second.timestamp = kSubscribeUnsubscribed;
            }
        }
    }
}

std::string SubscribeHelper::stringifyQualities(const std::map<QString, Quality>& qualities) const {
    std::string result;
    for (auto& quality : qualities) {
        if (!result.empty()) {
            result += ",";
        }
        result += quality.first.toStdString() + "-";
        result += quality.second == High ? "High" : "Low";
    }
    return result;
}

Quality SubscribeHelper::getSubscribeQuality(const std::string& userId) {
    std::lock_guard<std::recursive_mutex> locker(m_subscribeLock);
    Quality subscribeQuality = Low;
    auto userIter = m_subscribeList.find(userId);
    if (userIter == m_subscribeList.end())
        return subscribeQuality;
    for (const auto& quality : userIter->second.qualities) {
        // 如果找到高清就直接订阅高清，高清的优先级最高
        if (quality.second == High) {
            subscribeQuality = High;
            break;
        }
    }
    return subscribeQuality;
}
