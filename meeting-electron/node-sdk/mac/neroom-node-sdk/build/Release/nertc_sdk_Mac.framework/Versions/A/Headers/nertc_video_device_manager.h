/** @file nertc_video_device_manager.h
* @brief The interface header file of video device management of the NERTC SDK. 
* The interface header file of video device management of the NERTC SDK. 
* @copyright (c) 2021, NetEase Inc. All rights reserved.
*/

#ifndef NERTC_VIDEO_DEVICE_MANAGER_H
#define NERTC_VIDEO_DEVICE_MANAGER_H

#include "nertc_base_types.h"
#include "nertc_engine_defines.h"
#include "nertc_device_collection.h"

 /**
 * @namespace nertc
 * @brief namespace nertc
 */
namespace nertc
{
/** 
 * @if English
 * Video device management method.
 * <br>IVideoDeviceManager interface class provides related interfaces for video device management. Gets IVideoDeviceManager interface through instantiating the IVideoDeviceManager class.
 * @endif
 * @if Chinese
 * 视频设备管理方法。
 * <br>IVideoDeviceManager 接口类提供用于管理视频设备的相关接口。 可通过实例化 IVideoDeviceManager 类来获取 IVideoDeviceManager 接口。
* @endif
*/
class IVideoDeviceManager
{
protected:
    virtual ~IVideoDeviceManager() {}

public:
    /** 
     * @if English
     * Gets the list of all video capturing devices in the system.
     * <br>The method returns an IDeviceCollection object that includes all Video capturing devices in the system. Enumerates capturing devices with the App through the IDeviceCollection object.  
     * @note
     * After the method is used, the App needs to destroy the returned object. 
     * @return
     * - Success: An IDeviceCollection object includes all Video capturing devices.
     * - Failure: Null. 
     * @endif
     * @if Chinese
     * 获取系统中所有的视频采集设备列表。
     * <br>该方法返回一个 IDeviceCollection 对象，包含系统中所有的音频采集设备。通过IDeviceCollection 对象，App 可以枚举视频采集设备。
     * @note
     * 在使用结束后，App 需调用 destroy 方法销毁返回的对象。
     * @return
     * - 方法调用成功：一个 IDeviceCollection 对象，包含所有的视频采集设备。
     * - 方法调用失败：NULL 。
     * @endif
     */
    virtual IDeviceCollection * enumerateCaptureDevices() = 0;
    
    /**
     * @if Chinese
     * 指定视频采集设备。
     * <br>通过本接口可以实现为主流或辅流视频通道选择视频采集设备。
     * @since V4.6.20
     * @par 使用前提
     * 请在通过 \ref IRtcEngineEx::startVideoPreview(NERtcVideoStreamType type) "startVideoPreview" 接口开启视频预览后调用该方法。
     * @par 调用时机  
     * 请在初始化后调用该方法。
     * @note 
     * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>device_id</td>
     *      <td>const char [kNERtcMaxDeviceIDLength]</td>
     *      <td>视频采集设备的设备 ID。可以通过 \ref IVideoDeviceManager::enumerateCaptureDevices "enumerateCaptureDevices" 接口获取。</td>
     *  </tr>
     *  <tr>
     *      <td>type</td>
     *      <td>see #NERtcVideoStreamType</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain（默认）：主流。<li>kNERTCVideoStreamSub：辅流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //先获取主流通道的视频管理对象
     * nertc::IVideoDeviceManager * manager = nullptr;
     * rtcEngine->queryInterface(nertc::kNERtcIIDVideoDeviceManager, &(void*)manager);
     * std::string deviceID = ...;//通过 enumerateCaptureDevices 获取
     * nertc::NERtcVideoStreamType type = nertc::kNERTCVideoStreamMain; 
     * //设置主流通道的视频设备ID
     * videoManager->setDevice(deviceID, type);
     * //先获取辅流通道的视频管理对象
     * nertc::IVideoDeviceManager * manager = nullptr;
     * rtcEngine->queryInterface(nertc::kNERtcIIDVideoDeviceManager, &(void*)manager);
     * std::string deviceID = ...;//通过 enumerateCaptureDevices 获取
     * nertc::NERtcVideoStreamType type = nertc::kNERTCVideoStreamSub; 
     * //设置辅流通道的视频设备ID
     * videoManager->setDevice(deviceID, type);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *         - 30003（kNERtcErrInvalidParam）：参数错误，比如 deviceID 设置错误。
     *         - 30004（kNERtcErrNotSupported）：不支持的操作，比如使用的是纯音频 SDK。
     *         - 30008（kNERtcErrDeviceNotFound）：未找到设备。
     *         - 30009（kNERtcErrInvalidDeviceSourceID）：非法的设备，比如设置的 deviceID 字符串含有非法字符。
     * @endif
     */
    virtual int setDevice(const char device_id[kNERtcMaxDeviceIDLength], NERtcVideoStreamType type = kNERTCVideoStreamMain) = 0;
    
