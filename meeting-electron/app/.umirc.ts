import { defineConfig } from 'umi';
const platform = process.env.PLATFORM;
const nodeEnv = process.env.NODE_ENV;

const RUN_ENV = process.env.RUN_ENV || 'development';

const ROOMS_DOMAIN = {
  development: '',
  production: '',
  performance: '',
}[RUN_ENV];

const CREATE_ACCOUNT_URL = {
  development: '',
  production: '',
  performance: '',
}[RUN_ENV];
const MEETING_DOMAIN = {
  development: 'https://meeting.yunxinroom.com',
  production: 'https://meeting.yunxinroom.com',
  performance: 'https://meeting.yunxinroom.com',
}[RUN_ENV];

const APP_KEY = {
  development: '', // 开发环境
  production: '', // 生产环境
  performance: '',
}[RUN_ENV];

const UPDATE_URL = {
  development: '',
  production: '',
  performance: '',
}[RUN_ENV];

const SSO_APP_KEY = {
  development: '',
  production: '',
  performance: '',
}[RUN_ENV];
console.log(
  'ROOMS_DOMAIN ',
  ROOMS_DOMAIN,
  MEETING_DOMAIN,
  APP_KEY,
  UPDATE_URL,
  SSO_APP_KEY,
);

const routes = [
  {
    path: '/',
    component: '@/layouts/index',
    routes: [
      { path: '/', component: '@/pages/index' },
      { path: '/h5', component: '@/pages/h5' },
    ],
  },
];

if (platform === 'electron' || nodeEnv === 'development') {
  routes[0].routes.push(
    { path: '/setting', component: '@/pages/setting' },
    { path: '/history', component: '@/pages/history' },
    { path: '/login', component: '@/pages/login' },
    { path: '/nps', component: '@/pages/nps' },
    { path: '/about', component: '@/pages/about' },
    { path: '/rooms', component: '@/pages/rooms' },
    { path: '/meeting', component: '@/pages/meeting' },
    { path: '/member', component: '@/pages/member' },
    { path: '/chat', component: '@/pages/chat' },
    { path: '/invite', component: '@/pages/invite' },
    { path: '/memberNotify', component: '@/pages/memberNotify' },
    { path: '/plugin', component: '@/pages/plugin' },
    { path: '/notification/list', component: '@/pages/notification/list' },
    { path: '/notification/card', component: '@/pages/notification/card' },
    { path: '/imageCrop', component: '@/pages/imageCrop' },
    { path: '/scheduleMeeting', component: '@/pages/scheduleMeeting' },
    { path: '/monitoring', component: '@/pages/monitoring' },
    { path: '/addressBook', component: '@/pages/addressBook' },
    {
      path: '/screenSharing/video',
      component: '@/pages/screenSharing/video',
    },
    {
      path: '/authorization',
      component: '@/pages/authorization',
    },
  );
}

export default defineConfig({
  favicon: 'favicon.ico',
  nodeModulesTransform: {
    type: 'none',
  },
  routes: routes,
  fastRefresh: {},
  history: {
    type: 'hash',
  },
  publicPath: './',
  outputPath: 'build',
  hash: true,
  webpack5: {},
  chainWebpack(memo, { env, webpack }) {
    memo.module
      .rule('js')
      .include.add(require('path').resolve(__dirname, '../src'))
      .end();
    memo.module
      .rule('node')
      .test(/\.node$/)
      .use('node-loader')
      .loader('node-loader')
      .end();
  },
  define: {
    // 'process.env.PLATFORM': platform,
    'process.env.ROOMS_DOMAIN': ROOMS_DOMAIN,
    'process.env.MEETING_DOMAIN': MEETING_DOMAIN,
    'process.env.APP_KEY': APP_KEY,
    'process.env.UPDATE_URL': UPDATE_URL,
    'process.env.SSO_APP_KEY': SSO_APP_KEY,
    'process.env.MEETING_ENV': RUN_ENV,
    'process.env.CREATE_ACCOUNT_URL': CREATE_ACCOUNT_URL,
  },
});
