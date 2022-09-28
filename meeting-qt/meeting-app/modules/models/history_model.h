// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef HISTORYMODEL_H
#define HISTORYMODEL_H

#include <QAbstractTableModel>
#include <QObject>
#include "history_manager.h"

class HistoryManager;

class HistoryModel : public QAbstractTableModel {
    Q_OBJECT
public:
    explicit HistoryModel(QObject* parent = nullptr);

    enum HistoryDataType { kDataTypeHistory, kDataTypeCollect };

    enum {
        kMeetingSubject = Qt::UserRole,
        kMeetingStartTime,
        kMeetingID,
        kMeetingCreator,
        kMeetingCollect,
        kMeetingUniqueID,
    };

    Q_PROPERTY(HistoryManager* manager READ manager WRITE setManager)
    Q_PROPERTY(int dataType READ dataType WRITE setDataType)

    int rowCount(const QModelIndex& = QModelIndex()) const override;
    int columnCount(const QModelIndex& = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    HistoryManager* manager() const;
    void setManager(HistoryManager* pHistorymanager);

    int dataType() const { return m_dataType; }
    void setDataType(int dataType) { m_dataType = dataType; }

private:
    HistoryManager* m_pHistoryMgr = nullptr;
    int m_dataType = kDataTypeHistory;
};

#endif  // HISTORYMODEL_H
