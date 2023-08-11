/**
 * @file meeting_event_network_helper.h
 * @author Dylan (dengjiajia@corp.netease.com)
 * @brief
 * @date 2023/8/8
 */

#ifndef XKIT_DESKTOP_MEETING_EVENT_NETWORK_HELPER_H
#define XKIT_DESKTOP_MEETING_EVENT_NETWORK_HELPER_H

enum NetworkType {
    kNetworkTypeEthernet,
    kNetworkTypeWIFI,
    kNetworkType5G,
    kNetworkType4G,
    kNetworkType3G,
    kNetworkType2G,
    kNetworkTypeUnknown,
    kNetworkTypeNoNetwork,
};

class NetworkHelper {
public:
    static NetworkType GetNetworkType();
    static QString GetNetworkTypeString(NetworkType type);
};

#endif  // XKIT_DESKTOP_MEETING_EVENT_NETWORK_HELPER_H
