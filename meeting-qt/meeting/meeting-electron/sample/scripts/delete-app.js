const path = require('path');
const fs = require('fs');
const glob = require('glob');

exports.default = async function (context) {
  if (process.platform === 'darwin') {
    const basePath =
      '../release/mac/NEMeetingSDKDemo.app/Contents/Resources/app.asar.unpacked';

    glob(
      '*.*.*',
      {
        cwd: path.resolve(__dirname, `${basePath}/node_modules/nemeeting-sdk`),
        mark: true,
      },
      function (err, fileList) {
        if (err) {
          console.log('glob electron version error: ', err);
          return;
        }

        console.log('fileList length:', fileList.length);
        for (let index = 0; index < fileList.length; ) {
          // console.log(`fileList[${index}]: ${fileList[index]}`);
          fs.rmdirSync(
            path.resolve(
              __dirname,
              `${basePath}/node_modules/nemeeting-sdk/${fileList[index]}`
            ),
            {
              recursive: true,
            }
          );
          index += 1;
        }
      }
    );

    fs.rmdirSync(
      path.resolve(
        __dirname,
        `${basePath}/node_modules/nemeeting-sdk/dist/NetEaseMeetingClient.app`
      ),
      { recursive: true }
    );

    fs.rmdirSync(
      path.resolve(__dirname, `${basePath}/node_modules/nemeeting-sdk/bin`),
      {
        recursive: true,
      }
    );

    fs.rmdirSync(
      path.resolve(
        __dirname,
        `${basePath}/node_modules/nemeeting-sdk/nemeeting_sdk`
      ),
      {
        recursive: true,
      }
    );
  } else if (process.platform === 'win32') {
    const basePath = '../release/win-ia32-unpacked/resources/app.asar.unpacked';

    glob(
      '*.*.*',
      {
        cwd: path.resolve(__dirname, `${basePath}/node_modules/nemeeting-sdk`),
        mark: true,
      },
      function (err, fileList) {
        if (err) {
          console.log('glob electron version error: ', err);
          return;
        }

        console.log('fileList length:', fileList.length);
        for (let index = 0; index < fileList.length; ) {
          // console.log(`fileList[${index}]: ${fileList[index]}`);
          fs.rmdirSync(
            path.resolve(
              __dirname,
              `${basePath}/node_modules/nemeeting-sdk/${fileList[index]}`
            ),
            {
              recursive: true,
            }
          );
          index += 1;
        }
      }
    );

    fs.rmdirSync(
      path.resolve(__dirname, `${basePath}/node_modules/nemeeting-sdk/bin`),
      {
        recursive: true,
      }
    );

    fs.rmdirSync(
      path.resolve(
        __dirname,
        `${basePath}/node_modules/nemeeting-sdk/nemeeting_sdk`
      ),
      {
        recursive: true,
      }
    );

    fs.rmdirSync(
      path.resolve(
        __dirname,
        `${basePath}/node_modules/nemeeting-sdk/node-addon-api`
      ),
      {
        recursive: true,
      }
    );
  }
};
