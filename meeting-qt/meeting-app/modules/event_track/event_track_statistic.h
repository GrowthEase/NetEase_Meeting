/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef EVENT_TRACK_STATISTIC_H_
#define EVENT_TRACK_STATISTIC_H_
#include <string>
#include <map>
#include <list>
#include <functional>
#include <mutex>
#include <atomic>
#include <QtCore>

template<typename TEventFromatObject>
class IEventTrackData
{
public:
    virtual std::string EventTag() const = 0;
    virtual std::string EventType() const = 0;
    virtual bool CanMergeByType() const = 0;
    virtual bool IsReportImmediately() const = 0;
    virtual bool Fill(TEventFromatObject&) const = 0;
};
template<typename TEventFromatObject>
using EventTrackData = std::shared_ptr<IEventTrackData<TEventFromatObject>>;

template<typename TEventFromatObject>
using EventTrackList = std::list<EventTrackData<TEventFromatObject>>;

template<typename TEventFromatObject>
class IEventTrackStatistic
{
public:
    using EventTrackStatisticClosure = std::function<void(void)>;
    class HttpRequestInfo
    {
    public:
        HttpRequestInfo(const std::string& url, const std::string& body) :
            url_(url), body_(body) {
        }
        HttpRequestInfo(std::string&& url, std::string&& body) :
            url_(std::move(url)), body_(std::move(body)) {
        }
        HttpRequestInfo(const std::string& url) :
            url_(url), body_(""){
        }
        HttpRequestInfo(std::string&& url) :
            url_(std::move(url)), body_("") {
        }
    public:
        std::string url_;
        std::map<std::string,std::string> head_list_;
        std::string body_;
    };
    class Timer
    {
    public:
        std::function<void(int, EventTrackStatisticClosure)> fun_start_timer;
        std::function<void()> fun_stop_timer;
    };
    using HttpRequest = std::shared_ptr<HttpRequestInfo>;
    using AsyncTaskRunner = std::function<void(const EventTrackStatisticClosure&)>;
    using RequestURLGettor = std::function<std::string()>;
    using HttpResponceCallback = std::function<void(int reply_code, const std::string & reply_head, const std::string & reply_content)>;
    using HttpRequestHeadFiller = std::function<void(std::map<std::string,std::string>&)>;
    using HttpRequestor = std::function<void(const HttpRequest & request, const HttpResponceCallback & reply_cb)>;
    using FormatObjectToStringFunction = std::function<std::string(const TEventFromatObject& object)>;
public:
    virtual void SetCacheReportInfo(int cache_time_block, size_t cache_limit) = 0;
    virtual void SetAsyncTaskRunner(const AsyncTaskRunner& runner) = 0;
    virtual void SetRequestURLGettor(const RequestURLGettor& url_gettor) = 0;
    virtual void SetHttpRequestor(const HttpRequestor& requestor) = 0;
    virtual void SetHttpRequestHeadFiller(const HttpRequestHeadFiller& filler) = 0;
    virtual void SetTimer(Timer timer) = 0;
    virtual void SetFormatObjectToStringFunction(const FormatObjectToStringFunction& function) = 0;
    virtual void AddEventTrackData(const EventTrackData<TEventFromatObject>& data) = 0;
    virtual void Start() = 0;
    virtual void Stop() = 0;
    virtual void AttachStop(const EventTrackStatisticClosure&) = 0;
};


