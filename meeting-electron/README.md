# Meeting-Electron

网易会议 Electron 应用

## 前置依赖
node 16.20.2
> 请参考 https://docs.npmjs.com/downloading-and-installing-node-js-and-npm 安装 node

## 下载依赖

在`meeting-electron`项目根目录下执行以下命令安装依赖：

```bash
$ npm install node-gyp -g
$ npm run install:app
```

```html
根据当前系统复制根目录下的node-sdk/{系统}/neroom-node-sdk文件夹到app/electron/node_modules下
```

## 使用

### 设置appkey
```html
进入app/.umirc.ts 文件编辑APP_KEY字段根据环境填入对应appkey
```

### 启动 web 服务

```bash
$ cd app
$ npm start
```

### 启动 Electron

- 注意启动 Electron 之前需要先启动 web 服务

```bash
$ cd app/electron
$ npm start
```

## 打包

### web

```bash
$ cd app
$ npm run build:prod

完成后会在app文件夹下生成build文件夹
```

### Electron
- 注意打包Electron之前需要先打包 web
- 复制 app下build文件夹到 app/electron下
```bash
- 打包 Windows
  - 复制 app/electron/package.build.win.json 内容替换到 app/electron/package.json
    ```bash
    $ cd app/electron
    $ npm run build
    ```
- 打包 Mac
  - 复制 app/electron/package.build.json 内容替换到 app/electron/package.json
    ```bash
    $ cd app/electron
    $ npm run build
    ```
- 产物地址
```html
app/electron/dist
```
