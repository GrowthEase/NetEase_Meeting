"use strict";
// 根据窗口名称设置窗口焦点
function activateApplicationWindowByName(targetName) {
    var applescript = require('applescript');
    var exec = require('child_process').exec;
    var script = "\n            tell application \"System Events\"\n              set allProcesses to every process whose background only is false\n              repeat with proc in allProcesses\n                try\n                  if window \"".concat(targetName, "\" of proc exists then\n                      return name of proc\n                  end if\n                end try\n              end repeat\n            end tell\n          ");
    applescript.execString(script, function (err, rtn) {
        if (err) {
            console.error(err);
        }
        else {
            exec("osascript -e 'tell application \"System Events\" to tell process \"".concat(rtn || targetName, "\" to set frontmost to true'"));
            console.log(rtn); // 这就是窗口id对应的app名称
        }
    });
}
module.exports = {
    activateApplicationWindowByName: activateApplicationWindowByName,
};