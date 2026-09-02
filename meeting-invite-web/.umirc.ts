import { defineConfig } from 'umi'

const baseUrl = 'https://roomkit.netease.im/'

const webJumpUrl =
  'https://yiyong-qa.netease.im/yiyong-static/statics/ne-meeting-test/prod/#/'

const h5JumpUrl =
  'https://yiyong-qa.netease.im/yiyong-static/statics/ne-meeting-test/h5-prod/#/'

const publicPath =
  'https://yiyong-static.nosdn.127.net/meeting-web-invite-page-prod/'

export default defineConfig({
  hash: true,
  history: {
    type: 'hash',
  },
  publicPath: publicPath,
  routes: [
    { path: '/', component: '@/pages/invitePage' },
    { path: '/invite', component: '@/pages/invitePage' },
  ],
  links: [
    {
      rel: 'icon',
      href: 'https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/node-website/icon@128x128.png',
    },
  ],
  define: {
    'process.env.baseUrl': baseUrl,
    'process.env.webJumpUrl': webJumpUrl,
    'process.env.h5JumpUrl': h5JumpUrl,
  },
})
