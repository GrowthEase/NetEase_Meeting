// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>

struct BaseHistoryMeetingInfo {
    QString meetingID;
    QString meetingSuject;
};

struct HistoryMeetingInfo : public BaseHistoryMeetingInfo {
    bool isCollect;
    qint64 meetingUniqueID;
    qint64 meetingJoinTime;
    qint64 meetingStartTime;
    QString meetingCreator;
};

class DatabaseManager {
public:
    static DatabaseManager* getInstance() {
        static QMutex mutex;
        if (!m_instance) {
            QMutexLocker locker(&mutex);
            if (!m_instance) {
                m_instance = new DatabaseManager;
            }
        }
        return m_instance;
    }

    bool connectDB(const QString& path);
    void disconnectDB();
    bool createHistoryTable();
    bool addHistoryMeetingInfo(const HistoryMeetingInfo& info);
    bool searchHistoryByUniqueId(qint64 lastTimestamp, QVector<HistoryMeetingInfo>& infos);
    bool updateHistoryCollectField(qint64 meetingUniqueID, bool isCollect);
    bool updateHistoryJoinTimeField(qint64 meetingUniqueID, qint64 meetingJoinTime);
    bool searchAllCollectList(QVector<HistoryMeetingInfo>& infos);
    bool searchBaseHistoryInfoByMeeingId(int count, qint64 lastTimestamp, QVector<BaseHistoryMeetingInfo>& infos);

private:
    DatabaseManager();

private:
    QSqlDatabase m_db;
    static DatabaseManager* m_instance;
};

#endif  // DATABASEMANAGER_H
