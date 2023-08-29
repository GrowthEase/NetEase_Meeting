import { Uploader } from './nosUploader'
import LoggerStorage, { LogName } from './logStorage'
import DataReporter from './DataReporter'
import axios from 'axios'
import { BrowserType } from '../types'
// import sha1 from 'sha1'
const version = '1.0.0'

const salt = '021cc0370d824a51b7c8180485c27b38'
const reporter = DataReporter.getInstance()
const logger = LoggerStorage.getInstance()
export type LogType = 'error' | 'warn' | 'info' | 'log' | 'debug'

/**
 * @description: 获取日志
 * @param {LogName} logName
 * @param {*} start
 * @param {*} end
 * @return {*}
 */
export async function getLog(logName: LogName, start = 0, end = Date.now()) {
  const logInfo = await logger.getLog(logName, start, end)
  let result = ''
  for (const ele of logInfo) {
    result += `[${formatDate(ele.time, 'yyyy-MM-dd hh:mm:ss')}]${
      ele?.logStr
    }\r\n`
  }
  return result
}
let timeout: any
export function throttle(fn: (...args: any) => void, delay = 1000) {
  let prev = Date.now()
  return function (...args: any) {
    // @ts-ignore
    const context = this as any
    const now = Date.now()
    if (now - prev >= delay) {
      fn.apply(context, args)
      prev = Date.now()
    }
  }
}
/**
 * @description: 防抖
 * @param {*} fn
 * @param {*} wait
 * @return {*}
 */
export function debounce<T>(fn: T, wait: any = 300): T {
  let timer: any = null

  return function (...args) {
    if (timer) {
      clearTimeout(timer)
      timer = null
    }

    timer = setTimeout(() => {
      // @ts-ignore
      fn.apply(this, args)
    }, wait)
  } as unknown as T
}
/**
 * @description: 时间格式化
 * @param {*} time
 * @param {*} fmt
 * @return {*}
 */
export function formatDate(
  time: Date | number,
  fmt: any = 'yyyy/MM/dd hh:mm'
): any {
  const date = new Date(time)
  const o: Record<string, string> = {
    'M+': date.getMonth() + 1 + '', //月份
    'd+': date.getDate() + '', //日
    'h+': date.getHours() + '', //小时
    'm+': date.getMinutes() + '', //分
    's+': date.getSeconds() + '', //秒
    'q+': Math.floor((date.getMonth() + 3) / 3) + '', //季度
    S: date.getMilliseconds() + '', //毫秒
  }
  if (/(y+)/.test(fmt))
    fmt = fmt.replace(
      RegExp.$1,
      (date.getFullYear() + '').substr(4 - RegExp.$1.length)
    )
  for (const k in o)
    if (new RegExp('(' + k + ')').test(fmt))
      fmt = fmt.replace(
        RegExp.$1,
        RegExp.$1.length == 1 ? o[k] : ('00' + o[k]).substr(('' + o[k]).length)
      )
  return fmt
}

export function copyElementValue(value: any, callback: () => void) {
  const input = document.createElement('input')
  input.setAttribute('readonly', 'readonly')
  input.setAttribute('value', value)
  document.body.appendChild(input)
  input.setSelectionRange(0, 9999)
  input.select()
  if (document.execCommand('copy')) {
    document.execCommand('copy')
    console.log('复制成功')
    callback()
  }
  document.body.removeChild(input)
}
/**
 * @description: 上传日志
 * @param {*} start
 * @param {*} end
 * @param {Array} logNames
 * @return {*}
 */
