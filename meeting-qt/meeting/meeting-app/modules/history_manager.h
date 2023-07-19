// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef HISTORYMANAGER_H
#define HISTORYMANAGER_H

#include <QJsonArray>
#include <QMutex>
#include "database_manager.h"

class HistoryManager : public QObject {
    Q_OBJECT
public:
    HistoryManager();
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChange)

    QVector<HistoryMeetingInfo> getHistoryMeetingList() const { return m_HistoryMeetingList; }
    QVector<HistoryMeetingInfo> getCollectMeetingList() const { return m_collectMeetingList; }

    void init(const QString& path);
    void addHistoryMeeting(const HistoryMeetingInfo& info);

    Q_INVOKABLE void refreshHistoryMeetingList();
    Q_INVOKABLE QJsonArray getRecentMeetingList();
    Q_INVOKABLE void clearRecentMeetingList();
    Q_INVOKABLE void refreshCollectMeetingList();
    Q_INVOKABLE bool collect(int index, qint64 meetingUniqueID);
    Q_INVOKABLE bool cancelCollectFromHistory(int index, qint64 meetingUniqueID);
    Q_INVOKABLE bool cancelCollectFromCollectList(int index, qint64 meetingUniqueID);

    int count() const { return m_count; }
    void setCount(int count) {
        m_count = count;
        emit countChange();
    }

signals:
    void refreshHistory();
    void historyChanged(int index);
    void collectChanged(int index);
    void countChange();
    void newHistoryAdd();

private:
    QVector<HistoryMeetingInfo> m_HistoryMeetingList;
    QVector<HistoryMeetingInfo> m_collectMeetingList;
    QVector<BaseHistoryMeetingInfo> m_recentMeetingList;
    int m_count = 0;
};

#endif  // HISTORYMANAGER_H
