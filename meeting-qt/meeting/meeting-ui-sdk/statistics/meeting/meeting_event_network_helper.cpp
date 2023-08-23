/**
 * @file meeting_event_network_helper.cpp
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief
 * @date 2023/8/8
 */

#include "meeting_event_network_helper.h"
#include <QNetworkInformation>

NetworkType NetworkHelper::GetNetworkType() {
    if (!QNetworkInformation::loadDefaultBackend() || !QNetworkInformation::loadBackendByFeatures(QNetworkInformation::Feature::Reachability))
        return kNetworkTypeUnknown;
    auto* information = QNetworkInformation::instance();
    if (!information)
        return kNetworkTypeUnknown;
    auto reachability = QNetworkInformation::instance()->reachability();
    // 只获取无网络状态，其他均认为是物理网卡，QNetworkInterface 无法精确判断具体使用的是哪个接口
    if (reachability == QNetworkInformation::Reachability::Disconnected)
        return kNetworkTypeNoNetwork;
    return kNetworkTypeEthernet;
}

QString NetworkHelper::GetNetworkTypeString(NetworkType type) {
    switch (type) {
        case kNetworkTypeEthernet:
            return "ETHERNET";
        case kNetworkTypeWIFI:
            return "WIFI";
        case kNetworkType5G:
            return "5G";
        case kNetworkType4G:
            return "4G";
        case kNetworkType3G:
            return "3G";
        case kNetworkType2G:
            return "2G";
        case kNetworkTypeUnknown:
            return "UNKNOWN";
        case kNetworkTypeNoNetwork:
            return "NONE";
        default:
            return "UNKNOWN";
    }
}
