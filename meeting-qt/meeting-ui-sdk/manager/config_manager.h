/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

// Copyright (c) 2014-2020 NetEase, Inc.
// All right reserved.

#ifndef CONFIG_MANAGER_H
#define CONFIG_MANAGER_H

#include <QObject>
#include <QMutex>
#include <QSettings>

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
private:
    explicit ConfigManager(QObject *parent = nullptr);

public:
    QVariant getValue(const QString& key, const QVariant& defaultValue = QVariant());
    void setValue(const QString& key, const QVariant& value);
    bool contains(const QString &key);

private:
    QSettings*   m_settings = nullptr;
    static ConfigManager *m_instance;
};

#endif // CONFIG_MANAGER_H
