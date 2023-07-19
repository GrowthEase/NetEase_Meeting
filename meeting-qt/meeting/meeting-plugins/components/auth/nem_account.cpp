// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#include "nem_account.h"

NEMAccount::NEMAccount(QObject* parent)
    : QObject(parent) {}

NEMAccount::~NEMAccount() {}

bool NEMAccount::isValid() const {
    return m_isValid;
}

void NEMAccount::setIsValid(bool isValid) {
    if (m_isValid != isValid) {
        m_isValid = isValid;
        Q_EMIT isValidChanged();
    }
}

QString NEMAccount::displayName() const {
    return m_displayName;
}

void NEMAccount::setDisplayName(const QString& displayName) {
    if (m_displayName != displayName) {
        m_displayName = displayName;
        Q_EMIT displayNameChanged();
    }
}

QString NEMAccount::accountName() const {
    return m_accountName;
}

void NEMAccount::setAccountName(const QString& account) {
    if (m_accountName != account) {
        m_accountName = account;
        Q_EMIT accountNameChanged();
    }
}

QString NEMAccount::accountId() const {
    return m_accountId;
}

void NEMAccount::setAccountId(const QString& accountId) {
    if (m_accountId != accountId) {
        m_accountId = accountId;
        Q_EMIT accountIdChanged();
    }
}

QString NEMAccount::personalId() const {
    return m_personalId;
}

void NEMAccount::setPersonalId(const QString& personalId) {
    if (m_personalId != personalId) {
        m_personalId = personalId;
        Q_EMIT personalIdChanged();
    }
}

QString NEMAccount::shortPersonalId() const {
    return m_shortPersonalId;
}

void NEMAccount::setShortPersonalId(const QString& shortPersonalId) {
    if (m_shortPersonalId != shortPersonalId) {
        m_shortPersonalId = shortPersonalId;
        Q_EMIT shortPersonalIdChanged();
    }
}
