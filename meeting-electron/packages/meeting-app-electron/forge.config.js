module.exports = {
  packagerConfig: {
    appBundleId: 'com.netease.nmc.Meeting',
    name: '网易会议',
    icon: './assets/macx.icns',
    osxUniversal: {
      x64ArchFiles: '**/node_modules/neroom-node-sdk/**',
    },
    osxSign: {
      identity:
        'Developer ID Application: Hangzhou WangyiZhiyun Technology Co. Ltd. (7C9A6NRV5L)',
    },
  },
  rebuildConfig: {
    onlyModules: [],
  },
  makers: [
    {
      name: '@electron-forge/maker-dmg',
      config: {
        icon: 'assets/macx.icns',
        background: 'assets/install-background.png',
        window: {
          size: {
            width: 600,
            height: 400,
          },
        },
        contents: [
          {
            x: 172,
            y: 190,
            type: 'file',
            // arm64 x64 区分
            path: `${process.cwd()}/out/网易会议-darwin-universal/网易会议.app`,
          },
          {
            x: 428,
            y: 190,
            type: 'link',
            path: '/Applications',
          },
        ],
      },
    },
    // window打包
    // {
    //   name: '@electron-forge/maker-squirrel',
    //   config: {
    //     icon: './icon/macx.icns',
    //     noMsi: true,
    //   },
    // },
  ],
}
