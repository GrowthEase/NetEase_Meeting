/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef NEMETTING_EVENT_TRACK_STATISTIC_H
#define NEMETTING_EVENT_TRACK_STATISTIC_H
#include "event_track_statistic.h"
#include "nemeeting_event_track_static_strings.h"
#include <QJsonObject>
#include <QTimerEvent>
#include <QThread>
#include "modules/base/http_manager.h"
#include "modules/base/http_request.h"
#include "string_converter.h"

class NEMeetinEventTrackDataStaticData
{
public:
    QString platform_;
    QString device_id_;
    QString client_;
    QString os_ver_;
    QString manufacturer_;
    QString model_;
    QString app_key_;
    QString version_name_;
    QString sdk_version_;
};
class NEMeetinEventTrackDataDynamicData
{
public:
    QString network_type_;
    QString nickname_;
    QString uid_;
    //QString meeting_id_;
};

class NEMeetinEventTrackDataBase : public EventTrackDataBase<QJsonObject>
{
    using _ParentType = EventTrackDataBase<QJsonObject>;
public:
    NEMeetinEventTrackDataBase(const std::string& event_type,bool can_merge_by_type,bool is_report_immediately);
public:   
    virtual bool CanMergeByType() const  override;
    virtual bool IsReportImmediately() const  override;
    virtual bool Fill(QJsonObject& root) const override;
protected:
    virtual bool OnFill(QJsonObject& itme) const = 0;
private:
    void FillStaticData(QJsonObject& itme) const;
    void FillDynamicData(QJsonObject& itme) const ;
protected:
    static const std::string kEVENTTAG;
    bool can_merge_by_type_;
    bool is_report_immediately_;
    uint64_t time_;
    QString meeting_id_;
private:
    static std::once_flag static_data_once_flag_;
    static NEMeetinEventTrackDataStaticData static_data_;
};
class NEMeetinEventTrackData_Action : public NEMeetinEventTrackDataBase,public std::enable_shared_from_this<NEMeetinEventTrackData_Action>
{
public:
    static std::shared_ptr<NEMeetinEventTrackData_Action> CreateAction(const std::string& action_name,const std::string& module="meeting");
public:
    NEMeetinEventTrackData_Action(const std::string& action_name,const std::string& module);
    template<typename TValue>
    std::shared_ptr<NEMeetinEventTrackData_Action> AddData(const std::string& key,const TValue& value){
        event_data_items_[key.c_str()] = value;
        return this->shared_from_this();
    }
    template<>
    std::shared_ptr<NEMeetinEventTrackData_Action> AddData(const std::string& key,const std::string& value){
        event_data_items_[key.c_str()] = value.c_str();
        return this->shared_from_this();
    }
    std::shared_ptr<NEMeetinEventTrackData_Action> AddData(const QJsonObject& params) {
        event_data_items_ = params;
        return this->shared_from_this();
    }
protected:
    virtual bool OnFill(QJsonObject& itme) const override;
protected:
    static const std::string kEVENTTYPE;
    std::string action_name_;
    std::string module_;
    QJsonObject event_data_items_;
};
using __EventTrackStatistic = IEventTrackStatistic<QJsonObject>;
class EventTrackStatisticTimer : public QTimer
{
    Q_OBJECT
public:
    EventTrackStatisticTimer() : QTimer(nullptr),time_out_cb_(nullptr){
        connect(this, SIGNAL(timeout()), this, SLOT(onTimeout()));
    }
public:
    void StartTimer(int time_out,__EventTrackStatistic::EventTrackStatisticClosure time_out_cb){
        if(time_out_cb == nullptr)
            return;
        StopTimer();
        time_out_cb_ = time_out_cb;
        start(time_out);
    }
    void StopTimer(){
        if(isActive())
            stop();

    }
  private slots:
    void onTimeout() {
        if(time_out_cb_ != nullptr)
            time_out_cb_();
    }
private:
    __EventTrackStatistic::EventTrackStatisticClosure time_out_cb_;
};
class NEMeetingEventTrackStatistic;
class NEMeetingEventTrackStatisticRunner : public QThread
{
    Q_OBJECT
public:
    NEMeetingEventTrackStatisticRunner();

public: signals:
    void stopRunner(NEMeetingEventTrackStatistic* nem_tracker_statistic);
    void runTask(const __EventTrackStatistic::EventTrackStatisticClosure& task);
private slots:
    void onRunTask(const __EventTrackStatistic::EventTrackStatisticClosure& task){
        if(task != nullptr)
            task();
    }
};

class NEMeetingEventTrackStatistic: public QObject
{
    Q_OBJECT
    NEMeetingEventTrackStatistic() : QObject(nullptr){}
    class EventReportHttpRequest: public IHttpRequest
    {
    public:
        EventReportHttpRequest(__EventTrackStatistic::HttpRequest req) :
            IHttpRequest(kEventReportSubUrl, kEventReportMainUrl){
            for(auto it : req->head_list_)
            {
                setRawHeader(it.first.c_str(),it.second.c_str());
            }
            QByteArray byteArray = req->body_.c_str();
            setParams(byteArray);
        }
    private:
        static QString kEventReportMainUrl;
        static QString kEventReportSubUrl;
    };
public:
    static IEventTrackStatistic<QJsonObject>* getInstance();
    friend class NEMeetingEventTrackStatisticRunner;

private:
    void Init();
private:
    static NEMeetingEventTrackStatistic* instance_;
    EventTrackStatisticImp<QJsonObject> event_track_statistic_imp_;
    HttpManager http_manager_;
    EventTrackStatisticTimer event_track_statistic_timer_;
    NEMeetingEventTrackStatisticRunner runner_;
};

class EventTrackHelper
{
public:
    static void CreateEventTrack(const QString& action_name, const QString& module = "meeting", const QString& key = "", const QString& value = "") {
        auto action = NEMeetinEventTrackData_Action::CreateAction(NEMeeting::utils::QStringToStdStringUTF8(action_name),
                                                                  NEMeeting::utils::QStringToStdStringUTF8(module));
        if (!key.isEmpty() && !value.isEmpty()) {
            action->AddData(NEMeeting::utils::QStringToStdStringUTF8(key),
                            NEMeeting::utils::QStringToStdStringUTF8(value));
        }
        NEMeetingEventTrackStatistic::getInstance()->AddEventTrackData(action);
    }
    static void CreateEventTrack(const QString& action_name, const QString& module, const QJsonObject& params) {
        auto action = NEMeetinEventTrackData_Action::CreateAction(NEMeeting::utils::QStringToStdStringUTF8(action_name),
                                                                  NEMeeting::utils::QStringToStdStringUTF8(module));
        action->AddData(params);
        NEMeetingEventTrackStatistic::getInstance()->AddEventTrackData(action);
    }
    template<typename TValue>
    static void CreateEventTrack(const QString& action_name, const QString& module, const QString& key, const TValue& params) {
        auto action = NEMeetinEventTrackData_Action::CreateAction(NEMeeting::utils::QStringToStdStringUTF8(action_name),
                                                                  NEMeeting::utils::QStringToStdStringUTF8(module));
        action->AddData(key, params);
        NEMeetingEventTrackStatistic::getInstance()->AddEventTrackData(action);
    }
};

#endif // NEMETTING_EVENT_TRACK_STATISTIC_H
