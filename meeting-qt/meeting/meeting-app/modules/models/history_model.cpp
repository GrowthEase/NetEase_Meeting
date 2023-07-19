// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "history_model.h"

HistoryModel::HistoryModel(QObject* parent)
    : QAbstractTableModel(parent) {}

int HistoryModel::rowCount(const QModelIndex& modelIndex) const {
    Q_UNUSED(modelIndex)
    if (!m_pHistoryMgr) {
        return 0;
    }

    if (m_dataType == kDataTypeHistory) {
        auto historyMeetingList = m_pHistoryMgr->getHistoryMeetingList();
        return historyMeetingList.count();
    } else if (m_dataType == kDataTypeCollect) {
        auto collectMeetingList = m_pHistoryMgr->getCollectMeetingList();
        return collectMeetingList.count();
    }
    return 0;
}

int HistoryModel::columnCount(const QModelIndex& modelIndex) const {
    Q_UNUSED(modelIndex)
    return 5;
}

QVariant HistoryModel::data(const QModelIndex& modelIndex, int role) const {
    if (!modelIndex.isValid())
        return QVariant();

    QVector<HistoryMeetingInfo> meetingList;
    if (m_dataType == kDataTypeHistory) {
        meetingList = m_pHistoryMgr->getHistoryMeetingList();
    } else if (m_dataType == kDataTypeCollect) {
        meetingList = m_pHistoryMgr->getCollectMeetingList();
    }

    if (modelIndex.row() + 1 > meetingList.size())
        return QVariant();

    auto meetingInfo = meetingList.at(modelIndex.row());

    switch (role) {
        case kMeetingSubject:
            return QVariant(meetingInfo.meetingSuject);
        case kMeetingStartTime:
            return QVariant(QDateTime::fromMSecsSinceEpoch(meetingInfo.meetingStartTime).toString("yyyy-MM-dd hh:mm"));
        case kMeetingID:
            return QVariant(meetingInfo.meetingID);
        case kMeetingCreator:
            return QVariant(meetingInfo.meetingCreator);
        case kMeetingCollect:
            return QVariant(meetingInfo.isCollect);
        case kMeetingUniqueID:
            return QVariant(meetingInfo.meetingUniqueID);
    }

    return QVariant();
}

QHash<int, QByteArray> HistoryModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[kMeetingSubject] = "subject";
    names[kMeetingStartTime] = "startTime";
    names[kMeetingID] = "meetingID";
    names[kMeetingCreator] = "creator";
    names[kMeetingCollect] = "collect";
    names[kMeetingUniqueID] = "uniqueID";
    return names;
}

HistoryManager* HistoryModel::manager() const {
    return m_pHistoryMgr;
}

void HistoryModel::setManager(HistoryManager* pHistorymanager) {
    m_pHistoryMgr = pHistorymanager;

    connect(m_pHistoryMgr, &HistoryManager::refreshHistory, this, [=]() {
        beginResetModel();
        endResetModel();
    });
    connect(m_pHistoryMgr, &HistoryManager::collectChanged, this, [=](int index) {
        if (m_dataType == kDataTypeCollect) {
            beginRemoveRows(QModelIndex(), index, index);
            endRemoveRows();
        }
    });
    connect(m_pHistoryMgr, &HistoryManager::historyChanged, this, [=](int index) {
        if (m_dataType == kDataTypeHistory) {
            QModelIndex modelIndex = createIndex(index, 4);
            dataChanged(modelIndex, modelIndex);
        }
    });
}
