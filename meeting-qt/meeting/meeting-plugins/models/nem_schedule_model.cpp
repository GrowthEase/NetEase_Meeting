// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_schedule_model.h"

NEMScheduleModel::NEMScheduleModel(QObject* parent)
    : QAbstractListModel(parent) {}

NEMSchedule* NEMScheduleModel::schedule() const {
    return m_schedule;
}

void NEMScheduleModel::setSchedule(NEMSchedule* schedule) {
    beginResetModel();

    if (m_schedule)
        m_schedule->disconnect(this);

    m_schedule = schedule;

    if (m_schedule) {
        connect(m_schedule, &NEMSchedule::preResetItems, [=]() { beginResetModel(); });
        connect(m_schedule, &NEMSchedule::postResetItems, [=]() { endResetModel(); });
        connect(m_schedule, &NEMSchedule::preItemAppended, [=]() {
            const int index = m_schedule->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });
        connect(m_schedule, &NEMSchedule::postItemAppended, [=]() { endInsertRows(); });
        connect(m_schedule, &NEMSchedule::preItemRemoved, [=](int index) { beginRemoveRows(QModelIndex(), index, index); });
        connect(m_schedule, &NEMSchedule::postItemRemoved, [=]() { endRemoveRows(); });
        connect(m_schedule, &NEMSchedule::dataChanged, [=](int index) {
            QModelIndex modelIndex = createIndex(index, 0);
            this->dataChanged(modelIndex, modelIndex);
        });
        m_schedule->queryItems();
    }

    endResetModel();
}

int NEMScheduleModel::rowCount(const QModelIndex& parent) const {
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid() || !m_schedule)
        return 0;

    return m_schedule->items().size();
}

QVariant NEMScheduleModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || !m_schedule)
        return QVariant();

    const auto item = m_schedule->items().at(index.row());

    switch (role) {
        case TopicRole:
            return QVariant(item.topic);
            break;
        case UniqueIdRole:
            return QVariant(item.uniqueId);
            break;
        case MeetingIdRole:
            return QVariant(item.meetingId);
            break;
        case StateRole:
            return QVariant(item.state);
            break;
        case StartTimeRole:
            return QVariant(item.startTime);
            break;
        case EndTimeRole:
            return QVariant(item.endTime);
            break;
        case PasswordRole:
            return QVariant(item.password);
            break;
        case AutoMuteRole:
            return QVariant(item.mute);
            break;
        case LiveFlagRole:
            return QVariant(false);
            break;
    }

    return QVariant();
}

QHash<int, QByteArray> NEMScheduleModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[TopicRole] = "topic";
    names[UniqueIdRole] = "uniqueId";
    names[MeetingIdRole] = "meetingId";
    names[CreatedAtRole] = "createdAt";
    names[UpdatedAtRole] = "updatedAt";
    names[StateRole] = "state";
    names[StartTimeRole] = "startTime";
    names[EndTimeRole] = "endTime";
    names[PasswordRole] = "password";
    names[AutoMuteRole] = "mute";
    names[LiveFlagRole] = "live";
    return names;
}
