"use strict";
function initLog(fileName, path) {
    var log = require('electron-log/main');
    log.initialize({ preload: true });
    log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}';
    log.transports.file.maxSize = 1024 * 1024 * 10;
    log.transports.file.fileName = fileName;
    log.errorHandler.startCatching();
    log.eventLogger.startLogging();
    log.transports.file.resolvePathFn = function (variables) {
        return path.join(path, 'app', variables.fileName);
    };
}
function getLogDate() {
    var date = new Date();
    var year = date.getFullYear();
    var month = (date.getMonth() + 1).toString().padStart(2, '0');
    var day = date.getDate().toString().padStart(2, '0');
    var formattedDate = "".concat(year).concat(month).concat(day);
    console.log('formattedDate', formattedDate);
    return formattedDate;
}
module.exports = {
    initLog: initLog,
    getLogDate: getLogDate,
};