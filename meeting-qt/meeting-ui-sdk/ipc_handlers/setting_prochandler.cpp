/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "setting_prochandler.h"
#include "manager/global_manager.h"
#include "manager/meeting_manager.h"
#include "manager/settings_manager.h"

bool NESettingsServiceProcHandlerIMP::onShowSettingUIWnd(const NS_I_NEM_SDK::NESettingsUIWndConfig& /*config*/,
                                                         const NS_I_NEM_SDK::NESettingsService::NEShowSettingUIWndCallback& cb) {
    YXLOG_API(Info) << "Received show settings UI window request." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        GlobalManager::getInstance()->showSettingsWnd();
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    });
    return true;
}

void NESettingsServiceProcHandlerIMP::onShowMyMeetingElapseTime(bool show, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onShowMyMeetingElapseTime: " << show << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        MeetingManager::getInstance()->setShowMeetingDuration(show);
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
    });
}

void NESettingsServiceProcHandlerIMP::onIsShowMyMeetingElapseTimeEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsShowMyMeetingElapseTimeEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", MeetingManager::getInstance()->showMeetingDuration()); });
}

void NESettingsServiceProcHandlerIMP::onEnableBeauty(bool enable, const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onEnableBeauty. enable : " << enable << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_NOT_IMPLEMENTED, "NOT IMPLEMENTED", false); });
}

void NESettingsServiceProcHandlerIMP::onIsBeautyEnabled(const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsBeautyEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support beauty", false);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onSetBeautyValue(int value, const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onSetBeautyValue value : " << value << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SDK_SERVICE_NOTSUPPORT, "Beauty service dont support", false);
        } else {
            do {
                INEPreRoomService* preRoomService = GlobalManager::getInstance()->getPreRoomService();
                if (!preRoomService)
                    break;

                auto beautyController = preRoomService->getPreRoomBeautyController();
                if (!beautyController)
                    break;

                beautyController->setBeautyFaceValue(value, true);
                if (cb)
                    cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
                return;
            } while (true);

            if (cb)
                cb(NS_I_NEM_SDK::ERROR_CODE_UNEXPECTED, "beauty not initialize", false);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onGetBeautyValue(const nem_sdk_interface::NESettingsService::NEIntCallback& cb) {
    YXLOG_API(Info) << "Received onGetBeautyValue." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {

        if (GlobalManager::getInstance()->getGlobalConfig()->isBeautySupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_SDK_SERVICE_NOTSUPPORT, "Beauty service dont support", 0);
        } else {
            int value = 0;
            do {
                INEPreRoomService* preRoomService = GlobalManager::getInstance()->getPreRoomService();
                if (!preRoomService)
                    break;

                auto beautyController = preRoomService->getPreRoomBeautyController();
                if (!beautyController)
                    break;

                value = beautyController->getBeautyFaceValue();
                if (cb)
                    cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", value);
                return;
            } while (true);

            if (cb)
                cb(NS_I_NEM_SDK::ERROR_CODE_UNEXPECTED, "beauty not initialize", value);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsLiveEnabled(const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsLiveEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isLiveStreamSupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support live", false);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onGetHistoryMeeting(const nem_sdk_interface::NESettingsService::NEHistoryMeetingCallback& cb) {
    YXLOG_API(Info) << "Received onGetHistoryMeeting." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        NS_I_NEM_SDK::NEHistoryMeetingItem item;
        item.meetingId = ConfigManager::getInstance()->getValue("localLastConferenceId", "").toString().toStdString();
        item.meetingUniqueId = ConfigManager::getInstance()->getValue("localLastMeetingUniqueId", "").toString().toLong();
        item.nickname = ConfigManager::getInstance()->getValue("localLastNickname", "").toString().toStdString();
        item.subject = ConfigManager::getInstance()->getValue("localLastMeetingTopic", "").toString().toStdString();
        item.password = ConfigManager::getInstance()->getValue("localLastMeetingPassword", "").toString().toStdString();
        item.shortMeetingId = ConfigManager::getInstance()->getValue("localLastMeetingshortId", "").toString().toStdString();
        item.sipId = ConfigManager::getInstance()->getValue("localLastSipId", "").toString().toStdString();
        std::list<NS_I_NEM_SDK::NEHistoryMeetingItem> list;
        list.push_back(item);
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", list);
    });
}

void NESettingsServiceProcHandlerIMP::onIsWhiteboardEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsWhiteboardEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isWhiteboardSupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support whiteboard", false);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onIsCloudRecordEnabled(const nem_sdk_interface::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsRecordEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        if (GlobalManager::getInstance()->getGlobalConfig()->isCloudRecordSupported() == false) {
            cb(NS_I_NEM_SDK::ERROR_CODE_FAILED, "not support record", false);
        } else {
            cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", true);
        }
    });
}

void NESettingsServiceProcHandlerIMP::onSetTurnOnMyVideoWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyVideoWhenJoinMeeting: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setEnableVideoAfterJoin(bOn);
    });
}

void NESettingsServiceProcHandlerIMP::onIsTurnOnMyVideoWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyVideoWhenJoinMeeting." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableVideoAfterJoin()); });
}

void NESettingsServiceProcHandlerIMP::onSetTurnOnMyAudioWhenJoinMeeting(bool bOn, const NS_I_NEM_SDK::NEEmptyCallback& cb) {
    YXLOG_API(Info) << "Received onSetTurnOnMyAudioWhenJoinMeeting: " << bOn << YXLOGEnd;
    Invoker::getInstance()->execute([=]() {
        cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "");
        SettingsManager::getInstance()->setEnableAudioAfterJoin(bOn);
    });
}

void NESettingsServiceProcHandlerIMP::onIsTurnOnMyAudioWhenJoinMeetingEnabled(const NS_I_NEM_SDK::NESettingsService::NEBoolCallback& cb) {
    YXLOG_API(Info) << "Received onIsTurnOnMyAudioWhenJoinMeetingEnabled." << YXLOGEnd;
    Invoker::getInstance()->execute([=]() { cb(NS_I_NEM_SDK::ERROR_CODE_SUCCESS, "", SettingsManager::getInstance()->enableAudioAfterJoin()); });
}
