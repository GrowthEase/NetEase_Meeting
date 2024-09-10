const { shell } = require('electron');

function downloadFileByUrl(url) {
  shell.openExternal(url);
}

module.exports = {
  downloadFileByUrl,
};
