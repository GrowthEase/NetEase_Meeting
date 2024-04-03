# NEMeetingKit

NEMeetingKit-electron

## 前置依赖
node 16.14.1
## 下载依赖

```bash
$ npm install node-gyp -g
$ npm run install:app
```

```html
根据当前系统复制根目录下的node-sdk/xx/neroom-node-sdk到app/electron/node_modules下
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
```

### Electron

- 打包 Windows
  - 复制 app/elelctron/package.build.win.json 内容替换到 app/elelctron/package.json
    ```bash
    $ cd app/electron
    $ npm run build
    ```
- 打包 Mac
  - 复制 app/elelctron/package.build.json 内容替换到 app/elelctron/package.json
    ```bash
    $ cd app/electron
    $ npm run build
    ```
