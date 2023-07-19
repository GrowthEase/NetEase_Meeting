// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_share_controller.h"

NEMShareController::NEMShareController(QObject* parent)
    : QObject(parent) {}

bool NEMShareController::isValid() const {
    return m_isValid;
}

void NEMShareController::setIsValid(bool isValid) {
    if (m_isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

nem_sdk::ISharingController* NEMShareController::shareController() const {
    return m_shareController;
}

void NEMShareController::setShareController(nem_sdk::ISharingController* shareController) {
    if (m_shareController != shareController) {
        m_shareController = shareController;
        if (m_shareController != nullptr) {
            m_shareController->setSharingEventHandler(this);
            setIsValid(true);
        }
    }
}
