﻿// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef UI_UTILS_DELEGATE_H_
#define UI_UTILS_DELEGATE_H_

#pragma once

#include "Core/Define.h"

namespace ui {

typedef std::function<bool(ui::EventArgs*)> EventCallback;

class CEventSource : public std::vector<EventCallback> {
public:
    CEventSource& operator+=(const EventCallback& item) {
        push_back(item);
        return *this;
    }

    bool operator()(ui::EventArgs* param) const {
        for (auto it = this->begin(); it != this->end(); it++) {
            if (!(*it)(param))
                return false;
        }
        return true;
    }
};

typedef std::map<EventType, CEventSource> EventMap;

}  // namespace ui

#endif  // UI_UTILS_DELEGATE_H_