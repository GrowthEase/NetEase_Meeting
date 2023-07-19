// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "database_manager.h"
#include <QSqlError>
#include <QSqlQuery>

DatabaseManager* DatabaseManager::m_instance = nullptr;

DatabaseManager::DatabaseManager() {}

bool DatabaseManager::connectDB(const QString& path) {
    if (m_db.isValid() && m_db.isOpen()) {
        m_db.close();
    }

    qDebug() << "path:" << path;

    // 打印Qt支持的数据库驱动
    qDebug() << QSqlDatabase::drivers();

    // 添加Sqlite数据库
    m_db = QSqlDatabase::addDatabase("QSQLITE");

    // 设置数据库
    m_db.setDatabaseName(path);

    // 打开数据库  只有打开数据库才能进行下面的操作
    if (!m_db.open()) {
        qDebug() << "initDB error";
        QSqlError lastError = m_db.lastError();
        qDebug() << "initDB error: " << lastError.driverText();
        return false;
    } else {
        return true;
    }
}

void DatabaseManager::disconnectDB() {
    if (m_db.isValid() && m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::createHistoryTable() {
    if (!m_db.open()) {
        qDebug() << "createHistoryTable db not open";
        return false;
    }

    QSqlQuery query(m_db);
    bool ret = query.exec(
        "create table history (meetingUniqueID INTEGER primary key not null unique ,"
        "meetingID TEXT ,"
        "meetingJoinTime INTEGER ,"
        "meetingStartTime INTEGER, "
        "meetingSuject TEXT,"
        "meetingCreator TEXT,"
        "isCollect INTEGER)");

    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "createHistoryTable error: " << lastError.driverText();
        return false;
    }
    return true;
}

bool DatabaseManager::addHistoryMeetingInfo(const HistoryMeetingInfo& info) {
    if (!m_db.open()) {
        qDebug() << "addHistoryMeetingInfo db not open";
        return false;
    }

    QSqlQuery query(m_db);
    QString sql = QString("replace into history values(?, ?, ?, ?, ?, ?, ?)");
    bool ret = query.prepare(sql);
    if (!ret) {
        qDebug() << "addHistoryMeetingInfo prepare failed: " << query.lastError();
        return false;
    }

    query.addBindValue(info.meetingUniqueID);
    query.addBindValue(info.meetingID);
    query.addBindValue(info.meetingJoinTime);
    query.addBindValue(info.meetingStartTime);
    query.addBindValue(info.meetingSuject);
    query.addBindValue(info.meetingCreator);
    query.addBindValue(info.isCollect);

    ret = query.exec();
    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "addHistoryMeetingInfo error: " << lastError.driverText();
        return false;
    }
    return true;
}

bool DatabaseManager::searchHistoryByUniqueId(qint64 lastTimestamp, QVector<HistoryMeetingInfo>& infos) {
    if (!m_db.open()) {
        qDebug() << "searchHistoryByUniqueId db not open";
        return false;
    }

    QSqlQuery query(m_db);
    QString sql = QString("select * from history where meetingStartTime > %1 order by meetingStartTime desc").arg(lastTimestamp);
    bool ret = query.exec(sql);
    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "searchHistoryByUniqueId error: " << lastError.driverText();
        return false;
    }

    while (query.next()) {
        qDebug() << QString(
                        "meetingUniqueID: %1, meetingID: %2, meetingJoinTime: %3,"
                        " meetingStartTime: %4,meetingSuject: %5,meetingCreator: %6,isCollect: %7,")
                        .arg(query.value("meetingUniqueID").toLongLong())
                        .arg(query.value("meetingID").toString())
                        .arg(query.value("meetingJoinTime").toLongLong())
                        .arg(query.value("meetingStartTime").toLongLong())
                        .arg(query.value("meetingSuject").toString())
                        .arg(query.value("meetingCreator").toString())
                        .arg(query.value("isCollect").toBool());

        HistoryMeetingInfo info;
        info.meetingUniqueID = query.value("meetingUniqueID").toLongLong();
        info.meetingID = query.value("meetingID").toString();
        info.meetingJoinTime = query.value("meetingJoinTime").toLongLong();
        info.meetingStartTime = query.value("meetingStartTime").toLongLong();
        info.meetingSuject = query.value("meetingSuject").toString();
        info.meetingCreator = query.value("meetingCreator").toString();
        info.isCollect = query.value("isCollect").toBool();
        infos << info;
    }

    return true;
}

