#ifndef ROOMKIT_LISTENER_H_
#define ROOMKIT_LISTENER_H_

#include "room_kit_listener.h"

class RoomKitListener : public neroom::INEGlobalEventListener {
public:
    void afterRtcEngineInitialize(const std::string& roomUuid, const neroom::INERtcWrapper& rtcWrapper) override;
};

#endif  // ROOMKIT_LISTENER_H_
