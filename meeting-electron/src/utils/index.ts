import axios from 'axios'
import { getI18n } from 'react-i18next'
import { Md5 } from 'ts-md5/dist/md5'
import { BrowserType } from '../types'
import DataReporter from './DataReporter'
import LoggerStorage, { LogName } from './logStorage'
import { Uploader } from './nosUploader'
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
/**
 * @description: 深拷贝
 * @param {object} target
 * @return {*}
 */
export function deepClone(target: any) {
  if (target === null) return null
  if (typeof target !== 'object') return target
  const cloneTarget = Array.isArray(target) ? [] : {}
  for (const prop in target) {
    // Object.prototype.hasOwnProperty() 方法会返回一个布尔值，指示对象自身属性中是否具有指定的属性（也就是，是否有指定的键）
    // eslint-disable-next-line no-prototype-builtins
    if (target.hasOwnProperty(prop)) {
      cloneTarget[prop] = deepClone(target[prop])
    }
  }
  return cloneTarget
}

/**
 * @description: 检测是否包含属性
 * @param {*} obj
 * @param {*} itemName
 * @return {*}
 */
export function hasOwnType(obj, itemName) {
  return Object.prototype.hasOwnProperty.call(obj, itemName)
}

/**
 * 校验参数是否合法
 * @param param
 * @returns
 */
export function isLegalParam(param: string) {
  return param !== undefined && param !== null && param !== ''
}

/**
 * @description: 判断类型
 * @param {any} val
 * @param {*} type
 * @return {*}
 */
export function checkType(val: any, type?: string) {
  // 检测类型
  if (type)
    return (
      Object.prototype.toString.call(val).slice(8, -1).toLowerCase() ===
      type.toLowerCase()
    )
  return Object.prototype.toString.call(val).slice(8, -1).toLowerCase()
}

export function setDefaultDevice(devices: any[]): any[] {
  //  c++Electron环境才需要
  if (window.isElectronNative) {
    if (devices) {
      const index = devices.findIndex((device) => {
        return device.defaultDevice
      })
      if (index > -1) {
        const device = { ...devices[index] }
        device.originDeviceId = device.deviceId
        device.deviceId = `default$${device.deviceId}`
        device.deviceName =
          getI18n().t('defaultDevice') + ':' + device.deviceName
        device.default = true
        devices.unshift(device)
      }
    }
  }
  return devices
}

export function getDefaultDeviceId(deviceId: string): string {
  if (!deviceId) {
    return deviceId
  }
  const match = deviceId.match(/default\$(.*)/)
  return match ? match[1] : deviceId
}

export function checkIsDefaultDevice(deviceId: string | undefined): boolean {
  if (!deviceId) {
    return false
  }
  const match = deviceId.match(/default\$(.*)/)
  return !!match
}

/* 通过文字二进制得到文字字节数 */
function getByteByBinary(binaryCode: any) {
  /**
   * 二进制 Binary system,es6表示时以0b开头
   * 八进制 Octal number system,es5表示时以0开头,es6表示时以0o开头
   * 十进制 Decimal system
   * 十六进制 Hexadecimal,es5、es6表示时以0x开头
   */
  const byteLengthDatas = [0, 1, 2, 3, 4]
  const len = byteLengthDatas[Math.ceil(binaryCode.length / 8)]
  return len
}
/* 通过文字十六进制得到文字字节数 */
function getByteByHex(hexCode: string) {
  return getByteByBinary(parseInt(hexCode, 16).toString(2))
}

export function substringByByte3(str: string, maxLength: number) {
  if (!str || str.length <= maxLength) return str
  let result = ''
  let flag = false
  let len = 0
  let length = 0
  let length2 = 0
  for (let i = 0; i < str.length; i++) {
    const code = str.codePointAt(i)?.toString(16)
    if (!code) {
      return
    }
    if (code.length > 4) {
      i++
      if (i + 1 < str.length) {
        flag = str.codePointAt(i + 1)?.toString(16) == '200d'
      }
    }
    if (flag) {
      len += getByteByHex(code)
      if (i == str.length - 1) {
        length += len
        if (length <= maxLength) {
          result += str.substr(length2, i - length2 + 1)
        } else {
          break
        }
      }
    } else {
      if (len != 0) {
        length += len
        length += getByteByHex(code)
        if (length <= maxLength) {
          result += str.substr(length2, i - length2 + 1)
          length2 = i + 1
        } else {
          break
        }
        len = 0
        continue
      }
      length += getByteByHex(code)
      if (length <= maxLength) {
        if (code.length <= 4) {
          result += str[i]
        } else {
          result += str[i - 1] + str[i]
        }
        length2 = i + 1
      } else {
        break
      }
    }
  }
  return result
}

// 生成uuid
export function getUUID(): string {
  let date = new Date().getTime()
  const uuid = 'xxxxxxxx-xxxx-xxxx-xxxx'.replace(/[xy]/g, function (c) {
    const r = (date + Math.random() * 16) % 16 | 0
    date = Math.floor(date / 16)
    return (c == 'x' ? r : (r & 0x3) | 0x8).toString(16)
  })
  return uuid
}

const ROOMKIT_UUID = 'NERoomkit-uuid'
export function getDeviceKey() {
  let uuid = window.sessionStorage.getItem(ROOMKIT_UUID)
  if (uuid) {
    return uuid
  } else {
    uuid = getUUID()
    window.sessionStorage.setItem(ROOMKIT_UUID, uuid)
  }
  return uuid
}

const passwordHash = '@yiyong.im'

export function md5Password(password: string) {
  return Md5.hashStr(password + passwordHash)
}

/**
 * @description:
 * @param obj
 * @returns {string}
 */
export function objectToQueryString(obj: Record<string, any>): string {
  const keys = Object.keys(obj)
  const keyValuePairs = keys.map((key) => {
    return encodeURIComponent(key) + '=' + encodeURIComponent(obj[key])
  })
  return keyValuePairs.join('&')
}
//获取昵称方法
/**
 * 中文（最多两位，取最后两位） 》 英文 （最多两位，取前面两位）》 数字（最多两位，取最后两位） 》* 号
 */
export function getUserName(name: string): string {
  if (!name) {
    return '*'
  }
  const chineseMatch = name.match(/[\u4e00-\u9fff]+/g) // 匹配中文字符
  const allChinese = chineseMatch ? chineseMatch.join('') : '' // 将所有中文字符连接在一起

  const englishMatch = name.match(/[a-zA-Z]+/g) // 匹配英文字母
  const allEnglish = englishMatch ? englishMatch.join('') : ''

  const digitMatch = name.match(/\d+/g) // 匹配数字
  const allDigits = digitMatch ? digitMatch.join('') : ''

  if (allChinese) {
    return allChinese.slice(-2) // 取后面最多两个中文字符
  } else if (allEnglish) {
    return allEnglish.slice(0, 2) // 取前面最多两位英文字母
  } else if (allDigits) {
    return allDigits.slice(-2) // 取后面最多两位数字
  } else {
    return '*'
  }
}

export function checkPassword(pwd: string): boolean {
  return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d\S]{6,18}$/.test(pwd)
}

export function isPromiseCheck(obj): boolean {
  return (
    !!obj && //有实际含义的变量才执行方法，变量null，undefined和''空串都为false
    (typeof obj === 'object' || typeof obj === 'function') && // 初始promise 或 promise.then返回的
    typeof obj.then === 'function'
  )
}
