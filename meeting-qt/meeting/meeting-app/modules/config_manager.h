// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <QJsonObject>
#include <QMutex>
#include <QObject>
#include <QSettings>

class HttpManager;

class ConfigManager : public QObject {
    Q_OBJECT

public:
    static ConfigManager* getInstance() {
        static QMutex mutex;
        if (!m_instance) {
            QMutexLocker locker(&mutex);
            if (!m_instance) {
                m_instance = new ConfigManager(nullptr);
            }
        }
        return m_instance;
    }

public:
    Q_PROPERTY(bool needSafeTip READ needSafeTip WRITE setNeedSafeTip NOTIFY needSafeTipChanged)

    bool needSafeTip() { return m_needSafeTip; }
    void setNeedSafeTip(bool needSafeTip);

signals:
    void needSafeTipChanged();

private:
    explicit ConfigManager(QObject* parent = nullptr);

public:
    Q_INVOKABLE void requestServerAppConfigs();
    Q_INVOKABLE QJsonObject getSafeTipContent() const;
    Q_INVOKABLE bool isDebugModel();

    Q_INVOKABLE bool getTestEnv() const;
    Q_INVOKABLE void setTestEnv(bool test);
    Q_INVOKABLE void setSSOLogin(bool sso);
    Q_INVOKABLE bool getSSOLogin();

    QVariant getValue(const QString& key, const QVariant& defaultValue = QVariant());
    void setValue(const QString& key, const QVariant& value);
    bool getLocalDebugLevel() const;
    QString getAPaasAppKey() const { return m_aPaasAppKey; }
    QString getAPaasServerAddress() const { return m_aPaasServerAddress; }
    bool getPrivate() const { return m_bPrivate; }
    bool contains(const QString& key);

private:
    void initPrivate();

private:
    QSettings* m_settings = nullptr;
    std::shared_ptr<HttpManager> m_httpManager;
    static ConfigManager* m_instance;
    bool m_needSafeTip = false;
    QJsonObject m_safeTipJson;
    QString m_aPaasAppKey;
    QString m_aPaasServerAddress;

    bool m_bPrivate = false;
};

#endif  // CONFIG_MANAGER_H
