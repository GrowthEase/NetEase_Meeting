function initLog(fileName, path) {
  const log = require('electron-log/main');
  log.initialize({ preload: true });
  log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}';
  log.transports.file.maxSize = 1024 * 1024 * 10;
  log.transports.file.fileName = fileName;
  log.errorHandler.startCatching();
  log.eventLogger.startLogging();

  log.transports.file.resolvePathFn = (variables) =>
    path.join(path, 'app', variables.fileName);
}
function getLogDate() {
  const date = new Date();
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');

  const formattedDate = `${year}${month}${day}`;
  console.log('formattedDate', formattedDate);
  return formattedDate;
}

module.exports = {
  initLog,
  getLogDate,
};
