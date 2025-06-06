"use strict";
var isLocal = process.env.ENV_MODE === 'local';
var isWin32 = process.platform === 'win32';
var MINI_WIDTH = 1100;
var MINI_HEIGHT = 690;
module.exports = {
    isLocal: isLocal,
    isWin32: isWin32,
    MINI_WIDTH: MINI_WIDTH,
    MINI_HEIGHT: MINI_HEIGHT,
};