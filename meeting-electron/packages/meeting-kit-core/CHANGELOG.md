## v4.3.0(2024-03-06)

### New Features

- 新增断开音频功能，支持连接/断开本地音频
- 支持管理员修改参会者昵称
- 支持用户头像显示
- 支持音频模式

### Compatibility

- **meeting-web-react-ui:** ⚙️ Compatible with `NERoom` version `1.26.0`

## v4.2.1(2024-02-01)

### New Features

- **meeting-web-react-ui:** 🎸 新增等候室
- **meeting-web-react-ui:** 🎸 新增支持直播设置背景图
- **meeting-web-react-ui:** 🎸 新增会议水印功能，可以在会议中开启水印，后台可以配置水印内容、水印样式、是否强制打开(强制打开则端上不展示设置入口)
- **meeting-web-react-ui:** 🎸 新增聊天记录预览功能，会议创建者可以在历史会议中查看会议聊天记录及导出
- **meeting-web-react-ui:** 🎸 新增安全模块，支持等候室开关、水印开关和锁定会议开关

### Bug Fixes

- **Meeting:** 🎸 修复聊天室消息过多时候，导致的应用卡顿问题。

### Compatibility

- **meeting-web-react-ui:** ⚙️ Compatible with `NERoom` version `1.25.0`

## v4.0.0(2023-11-30)

### New Features

- **meeting-web-react-ui:** 🎸 会议状态变更事件增加回调：开始加入 RTC、加入 RTC 成功、加入 RTC 失败

### Refactor

- **meeting-web-react-ui:** 💡 优化会议组件 H5 聊天室接收图片展示

## v3.16.0(2023-09-06)

### New Features

- **meeting-web-react-ui:** 🎸 会议组件 H5 支持自定义菜单
- **meeting-web-react-ui:** 🎸 会议组件 H5 聊天室支持接收和下载图片
- **meeting-web-react-ui:** 🎸 增加会议状态变更回调 API
- **meeting-web-react-ui:** 🎸 支持配置是否显示长短会议号
- **meeting-web-react-ui:** 🎸 新增匿名入会 API

### Refactor

- **meeting-web-react-ui:** 💡 会议层添加 framework、修改上报耗时

### Bug Fixed

🐛 白板权限被取消后没有弹窗提示
🐛 修复断网情况下本端无法更新音视频状态
🐛 修复断网后移除成员，重新入会后仍会被移除

- ### Compatibility

- **meeting-web-react-ui:** ⚙️ Compatible with `NERoom` version `1.20.0`

## v3.14.1(2023-08-09)

### NEW Features

- **meeting-web-react-ui:** 🎸 新增会议剩余时间提醒

### Bug Fixes

- **meeting-web-react-ui:** 🐛 修复匿名成员离开成员列表数量错误问题

## v3.12.0(2023-05-30)

### NEW Features

- **meeting-web-react-ui:** 🎸 支持主持人会前设置开启关闭音视频设备

## v3.11.0(2023-04-27)

### NEW Features

- **meeting-web-ui:** 🎸 新增私有化部署支持

### Bug Fixes

- **meeting-web-react-ui:** 🐛 修复房间从 2 人变 1 人情况下界面显示未移除离开人员问题

## v3.10.1(2023-04-27)

**Note:** Version bump only for package nemeeting-web-sdk

## v3.10.0(2023-04-11)

### NEW Features

- **meeting-web-react-ui:** 🎸 统一字段 meetingId 为 meetingNum
- **meeting-web-react-ui:** 🎸 checkSystemRequirements 方法支持初始化之前调用

### Bug Fixes

- **meeting-web-react-ui:** 🐛 修复 ios 下 video 遮挡昵称问题

## v3.9.1(2023-03-13)

### Bug Fixes

- **meeting-web-react-ui:** 🐛 修复 ios 切换视图到主屏幕出现画布遮挡问题

## v3.9.0(2023-03-02)

### Bug Fixes

