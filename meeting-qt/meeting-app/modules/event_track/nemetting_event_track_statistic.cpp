/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "modules/event_track/nemetting_event_track_statistic.h"
#include <QDateTime>
#include <QJsonArray>
#include <QNetworkInterface>
#include <QSysInfo>
#include "modules/config_manager.h"
#include "modules/sys_info.h"
#include "string_converter.h"
#include "version.h"

Q_DECLARE_METATYPE(__EventTrackStatistic::EventTrackStatisticClosure)
const std::string NEMeetinEventTrackDataBase::kEVENTTAG = "event";
std::once_flag NEMeetinEventTrackDataBase::static_data_once_flag_;
NEMeetinEventTrackDataStaticData NEMeetinEventTrackDataBase::static_data_;
NEMeetinEventTrackDataBase::NEMeetinEventTrackDataBase(const std::string& event_type, bool can_merge_by_type, bool is_report_immediately)
    : _ParentType(kEVENTTAG, event_type)
    , can_merge_by_type_(can_merge_by_type)
    , is_report_immediately_(is_report_immediately)
    , time_(QDateTime::currentMSecsSinceEpoch())
    , meeting_id_("") {}
bool NEMeetinEventTrackDataBase::CanMergeByType() const {
    return can_merge_by_type_;
}
bool NEMeetinEventTrackDataBase::IsReportImmediately() const {
    return is_report_immediately_;
}
bool NEMeetinEventTrackDataBase::Fill(QJsonObject& root) const {
    bool ret = false;
    QJsonObject event_tag_object = root[kEVENTTAG.c_str()].toObject();
    if (CanMergeByType()) {
        QJsonObject event_item_object;
        FillStaticData(event_item_object);
        FillDynamicData(event_item_object);
        ret = OnFill(event_item_object);

        QJsonArray event_item_array_object = event_tag_object[event_type_.c_str()].toArray();

        event_item_array_object.append(event_item_object);
        event_tag_object[event_type_.c_str()] = event_item_array_object;
        root[kEVENTTAG.c_str()] = event_tag_object;
    } else {
        QJsonObject event_type_object;
        FillStaticData(event_type_object);
        FillDynamicData(event_type_object);
        ret = OnFill(event_type_object);
        event_tag_object[event_type_.c_str()] = event_type_object;
        root[kEVENTTAG.c_str()] = event_tag_object;
    }
    return ret;
}
void NEMeetinEventTrackDataBase::FillStaticData(QJsonObject& itme) const {
    std::call_once(static_data_once_flag_, [&]() {
        static_data_.platform_ = "PC";
        static_data_.device_id_ = QString(QSysInfo::machineUniqueId()).replace("-", "");
        static_data_.client_ = "meeting";
        static_data_.os_ver_ = QSysInfo::prettyProductName();
        static_data_.manufacturer_ = SysInfo::GetSystemManufacturer();
        static_data_.model_ = SysInfo::GetSystemProductName();
        static_data_.app_key_ = "";
        static_data_.version_name_ = APPLICATION_VERSION;
        static_data_.sdk_version_ = NERTC_SDK_VERSION;
    });

    itme["platform"] = static_data_.platform_;
    itme["sdk_device_id"] = static_data_.device_id_;
    // itme["client"] = static_data_.client_;
    itme["os_ver"] = static_data_.os_ver_;
    itme["manufacturer"] = static_data_.manufacturer_;
    itme["model"] = static_data_.model_;
    itme["app_key"] = static_data_.app_key_;
    itme["version_name"] = static_data_.version_name_;
    itme["sdk_version"] = static_data_.sdk_version_;
    itme["occur_time"] = (qint64)time_;
    itme["meeting_id"] = meeting_id_;
}
void NEMeetinEventTrackDataBase::FillDynamicData(QJsonObject& itme) const {
    NEMeetinEventTrackDataDynamicData dynamic_data;
    dynamic_data.uid_ = "";       // TODO
    dynamic_data.nickname_ = "";  // TODO
    // dynamic_data.meeting_id_ = DataCenter::getInstance()->conferenceId();
    QString net_type;
    auto all_net_i = QNetworkInterface::allInterfaces();
    for (auto it : all_net_i) {
        if (it.isValid() && (it.flags() & QNetworkInterface::IsUp) && (it.flags() & QNetworkInterface::IsRunning)) {
            switch (it.type()) {
                case QNetworkInterface::Wifi: {
                    if (!net_type.isEmpty())
                        net_type.append("/");
                    net_type.append("Wifi");
                } break;
                case QNetworkInterface::Ethernet: {
                    if (!net_type.isEmpty())
                        net_type.append("/");
                    net_type.append("Ethernet");
                } break;
                default:
                    break;
            }
        }
    }
    if (net_type.isEmpty())
        net_type = "Unknown";
    dynamic_data.network_type_ = net_type;
    itme["uid"] = dynamic_data.uid_;
    itme["nickname"] = dynamic_data.nickname_;
    // itme["meeting_id"] = dynamic_data.meeting_id_;
    itme["network_type"] = dynamic_data.network_type_;
}
const std::string NEMeetinEventTrackData_Action::kEVENTTYPE = "action";
std::shared_ptr<NEMeetinEventTrackData_Action> NEMeetinEventTrackData_Action::CreateAction(const std::string& action_name,
                                                                                           const std::string& module /* = "meeting"*/) {
    return std::make_shared<NEMeetinEventTrackData_Action>(action_name, module);
}
NEMeetinEventTrackData_Action::NEMeetinEventTrackData_Action(const std::string& action_name, const std::string& module)
    : NEMeetinEventTrackDataBase(kEVENTTYPE, true, false)
    , action_name_(action_name)
    , module_(module) {}
