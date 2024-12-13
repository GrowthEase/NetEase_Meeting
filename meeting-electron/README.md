<div align="center"><a name="readme-top"></a>
<img height="200" src="./logo.png">
<h1>Meeting-Electron</h1>
本项目是网易会议的Electron、Web实现
</div>  


## ✨ 平台支持
- [Electron](https://www.electronjs.org/)
- Web
- H5  

> 同时支持以上平台的应用及对应组件输出

## ☀️ 授权协议

[MIT](https://github.com/NG-ZORRO/ng-zorro-antd/blob/master/LICENSE)

## ☀️ 项目结构
```
packages/
├── meeting-app-electron/                                     # Electro应用入口
├── meeting-app-web/                                          # Web应用入口
│   ├── src/                            
│   │   ├── pages                                             # Electron独立窗口入口 
│   │   │   ├── about                                         # 批注
│   │   │   ├── annotation                                    # 通用UI组件
│   │   │   ├── bulletScreenMessage                           # 弹幕独立窗口
│   │   │   ├── caption                                       # 字幕独立窗口
│   │   │   ├── chat                                          # 聊天室窗口
│   │   │   ├── immediateMeeting                              # 即可会议窗口
│   │   │   ├── interpreter                                   # 同声传译窗口
│   │   │   ├── invite                                        # 邀请浮窗
│   │   │   ├── joinMeeting                                   # 加入会议窗口
│   │   │   ├── member                                        # 成员列表窗口
│   │   │   ├── memberNotify                                  # 成员通知窗口
│   │   │   ├── monitoring                                    # 质量监控窗口
│   │   │   ├── notification                                  # 通知浮窗窗口
│   │   │   ├── plugin                                        # 会议插件窗口
│   │   │   ├── scheduleMeeting                               # 预约会议窗口
│   │   │   ├── setting                                       # 设置窗口
│   │   │   ├── imageCrop                                     # 编辑头像窗口
│   │   │   ├── transcription                                 # 转写窗口
├── meeting-kit-core/                                         # 会议核心代码包含业务逻辑和UI
│   ├── src/                            
│   │   ├── coomponent            
│   │   │   ├── common                                        # 通用UI组件
│   │   │   ├── electron                                      # Electron UI组件
│   │   │   ├── h5                                            # h5 UI组件
│   │   │   ├── web                                           # Web UI组件
│   │   ├── kit                                               # 组件对外暴露接口
│   │   │   ├── impl                                          # 接口具体实现入口
│   │   │   │   ├── service                                   
│   │   │   │   │   ├── guest_service.ts                      # 访客服务
│   │   │   │   │   ├── meeting_account_service.ts            # 账号服务
│   │   │   │   │   ├── meeting_contacts_service.ts           # 通讯录服务
│   │   │   │   │   ├── meeting_invite_service.ts             # 要求服务
│   │   │   │   │   ├── meeting_message_channel_service.ts    # 消息服务
│   │   │   │   │   ├── meeting_service.ts                    # 会中服务
│   │   │   │   │   ├── pre_meeting_service.ts                # 会前服务
│   │   │   │   │   ├── settings_meeting_service.ts           # 设置
│   │   │   │   ├── meeting_kit.ts                            # 接口入口
│   │   │   ├── interface                                     # 接口声明文件入口
├── meeting-kit-electron/                                     # 会议组件Electron入口
├── meeting-kit-web/                                          # 会议组件Web&H5口
```
## 📦 安装
### 安装前置依赖

node 18.19.0 及以上版本

> 请参考 https://docs.npmjs.com/downloading-and-installing-node-js-and-npm 安装 node

pnpm 9.3.0 及以上版本

> 请参考 https://pnpm.io/installation 安装 pnpm

### 安装项目依赖

在项目根目录下执行以下命令安装依赖：

```bash
$ pnpm install:app
```

## 🔨 使用

设置 appkey
```html
进入packages/meeting-app-web/.umirc.ts 文件编辑APP_KEY字段根据环境填入对应appkey
```
### 启动web服务
在项目根目录下执行以下命令

```bash
$ pnpm start:meeting-app-web
```
> web服务启动后，对应url添加路径/h5即为H5页面入口如: http://localhost:8000/h5

### 启动 Electron
注意启动 Electron 之前需要先启动 web 服务

```bash
$ pnpm start:meeting-app-electron
```

## ⌨️ 应用打包

### web&H5

```bash
$ pnpm run build:web
```
> 产物地址：packages/meeting-app-web/build

### Electron

```bash
$ pnpm run build:electron
```
> 产物地址: packages/meeting-app-electron/dist

## ⌨️ 组件打包
#### Web
进入meeting-electron/packages/meeting-kit-core
```bash
$ cd meeting-electron/packages/meeting-kit-core
$ pnpm run build
$ cd meeting-electron/packages/meeting-kit-web
$ pnpm run build
```
> 完成后会在meeting-kit-web文件夹下生成dist文件夹即为web组件产物，可根据引入方式使用对应文件

#### H5
修改meeting-electron/packages/meeting-kit-core/package.json内容如下：
```bash
main字段值修改为: "dist/index.umd.js"
typings字段值修改为: "dist/types/kit/index.d.ts"
```
```bash
$ cd meeting-electron/packages/meeting-kit-core
$ pnpm run build:h5
$ cd meeting-electron/packages/meeting-kit-web
$ pnpm run build
```
> 完成后会在meeting-kit-web文件夹下生成dist文件夹即为H5组件产物, 可根据引入方式使用对应文件

#### Electron
进入meeting-electron/packages/meeting-kit-electron
```bash
$ cd meeting-electron/packages/meeting-kit-electron
$ pnpm run build
```
> 完成后会在meeting-kit-electron文件夹下生成dist文件即为Electron组件产物, 可根据引入方式使用对应文件

## 修改应用名称
#### Electron
替换packages/meeting-app-electron/package.json文件build字段下productName属性名称
#### Web
替换packages/meeting-app-web/src/components/HomePage/index.tsx下document.title字段
## 修改应用图标
#### mac
替换packages/meeting-app-electron/package.json文件build字段下mac -> icon属性(格式需要icns)
#### Windows
替换packages/meeting-app-electron/package.json文件build字段下win -> icon属性(格式需要ico)
#### Web
替换packages/meeting-app-web/public/favicon.ico
