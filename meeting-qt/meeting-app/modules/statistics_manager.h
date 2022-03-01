/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef STATISTICSMANAGER_H
#define STATISTICSMANAGER_H

#include <QObject>

class StatisticsManager : public QObject
{
    Q_OBJECT
public:
    explicit StatisticsManager(QObject *parent = nullptr);

signals:

public slots:
    /**
     * @brief meetingStatistics
     *  前端上报打点统计数据
     * @param eventName  event  名称
     * @param module     模块
     * @param params     具体参数
     */
    void meetingStatistics(const QString& eventName, const QString& module, const QJsonObject& params = QJsonObject());

};

#endif // STATISTICSMANAGER_H