- **meeting-web-react-ui:** 🐛 修复关闭视频后重新打开帧率未按照上次设置值
- ### Compatibility

- **meeting-web-react-ui:** ⚙️ Compatible with `NERoom` version `1.12.0`

## v3.8.0(2023-01-09)

### Bug Fixes

- **meeting-web-react-ui:** 🐛 修复成员互踢后，成员数量显示错误，后入会成员无法显示问题

### Compatibility

- **meeting-web-react-ui:** ⚙️ Compatible with `NERoom` version `1.11.0`

## v3.7.1(2022-12-23)

**Note:** Version bump only for package nemeeting-web-sdk

## v3.7.0(2022-12-08)

### NEW Features

- **meeting-web-react-ui:** 🎸 支持显示会议主题

### Bug Fixes

- **meeting-web-react-ui:** 🐛 视频播放无权限无法重新播放问题
- **meeting-web-react-ui:** 🐛 修复聊天室显示系统透传消息问题，设置音频默认属性为 music_standard
- **meeting-web-react-ui:** 🐛 修复未开启视频无法显示共享流问题
- ### Compatibility

- **meeting-web-react-ui:** ⚙️ Compatible with `NERoom` version `1.10.0`

## v0.3.1(2022-08-19)

### Bug Fixes

- **meeting-web-react-ui:** 🐛 storybook 引入方式

# [0.3.0] (2022-08-16)

### chore

- **meeting-web-react-ui:** 🤖 license 配置改为又外层 lerna 添加

### BREAKING CHANGES

- **meeting-web-react-ui:** 🧨 1.0.0 全新发布

# 0.2.0 (2022-08-16)

### Bug Fixes

