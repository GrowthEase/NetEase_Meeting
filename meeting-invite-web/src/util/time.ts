export function filterDate(time: number) {
  const date = new Date(time)
  const Y = date.getFullYear()
  const M =
    date.getMonth() + 1 < 10 ? '0' + (date.getMonth() + 1) : date.getMonth() + 1
  const D = date.getDate()

  return `${Y}年${M}月${D}日`
}

export function filterTime(time: number, type: number, isEnd: boolean) {
  const date = new Date(time)
  let H: number | string = date.getHours() // 小时
  let M: number | string = date.getMinutes() // 分钟

  if (type !== 3 && isEnd) {
    H = H + 1
  }

  if (H < 10) {
    H = '0' + H
  }

  if (M < 10) {
    M = '0' + M
  }

  return `${H}:${M}`
}
// // js判断是否是苹果设备
// export function checkIsAppleDevice() {
//   var u = navigator.userAgent,
//     app = navigator.appVersion;
//   var ios = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
//   var iPad = u.indexOf('iPad') > -1;
//   var iPhone = u.indexOf('iPhone') > -1 || u.indexOf('Mac') > -1;
//   if (ios || iPad || iPhone) {
//     return true;
//   } else {
//     return false;
//   }
// }
// //js判断是否为Android设备
// export function checkIsAndroidDevice() {
//   var u = navigator.userAgent;
//   if (u.indexOf('Android') > -1 || u.indexOf('Adr') > -1) {
//     return true;
//   } else {
//     return false;
//   }
// } //js判断是否为鸿蒙系统 chos是鸿蒙webview的标识
// export function checkIsHarmonyOS() {
//   var u = navigator.userAgent;
//   if (u.indexOf('ohos') > -1) {
//     return true;
//   } else {
//     return false;
//   }
// }
