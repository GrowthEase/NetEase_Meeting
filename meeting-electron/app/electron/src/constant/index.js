const isLocal = process.env.MODE === 'local';
const isWin32 = process.platform === 'win32';
const MINI_WIDTH = 1150;
const MINI_HEIGHT = 690;
const agreement = 'nemeeting'; // 自定义协议名

module.exports = {
  isLocal,
  isWin32,
  agreement,
  MINI_WIDTH,
  MINI_HEIGHT,
};