bool NEMeetinEventTrackData_Action::OnFill(QJsonObject& itme) const {
    itme["action_name"] = action_name_.c_str();
    itme["component"] = module_.c_str();
    auto data_key_list = event_data_items_.keys();
    for (auto it : data_key_list)
        itme[it] = event_data_items_.value(it);
    return true;
}
NEMeetingEventTrackStatistic* NEMeetingEventTrackStatistic::instance_ = nullptr;
QString NEMeetingEventTrackStatistic::EventReportHttpRequest::kEventReportMainUrl = "";
QString NEMeetingEventTrackStatistic::EventReportHttpRequest::kEventReportSubUrl = "statics/report/common/form";
IEventTrackStatistic<QJsonObject>* NEMeetingEventTrackStatistic::getInstance() {
    static QMutex mutex;
    if (instance_ == nullptr) {
        QMutexLocker locker(&mutex);
        if (instance_ == nullptr) {
            instance_ = new NEMeetingEventTrackStatistic();
            instance_->Init();
        }
    }
    return &instance_->event_track_statistic_imp_;
}
void NEMeetingEventTrackStatistic::Init() {
    //    moveToThread(&runner_);
    //    event_track_statistic_timer_.moveToThread(&runner_);
    //    http_manager_.moveToThread(&runner_);
    event_track_statistic_imp_.SetRequestURLGettor([]() { return ""; });
    event_track_statistic_imp_.SetCacheReportInfo(1000 * 60, 10);
    event_track_statistic_imp_.SetHttpRequestHeadFiller([](std::map<std::string, std::string>& head) {
        head.clear();
        head["Content-Type"] = "application/json";
        head["ver"] = "1.0";
        head["sdktype"] = "meeting";
        head["appkey"] = "";  // TODO
    });
    event_track_statistic_imp_.SetHttpRequestor(
        [this](const __EventTrackStatistic::HttpRequest& request, const __EventTrackStatistic::HttpResponceCallback& reply_cb) {
            EventReportHttpRequest roprt_request(request);
            http_manager_.postRequest(roprt_request, [reply_cb](int code, QJsonObject /*obj*/) {
                if (reply_cb != nullptr)
                    reply_cb(code, "", "");
            });
        });
    __EventTrackStatistic::Timer timer;
    timer.fun_start_timer = [this](int time_out, __EventTrackStatistic::EventTrackStatisticClosure cb) {
        event_track_statistic_timer_.StartTimer(time_out, cb);
    };
    timer.fun_stop_timer = [this]() { event_track_statistic_timer_.StopTimer(); };
    event_track_statistic_imp_.SetTimer(timer);
    event_track_statistic_imp_.SetFormatObjectToStringFunction(
        [](const QJsonObject& object) { return NEMeeting::utils::QJsonObjectToStdStringUTF8(object); });
    event_track_statistic_imp_.AttachStop([]() {
        //        emit runner_.stopRunner(this);
        //        runner_.wait(1000);
    });

    //    connect(&runner_,&NEMeetingEventTrackStatisticRunner::started,this,[this](){
    //        event_track_statistic_imp_.Start();
    //    });
    //    event_track_statistic_imp_.SetAsyncTaskRunner([this](const __EventTrackStatistic::EventTrackStatisticClosure& task){
    //        emit runner_.runTask(task);
    //    });
    //    runner_.start();
    event_track_statistic_imp_.Start();
}

NEMeetingEventTrackStatisticRunner::NEMeetingEventTrackStatisticRunner() {
    qRegisterMetaType<NEMeetingEventTrackStatistic*>();
    qRegisterMetaType<__EventTrackStatistic::EventTrackStatisticClosure>();
    connect(
        this, &NEMeetingEventTrackStatisticRunner::stopRunner, this,
        [this](NEMeetingEventTrackStatistic* nem_tracker_statistic) {
            nem_tracker_statistic->event_track_statistic_timer_.StopTimer();
            exit(0);
        },
        Qt::QueuedConnection);
    connect(this, SIGNAL(runTask(const __EventTrackStatistic::EventTrackStatisticClosure&)), this,
            SLOT(onRunTask(const __EventTrackStatistic::EventTrackStatisticClosure&)), Qt::QueuedConnection);
}
