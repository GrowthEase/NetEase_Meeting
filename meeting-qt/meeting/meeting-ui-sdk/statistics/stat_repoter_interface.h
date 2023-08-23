/**
 * @file stat_repoter_interface.h
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief 上报能力基础抽象，提供上报能力的基础接口，可继承后扩展为其他实现
 * @version 0.1
 * @date 2023-06-20
 *
 * Copyright (c) 2023 NetEase
 *
 */
#ifndef STAT_REPOTER_INTERFACE_H_
#define STAT_REPOTER_INTERFACE_H_

#include <memory>
#include "stat_event_interface.h"

class IStatReporterInterface {
public:
    virtual ~IStatReporterInterface() = default;
    virtual void AddEvent(const std::shared_ptr<IStatEvent>& event) = 0;
    virtual void RemoveEvent(const std::string& event_uuid) = 0;
};

class StatReporterBase : public IStatReporterInterface {
public:
    StatReporterBase() = default;
    ~StatReporterBase() override = default;
    void AddEvent(const std::shared_ptr<IStatEvent>& event) override { OnAddEvent(event); }
    void RemoveEvent(const std::string& event_uuid) override { OnRemoveEvent(event_uuid); }

protected:
    virtual void OnAddEvent(const std::shared_ptr<IStatEvent>& event) {}
    virtual void OnRemoveEvent(const std::string& event_uuid) {}
};

#endif  // STAT_REPOTER_INTERFACE_H_