    /**
     * @if Chinese
     * 获取当前使用的视频采集设备信息。
     * <br>通过本接口可以实现获取主流或辅流视频通道已选择的视频采集设备信息。
     * @since V4.6.20
     * @par 使用前提
     * 请在通过 \ref IVideoDeviceManager::setDevice "setDevice" 接口设置视频采集设备后调用该方法，否则返回空。
     * @par 调用时机  
     * 请在初始化后调用该方法。
     * @note 
     * 纯音频 SDK 禁用该接口，如需使用请前往<a href="https://doc.yunxin.163.com/nertc/sdk-download" target="_blank">云信官网</a>下载并替换成视频 SDK。
     * @par 参数说明
     * <table>
     *  <tr>
     *      <th>**参数名称**</th>
     *      <th>**类型**</th>
     *      <th>**描述**</th>
     *  </tr>
     *  <tr>
     *      <td>device_id</td>
     *      <td>const char [kNERtcMaxDeviceIDLength]</td>
     *      <td>视频采集设备的设备 ID。可以通过 \ref IVideoDeviceManager::enumerateCaptureDevices "enumerateCaptureDevices" 接口获取。</td>
     *  </tr>
     *  <tr>
     *      <td>type</td>
     *      <td>see #NERtcVideoStreamType</td>
     *      <td>视频通道类型：<ul><li>kNERTCVideoStreamMain（默认）：主流。<li>kNERTCVideoStreamSub：辅流。</td>
     *  </tr>
     * </table>
     * @par 示例代码
     * @code
     * //获取主流视频通道的设备信息
     * std::string device_id = "\\?\usb#vid_046d&pid_081b&mi_00#7&1f6973a&0&0000#{65e8773d-8f56-11d0-a3b9-00a0c9223196}\global"; // 可以通过 IVideoDeviceManager 接口获取device_id
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamMain;
     * setDevice(device_id.c_str(), type);
     * //获取辅流通道的设备信息
     * std::string device_id = "\\?\usb#vid_046d&pid_081b&mi_00#7&1f6973a&0&0000#{65e8773d-8f56-11d0-a3b9-00a0c9223196}\global"; // 可以通过 IVideoDeviceManager 接口获取device_id
     * nertc::NERtcVideoStreamType type = nertc::NERtcVideoStreamType::kNERTCVideoStreamSub
     * setDevice(device_id.c_str(), type);
     * @endcode
     * @return
     * - 0（kNERtcNoError）：方法调用成功。
     * - 其他：方法调用失败。
     *          - 30004（kNERtcErrNotSupported）：不支持的操作，比如使用的是纯音频 SDK。
     * @endif
     */
    virtual int getDevice(char device_id[kNERtcMaxDeviceIDLength], NERtcVideoStreamType type = kNERTCVideoStreamMain) = 0;
};
} //namespace nertc

#endif