export async function uploadLog(
  logNames: Array<LogName> = ['meetingLog', 'imLog', 'rtcLog'],
  start = 0,
  end = Date.now()
) {
  const arr: Array<Promise<any>> = []
  if (!logNames || logNames?.length === 0) {
    logNames = ['meetingLog', 'imLog', 'rtcLog']
  }
  for (const ele of logNames) {
    if (!['meetingLog', 'imLog', 'rtcLog'].includes(ele)) {
      throw new Error(
        `${ele} is not a right arguments, please use right arguments：meetingLog, imLog, rtcLog`
      )
    }
    const logInfo = await getLog(ele, start, end)
    const data = {
      ext: 'log',
      sdkver: version,
      platform: 'web',
      sdktype: 'meeting',
    }
    const [Nonce, CurTime] = [Math.floor(Math.random() * 1000000), Date.now()]
    const fileUploadReq = new Promise<void>((resolve, reject) => {
      axios
        .post('https://statistic.live.126.net/sdklog/getToken', data, {
          headers: {
            'content-type': 'application/json',
            Nonce,
            CurTime,
            // CheckSum: `${sha1(JSON.stringify(data) + Nonce + CurTime + salt)}`,
          },
        })
        .then((response) => {
          const nosRes = response?.data?.data
          const uploader = Uploader({
            onError: function (err) {
              reject(err)
            },
          })
          const file = new File([logInfo], `${CurTime}.log`, {
            type: 'application/json',
          })
          uploader.addFile(file)
          uploader.upload(
            {
              bucketName: nosRes.bucket,
              objectName: nosRes.fileName,
              token: nosRes.xNosToken,
            },
            function () {
              // dataReport(dataReportAddr, 'logUpload', `${dataReportParams.appkey}-${dataReportParams.channel}`, {
              //     uid: dataReportParams.uid,
              //     appkey: dataReportParams.appkey,
              //     channel: dataReportParams.channel,
              //     filename: nosRes.data.fileName,
              //     time: Date.now()
              // })
              resolve(nosRes.fileName)
            }
          )
        })
    })
    arr.push(fileUploadReq)
  }
  try {
    const result = await Promise.all(arr)
    reporter.sendLog({
      action_name: 'meeting-log-upload',
      log: result.toString(),
    })
    return result
  } catch (e) {
    console.error('upload error', e)
    throw e
  }
}

/**
 * @description: 下载日志
 * @param {*} start
 * @param {*} end
 * @param {Array} logName
 * @return {*}
 */
export async function downloadLog(
  logNames: Array<LogName> = ['meetingLog', 'imLog', 'rtcLog'],
  start = 0,
  end = Date.now()
) {
  if (!logNames || logNames?.length === 0) {
    logNames = ['meetingLog', 'imLog', 'rtcLog']
  }
  for (const ele of logNames) {
    if (!['meetingLog', 'imLog', 'rtcLog'].includes(ele)) {
      throw new Error(
        `${ele} is not a right arguments, please use right arguments：meetingLog, imLog, rtcLog`
      )
    }
    const logInfo = await getLog(ele, start, end)
    const logBlob = new Blob([logInfo], { type: 'application/json' })
    const a = document.createElement('a')
    a.download = `${ele}-${start}-${end}.log`
    const href = window.URL.createObjectURL(logBlob)
    a.href = href
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(href)
  }
}

// 判断系统
export function getClientType(): 'Android' | 'IOS' | 'PC' {
  const u = navigator.userAgent
  const isAndroid = u.indexOf('Android') > -1 || u.indexOf('Adr') > -1 //判断是否是 android终端
  const isIOS = !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/) //判断是否是 iOS终端
  if (isAndroid) {
    return 'Android'
  } else if (isIOS) {
    return 'IOS'
  } else {
    return 'PC'
  }
}

//获取判断浏览器类型
export function getBrowserType(): BrowserType {
  const ua = navigator.userAgent.toLowerCase()
  if (!ua) {
    return BrowserType.UNKNOWN
  }
  if (ua.match(/MicroMessenger/i)) {
    return BrowserType.WX
  } else if (navigator.userAgent.indexOf('UCBrowser') > -1) {
    return BrowserType.UC
  } else if (navigator.userAgent.indexOf('MQQBrowser') > -1) {
    return BrowserType.QQ
  } else {
    return BrowserType.OTHER
  }
}

// 获取ios系统版本
export function getIosVersion(): string {
  // 获取 User Agent 字符串
  const userAgent = navigator.userAgent

  // 使用正则表达式提取 iOS 版本号
  const match = userAgent.match(/(iPhone|iPad|iPod)\s+OS\s+([\d_]+)/)
  return match && match[2] ? match[2].replace(/_/g, '.') : ''
}

export function getDefaultLanguage(): string {
  return ['zh-CN', 'en-US', 'ja-JP'].includes(navigator?.language)
    ? navigator?.language
    : 'en-US'
}

export function getMeetingDisplayId(meetingNum: string | undefined): string {
  if (!meetingNum) {
    return ''
  }
  return (
    meetingNum.slice(0, 3) +
    '-' +
    meetingNum.slice(3, 6) +
    (meetingNum?.length > 6 ? `-${meetingNum.slice(6)}` : '')
  )
}