- **meeting-web-react-ui:** 🐛 安装云信 log
- **meeting-web-react-ui:** 🐛 本地音视频、改名、dialog
- **meeting-web-react-ui:** 🐛 补充会议信息逻辑
- **meeting-web-react-ui:** 🐛 部分机型机械音
- **meeting-web-react-ui:** 🐛 参会者角色标签显示两行
- **meeting-web-react-ui:** 🐛 参会者列表排序
- **meeting-web-react-ui:** 🐛 参会者文案+storybook 页面添加
- **meeting-web-react-ui:** 🐛 参会者 hint 样式调整
- **meeting-web-react-ui:** 🐛 操作栏自动隐藏逻辑修复
- **meeting-web-react-ui:** 🐛 成员列表去除不在 rtc 房间成员
- **meeting-web-react-ui:** 🐛 成员列表中的 host 操作不在本期交付内容，先注释掉
- **meeting-web-react-ui:** 🐛 顶部组件逻辑完善
- **meeting-web-react-ui:** 🐛 定位改为 absolute，宽高改为百分比
- **meeting-web-react-ui:** 🐛 对外销毁接口，无完全清除问题
- **meeting-web-react-ui:** 🐛 还原断网处理
- **meeting-web-react-ui:** 🐛 横屏/点击主画面隐藏工具栏
- **meeting-web-react-ui:** 🐛 会议结束 loading 页要消失+主持人名称变更同步
- **meeting-web-react-ui:** 🐛 获取设备信息优化
- **meeting-web-react-ui:** 🐛 结束/离开会议，成员列表的一些操作
- **meeting-web-react-ui:** 🐛 举手提示
- **meeting-web-react-ui:** 🐛 开启音视频内增加对当前房间管控状态的处理
- **meeting-web-react-ui:** 🐛 类型修改
- **meeting-web-react-ui:** 🐛 离开后状态未重置的问题
- **meeting-web-react-ui:** 🐛 离开时重置账号登录状态
- **meeting-web-react-ui:** 🐛 联席主持人标签
- **meeting-web-react-ui:** 🐛 聊天室消息展示不准确
- **meeting-web-react-ui:** 🐛 聊天室消息展示不准确
- **meeting-web-react-ui:** 🐛 聊天室样式
- **meeting-web-react-ui:** 🐛 浏览器兼容性检测 api 不再通过回调处理
- **meeting-web-react-ui:** 🐛 轮播样式对齐
- **meeting-web-react-ui:** 🐛 密码弹窗校验样式+联席主持人显示
- **meeting-web-react-ui:** 🐛 密码入会重置数据完善
- **meeting-web-react-ui:** 🐛 切换摄像头改为先关后切再开
- **meeting-web-react-ui:** 🐛 切换摄像头增加防抖处理
- **meeting-web-react-ui:** 🐛 软键盘问题
- **meeting-web-react-ui:** 🐛 删除无用代码
- **meeting-web-react-ui:** 🐛 摄像头切换问题
- **meeting-web-react-ui:** 🐛 手放下提示仅当前用户提示
- **meeting-web-react-ui:** 🐛 添加对 meetingInfo 判断
- **meeting-web-react-ui:** 🐛 添加 vConsole，摄像头前后置切换，改名，sdk 升级 1.5
- **meeting-web-react-ui:** 🐛 修复白板第一次进入显示工具栏问题，修复视频播放问题
- **meeting-web-react-ui:** 🐛 修复部分移动端浏览器自动播放限制问题
- **meeting-web-react-ui:** 🐛 修复成员离开房间重新打开视频加入无法加载视频
- **meeting-web-react-ui:** 🐛 修复成员列表筛选无效的 bug
- **meeting-web-react-ui:** 🐛 修复弹窗被隐藏
- **meeting-web-react-ui:** 🐛 修复断网设置焦点失效问题，ios 微信浏览器获取设备失败无法入会
- **meeting-web-react-ui:** 🐛 修复断网重连造成多个人员重复问题，当前说话这更新频率降低为 4s
- **meeting-web-react-ui:** 🐛 修复对外暴露回调函数未执行问题
- **meeting-web-react-ui:** 🐛 修复多端互踢事件未触发
- **meeting-web-react-ui:** 🐛 修复改名后弹窗内名称未更新问题
- **meeting-web-react-ui:** 🐛 修复共享后取消共享渲染无画面问题，添加 https
- **meeting-web-react-ui:** 🐛 修复监听事件闭包造成无法获取最新数据问题
- **meeting-web-react-ui:** 🐛 修复举手判断逻辑，去除主持人操作逻辑
- **meeting-web-react-ui:** 🐛 修复举手状态被覆盖问题
- **meeting-web-react-ui:** 🐛 修复开启音视频入会时位置变化导致的画面重开问题
- **meeting-web-react-ui:** 🐛 修复控制栏隐藏导致弹窗隐藏
- **meeting-web-react-ui:** 🐛 修复没有根据说话者排序问题
- **meeting-web-react-ui:** 🐛 修复图片不显示问题
- **meeting-web-react-ui:** 🐛 修复样式问题
- **meeting-web-react-ui:** 🐛 修复主持人操作全体中的举手逻辑
- **meeting-web-react-ui:** 🐛 修复主持人将解除非本端音频也有提示问题
- **meeting-web-react-ui:** 🐛 修复自动播放受限相关问题
- **meeting-web-react-ui:** 🐛 修复 ios 重播远端音频流失败的问题
- **meeting-web-react-ui:** 🐛 修复 ts 声明
- **meeting-web-react-ui:** 🐛 修改引用报错
- **meeting-web-react-ui:** 🐛 修改 ts 声明
- **meeting-web-react-ui:** 🐛 样式调整
- **meeting-web-react-ui:** 🐛 样式调整
- **meeting-web-react-ui:** 🐛 样式调整
- **meeting-web-react-ui:** 🐛 样式改动
- **meeting-web-react-ui:** 🐛 样式优化
- **meeting-web-react-ui:** 🐛 隐藏 loading 方法提前
- **meeting-web-react-ui:** 🐛 增加入会密码弹窗+屏幕共享 icon
- **meeting-web-react-ui:** 🐛 增加 loading+操作栏隐藏
- **meeting-web-react-ui:** 🐛 重复初始化问题
- **meeting-web-react-ui:** 🐛 主持人信息变更
- **meeting-web-react-ui:** 🐛 字段名修改
- **meeting-web-react-ui:** 🐛 字段名修改
- **meeting-web-react-ui:** 🐛 自动播放受限时只重播打开音频的成员流
- **meeting-web-react-ui:** 🐛 组件底部逻辑补充
- **meeting-web-react-ui:** 🐛 ios 微信浏览器无法获取设备造成的进入会议失败
- **meeting-web-react-ui:** 🐛 loading 页面优化+聊天室滚动到最新一条
- **meeting-web-react-ui:** 🐛 vconsole 改为 cdn 模式引入
- **meeting-web-react-ui:** 🐛 删除重复测试数据
- **meeting-web-react-ui:** 🐛 头部组件 visible 参数

