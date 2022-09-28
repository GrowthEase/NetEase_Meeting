// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include <QJsonArray>

#include "database_manager.h"
#include "history_manager.h"

HistoryManager::HistoryManager() {}

void HistoryManager::init(const QString& path) {
    QDir logDir;
    if (!logDir.exists(path))
        logDir.mkpath(path);

    QString dbPath = path + ("meeting.db");
    DatabaseManager::getInstance()->connectDB(dbPath);
    DatabaseManager::getInstance()->createHistoryTable();
}

void HistoryManager::refreshHistoryMeetingList() {
    m_HistoryMeetingList.clear();
    qint64 interval = (qint64)30 * 24 * 60 * 60 * 1000;
    qint64 lastTimestamp = QDateTime::currentDateTime().toMSecsSinceEpoch() - interval;
    DatabaseManager::getInstance()->searchHistoryByUniqueId(lastTimestamp, m_HistoryMeetingList);
    qInfo() << "refreshHistoryMeetingList: " << m_HistoryMeetingList.count();
    emit refreshHistory();
    setCount(m_HistoryMeetingList.count());
}

QJsonArray HistoryManager::getRecentMeetingList() {
    QVector<BaseHistoryMeetingInfo> infos;
    qint64 lastClearTimestamp = ConfigManager::getInstance()->getValue("lastClearTimestamp", 0).toULongLong();
    DatabaseManager::getInstance()->searchBaseHistoryInfoByMeeingId(10, lastClearTimestamp, infos);
    QJsonArray array;
    for (auto& info : infos) {
        QJsonObject obj;
        obj["meetingID"] = info.meetingID;
        obj["meetingSuject"] = info.meetingSuject;
        array << obj;
    }
    return array;
}

void HistoryManager::clearRecentMeetingList() {
    qint64 curTimestamp = QDateTime::currentDateTime().toMSecsSinceEpoch();
    ConfigManager::getInstance()->setValue("lastClearTimestamp", curTimestamp);
}

void HistoryManager::refreshCollectMeetingList() {
    m_collectMeetingList.clear();
    DatabaseManager::getInstance()->searchAllCollectList(m_collectMeetingList);
    qInfo() << "refreshCollectMeetingList: " << m_collectMeetingList.count();
    emit refreshHistory();
}

bool HistoryManager::collect(int index, qint64 meetingUniqueID) {
    bool ret = DatabaseManager::getInstance()->updateHistoryCollectField(meetingUniqueID, true);
    if (ret) {
        m_HistoryMeetingList[index].isCollect = true;
        emit historyChanged(index);
    }

    return ret;
}

bool HistoryManager::cancelCollectFromHistory(int index, qint64 meetingUniqueID) {
    bool ret = DatabaseManager::getInstance()->updateHistoryCollectField(meetingUniqueID, false);
    if (ret) {
        m_HistoryMeetingList[index].isCollect = false;
        emit historyChanged(index);
    }
    return ret;
}

bool HistoryManager::cancelCollectFromCollectList(int index, qint64 meetingUniqueID) {
    bool ret = DatabaseManager::getInstance()->updateHistoryCollectField(meetingUniqueID, false);
    if (ret) {
        // m_collectMeetingList.remove(index); todo
        emit collectChanged(index);
    }
    return ret;
}

void HistoryManager::addHistoryMeeting(const HistoryMeetingInfo& info) {
    bool ret = DatabaseManager::getInstance()->addHistoryMeetingInfo(info);
    if (ret) {
        emit newHistoryAdd();
    }
}
