// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_MODELS_NEM_SCHEDULE_MODEL_H_
#define MEETING_PLUGINS_MODELS_NEM_SCHEDULE_MODEL_H_

#include <QAbstractListModel>
#include "components/schedules/nem_schedules.h"

class NEMScheduleModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit NEMScheduleModel(QObject* parent = nullptr);

    enum {
        TopicRole = Qt::UserRole,  // Topic of this schedule
        UniqueIdRole,              // Unique ID of this schedule
        MeetingIdRole,
        CreatedAtRole,
        UpdatedAtRole,
        StateRole,
        StartTimeRole,
        EndTimeRole,
        PasswordRole,
        AutoMuteRole,
        LiveFlagRole
    };

    Q_PROPERTY(NEMSchedule* schedule READ schedule WRITE setSchedule NOTIFY scheduleChanged)

    NEMSchedule* schedule() const;
    void setSchedule(NEMSchedule* schedule);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void scheduleChanged();

private:
    NEMSchedule* m_schedule = nullptr;
};

#endif  // MEETING_PLUGINS_MODELS_NEM_SCHEDULE_MODEL_H_