bool DatabaseManager::updateHistoryCollectField(qint64 meetingUniqueID, bool isCollect) {
    if (!m_db.open()) {
        qDebug() << "updateHistoryCollectField db not open";
        return false;
    }

    QSqlQuery query(m_db);
    QString sql = QString("update history set isCollect = ? where meetingUniqueID = ?");
    bool ret = query.prepare(sql);
    if (!ret) {
        qDebug() << "updateHistoryCollectField prepare failed: " << query.lastError();
        return false;
    }

    query.addBindValue(isCollect);
    query.addBindValue(meetingUniqueID);

    ret = query.exec();
    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "updateHistoryCollectField error: " << lastError.driverText();
        return false;
    }
    return true;
}

bool DatabaseManager::updateHistoryJoinTimeField(qint64 meetingUniqueID, qint64 meetingJoinTime) {
    if (!m_db.open()) {
        qDebug() << "updateHistoryJoinTimeField db not open";
        return false;
    }

    QSqlQuery query(m_db);
    QString sql = QString("update history set meetingJoinTime = ? where meetingUniqueID = ?");
    bool ret = query.prepare(sql);
    if (!ret) {
        qDebug() << "updateHistoryJoinTimeField prepare failed: " << query.lastError();
        return false;
    }

    query.addBindValue(meetingJoinTime);
    query.addBindValue(meetingUniqueID);

    ret = query.exec();
    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "updateHistoryJoinTimeField error: " << lastError.driverText();
        return false;
    }
    return true;
}

bool DatabaseManager::searchAllCollectList(QVector<HistoryMeetingInfo>& infos) {
    if (!m_db.open()) {
        qDebug() << "searchAllCollectList db not open";
        return false;
    }

    QSqlQuery query(m_db);
    QString sql = QString("select * from history where isCollect = 1 order by meetingStartTime desc");
    bool ret = query.exec(sql);
    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "searchHistoryByUniqueId error: " << lastError.driverText();
        return false;
    }

    while (query.next()) {
        qDebug() << QString(
                        "meetingUniqueID: %1, meetingID: %2, meetingJoinTime: %3,"
                        " meetingStartTime: %4,meetingSuject: %5,meetingCreator: %6,isCollect: %7,")
                        .arg(query.value("meetingUniqueID").toLongLong())
                        .arg(query.value("meetingID").toString())
                        .arg(query.value("meetingJoinTime").toLongLong())
                        .arg(query.value("meetingStartTime").toLongLong())
                        .arg(query.value("meetingSuject").toString())
                        .arg(query.value("meetingCreator").toString())
                        .arg(query.value("isCollect").toBool());

        HistoryMeetingInfo info;
        info.meetingUniqueID = query.value("meetingUniqueID").toLongLong();
        info.meetingID = query.value("meetingID").toString();
        info.meetingJoinTime = query.value("meetingJoinTime").toLongLong();
        info.meetingStartTime = query.value("meetingStartTime").toLongLong();
        info.meetingSuject = query.value("meetingSuject").toString();
        info.meetingCreator = query.value("meetingCreator").toString();
        info.isCollect = query.value("isCollect").toBool();
        infos << info;
    }

    return true;
}

bool DatabaseManager::searchBaseHistoryInfoByMeeingId(int count, qint64 lastTimestamp, QVector<BaseHistoryMeetingInfo>& infos) {
    if (!m_db.open()) {
        qDebug() << "searchHistoryByMeeingId db not open";
        return false;
    }

    QSqlQuery query(m_db);
    QString sql = QString(
                      "select meetingID, meetingSuject, MAX(meetingJoinTime) from history where meetingJoinTime > %1 group by meetingID order by "
                      "meetingJoinTime desc limit %2")
                      .arg(lastTimestamp)
                      .arg(count);
    bool ret = query.exec(sql);
    if (!ret) {
        QSqlError lastError = query.lastError();
        qDebug() << "searchHistoryByMeeingId error: " << lastError.driverText();
        return false;
    }

    while (query.next()) {
        qDebug() << QString("meetingID: %2, meetingSuject: %3").arg(query.value("meetingID").toString()).arg(query.value("meetingSuject").toString());

        BaseHistoryMeetingInfo info;
        info.meetingID = query.value("meetingID").toString();
        info.meetingSuject = query.value("meetingSuject").toString();
        infos << info;
    }

    return true;
}