### Code Refactoring

- **meeting-web-react-ui:** 💡 修改类型声明文件路径，npm 发包配置

### NEW Features

- **meeting-web-react-ui:** 🎸 暴露密码登录接口
- **meeting-web-react-ui:** 🎸 不在当前画面不订阅视频流
- **meeting-web-react-ui:** 🎸 成员列表样式修改
- **meeting-web-react-ui:** 🎸 初始化项目配置
- **meeting-web-react-ui:** 🎸 登录方法无返回
- **meeting-web-react-ui:** 🎸 点击小窗阻止冒泡
- **meeting-web-react-ui:** 🎸 替换 icon 引入方式
- **meeting-web-react-ui:** 🎸 添加白板支持
- **meeting-web-react-ui:** 🎸 添加画布滑动
- **meeting-web-react-ui:** 🎸 添加画布模块
- **meeting-web-react-ui:** 🎸 添加获取会议信息和成员信息接口
- **meeting-web-react-ui:** 🎸 添加举手功能
- **meeting-web-react-ui:** 🎸 添加匿名登录，添加部分事件监听
- **meeting-web-react-ui:** 🎸 添加全体视频操作，对外暴露宽高设置
- **meeting-web-react-ui:** 🎸 添加主持人打开本端音视频弹框提示功能
- **meeting-web-react-ui:** 🎸 添加 neroom 逻辑
- **meeting-web-react-ui:** 🎸 添加 videocard, 引入 icon
- **meeting-web-react-ui:** 🎸 添加 VideoCard 组件
- **meeting-web-react-ui:** 🎸 增加错误提示
- **meeting-web-react-ui:** 🎸 增加大小屏幕切换
- **meeting-web-react-ui:** 🎸 增加登出、检查浏览器兼容性 API
- **meeting-web-react-ui:** 🎸 增加浏览器兼容性检查
- **meeting-web-react-ui:** 🎸 add chatroom
- **meeting-web-react-ui:** 🎸 头部组件

### BREAKING CHANGES

- **meeting-web-react-ui:** 🧨 1.0.0

## 1.0.0 (2022-08-12)

### Bug Fixes

