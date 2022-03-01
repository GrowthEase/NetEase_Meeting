/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <QObject>
#include <QMutex>
#include <QSettings>
#include <QJsonObject>

class HttpManager;

class ConfigManager : public QObject
{
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

    bool needSafeTip(){ return m_needSafeTip;}
    void setNeedSafeTip(bool needSafeTip);

signals:
    void needSafeTipChanged();

private:
    explicit ConfigManager(QObject *parent = nullptr);

public:
    Q_INVOKABLE void requestServerAppConfigs();
    Q_INVOKABLE QJsonObject getSafeTipContent() const;
    QVariant getValue(const QString& key, const QVariant& defaultValue = QVariant());
    void setValue(const QString& key, const QVariant& value);
    bool getLocalDebugLevel() const;

private:
    QSettings*   m_settings = nullptr;
    std::shared_ptr<HttpManager> m_httpManager;
    static ConfigManager *m_instance;
    bool m_needSafeTip = false;
    QJsonObject m_safeTipJson;
};

#endif // CONFIG_MANAGER_H
