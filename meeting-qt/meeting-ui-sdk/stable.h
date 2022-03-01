/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef STABLE_H
#define STABLE_H

#if defined __cplusplus

// qt
#include <QDir>
#include <QTimer>
#include <QMutex>
#include <QThread>
#include <QScreen>
#include <QVector>
#include <QProcess>
#include <QDateTime>
#include <QQuickView>
#include <QJsonArray>
#include <QTextStream>
#include <QQuickStyle>
#include <QQmlContext>
#include <QTranslator>
#include <QJsonObject>
#include <QJsonDocument>
#include <QSharedMemory>
#include <QStandardPaths>
#include <QGuiApplication>
#include <QDesktopServices>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>

// std
#include <functional>
#include <iostream>
#include <vector>
#include <memory>
#include <string>
#include <mutex>
#include <list>
#include <map>

// third parties
//#define USE_GOOGLE_LOG
#ifdef USE_GOOGLE_LOG
#include "glog/logging.h"
#define YXLOGEnd ""
#define YXLOG LOG
#define YXLOG_API LOG
#else
#include "alog.h"
#define YXLOGEnd ALOGEnd
#define YXLOG(level) ALOG_DIY("ui", LogNormal, level)
#define YXLOG_API(level) ALOG_DIY("ui", LogApi, level)
#endif
#include "libyuv.h"

// ipc
#include "nemeeting_sdk_interface_include.h"

// application
#include "utils/singleton.h"
#include "utils/invoker.h"
#include "manager/config_manager.h"

#endif

#endif // STABLE_H
