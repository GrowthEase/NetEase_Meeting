const { app } = require('electron')
const path = require('path')

const agreement = 'nemeeting' // 自定义协议名

const AGREEMENT_REGEXP = new RegExp(`^${agreement}://`)

// 注册自定义协议
function setDefaultProtocol() {
  app.removeAsDefaultProtocolClient(agreement) // 每次运行都删除自定义协议 然后再重新注册
  // 开发模式下在window运行需要做兼容
  if (process.env.NODE_ENV === 'development' && process.platform === 'win32') {
    // 设置electron.exe 和 app的路径
    app.setAsDefaultProtocolClient(agreement, process.execPath, [
      path.resolve(process.argv[1]),
    ])
  } else {
    app.setAsDefaultProtocolClient(agreement)
  }
}

// 初始化监听自定义协议唤起
function watchProtocol(handleUrl) {
  setDefaultProtocol()
  // mac唤醒应用 会激活open-url事件 在open-url中判断是否为自定义协议打开事件
  // TODO：未启动应用情况下，通过链接唤起应用入会
  app.on('open-url', (event, url) => {
    const isProtocol = AGREEMENT_REGEXP.test(url)

    console.log('mac 自定义协议被唤起', url)
    if (isProtocol) {
      handleUrl(url)
    }
  })
  // window系统下唤醒应用会激活second-instance事件 它在ready执行之后才能被监听
  app.on('second-instance', (event, commandLine) => {
    console.log('second-instance', commandLine)
    // commandLine是一个数组，唤醒的链接作为数组的一个元素放在这里面
    commandLine.forEach((str) => {
      if (AGREEMENT_REGEXP.test(str)) {
        console.log('windows 自定义协议被唤起', str)
        handleUrl(str)
      }
    })
  })
}

module.exports = {
  watchProtocol,
}
