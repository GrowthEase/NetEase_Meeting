/**
 * @file stat_event_interface.h
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief 上报事件的基础抽象
 * @version 0.1
 * @date 2023-06-20
 *
 * Copyright (c) 2023 NetEase
 *
 */
#ifndef STAT_EVENT_INTERFACE_H_
#define STAT_EVENT_INTERFACE_H_

#include <QDateTime>
#include <string>

class IStatEvent {
public:
    virtual ~IStatEvent() = default;
    virtual std::string GetEventName() const = 0;
    virtual std::string GetEventContent() const = 0;
    virtual std::string GetEventUUID() const = 0;
    virtual time_t GetStartTime() const = 0;
    virtual time_t GetEndTime() const = 0;
    virtual uint32_t GetDuration() const = 0;
    virtual bool IsSucceed() const = 0;
    virtual int32_t GetResultCode() const = 0;
    virtual std::string GetParameters() const = 0;
    virtual void FinalEvent() = 0;
};

class StatEventBase : public IStatEvent {
public:
    StatEventBase() = default;
    ~StatEventBase() override = default;
    std::string GetEventName() const override { return OnGetEventName(); }
    std::string GetEventContent() const override { return OnGetEventContent(); }
    std::string GetEventUUID() const override { return OnGetEventUUID(); }
    time_t GetStartTime() const override { return OnGetStartTime(); }
    time_t GetEndTime() const override { return OnGetEndTime(); }
    uint32_t GetDuration() const override { return OnGetEndTime() - OnGetStartTime(); }
    bool IsSucceed() const override { return OnGetSucceed(); }
    int32_t GetResultCode() const override { return OnGetResultCode(); }
    std::string GetParameters() const override { return OnGetParameters(); }
    void FinalEvent() override { OnFinalEvent(); }

protected:
    virtual std::string OnGetEventName() const { return ""; }
    virtual std::string OnGetEventContent() const { return ""; }
    virtual std::string OnGetEventUUID() const { return ""; }
    virtual time_t OnGetStartTime() const { return 0; }
    virtual time_t OnGetEndTime() const { return 0; }
    virtual bool OnGetSucceed() const { return false; }
    virtual int32_t OnGetResultCode() const { return 0; }
    virtual std::string OnGetParameters() const { return ""; }
    virtual void OnFinalEvent() {}
};

class IMeetingStep {
public:
    IMeetingStep() = default;
    virtual ~IMeetingStep() = default;
    virtual std::string GetStepName() const = 0;
    virtual std::string GetStepMessage() const = 0;
    virtual time_t GetStartTime() const = 0;
    virtual time_t GetEndTime() const = 0;
    virtual int32_t GetResultCode() const = 0;
    virtual std::string GetStepParameters() const = 0;
    virtual std::string GetStepRequestID() const = 0;
    virtual std::string GetStepContent() const = 0;
    virtual void SetStepIndex(std::size_t index) = 0;
    virtual uint8_t GetStepIndex() const = 0;
    virtual qint32 GetServerCost() const = 0;
};

static const char* kMeetingEventStepKeyStep = "step";
static const char* kMeetingEventStepKeyMessage = "message";
static const char* kMeetingEventStepKeyStartTime = "startTime";
static const char* kMeetingEventStepKeyEndTime = "endTime";
static const char* kMeetingEventStepKeyDuration = "duration";
static const char* kMeetingEventStepKeyResultCode = "code";
static const char* kMeetingEventStepKeyIndex = "index";
static const char* kMeetingEventStepKeyParameters = "params";
static const char* kMeetingEventStepKeyRequestID = "requestId";
static const char* kMeetingEventStepKeyServerCost = "serverCost";

class MeetingEventStepBase : public IMeetingStep {
public:
    MeetingEventStepBase(const std::string& stepName)
        : step_name_(stepName) {
        start_time_ = QDateTime::currentMSecsSinceEpoch();
    }
    ~MeetingEventStepBase() override = default;
    std::string GetStepName() const override { return step_name_; }
    void SetStepMessage(const std::string& message) { step_message_ = message; }
    std::string GetStepMessage() const override { return step_message_; }
    void SetStartTime(time_t startTime) { start_time_ = startTime; }
    time_t GetStartTime() const override { return start_time_; }
    void SetEndTime(time_t endTime) { end_time_ = endTime; }
    time_t GetEndTime() const override { return end_time_; }
    void SetResultCode(int32_t resultCode) { result_code_ = resultCode; }
    int32_t GetResultCode() const override { return result_code_; }
    std::string GetStepParameters() const override { return parameters_; }
    void SetStepRequestID(const std::string& requestID) { request_id_ = requestID; }
    std::string GetStepRequestID() const override { return request_id_; }
    void SetStepIndex(std::size_t index) override { step_index_ = index; }
    uint8_t GetStepIndex() const override { return step_index_; }
    void SetServerCost(qint32 serverCost) { server_cost_ = serverCost; }
    qint32 GetServerCost() const override { return server_cost_; }
    std::string GetStepContent() const override {
        QJsonObject values;
        values[kMeetingEventStepKeyStep] = QString::fromStdString(GetStepName());
        values[kMeetingEventStepKeyStartTime] = static_cast<int64_t>(GetStartTime());
        values[kMeetingEventStepKeyEndTime] = static_cast<int64_t>(GetEndTime());
        values[kMeetingEventStepKeyDuration] = static_cast<int64_t>(GetEndTime() - GetStartTime());
        values[kMeetingEventStepKeyResultCode] = GetResultCode();
        values[kMeetingEventStepKeyIndex] = GetStepIndex();
        if (!GetStepParameters().empty())
            values[kMeetingEventStepKeyParameters] = QString::fromStdString(GetStepParameters());
        if (!GetStepMessage().empty())
            values[kMeetingEventStepKeyMessage] = QString::fromStdString(GetStepMessage());
        if (!GetStepRequestID().empty())
            values[kMeetingEventStepKeyRequestID] = QString::fromStdString(GetStepRequestID());
        if (GetServerCost() > 0)
            values[kMeetingEventStepKeyServerCost] = GetServerCost();
        QJsonDocument doc(values);
        QString valuesString = doc.toJson(QJsonDocument::Compact);
        return valuesString.toStdString();
    }

private:
    std::string step_name_;
    std::string step_content_;
    std::string step_message_;
    time_t start_time_{0};
    time_t end_time_{0};
    int32_t result_code_{0};
    std::string parameters_;
    std::string request_id_;
    std::size_t step_index_{0};
    qint32 server_cost_{0};
};

#endif  // STAT_EVENT_INTERFACE_H_
