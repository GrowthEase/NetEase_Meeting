import { defineConfig } from 'umi';
import ts from 'typescript';
import path from 'path';
import fs from 'fs';

const platform = process.env.PLATFORM;
const nodeEnv = process.env.NODE_ENV;

const RUN_ENV = process.env.RUN_ENV || 'development';
console.log('RUN_ENV>>>>', RUN_ENV);

const ROOMS_DOMAIN = {
  development: 'https://meeting.yunxinroom.com',
  production: 'https://meeting.yunxinroom.com',
  private: 'https://meeting.yunxinroom.com',
}[RUN_ENV];

const CREATE_ACCOUNT_URL = {
  development: 'https://meeting.yunxin.163.com',
  production: 'https://meeting.yunxin.163.com',
  private: 'https://meeting.yunxin.163.com',
}[RUN_ENV];
const MEETING_DOMAIN = {
  development: 'https://meeting.yunxinroom.com',
  production: 'https://meeting.yunxinroom.com',
  private: 'ttps://meeting.yunxinroom.com',
}[RUN_ENV];

const APP_KEY = {
  development: '',
  production: '',
  private: '',
}[RUN_ENV];

const UPDATE_URL = {
  development: '',
  production: '',
  private: '',
}[RUN_ENV];

const SSO_APP_KEY = {
  development: '',
  production: '',
  private: '',
}[RUN_ENV];

const WEBSITE_URL = {
  development: 'https://meeting.163.com/',
  production: 'https://meeting.163.com/',
  private: 'https://meeting.163.com/',
}[RUN_ENV];

const RECORD_URL = {
  production: 'https://meeting.163.com/recordInfo',
  development: 'https://meeting.163.com/recordInfo',
}[RUN_ENV];

const PRIVATE_CONFIG = {
  development: null,
  production: null,
  private: {
    imPrivateConf: {
      lbs: '',
      link: '',
      linkSslWeb: true,
      nosUploader: '',
      nosDownloader: '',
      httpsEnabled: true,
    },
    neRtcServerAddresses: {
      lbsServer: '',
      channelServer: '',
      statisticsServer: '',
      roomServer: '',
      compatServer: '',
      nosLbsServer: '',
      nosUploadSever: '',
      nosTokenServer: '',
      useIPv6: false,
    },
    whiteboardConfig: {
      roomServer: '',
      sdkLogNosServer: '',
      dataReportServer: '',
      directNosServer: '',
      mediaUploadServer: '',
      docTransServer: '',
      fontDownloadServer: '',
      lbsUrl: '',
    },
  },
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
    { path: '/nps', component: '@/pages/nps' },
    { path: '/about', component: '@/pages/about' },
    { path: '/member', component: '@/pages/member' },
    { path: '/chat', component: '@/pages/chat' },
    { path: '/invite', component: '@/pages/invite' },
    { path: '/memberNotify', component: '@/pages/memberNotify' },
    { path: '/plugin', component: '@/pages/plugin' },
    { path: '/notification/list', component: '@/pages/notification/list' },
    { path: '/notification/card', component: '@/pages/notification/card' },
    { path: '/imageCrop', component: '@/pages/imageCrop' },
    { path: '/scheduleMeeting', component: '@/pages/scheduleMeeting' },
    { path: '/joinMeeting', component: '@/pages/JoinMeeting' },
    { path: '/immediateMeeting', component: '@/pages/immediateMeeting' },
    { path: '/feedback', component: '@/pages/feedback' },
    { path: '/live', component: '@/pages/live' },

    { path: '/monitoring', component: '@/pages/monitoring' },
    { path: '/addressBook', component: '@/pages/addressBook' },
    { path: '/captionWindow', component: '@/pages/caption' },
    {
      path: '/transcriptionWindow',
      component: '@/pages/transcription/',
    },
    {
      path: '/transcriptionInMeetingWindow',
      component: '@/pages/transcription/transcriptionInMeeting',
    },
    {
      path: '/interpreterSetting',
      component: '@/pages/interpreter/interpreterSetting',
    },
    {
      path: '/interpreterWindow',
      component: '@/pages/interpreter/interpreterWindow',
    },
    {
      path: '/screenSharing/video',
      component: '@/pages/screenSharing/video',
    },
    {
      path: '/screenSharing/screenMarker/:index',
      component: '@/pages/screenSharing/screenMarker/[index]',
    },
    {
      path: '/authorization',
      component: '@/pages/authorization',
    },
    {
      path: '/annotation',
      component: '@/pages/annotation',
    },
    {
      path: '/meeting-component',
      component: '@/pages/meeting-component',
    },
    {
      path: '/bulletScreenMessageWindow',
      component: '@/pages/bulletScreenMessage',
    },
    {
      path: '/dualMonitors',
      component: '@/pages/dualMonitors',
    },
  );
}

function rendererCompile() {
  const renderersTSPath = path.join(
    __dirname,
    '../meeting-kit-core/src/libs/Renderer/Renderers/ts',
  );

  const renderersJSPath = renderersTSPath.replace(/\/ts$/, '/js');

  console.log('renderersJSPath', renderersJSPath);
  if (!fs.existsSync(renderersJSPath)) {
    fs.mkdirSync(renderersJSPath);
  }
  fs.readdirSync(renderersTSPath).forEach((item) => {
    let filePath = path.join(renderersTSPath, item);
    if (filePath.endsWith('.ts')) {
      const sourceCode = fs.readFileSync(filePath, 'utf8');
      const result = ts.transpileModule(sourceCode, {
        compilerOptions: { module: ts.ModuleKind.CommonJS },
      });

      fs.writeFileSync(
        filePath.replace(/\.ts/, '.js').replace(/\/ts/, '/js'),
        result.outputText,
      );
    }
  });
}


// rendererCompile();

export default defineConfig({
  locale: false,
  initialState: false,
  layout: false,
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
    memo.resolve.alias.set('@meeting-module', '@/../../meeting-kit-core/src');

    memo.resolve.alias.set(
      'nemeeting-core-sdk',
      '@/../../meeting-kit-core/src/kit',
    );

    memo.module
      .rule('js')
      .include.add(require('path').resolve(__dirname, '../meeting-kit-core/'))
      .end();

    // memo.plugin('RendererCompilePlugin')
    //   .use(RendererCompilePlugin);

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
    'process.env.PRIVATE_CONFIG': PRIVATE_CONFIG,
    'process.env.WEBSITE_URL': WEBSITE_URL,
    'process.env.RECORD_URL': RECORD_URL,
  },
});
