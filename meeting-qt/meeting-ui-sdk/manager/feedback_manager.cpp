/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "feedback_manager.h"
#include "global_manager.h"
#include "pre_meeting_manager.h"

FeedbackManager::FeedbackManager(QObject* parent)
    : QObject(parent) {}

bool FeedbackManager::initialize() {
    return true;
}

void FeedbackManager::release() {}

void FeedbackManager::Uploadsources(const int& type, const std::string& path, const NS_I_NEM_SDK::NEFeedbackService::NEFeedbackCallback& cb) {
    // call native sdk
    GlobalManager::getInstance()->getPreRoomService()->upLoaderFile(
        type, path, [type, cb](const int& code, const std::string& msg, const int& ntype, const std::string& url) {
            cb(nem_sdk_interface::NEErrorCode(code), msg, url, type);
        });
}
