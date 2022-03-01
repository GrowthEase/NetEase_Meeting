/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEM_SDK_INTERFACE_APP_PROCHANDLER_PREMEETING_PROCHANDLER_H_
#define NEM_SDK_INTERFACE_APP_PROCHANDLER_PREMEETING_PROCHANDLER_H_

#include "client_premeeting_service.h"
#include "pre_room_service_interface.h"


class NEPreMeetingServiceProcHandlerIMP : public QObject, public NS_I_NEM_SDK::NEPremeetingServiceProcHandler
{
    Q_OBJECT
public:
    NEPreMeetingServiceProcHandlerIMP(QObject* parent = nullptr);
public:
    virtual void onScheduleMeeting(const NS_I_NEM_SDK::NEMeetingItem& item, const NS_I_NEM_SDK::NEPreMeetingService::NEScheduleMeetingItemCallback& callback) override;
    virtual void onEditMeeting(const NS_I_NEM_SDK::NEMeetingItem& item, const NS_I_NEM_SDK::NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) override;
    virtual void onCancelMeeting(const int64_t&meetingUniqueId, const NS_I_NEM_SDK::NEPreMeetingService::NEOperateScheduleMeetingCallback& callback) override;
    virtual void onGetMeetingItemById(const int64_t&meetingUniqueId, const NS_I_NEM_SDK::NEPreMeetingService::NEScheduleMeetingItemCallback& callback) override;
    virtual void onGetMeetingList(std::list<NS_I_NEM_SDK::NEMeetingItemStatus> status, const NS_I_NEM_SDK::NEPreMeetingService::NEGetMeetingListCallback& callback) override;

public slots:
    void onScheduleOrEditMeeting(int errorCode, const QString& errorMessage,  const neroom::NERoomItem& info);
    void onQueryMeetingList(int errorCode, const QString& errorMessage, const QList<neroom::NERoomItem>& scheduledLists);
    void onMeetingStatusChanged(uint64_t uniqueMeetingId, int meetingStatus);

private:
    NS_I_NEM_SDK::NEPreMeetingService::NEScheduleMeetingItemCallback    m_scheduleMeetingCallback = nullptr;
    NS_I_NEM_SDK::NEPreMeetingService::NEOperateScheduleMeetingCallback m_editMeetingCallback = nullptr;
    NS_I_NEM_SDK::NEPreMeetingService::NEGetMeetingListCallback         m_getMeetingListCallback = nullptr;

};

#endif // NEM_SDK_INTERFACE_APP_PROCHANDLER_PREMEETING_PROCHANDLER_H_

