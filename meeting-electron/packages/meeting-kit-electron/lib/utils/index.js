"use strict";
var shell = require('electron').shell;
function downloadFileByUrl(url) {
    shell.openExternal(url);
}
module.exports = {
    downloadFileByUrl: downloadFileByUrl,
};