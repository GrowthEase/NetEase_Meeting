#include "roomkit_listener.h"
#include "stable.h"

static const std::string kStreamEncryptionKey = "";

void RoomKitListener::afterRtcEngineInitialize(const std::string& roomUuid, const neroom::INERtcWrapper& rtcWrapper) {
    YXLOG(Info) << "[RoomKitListener] Enable stream encryption after RTC SDK initialized." << roomUuid << YXLOGEnd;
    auto* rtcEngine = rtcWrapper.getRtcEngine();
    if (rtcEngine && !kStreamEncryptionKey.empty()) {
        nertc::NERtcEncryptionConfig config;
        config.mode = nertc::kNERtcGMCryptoSM4ECB;
        std::strncpy(config.key, kStreamEncryptionKey.c_str(), kNERtcEncryptByteLength);
        auto result = rtcEngine->enableEncryption(true, config);
        if (result != 0)
            YXLOG(Error) << "[RoomKitListener] Failed to enable stream encryption." << result << YXLOGEnd;
        else
            YXLOG(Info) << "[RoomKitListener] Succeed to enable stream encryption." << YXLOGEnd;
    } else {
        YXLOG(Error) << "[RoomKitListener] An empty RTC engine object or empty encrypt key." << YXLOGEnd;
    }
}
