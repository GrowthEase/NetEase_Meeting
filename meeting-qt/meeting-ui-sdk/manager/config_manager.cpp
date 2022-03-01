/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "config_manager.h"
#include <QDebug>
#include <QGuiApplication>

ConfigManager* ConfigManager::m_instance = nullptr;

ConfigManager::ConfigManager(QObject* parent)
    : QObject(parent) {
    m_settings = new QSettings();
}

QVariant ConfigManager::getValue(const QString& key, const QVariant& defaultValue) {
    return m_settings->value(key, defaultValue);
}

void ConfigManager::setValue(const QString& key, const QVariant& value) {
    return m_settings->setValue(key, value);
}

bool ConfigManager::contains(const QString& key) {
    return m_settings->contains(key);
}
