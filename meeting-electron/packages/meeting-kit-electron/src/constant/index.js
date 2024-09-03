const isLocal = process.env.MODE === 'local'
const isWin32 = process.platform === 'win32'
const MINI_WIDTH = 1184
const MINI_HEIGHT = 690

module.exports = {
  isLocal,
  isWin32,
  MINI_WIDTH,
  MINI_HEIGHT,
}
