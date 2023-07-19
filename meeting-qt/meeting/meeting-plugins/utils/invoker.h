// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_UTILS_INVOKER_H_
#define MEETING_PLUGINS_UTILS_INVOKER_H_

#include <QThread>

typedef std::function<void()> InvokerFunc;

class Invoker : public QObject {
    Q_OBJECT
public:
    explicit Invoker(QObject* parent = 0)
        : QObject(parent) {
        qRegisterMetaType<InvokerFunc>("InvokerFunc");
    }
    void execute(const InvokerFunc& func, bool block = false) {
        if (QThread::currentThread() == thread()) {
            func();
            return;
        }
        if (block) {
            metaObject()->invokeMethod(this, "onExecute", Qt::BlockingQueuedConnection, Q_ARG(InvokerFunc, func));
        } else {
            metaObject()->invokeMethod(this, "onExecute", Qt::QueuedConnection, Q_ARG(InvokerFunc, func));
        }
    }
private slots:
    void onExecute(const InvokerFunc& func) { func(); }
};

#endif  // MEETING_PLUGINS_UTILS_INVOKER_H_
