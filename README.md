# 网易会议组件概述
网易会议组件目前已经开源，源代码已经上传至 Github。该项目由网易云信团队自研，结合网易云信系统相关通讯功能，实时音视频、即时消息、白板、直播等功能构建一套会议系统，可以让开发者很容易具备高效稳定会议系统能力, 一周就能开发出一个属于自己的ZOOM。    


网易会议NEMeeting SDK(以下简称SDK)提供了一套简单易用的接口，允许开发者通过调用 SDK提供的API，快速地集成音视频会议功能至现有应用中。为企业打造专属的会议能力，卓越的音视频性能，丰富的会议协作能力，坚实的会议安全保障，提升协作效率，满足大中小会议全场景需求。提供全套开放、简单、安全的视频会议服务。您可以使用进行远程音视频会议、在线协作、会管会控、会议录制、指定邀请、布局管理等。


## 功能特性

<table>
 <tr>
 	<td width="100px">功能分类</td>
	<td width="100px" >功能</td>
	<td>功能描述</td>
 </tr>
  <tr>
 	<td>基础功能 </td>
	<td>语音/视频通话</td>
	<td>支持一对一或多人间的语音/视频通话功能，并进行音视频实时切换。支持纯转发会议或者讨论式会议。</td>
  </tr>
  <tr>
    <td rowspan="3">协作功能 </td>
	<td>实时消息</td>
	<td>主持人和与会人在会议过程中发送实时文字消息进行互动。</td>
 </tr>
   <tr>
	<td>白板共享</td>
	<td>主持人在白板上书写，有助于提升协作效率；其他与会人也可使用白板与主持人进行实时互动。支持白板双指缩放大小及移动位置。</td>
 </tr>
   <tr>
	<td>屏幕共享</td>
	<td>主持人或与会人将自己屏幕的内容分享给其他与会人观看，提高沟通效率。</td>
 </tr>
  <tr>
    <td rowspan="3">管理功能 </td>
	<td>会议控制</td>
	<td>可区分主持人和与会人员角色权限，显示与会人员列表及音视频状态。主持人可以管理与会人在会议过程中发送音、视频的权限，例如全体静音、单独关闭某与会人员的摄像头或麦克风、移出房间、设置与会人员开启摄像头或麦克风需审批等。提供进出会议人员通知，可以设置房间超过预定人数后关闭通知。</td>
 </tr>
   <tr>
	<td>会议邀请</td>
	<td>一键获取会议名称、密码，邀请他人参与会议。</td>
 </tr>
   <tr>
	<td>视图切换</td>
	<td>可以设置演讲者视图或平铺视图。支持自动切换视频视图和音频视图。</td>
 </tr>
</table>


# 网易会议组件架构
整套会议系统客户端支持 Android、iOS、Web、Electron、Windows、macOS等平台, 如何确保用户快速接入以及各端一致性问题, 我们对会议客户端进行了一定的拆分设计。

## 网易会议组件架构：
![meeting framework](https://github.com/J-yying/MeetingDocument/blob/main/%E7%BD%91%E6%98%93%E4%BC%9A%E8%AE%AE%E7%BB%84%E4%BB%B6%E6%9E%B6%E6%9E%84.jpeg)

### Base

这一层主要是包含云信的各基础SDK，同时也会包含一些第三方SDK。

### Room Kit

Room Kit 是一个无UI房间服务组件，这一层承载了和Server通信逻辑，同时处理了一些会控逻辑，未来方向也会演进成一个泛会议的房间服务。如果用户不想复用我们默认的UI布局, 可以基于Room Kit来实现自己的会议UI。

移动端基于 Flutter 实现, 为了方便原生项目接入, 同样我们提供混合开发模式允许通过Java以及OC等原生语言接入。

### Meeting SDK

Meeting SDK 是一个带UI的会议服务组件, 相比于RoomKit 我们提供了一整套的标准会议UI实现, 同时我们也提供了有限的UI自定义功能。

移动端基于 Flutter 实现, 为了方便原生项目接入, 同样我们提供混合开发模式允许通过Java以及OC等原生语言接入。

桌面端基于 Qt 实现, 为了便于客户集成, 我们通过IPC等机制把Qt相关实现进行了隔离, 避免用户工程集成问题。

### App

云信标准版网易会议应用实现, 支持直接编译成一个独立的应用。

# 网易会议系统服务交互流程：

会议系统设计利用云信原有PaaS能力, 我们通过 IM Server 来进行会控通知和聊天, 通过Media Server实现 媒体数据的转发。   

在此基础上我们重点对会议相关特性进行了设计, 包括多租户账号体系、安全入会、会议预定、会议控制、视图布局、角色控制等。  


![meeting_server](https://github.com/J-yying/MeetingDocument/blob/main/%E4%BC%9A%E8%AE%AE%E6%9C%8D%E5%8A%A1.jpeg)  

--------------------


为便于开发者对网易会议系统的理解，我们提供了网易会议相关的时序图供开发者进行流程上的参考；    
![meeting_flow_chart](https://github.com/J-yying/MeetingDocument/blob/main/meeting_flow_chart.png)

--------------------

# 集成方法概述
1. [Android 集成方式](https://github.com/netease-kit/documents/blob/main/%E4%B8%9A%E5%8A%A1%E7%BB%84%E4%BB%B6/%E4%BC%9A%E8%AE%AE%E7%BB%84%E4%BB%B6/%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B/%E8%B7%91%E9%80%9A%E7%A4%BA%E4%BE%8B%E9%A1%B9%E7%9B%AE_Android.md)
2. [iOS 集成方式](https://github.com/netease-kit/documents/blob/main/%E4%B8%9A%E5%8A%A1%E7%BB%84%E4%BB%B6/%E4%BC%9A%E8%AE%AE%E7%BB%84%E4%BB%B6/%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B/%E8%B7%91%E9%80%9A%E7%A4%BA%E4%BE%8B%E9%A1%B9%E7%9B%AE_iOS.md)
3. [Windows 集成方式](https://github.com/netease-kit/documents/blob/main/%E4%B8%9A%E5%8A%A1%E7%BB%84%E4%BB%B6/%E4%BC%9A%E8%AE%AE%E7%BB%84%E4%BB%B6/%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B/%E8%B7%91%E9%80%9A%E7%A4%BA%E4%BE%8B%E9%A1%B9%E7%9B%AE_Windows.md)
4. [Mac 集成方式](https://github.com/netease-kit/documents/blob/main/%E4%B8%9A%E5%8A%A1%E7%BB%84%E4%BB%B6/%E4%BC%9A%E8%AE%AE%E7%BB%84%E4%BB%B6/%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B/%E8%B7%91%E9%80%9A%E7%A4%BA%E4%BE%8B%E9%A1%B9%E7%9B%AE_MacOS.md)

# 代码许可
The MIT License（MIT）
