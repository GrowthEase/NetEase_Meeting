// 根据窗口名称设置窗口焦点
function activateApplicationWindowByName(targetName) {
  const applescript = require('applescript');
  const { exec } = require('child_process');
  const script = `
            tell application "System Events"
              set allProcesses to every process whose background only is false
              repeat with proc in allProcesses
                try
                  if window "${targetName}" of proc exists then
                      return name of proc
                  end if
                end try
              end repeat
            end tell
          `;
  applescript.execString(script, function (err, rtn) {
    if (err) {
      console.error(err);
    } else {
      exec(
        `osascript -e 'tell application "System Events" to tell process "${
          rtn || targetName
        }" to set frontmost to true'`,
      );
      console.log(rtn); // 这就是窗口id对应的app名称
    }
  });
}

module.exports = {
  activateApplicationWindowByName,
};
