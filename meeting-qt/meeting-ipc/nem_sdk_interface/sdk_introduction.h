/**
 * @file sdk_introduction.h
 * @brief NEMeeting SDK接口概览
 * @copyright (c) 2014-2021, NetEase Inc. All rights reserved
 * @author
 * @date 2021/04/08
 */

/**
 @mainpage 产品介绍
 @brief <p>网易云信 NEMeeting SDK
 提供完善的在线会议组件，支持多人音视频，屏幕共享，成员会控操作，聊天室，白板，美颜等功能以及部分自定义功能。</p>
 <p><ul>
 <li>\ref nem_sdk_interface::NEMeetingSDK "NEMeetingSDK" SDK实例的创建和初始化，获取服务等方法。</li>
 <li>\ref nem_sdk_interface::NEAuthService "NEAuthService" 登录服务，包含登录登出，状态监听注册等方法。</li>
 <li>\ref nem_sdk_interface::NEMeetingService "NEMeetingService" 会议服务，包含加入/创建会议，获取会议相关信息，音频订阅/取消订阅，状态监听注册等方法。</li>
 <li>\ref nem_sdk_interface::NESettingsService "NESettingsService" 配置服务，包含音视频、美颜、直播、白板、录制等的控制器，一些状态监听注册等方法。</li>
 <li>\ref nem_sdk_interface::NEAccountService "NEAccountService" 账户服务，包含获取会议id等方法。</li>
 <li>\ref nem_sdk_interface::NEFeedbackService "NEFeedbackService" 反馈服务，包含获取日志等，状态监听注册等方法。</li>
 <li>\ref nem_sdk_interface::NEPreMeetingService "NEPreMeetingService" 预约会议服务，会议的预约，取消，编辑，获取列表等方法。</li>
 </ul></p>
 
 <h2 id="服务管理">服务管理</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getInstance "getInstance"</td>
    <td>创建并获取 NEMeetngSDK 对象</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::initialize "initialize"</td>
    <td>初始化 NEMeetngSDK 对象</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::unInitialize "unInitialize"</td>
    <td>反初始化 NEMeetngSDK 对象</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::querySDKVersion "querySDKVersion"</td>
    <td>获取 NEMeetngSDK 版本号</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getAuthService "getAuthService"</td>
    <td>获取登录服务</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getMeetingService "getMeetingService"</td>
    <td>获取会议服务</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getSettingsService "getSettingsService"</td>
    <td>获取配置服务</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getAccountService "getAccountService"</td>
    <td>获取账户服务</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getFeedbackService "getFeedbackService"</td>
    <td>获取反馈服务</td>
    <td>V1.9.0</td>
  </tr>
   <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::getPremeetingService "getPremeetingService"</td>
    <td>获取预约会议服务</td>
    <td>V1.9.0</td>
  </tr>
</table>

 <h2 id="故障排查">故障排查</h2>

<table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::setExceptionHandler "setExceptionHandler"</td>
    <td>设置异常回调，可监听SDK是否已断开</td>
    <td>V1.9.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingSDK::setLogHandler "setLogHandler"</td>
    <td>设置日志回调，可监听一些SDK的一些关键日志</td>
    <td>V1.9.0</td>
  </tr>
</table>

*/

/**
 @defgroup getNEMeetingSDK 创建并获取NEMeetingSDK实例
 */
