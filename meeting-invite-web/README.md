# 会议邀请页

这是一个基于 Umi、React 和 TypeScript 的会议邀请页，提供以下入口：

- 邀请详情：`/` 或 `/invite?meeting=<会议邀请码>`

## 开发与构建

安装依赖并启动本地预览服务。预览服务使用线上 API 和入会地址：

```bash
yarn
yarn start
```

构建线上版本：

```bash
yarn build
```

构建产物默认输出到 `dist/`。部署前请确认 `.umirc.ts` 中的 API 地址、网页跳转地址和静态资源发布地址都已替换为目标环境的值。

## 当前默认值

以下值与当前 [`.umirc.ts`](.umirc.ts)、Logo 组件和邀请页代码保持一致。项目当前只保留线上配置：

| 配置项 | 默认值 |
| --- | --- |
| 软件名称 | `网易会议` |
| 线上 API 地址 | `https://roomkit.netease.im/` |
| 线上网页版入会 | `https://yiyong-qa.netease.im/yiyong-static/statics/ne-meeting-test/prod/#/` |
| 线上 H5 入会 | `https://yiyong-qa.netease.im/yiyong-static/statics/ne-meeting-test/h5-prod/#/` |
| 线上 `publicPath` | `https://yiyong-static.nosdn.127.net/meeting-web-invite-page-prod/` |
| APP 入会协议 | `nemeeting://meeting.netease.im/` |
| APP 下载地址 | `https://meeting.163.com/` |
| 浏览器 favicon | `https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/node-website/icon@128x128.png` |

`yarn start` 仅用于本地预览，但请求仍发送到线上服务；`yarn build` 构建线上版本。会议邀请码没有默认值，必须通过 URL 的 `meeting` 参数传入，例如 `/invite?meeting=123456`。

## 替换软件名称和图标

### 顶部固定名称和图标

邀请详情页中的软件名称和主图标位于 [`src/pages/invitePage/index.tsx`](src/pages/invitePage/index.tsx)。

1. 修改卡片标题 `网易会议`，替换为目标软件名称。
2. 将页面中的内嵌 SVG 替换为目标 Logo。可以直接替换 `<svg>...</svg>` 内容，也可以改成图片：

   ```tsx
   <img src={require('../../assets/logo.png')} alt="软件 Logo" />
   ```

3. 如果使用图片，请把文件放到 `src/assets/`，并根据图片比例调整 `width`、`height` 和外层间距。

### 邀请详情页名称

该文件中还有“该页面会唤起网易会议”“若您已安装了网易会议”等提示语，如软件改名，应一并搜索并替换。

### 浏览器标签页图标

浏览器 favicon 配置在 [`.umirc.ts`](.umirc.ts) 的 `links` 中：

```ts
links: [
  {
    rel: 'icon',
    href: 'https://example.com/assets/favicon.png',
  },
],
```

也可以使用项目内资源。修改后重新构建，并清理浏览器缓存验证。

### 邀请页中的其他图片

- `src/assets/background.png`：桌面端背景图。
- `src/assets/Frame.png`：网页入会按钮中的图标。
- `src/assets/openBrowserTip.png`：微信、QQ、POPO 等内置浏览器中的“请用默认浏览器打开”提示图。

替换这些资源时保持文件路径不变最简单；如果修改文件名，需要同步修改 `invitePage/index.tsx` 中对应的 `require(...)` 路径。

## 更换网页入会、H5 入会和 APP 唤起

### 网页版和 H5 入会地址

地址集中配置在 [`.umirc.ts`](.umirc.ts) 的 `webJumpUrl` 和 `h5JumpUrl`。项目当前只配置线上地址：

```ts
const webJumpUrl = 'https://example.com/web/#/'
const h5JumpUrl = 'https://example.com/h5/#/'
```

点击“网页版入会”或移动端“加入会议”时，页面会向目标地址追加以下参数：

```text
meetingId=<会议号>
meetingAppKey=<应用 AppKey>
guestJoinType=<访客入会类型>
type=invitation
```

目标网页需要兼容这些参数，并根据实际路由决定 `#`、`?` 的位置。如果目标地址已经包含查询参数，请在 `invitePage/index.tsx` 中调整拼接方式，不要直接重复添加 `?`。

当前代码对 `location.origin === 'https://meeting.163.com'` 做了特殊处理，会改用该域名下的 `/app/` 和 `/app/#/h5/`。如果更换正式站点域名，请同步修改或删除这段特殊分支。

### APP 入会协议

APP 入会使用自定义协议，代码位于 [`src/pages/invitePage/index.tsx`](src/pages/invitePage/index.tsx) 的 `getMeetingInfo` 和 `joinMeeting`：

```ts
window.location.href =
  `nemeeting://meeting.netease.im/?meetingId=${meetingNum}&type=invitation`
```

更换 APP 协议时需要同时修改这两处，并确认桌面端/移动端系统已经注册该协议。若协议参数名称变化，也要同步修改 APP 端的解析逻辑。

### 下载地址

无法唤起 APP 时，“立即下载”按钮会跳转到 `invitePage/index.tsx` 中 `download` 函数的地址：

```ts
window.location.href = 'https://meeting.163.com/'
```

将其替换为软件下载页、应用商店地址或自有下载页。若需要按操作系统分别跳转，应在 `download` 函数中根据 User-Agent 分流。

## 发布前检查

- 确认线上 API、`webJumpUrl`、`h5JumpUrl` 和 `publicPath` 均为正式发布地址，不要误填测试/QA 域名。
- 替换 Logo、背景和字体等资源前确认拥有相应的商标、版权和再分发授权。
- 发布前执行一次完整构建，并在桌面浏览器、移动浏览器、微信/QQ 内置浏览器和已安装 APP 的环境分别验证跳转。
