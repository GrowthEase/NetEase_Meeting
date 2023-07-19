// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_MODELS_NEM_MEMBERS_MODEL_H_
#define MEETING_PLUGINS_MODELS_NEM_MEMBERS_MODEL_H_

#include <QAbstractListModel>
#include "components/meeting/nem_audio_controller.h"
#include "components/meeting/nem_members_controller.h"
#include "components/meeting/nem_video_controller.h"

class NEMMembersModel : public QAbstractListModel {
    Q_OBJECT

public:
    explicit NEMMembersModel(QObject* parent = nullptr);

    enum {
        AccountId = Qt::UserRole,  // Account ID of member
        AvRoomUid,                 // RTC channel ID of member
        Nickname,
        AudioStatus,
        VideoStatus,
        HandsupStatus,
        ShareStatus,
        LiveStatus,
        ClientType,
    };

    Q_PROPERTY(NEMMembersController* membersController READ membersController WRITE setMembersController NOTIFY membersControllerChanged)

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    NEMMembersController* membersController() const;
    void setMembersController(NEMMembersController* membersController);

Q_SIGNALS:
    void membersControllerChanged();

private:
    NEMMembersController* m_membersController = nullptr;
};

#endif  // MEETING_PLUGINS_MODELS_NEM_MEMBERS_MODEL_H_
