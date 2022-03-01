/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "config_manager.h"
#include <QDebug>
#include <QGuiApplication>
#include <QJsonArray>

#include "base/http_request.h"
#include "base/nem_auth_requests.h"
#include "base/http_manager.h"

ConfigManager* ConfigManager::m_instance = nullptr;

ConfigManager::ConfigManager(QObject *parent)
    : QObject(parent)
    , m_httpManager(new HttpManager(parent))
{
    m_settings = new QSettings();
}

void ConfigManager::setNeedSafeTip(bool needSafeTip)
{
    m_needSafeTip = needSafeTip;
    emit needSafeTipChanged();
}

void ConfigManager::requestServerAppConfigs()
{
    QString timestamp = ConfigManager::getInstance()->getValue("lastConfigTimestamp", "").toString();
    if(timestamp.isEmpty()) {
        timestamp = "0";
    }
    nem_auth::GetAppConfigs request(timestamp);

    m_httpManager->postRequest(request, [this](int code, const QJsonObject& response) {
        if(code == 200) {
            QJsonArray configs = response["configs"].toArray();
            if(configs.size() <= 0) {
                //读取本地配置
                QString appConfigJsonType_1 = getValue("lastAppConfigType_1", "").toString();
                if(appConfigJsonType_1.isEmpty()) {
                    return;
                }

                QJsonDocument jsonDocument = QJsonDocument::fromJson(appConfigJsonType_1.toUtf8().data());
                m_safeTipJson = jsonDocument.object();
                setNeedSafeTip(true);
            } else {
                QJsonObject obj = configs.at(0).toObject();
                m_safeTipJson.insert("content", obj["content"].toString());
                m_safeTipJson.insert("okBtnLabel", obj["okBtnLabel"].toString());
                m_safeTipJson.insert("title", obj["title"].toString());

                if(obj["type"].toInt() == 1) {
                    bool resetConfig = !obj["enable"].toBool();
                    if(resetConfig) {
                        setValue("lastAppConfigType_1", "");
                        return;
                    }

                    setValue("lastAppConfigType_1", QJsonDocument(m_safeTipJson).toJson(QJsonDocument::Compact));
                    setNeedSafeTip(true);
                }
            }

            QString lastConfigTimestamp = response["time"].toVariant().toString();
            setValue("lastConfigTimestamp", lastConfigTimestamp);
        }
    });
}

QJsonObject ConfigManager::getSafeTipContent() const
{
    return m_safeTipJson;
}

QVariant ConfigManager::getValue(const QString &key, const QVariant &defaultValue)
{
    return m_settings->value(key, defaultValue);
}

void ConfigManager::setValue(const QString &key, const QVariant &value)
{
    return m_settings->setValue(key, value);
}

bool ConfigManager::getLocalDebugLevel() const
{
    int minLevel = ConfigManager::getInstance()->getValue("localLogLevel", 2).toUInt();
    return (ALogLevel)minLevel <= Debug;
}
