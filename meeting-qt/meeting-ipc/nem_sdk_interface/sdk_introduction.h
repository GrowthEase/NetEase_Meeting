// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 * @file sdk_introduction.h
 * @brief NEMeetingKit接口概览
 * @copyright (c) 2014-2022, NetEase Inc. All rights reserved
 * @author
 * @date 2022/05/19
 */

/**
 @mainpage 产品介绍
 @brief <p>网易云信 NEMeetingKit
 提供完善的在线会议组件，支持多人音视频，屏幕共享，成员会控操作，聊天室，白板，美颜等功能以及部分自定义功能。</p>
 <p><ul>
 <li>\ref nem_sdk_interface::NEMeetingKit "NEMeetingKit" Kit实例的创建和初始化，获取服务等方法。</li>
 <li>\ref nem_sdk_interface::NEAuthService "NEAuthService" 登录服务，包含登录登出，状态监听注册等方法。</li>
 <li>\ref nem_sdk_interface::NEMeetingService "NEMeetingService"
会议服务，包含加入/创建会议，获取会议相关信息，音频订阅/取消订阅，状态监听注册等方法。</li> <li>\ref nem_sdk_interface::NESettingsService
"NESettingsService" 配置服务，包含音视频、美颜、直播、白板、录制等的控制器，一些状态监听注册等方法。</li> <li>\ref nem_sdk_interface::NEAccountService
"NEAccountService" 账户服务，包含获取会议id等方法。</li> <li>\ref nem_sdk_interface::NEFeedbackService "NEFeedbackService"
反馈服务，包含获取日志等，状态监听注册等方法。</li> <li>\ref nem_sdk_interface::NEPreMeetingService "NEPreMeetingService"
预约会议服务，会议的预约，取消，编辑，获取列表等方法。</li>
 </ul></p>

 <h2 id="服务管理">服务管理</h2>

 <table>
  <tr>
    <th width=400><b>方法</b></th>
    <th width=600><b>功能</b></th>
    <th width=200><b>起始版本</b></th>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getInstance "getInstance"</td>
    <td>创建并获取 NEMeetngKit 对象</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::initialize "initialize"</td>
    <td>初始化 NEMeetingKit 对象</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::unInitialize "unInitialize"</td>
    <td>反初始化 NEMeetingKit 对象</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::queryKitVersion "queryKitVersion"</td>
    <td>获取 NEMeetingKit 版本号</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getAuthService "getAuthService"</td>
    <td>获取登录服务</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getMeetingService "getMeetingService"</td>
    <td>获取会议服务</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getSettingsService "getSettingsService"</td>
    <td>获取配置服务</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getAccountService "getAccountService"</td>
    <td>获取账户服务</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getFeedbackService "getFeedbackService"</td>
    <td>获取反馈服务</td>
    <td>V3.0.0</td>
  </tr>
   <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::getPremeetingService "getPremeetingService"</td>
    <td>获取预约会议服务</td>
    <td>V3.0.0</td>
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
    <td> \ref nem_sdk_interface::NEMeetingKit::setExceptionHandler "setExceptionHandler"</td>
    <td>设置异常回调，可监听Kit是否已断开</td>
    <td>V3.0.0</td>
  </tr>
  <tr>
    <td> \ref nem_sdk_interface::NEMeetingKit::setLogHandler "setLogHandler"</td>
    <td>设置日志回调，可监听一些Kit的一些关键日志</td>
    <td>V3.0.0</td>
  </tr>
</table>

*/

/**
 @defgroup getNEMeetingKit 创建并获取NEMeetingKit实例
 */
