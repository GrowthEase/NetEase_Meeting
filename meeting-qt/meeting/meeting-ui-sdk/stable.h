// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef STABLE_H
#define STABLE_H

#if defined __cplusplus

// qt
#include <QCommandLineParser>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMutex>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickView>
#include <QScreen>
#include <QSharedMemory>
#include <QStandardPaths>
#include <QTextStream>
#include <QThread>
#include <QTimer>
#include <QTranslator>
#include <QVector>

// std
#include <functional>
#include <iostream>
#include <list>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

// third parties
#include "alog.h"
#define YXLOGEnd ALOGEnd
#define YXLOG(level) ALOG_DIY("ui", LogNormal, level)
#define YXLOG_API(level) ALOG_DIY("ui", LogApi, level)

#include "libyuv.h"

// ipc
#include "nemeeting_sdk_interface_include.h"

// application
#include "manager/config_manager.h"
#include "utils/invoker.h"
#include "utils/singleton.h"

#endif

#endif  // STABLE_H