- **meeting-web-react-ui:** 🐛 ios 微信浏览器无法获取设备造成的进入会议失败
- **meeting-web-react-ui:** 🐛 loading 页面优化+聊天室滚动到最新一条
- **meeting-web-react-ui:** 🐛 vconsole 改为 cdn 模式引入
- **meeting-web-react-ui:** 🐛 主持人信息变更
- **meeting-web-react-ui:** 🐛 举手提示
- **meeting-web-react-ui:** 🐛 会议结束 loading 页要消失+主持人名称变更同步
- **meeting-web-react-ui:** 🐛 修复 ios 重播远端音频流失败的问题
- **meeting-web-react-ui:** 🐛 修复主持人将解除非本端音频也有提示问题
- **meeting-web-react-ui:** 🐛 修复主持人操作全体中的举手逻辑
- **meeting-web-react-ui:** 🐛 修复举手判断逻辑，去除主持人操作逻辑
- **meeting-web-react-ui:** 🐛 修复举手状态被覆盖问题
- **meeting-web-react-ui:** 🐛 修复共享后取消共享渲染无画面问题，添加 https
- **meeting-web-react-ui:** 🐛 修复图片不显示问题
- **meeting-web-react-ui:** 🐛 修复多端互踢事件未触发
- **meeting-web-react-ui:** 🐛 修复对外暴露回调函数未执行问题
- **meeting-web-react-ui:** 🐛 修复开启音视频入会时位置变化导致的画面重开问题
- **meeting-web-react-ui:** 🐛 修复弹窗被隐藏
- **meeting-web-react-ui:** 🐛 修复成员列表筛选无效的 bug
- **meeting-web-react-ui:** 🐛 修复成员离开房间重新打开视频加入无法加载视频
- **meeting-web-react-ui:** 🐛 修复控制栏隐藏导致弹窗隐藏
- **meeting-web-react-ui:** 🐛 修复改名后弹窗内名称未更新问题
- **meeting-web-react-ui:** 🐛 修复断网设置焦点失效问题，ios 微信浏览器获取设备失败无法入会
- **meeting-web-react-ui:** 🐛 修复断网重连造成多个人员重复问题，当前说话这更新频率降低为 4s
- **meeting-web-react-ui:** 🐛 修复样式问题
- **meeting-web-react-ui:** 🐛 修复没有根据说话者排序问题
- **meeting-web-react-ui:** 🐛 修复白板第一次进入显示工具栏问题，修复视频播放问题
- **meeting-web-react-ui:** 🐛 修复监听事件闭包造成无法获取最新数据问题
- **meeting-web-react-ui:** 🐛 修复自动播放受限相关问题
- **meeting-web-react-ui:** 🐛 修复部分移动端浏览器自动播放限制问题
- **meeting-web-react-ui:** 🐛 修改引用报错
- **meeting-web-react-ui:** 🐛 切换摄像头增加防抖处理
- **meeting-web-react-ui:** 🐛 切换摄像头改为先关后切再开
- **meeting-web-react-ui:** 🐛 删除无用代码
- **meeting-web-react-ui:** 🐛 参会者 hint 样式调整
- **meeting-web-react-ui:** 🐛 参会者列表排序
- **meeting-web-react-ui:** 🐛 参会者文案+storybook 页面添加
- **meeting-web-react-ui:** 🐛 参会者角色标签显示两行
- **meeting-web-react-ui:** 🐛 增加 loading+操作栏隐藏
- **meeting-web-react-ui:** 🐛 增加入会密码弹窗+屏幕共享 icon
- **meeting-web-react-ui:** 🐛 字段名修改
- **meeting-web-react-ui:** 🐛 字段名修改
- **meeting-web-react-ui:** 🐛 安装云信 log
- **meeting-web-react-ui:** 🐛 定位改为 absolute，宽高改为百分比
- **meeting-web-react-ui:** 🐛 密码入会重置数据完善
- **meeting-web-react-ui:** 🐛 密码弹窗校验样式+联席主持人显示
- **meeting-web-react-ui:** 🐛 对外销毁接口，无完全清除问题
- **meeting-web-react-ui:** 🐛 开启音视频内增加对当前房间管控状态的处理
- **meeting-web-react-ui:** 🐛 成员列表中的 host 操作不在本期交付内容，先注释掉
- **meeting-web-react-ui:** 🐛 成员列表去除不在 rtc 房间成员
- **meeting-web-react-ui:** 🐛 手放下提示仅当前用户提示
- **meeting-web-react-ui:** 🐛 摄像头切换问题
- **meeting-web-react-ui:** 🐛 操作栏自动隐藏逻辑修复
- **meeting-web-react-ui:** 🐛 本地音视频、改名、dialog
- **meeting-web-react-ui:** 🐛 样式优化
- **meeting-web-react-ui:** 🐛 样式改动
- **meeting-web-react-ui:** 🐛 样式调整
- **meeting-web-react-ui:** 🐛 样式调整
- **meeting-web-react-ui:** 🐛 样式调整
- **meeting-web-react-ui:** 🐛 横屏/点击主画面隐藏工具栏
- **meeting-web-react-ui:** 🐛 浏览器兼容性检测 api 不再通过回调处理
- **meeting-web-react-ui:** 🐛 添加 vConsole，摄像头前后置切换，改名，sdk 升级 1.5
- **meeting-web-react-ui:** 🐛 添加对 meetingInfo 判断
- **meeting-web-react-ui:** 🐛 离开后状态未重置的问题
- **meeting-web-react-ui:** 🐛 离开时重置账号登录状态
- **meeting-web-react-ui:** 🐛 类型修改
- **meeting-web-react-ui:** 🐛 组件底部逻辑补充
- **meeting-web-react-ui:** 🐛 结束/离开会议，成员列表的一些操作
- **meeting-web-react-ui:** 🐛 聊天室样式
- **meeting-web-react-ui:** 🐛 聊天室消息展示不准确
- **meeting-web-react-ui:** 🐛 聊天室消息展示不准确
- **meeting-web-react-ui:** 🐛 联席主持人标签
- **meeting-web-react-ui:** 🐛 自动播放受限时只重播打开音频的成员流
- **meeting-web-react-ui:** 🐛 获取设备信息优化
- **meeting-web-react-ui:** 🐛 补充会议信息逻辑
- **meeting-web-react-ui:** 🐛 轮播样式对齐
- **meeting-web-react-ui:** 🐛 软键盘问题
- **meeting-web-react-ui:** 🐛 还原断网处理
- **meeting-web-react-ui:** 🐛 部分机型机械音
- **meeting-web-react-ui:** 🐛 重复初始化问题
- **meeting-web-react-ui:** 🐛 隐藏 loading 方法提前
- **meeting-web-react-ui:** 🐛 顶部组件逻辑完善
- **meeting-web-react-ui:** 🐛 删除重复测试数据
- **meeting-web-react-ui:** 🐛 头部组件 visible 参数

