# Meeting-Electron

网易会议 Electron 应用

## 前置依赖

node 18.19.0 及以上版本

> 请参考 https://docs.npmjs.com/downloading-and-installing-node-js-and-npm 安装 node

pnpm 9.3.0 及以上版本

> 请参考 https://pnpm.io/installation 安装 pnpm

## 下载依赖

在项目根目录下执行以下命令安装依赖：

```bash
$ pnpm install:app
```

## 使用

### 设置 appkey

```html
进入packages/meeting-app-web/.umirc.ts 文件编辑APP_KEY字段根据环境填入对应appkey
```

### 启动 web 服务

在项目根目录下执行以下命令：

```bash
$ pnpm start:meeting-app-web
```

### 启动 Electron

- 注意启动 Electron 之前需要先启动 web 服务

```bash
$ pnpm start:meeting-app-electron
```

## 打包

### web

```bash
$ pnpm run build:web

完成后会在packages/meeting-app-web文件夹下生成build文件夹
```

### Electron

```bash
- 打包
    $ pnpm run build:electron
- 产物地址
  packages/meeting-app-electron/dist
```

## 修改应用名称
### Electron
替换packages/meeting-app-electron/package.json文件build字段下productName属性名称
### Web
替换packages/meeting-app-web/src/components/HomePage/index.tsx下document.title字段
## 修改应用图标
### Electron
### mac
替换packages/meeting-app-electron/package.json文件build字段下mac -> icon属性(格式需要icns)
### Windows
替换packages/meeting-app-electron/package.json文件build字段下win -> icon属性(格式需要ico)
### Web
替换packages/meeting-app-web/public/favicon.ico
