/**
 * @copyright Copyright (c) 2021 NetEase, Inc. All rights reserved.
 *            Use of this source code is governed by a MIT license that can be found in the LICENSE file.
 */

#include "nem_hosting_module_protocol/protocol/global_protocol.h"
#include "stdint.h"

std::atomic_uint64_t NS_NEM_SDK_HOSTMOD_CORE::NEMIPCProtocolHead::g_sn_(UINT64_MAX);

NNEM_SDK_HOSTING_MODULE_PROTOCOL_BEGIN_DECLS

void InitRequest::OnPack(Json::Value& root) const
{
    auto appinfo = init_config_.getAppInfo();
    auto loggerConfig = init_config_.getLoggerConfig();
    root["AppInfo"]["ApplicationName"] = appinfo->ApplicationName();
    root["AppInfo"]["OrganizationName"] = appinfo->OrganizationName();
    root["AppInfo"]["ProductName"] = appinfo->ProductName();
    root["AppKey"] = init_config_.getAppKey();
    root["Domain"] = init_config_.getDomain();
    root["enableDebugLog"] = init_config_.getEnableDebugLog();
    root["logSize"] = init_config_.getLogSize();
    root["UseAssetServerConfig"] = init_config_.getUseAssetServerConfig() ? true : false;
    root["keepAliveInterval"] = init_config_.getKeepAliveInterval();
    root["LoggerConfig"]["path"] = loggerConfig->LoggerPath();
    root["LoggerConfig"]["level"] = loggerConfig->LoggerLevel();
}

void InitRequest::OnParse(const Json::Value& root)
{
    auto appinfo = init_config_.getAppInfo();
    auto loggerConfig = init_config_.getLoggerConfig();
    appinfo->ApplicationName(root["AppInfo"]["ApplicationName"].asString());
    appinfo->OrganizationName(root["AppInfo"]["OrganizationName"].asString());
    appinfo->ProductName(root["AppInfo"]["ProductName"].asString());
    init_config_.setAppKey(root["AppKey"].asString());
    init_config_.setDomain(root["Domain"].asString());
    init_config_.setEnableDebugLog(root["enableDebugLog"].asBool());
    init_config_.setLogSize(root["logSize"].asInt());
    init_config_.setUseAssetServerConfig(root["UseAssetServerConfig"].asBool());
    init_config_.setKeepAliveInterval(root["keepAliveInterval"].asInt());
    loggerConfig->LoggerPath(root["LoggerConfig"]["path"].asString());
    loggerConfig->LoggerLevel((NELogLevel)root["LoggerConfig"]["level"].asInt());
}

void QuerySDKVersionResponse::OnOtherPack(Json::Value& root) const
{
    root["sdkVersion"] = sdkVersion;
}

void QuerySDKVersionResponse::OnOtherParse(const Json::Value& root)
{
    sdkVersion = root["sdkVersion"].asString();
}

NNEM_SDK_HOSTING_MODULE_PROTOCOL_END_DECLS