template<typename TEventFromatObject>
class EventTrackDataBase : public IEventTrackData<TEventFromatObject>
{
public:
    EventTrackDataBase(const std::string& event_tag,const std::string& event_type) :
        event_tag_(event_tag), event_type_(event_type){
    }
    EventTrackDataBase(std::string&& event_tag, std::string&& event_type) :
        event_tag_(std::move(event_tag)), event_type_(std::move(event_type)) {
    }
public:
    virtual std::string EventTag() const override{
        return event_tag_;
    }
    virtual std::string EventType() const override {
        return event_type_;
    }
protected:
    std::string event_tag_;
    std::string event_type_;
};
template<typename TEventFromatObject>
class EventTrackStatisticImp : public IEventTrackStatistic<TEventFromatObject>
{
    using ParentType = IEventTrackStatistic<TEventFromatObject>;
    using ThisType = EventTrackStatisticImp<TEventFromatObject>;
    class Reportor;
    friend class Reportor;
    class Reportor
    {
        friend class EventTrackStatisticImp;
    public:
        Reportor(ThisType* imp) : _this(imp){
            if(_this->timer_.fun_stop_timer != nullptr)
                _this->timer_.fun_stop_timer();            
        }
        ~Reportor() {           
            std::lock_guard<std::recursive_mutex> auto_lock(_this->event_track_data_lock_);
            _this->event_track_data_.clear();
            if(_this->timer_.fun_start_timer != nullptr){
                auto* imp = _this;
                _this->timer_.fun_start_timer(_this->cache_time_block_,[imp]() {
                    Reportor(imp).Report();
                });
            }
        }
    private:
        void Report() const{
            std::lock_guard<std::recursive_mutex> auto_lock(_this->event_track_data_lock_);
            if (_this->event_track_data_.size() == 0)
                return;
            TEventFromatObject format_object;
            for (auto it : _this->event_track_data_)
                it->Fill(format_object);
            _this->Report(format_object);
        }
    private:
        ThisType* _this;
    };
public:
    EventTrackStatisticImp() :
        running_(false),
        async_task_runner_(nullptr),
        url_gettor_(nullptr),
        http_requestor_(nullptr),
        http_request_head_filler_(nullptr),
        format_object_to_string_function_(nullptr),
        stop_callback_(nullptr),
        cache_limit_(10),
        cache_time_block_(10*1000){
    }
    ~EventTrackStatisticImp() {
        Stop();
    }
public:
    virtual void SetCacheReportInfo(int cache_time_block, size_t cache_limit)  override {
        cache_time_block_ = cache_time_block;
        cache_limit_ = cache_limit;
    }
    virtual void SetAsyncTaskRunner(const typename ParentType::AsyncTaskRunner& runner)  override {
        async_task_runner_ = runner;
    }
    virtual void SetRequestURLGettor(const typename ParentType::RequestURLGettor& url_gettor) override {
        url_gettor_ = url_gettor;
    }
    virtual void SetHttpRequestor(const typename ParentType::HttpRequestor& requestor)  override {
        http_requestor_ = requestor;
    }
    virtual void SetHttpRequestHeadFiller(const typename ParentType::HttpRequestHeadFiller& filler)  override {
        http_request_head_filler_ = filler;
    }
    virtual void SetTimer(typename ParentType::Timer timer)  override {
        timer_ = timer;
    }
    virtual void SetFormatObjectToStringFunction(const typename ParentType::FormatObjectToStringFunction& function) override {
        format_object_to_string_function_ = function;
    }
    virtual void Start() override {
        running_ = true;
        Reportor(this).Report();
    }
    virtual void Stop() override {
        if (running_)
        {
            running_ = false;
            if(timer_.fun_stop_timer != nullptr)
                timer_.fun_stop_timer();
            if(stop_callback_ != nullptr)
                stop_callback_();
            std::lock_guard<std::recursive_mutex> auto_lock(event_track_data_lock_);
            event_track_data_.clear();
        }
    }
    virtual void AttachStop(const typename ParentType::EventTrackStatisticClosure& stop_callback) override{
        stop_callback_ = stop_callback;
    }
    virtual void AddEventTrackData(const EventTrackData<TEventFromatObject>& data)  override {
        auto task = [this, data]() {
            if (data->IsReportImmediately()) {
                TEventFromatObject format_object;
                data->Fill(format_object);
                Report(format_object);
            }
            else	{
                std::lock_guard<std::recursive_mutex> auto_lock(event_track_data_lock_);
                event_track_data_.emplace_back(data);
                if (event_track_data_.size() >= cache_limit_) {
                    Reportor(this).Report();
                }
                else
                {

                }
            }
        };
        if (async_task_runner_ != nullptr)
            async_task_runner_(task);
        else
            task();
    }
private:
    void Report(const TEventFromatObject& format_object) {
        auto task = [this,format_object](){
            typename ParentType::HttpRequest request = std::make_shared<typename ParentType::HttpRequestInfo>(url_gettor_ == nullptr ? "" : url_gettor_());
            if (http_request_head_filler_ != nullptr)
                http_request_head_filler_(request->head_list_);
            if (format_object_to_string_function_ != nullptr)
                request->body_ = format_object_to_string_function_(format_object);
            if (http_requestor_ != nullptr)
                http_requestor_(request, [](int, const std::string&, const std::string&) {
                });
        };
        if(async_task_runner_ != nullptr)
            async_task_runner_(task);
        else
            task();
    }
private:
    std::atomic_bool running_;
    std::recursive_mutex event_track_data_lock_;
    EventTrackList<TEventFromatObject> event_track_data_;
    typename ParentType::AsyncTaskRunner async_task_runner_;
    typename ParentType::RequestURLGettor url_gettor_;
    typename ParentType::HttpRequestor http_requestor_;
    typename ParentType::HttpRequestHeadFiller http_request_head_filler_;
    typename ParentType::Timer timer_;
    typename ParentType::FormatObjectToStringFunction format_object_to_string_function_;
    typename ParentType::EventTrackStatisticClosure stop_callback_;
    int cache_time_block_;
    size_t cache_limit_;
};
#endif //EVENT_TRACK_STATISTIC_H_
