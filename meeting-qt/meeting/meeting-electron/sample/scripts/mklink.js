const path = require('path');
const fs = require('fs-extra');

if (process.platform === 'darwin') {
  let client_app_path = `${path.resolve(
    __dirname,
    '../node_modules/electron/dist/Electron.app/Contents/Frameworks/Electron Helper (Renderer).app/Contents/Frameworks'
  )}`;
  let dst = `${client_app_path}/NetEaseMeetingClient.app`;

  fs.rmdirSync(dst, { recursive: true });

  let src = `${path.resolve(
    __dirname,
    '../src/node_modules/nemeeting-sdk/dist/NetEaseMeetingClient.app'
  )}`;
  // console.log('src: ', src);
  // console.log('dst: ', dst);
  fs.copySync(src, dst, { overwrite: true });
}
