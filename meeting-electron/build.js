const fs = require('fs')
const { exec } = require('child_process')
const util = require('util')
const execPromise = util.promisify(exec)

console.log('>>>>>>>>>>start copy<<<<<<<<<<')
fs.cpSync(
  './packages/meeting-app-web/build',
  './packages/meeting-kit-electron/build',
  { recursive: true }
)
console.log('>>>>>>>>>>end copy<<<<<<<<<<')

console.log('>>>>>>>>>>start build nemeeting-electron-sdk<<<<<<<<<<')
execPromise('pnpm -F nemeeting-electron-sdk build')
  .then(async () => {
    console.log('>>>>>>>>>>end build nemeeting-electron-sdk<<<<<<<<<<')
    console.log('>>>>>>>>>>start build nemeeting-app-electron<<<<<<<<<<')
    await execPromise('pnpm -F nemeeting-app-electron build').catch((err) => {
      console.error(
        '>>>>>>>>>>build nemeeting-app-electron error<<<<<<<<<<',
        err
      )
    })
    console.log('>>>>>>>>>>end build nemeeting-app-electron<<<<<<<<<<')
  })
  .catch((err) => {
    console.error('>>>>>>>>>>build nemeeting-electron-sdk error<<<<<<<<<<', err)
  })
