// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef MEETING_PLUGINS_COMPONENTS_AUTH_NEM_ACCOUNT_H_
#define MEETING_PLUGINS_COMPONENTS_AUTH_NEM_ACCOUNT_H_

#include <QObject>

class NEMAccount : public QObject {
    Q_OBJECT

public:
    explicit NEMAccount(QObject* parent = nullptr);
    ~NEMAccount();

    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)
    Q_PROPERTY(QString accountName READ accountName NOTIFY accountNameChanged)
    Q_PROPERTY(QString accountId READ accountId NOTIFY accountIdChanged)
    Q_PROPERTY(QString personalId READ personalId NOTIFY personalIdChanged)
    Q_PROPERTY(QString shortPersonalId READ shortPersonalId NOTIFY shortPersonalIdChanged)

    bool isValid() const;
    void setIsValid(bool isValid);

    QString displayName() const;
    void setDisplayName(const QString& displayName);

    QString accountName() const;
    void setAccountName(const QString& account);

    QString accountId() const;
    void setAccountId(const QString& accountId);

    QString personalId() const;
    void setPersonalId(const QString& personalId);

    QString shortPersonalId() const;
    void setShortPersonalId(const QString& shortPersonalId);

Q_SIGNALS:
    void isValidChanged();
    void authenticateChanged();
    void authTypeChanged();
    void displayNameChanged();
    void accountNameChanged();
    void accountIdChanged();
    void personalIdChanged();
    void shortPersonalIdChanged();

private:
    bool m_isValid = false;
    QString m_displayName;
    QString m_accountName;
    QString m_accountId;
    QString m_personalId;
    QString m_shortPersonalId;
};

#endif  // MEETING_PLUGINS_COMPONENTS_AUTH_NEM_ACCOUNT_H_
