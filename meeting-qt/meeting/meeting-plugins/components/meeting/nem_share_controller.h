// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_MEETING_NEM_SHARE_CONTROLLER_H_
#define MEETING_PLUGINS_COMPONENTS_MEETING_NEM_SHARE_CONTROLLER_H_

#include <QObject>
#include <QPointer>
#include <string>
#include <vector>
#include "meeting/sharing_ctrl_interface.h"

class NEMShareController : public QObject, public nem_sdk::ISharingEventHandler {
    Q_OBJECT

public:
    explicit NEMShareController(QObject* parent = nullptr);

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)

    bool isValid() const;
    void setIsValid(bool isValid);

    nem_sdk::ISharingController* shareController() const;
    void setShareController(nem_sdk::ISharingController* shareController);

Q_SIGNALS:
    void isValidChanged();
    void sharingStatusChanged(const QString& accountId, bool sharing, bool paused);

protected:
    void onSharingStatusChanged(const std::string& sharingAccountId, bool isSharing, bool isPause) {}
    void onError(uint32_t errorCode, const std::string& errorMessage) {}

private:
    bool m_isValid = false;
    nem_sdk::ISharingController* m_shareController = nullptr;
};

#endif  // MEETING_PLUGINS_COMPONENTS_MEETING_NEM_SHARE_CONTROLLER_H_
