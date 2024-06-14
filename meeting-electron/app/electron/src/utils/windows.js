function activateApplicationWindowByHandle(winHandle) {
  const ffi = require('ffi-napi');

  const user32 = ffi.Library('user32', {
    SetForegroundWindow: ['bool', ['long']],
    ShowWindow: ['bool', ['long', 'int']],
  });
  const targetWindowHandle = 0x00000000; // Replace with the actual window handle

  // Show and bring the window to the foreground
  user32.ShowWindow(winHandle, 5); // SW_SHOW
  user32.SetForegroundWindow(winHandle);
}
// Get the window handle of the target application
// function getTargetWindowHandleWindows(appName) {
//   const windowTitle = appName; // Replace with the actual window title
//   const windowClassName = null; // Replace with the actual window class name (or use null to match any class)
//
//   // Find the window handle based on the window title and class name
//   const windowHandle = user32.FindWindowA(windowClassName, windowTitle);
//
//   // If the window handle is not found, you can alternatively get the handle of the foreground window
//   // const windowHandle = user32.GetForegroundWindow();
//
//   return windowHandle;
// }

module.exports = {
  activateApplicationWindowByHandle,
};
