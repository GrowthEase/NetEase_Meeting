const isLocal = process.env.ENV_MODE === 'local'
const isWin32 = process.platform === 'win32'
const MINI_WIDTH = 1100
const MINI_HEIGHT = 690

module.exports = {
  isLocal,
  isWin32,
  MINI_WIDTH,
  MINI_HEIGHT,
}
