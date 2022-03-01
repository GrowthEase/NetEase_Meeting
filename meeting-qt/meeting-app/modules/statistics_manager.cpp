/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "statistics_manager.h"
#include "event_track/nemetting_event_track_statistic.h"

StatisticsManager::StatisticsManager(QObject *parent) : QObject(parent)
{

}

void StatisticsManager::meetingStatistics(const QString &eventName, const QString &module, const QJsonObject &params)
{
    qInfo() << __FUNCTION__ << eventName << module << params;
    auto action = NEMeetinEventTrackData_Action::CreateAction(NEMeeting::utils::QStringToStdStringUTF8(eventName),
                                                              NEMeeting::utils::QStringToStdStringUTF8(module));
    action->AddData(params);
    NEMeetingEventTrackStatistic::getInstance()->AddEventTrackData(action);
}
