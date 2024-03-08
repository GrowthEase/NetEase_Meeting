/** 
 * @file nertc_device_collection.h
* @brief The interface header file of NERTC SDK device NERTC SDK device collection. 
* All parameter descriptions of the NERTC SDK. All string-related parameters (char *) are encoded in UTF-8.
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/

#ifndef NERTC_DEVICE_COLLECTION_H
#define NERTC_DEVICE_COLLECTION_H

#include "nertc_base_types.h"
#include "nertc_engine_defines.h"

 /**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{
/** 
 * @if English
 * Device-related methods.
 * <br>The interface class gets device-related information.

 * @endif
 * @if Chinese
 * 设备相关方法。
 * <br>此接口类获取设备相关的信息。
 * @endif
*/
class IDeviceCollection
{
protected:
    virtual ~IDeviceCollection(){}

public:
    /** 
     * @if English
     * Gets the number of devices.
     * @note You must call \ref IAudioDeviceManager::enumeratePlayoutDevices "enumeratePlayoutDevices" or \ref IAudioDeviceManager::enumerateRecordDevices "enumerateRecordDevices" before calling the method to get the number of playing and capturing devices.
     * @return The number of capturing and playback devices.
     * 
     * @endif
     * @if Chinese
     * 获取设备数量。
     * @note 调用此方法之前，必须调用 \ref IAudioDeviceManager::enumeratePlayoutDevices "enumeratePlayoutDevices" 或 \ref IAudioDeviceManager::enumerateRecordDevices "enumerateRecordDevices" 方法获取播放或采集设备数量。
     * @return 采集或播放设备数量。
     * @endif
     */
    virtual uint16_t getCount() = 0;

    /** 
     * @if English
     * Gets the device information of the specified index. 
     * @param index specifies the device information that you want to check. The value must be lower than the value returned by \ref IDeviceCollection::getCount "getCount".
     * @param device_name Device name.
     * @param device_id Device ID.
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * @endif
     * @if Chinese
     * 获取指定 index 的设备信息。
     * @param index  指定想查询的设备信息。必须小于 \ref IDeviceCollection::getCount "getCount"返回的值。
     * @param device_name  设备名称。
     * @param device_id  设备 ID。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int getDevice(uint16_t index, char device_name[kNERtcMaxDeviceNameLength], char device_id[kNERtcMaxDeviceIDLength]) = 0;

    /** 
     * @if English
     * Searches specified information about index-related devices. 
     * @note The link method of returnable devices and the non-useful status determined by the SDK.
     * @param index specifies the device information that you want to check.
     * @param device_info For information about device information, see \ref NERtcDeviceInfo "NERtcDeviceInfo".
     * @return
     * - 0: Success.
     * - Other values: Failure.
     * 
     * @endif
     * @if Chinese
     * 检索有关索引设备的指定信息。
     * @note 可返回设备的链接方式，和SDK判定的疑似不可用状态。
     * @param index  指定想查询的设备信息。
     * @param device_info 设备信息，详细信息请参考 \ref NERtcDeviceInfo "NERtcDeviceInfo"。
     * @return
     * - 0: 方法调用成功；
     * - 其他: 方法调用失败。
     * @endif
     */
    virtual int getDeviceInfo(uint16_t index, NERtcDeviceInfo* device_info) = 0;
   
    /** 
     * @if English
     * Releases all IDeviceCollection resources.
     * 
     * @endif
     * @if Chinese
     * 释放所有 IDeviceCollection 资源。
     * @endif
     */
    virtual void destroy() = 0;
};
} //namespace nertc

#endif