### NEW Features

- **meeting-web-react-ui:** 🎸 add chatroom
- **meeting-web-react-ui:** 🎸 不在当前画面不订阅视频流
- **meeting-web-react-ui:** 🎸 初始化项目配置
- **meeting-web-react-ui:** 🎸 增加大小屏幕切换
- **meeting-web-react-ui:** 🎸 增加密码登录
- **meeting-web-react-ui:** 🎸 增加浏览器兼容性检查
- **meeting-web-react-ui:** 🎸 增加登出、检查浏览器兼容性 API
- **meeting-web-react-ui:** 🎸 增加错误提示
- **meeting-web-react-ui:** 🎸 密码登录
- **meeting-web-react-ui:** 🎸 成员列表样式修改
- **meeting-web-react-ui:** 🎸 暴露密码登录接口
- **meeting-web-react-ui:** 🎸 替换 icon 引入方式
- **meeting-web-react-ui:** 🎸 添加 neroom 逻辑
- **meeting-web-react-ui:** 🎸 添加 videocard, 引入 icon
- **meeting-web-react-ui:** 🎸 添加 VideoCard 组件
- **meeting-web-react-ui:** 🎸 添加主持人打开本端音视频弹框提示功能
- **meeting-web-react-ui:** 🎸 添加举手功能
- **meeting-web-react-ui:** 🎸 添加全体视频操作，对外暴露宽高设置
- **meeting-web-react-ui:** 🎸 添加匿名登录，添加部分事件监听
- **meeting-web-react-ui:** 🎸 添加画布模块
- **meeting-web-react-ui:** 🎸 添加画布滑动
- **meeting-web-react-ui:** 🎸 添加白板支持
- **meeting-web-react-ui:** 🎸 添加获取会议信息和成员信息接口
- **meeting-web-react-ui:** 🎸 点击小窗阻止冒泡
- **meeting-web-react-ui:** 🎸 登录方法无返回
- **meeting-web-react-ui:** 🎸 头部组件

### BREAKING CHANGES

- **meeting-web-react-ui:** 🧨 1.0.0
