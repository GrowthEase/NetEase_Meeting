import axios from 'axios'
import { getI18n } from 'react-i18next'
import { Md5 } from 'ts-md5/dist/md5'
import { BrowserType, CommonBar, MeetingSetting, UserEventType } from '../types'
import LoggerStorage, { LogName } from './logStorage'
import { LoginUserInfo } from '../app/src/types'
import {
  ACCOUNT_INFO_KEY,
  LANGUAGE_KEY,
  LOCALSTORAGE_CUSTOM_LANGS,
  LOCALSTORAGE_MEETING_SETTING,
} from '../config'
import {
  NEDeviceBaseInfo,
  NERoomCaptionTranslationLanguage,
} from 'neroom-types'
import dayjs from 'dayjs'
import { NEMeetingPrivateConfig } from '../types/type'
import EventEmitter from 'eventemitter3'
import { MenuClickType } from '../kit/interface/service/meeting_service'
import { createDefaultSetting } from '../services'
import { i18n, MeetingPermission, MeetingSecurityCtrlValue } from '../kit'
import { NEMeetingASRTranslationLanguage } from '../kit/interface'
import timezones_zh from '../locales/timezones/timezones_zh'

// import sha1 from 'sha1'
const version = '1.0.0'

const logger = LoggerStorage.getInstance()

export type LogType = 'error' | 'warn' | 'info' | 'log' | 'debug'

/**
 * @description: 获取日志
 * @param {LogName} logName
 * @param {*} start
 * @param {*} end
 * @return {*}
 */
export async function getLog(
  logName: LogName,
  start = 0,
  end = Date.now()
): Promise<string> {
  const logInfo = await logger.getLog(logName, start, end)
  let result = ''

  for (const ele of logInfo) {
    result += `[${formatDate(ele.time, 'yyyy-MM-dd hh:mm:ss')}]${
      ele?.logStr
    }\r\n`
  }

  return result
}

export function throttle<T extends (...args) => void>(fn: T, delay = 1000): T {
  let prev = Date.now()

  return function (...args) {
    const context = this as unknown
    const now = Date.now()

    if (now - prev >= delay) {
      fn.apply(context, args)
      prev = Date.now()
    }
  } as unknown as T
}

/**
 * @description: 防抖
 * @param {*} fn
 * @param {*} wait
 * @return {*}
 */
export function debounce<T>(fn: T, wait: number = 300): T {
  let timer: null | ReturnType<typeof setTimeout> = null

  return function (...args) {
    if (timer) {
      clearTimeout(timer)
      timer = null
    }

    timer = setTimeout(() => {
      fn.apply(this, args)
    }, wait)
  } as unknown as T
}

export function getDateFormatString(language: string) {
  if (language.startsWith('zh') || language.startsWith('ja')) {
    return 'YYYY[年]MM[月]DD[日]'
  }

  return 'MMMM DD, YYYY'
}

/**
 * @description: 时间格式化
 * @param {*} time
 * @param {*} fmt
 * @return {*}
 */
export function formatDate(
  time: Date | number | string,
  fmt: string = 'yyyy/MM/dd hh:mm',
  timezone?: string,
  language?: string
): string {
  if (timezone) {
    return language
      ? dayjs(time).locale(language).tz(timezone).format(fmt)
      : dayjs(time).tz(timezone).format(fmt)
  } else {
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
          RegExp.$1.length == 1
            ? o[k]
            : ('00' + o[k]).substr(('' + o[k]).length)
        )
  }

  return fmt
}

/**
 * @description: 获取当前时间
 */
export function getCurrentDateTime(): { time: string; date: string } {
  const now = new Date()
  const time = `${now.getHours().toString().padStart(2, '0')}:${now
    .getMinutes()
    .toString()
    .padStart(2, '0')}`
  const date = now.toISOString().slice(0, 10)

  return { time, date }
}

export function formatTimestamp(timestamp: number): string {
  const date = new Date(timestamp)
  const year = date.getFullYear()
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')

  return `${year}-${month}-${day} ${hours}:${minutes}`
}

export function copyElementValue(value, callback: () => void): void {
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

export function copyElementValueLineBreak(
  value: string,
  callback: () => void
): void {
  const oInput = document.createElement('textarea')

  oInput.value = value
  document.body.appendChild(oInput)
  oInput.select() // 选择对象
  document.execCommand('Copy') // 执行浏览器复制命令
  oInput.className = 'oInput'
  oInput.style.display = 'none'
  document.body.removeChild(oInput)
  callback()
}

/**
 * @description: 上传日志
 * @param {*} start
 * @param {*} end
 * @param {Array} logNames
 * @return {*}
 */
export async function uploadLog(
  logNames: Array<LogName> = ['meetingLog', 'imLog', 'rtcLog']
) {
  const arr: Array<Promise<void>> = []

  if (!logNames || logNames?.length === 0) {
    logNames = ['meetingLog', 'imLog', 'rtcLog']
  }

  for (const ele of logNames) {
    if (!['meetingLog', 'imLog', 'rtcLog'].includes(ele)) {
      throw new Error(
        `${ele} is not a right arguments, please use right arguments：meetingLog, imLog, rtcLog`
      )
    }

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

    arr.push(fileUploadReq as never)
  }

  try {
    const result = await Promise.all(arr)

    return result
  } catch (e) {
    console.error('upload error', e)
    throw e
  }
}

/**
 * @description: 格式化当前时间
 */
export function formatTimeWithLanguage(
  timestamp: number,
  language: string
): string {
  const date = new Date(timestamp)
  const isEnUS = language === 'en-US'
  const month = date.toLocaleString(isEnUS ? 'en-US' : 'ja-JP', {
    month: 'long',
  })
  const day = date.getDate()

  if (isEnUS) {
    return `${month} ${day}`
  } else {
    return `${date.getMonth() + 1}月${day}日`
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

export function filterDate(time: number) {
  const date = new Date(time)
  const Y = date.getFullYear()
  const M =
    date.getMonth() + 1 < 10 ? '0' + (date.getMonth() + 1) : date.getMonth() + 1
  const D = date.getDate()

  return `${Y}年${M}月${D}日`
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
export function deepClone(target) {
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
export function hasOwnType(obj, itemName): boolean {
  return Object.prototype.hasOwnProperty.call(obj, itemName)
}

/**
 * 校验参数是否合法
 * @param param
 * @returns
 */
export function isLegalParam(param: string): boolean {
  return param !== undefined && param !== null && param !== ''
}

/**
 * @description: 判断类型
 * @param val
 * @param {*} type
 * @return {*}
 */
export function checkType(val, type?: string): boolean | string {
  // 检测类型
  if (type)
    return (
      Object.prototype.toString.call(val).slice(8, -1).toLowerCase() ===
      type.toLowerCase()
    )
  return Object.prototype.toString.call(val).slice(8, -1).toLowerCase()
}

export function setDefaultDevice(
  devices: NEDeviceBaseInfo[]
): NEDeviceBaseInfo[] {
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
function getByteByBinary(binaryCode: string) {
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

export function substringByByte3(
  str: string,
  maxLength: number
): string | undefined {
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
export function objectToQueryString(
  obj: Record<string, string | number>
): string {
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

/**
 * 解析输入的文件大小
 * @param size 文件大小，单位b
 * @param level 递归等级，对应fileSizeMap
 */
export const parseFileSize = (size: number, level = 0): string => {
  const fileSizeMap: { [key: number]: string } = {
    0: 'B',
    1: 'KB',
    2: 'MB',
    3: 'GB',
    4: 'TB',
  }

  const handler = (size: number, level: number): string => {
    if (level >= Object.keys(fileSizeMap).length) {
      return 'the file is too big'
    }

    if (size < 1024) {
      return `${size}${fileSizeMap[level]}`
    }

    return handler(Math.round(size / 1024), level + 1)
  }

  return handler(size, level)
}

/**
 * 下载文件
 * @param url
 * @param fileName
 */
export function downloadFile(url: string): void {
  // 使用 iframe 下载文件
  const iframe = document.createElement('iframe')

  document.body.appendChild(iframe)
  iframe.src = url
  setTimeout(() => {
    document.body.removeChild(iframe)
  }, 5000)
}

/**
 * @description: 持续时间格式化 返回"xx:xx"
 * @param startTime 开始时间
 */
export function meetingDuration(startTime: number): string {
  const now = new Date().getTime()
  const duration = now - startTime
  const hours = Math.floor(duration / (1000 * 60 * 60))
  const minutes = Math.floor((duration % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((duration % (1000 * 60)) / 1000)
  let durationString = ''

  if (hours >= 1) {
    durationString += `${hours.toString().padStart(2, '0')}:`
  }

  durationString += `${minutes.toString().padStart(2, '0')}:${seconds
    .toString()
    .padStart(2, '0')}`
  return durationString
}

// 最后是否为表情符号
export function isLastCharacterEmoji(str: string): boolean {
  // 使用正则表达式匹配表情符号
  const emojiRegex = /[\uD83C-\uDBFF\uDC00-\uDFFF]+$/u

  return emojiRegex.test(str)
}

function getUserUuid() {
  const userInfoStr = localStorage.getItem(ACCOUNT_INFO_KEY)
  let userUuid: string | undefined

  if (userInfoStr) {
    try {
      const userInfo = JSON.parse(userInfoStr) as LoginUserInfo

      userUuid = userInfo.userUuid
    } catch {
      //
    }
  }

  return userUuid
}

export function setLocalStorageSetting(str: string) {
  const userUuid = getUserUuid()

  userUuid &&
    localStorage.setItem(`${LOCALSTORAGE_MEETING_SETTING}-${userUuid}`, str)
}

export function getLocalStorageSetting(): MeetingSetting {
  let setting = createDefaultSetting()
  const userUuid = getUserUuid()
  const language = localStorage.getItem(LANGUAGE_KEY)

  if (!userUuid) {
    if (language && setting.normalSetting?.language === '') {
      setting.normalSetting.language = language
    }

    return setting
  }

  const userKey = `${LOCALSTORAGE_MEETING_SETTING}-${userUuid}`
  const settingStr = localStorage.getItem(userKey)

  if (settingStr) {
    try {
      const tmpSetting = JSON.parse(settingStr) as MeetingSetting

      setting = { ...setting, ...tmpSetting }
    } catch (error) {
      console.log('getLocalStorageSetting err', error)
    }
  }

  if (language && setting.normalSetting.language === '') {
    i18n.changeLanguage(language)
    setting.normalSetting.language = language
  }

  return setting
}

export function getLocalStorageCustomLangs(): string[] {
  let customLangs: string[] = []
  let customLangsStr = ''

  if (window.isElectronNative) {
    customLangsStr = localStorage.getItem(LOCALSTORAGE_CUSTOM_LANGS) || ''
  } else {
    customLangsStr = sessionStorage.getItem(LOCALSTORAGE_CUSTOM_LANGS) || ''
  }

  if (customLangsStr) {
    try {
      customLangs = JSON.parse(customLangsStr)
    } catch (error) {
      console.log('LOCALSTORAGE_CUSTOM_LANGS err', error)
    }
  }

  return customLangs
}

export function setLocalStorageCustomLangs(customLangs?: string[]): void {
  if (!customLangs && window.isElectronNative) {
    localStorage.removeItem(LOCALSTORAGE_CUSTOM_LANGS)
    return
  }

  const customLangsStr = JSON.stringify(customLangs)

  if (window.isElectronNative) {
    localStorage.setItem(LOCALSTORAGE_CUSTOM_LANGS, customLangsStr)
  } else {
    sessionStorage.setItem(LOCALSTORAGE_CUSTOM_LANGS, customLangsStr)
  }
}

export function getLocalUserInfo(): LoginUserInfo | null {
  const userString = localStorage.getItem(ACCOUNT_INFO_KEY)
  let userInfo: LoginUserInfo | null = null

  if (userString) {
    userInfo = JSON.parse(userString)
  }

  return userInfo
}

// 解析配置文件私有化参数
export function parsePrivateConfig(privateConfig: NEMeetingPrivateConfig) {
  const imConfig = privateConfig.im
  const rtcConfig = privateConfig.rtc
  const whiteboardConfig = privateConfig.whiteboard
  const im = {
    ...imConfig,
    handShakeType: imConfig?.hand_shake_type,
    negoKeyNeca: imConfig?.nego_key_neca,
    commNeca: imConfig?.comm_enca,
    lbs: imConfig?.lbs,
    nosLbs: imConfig?.nos_lbs,
    link: imConfig?.link,
    nosUploader: imConfig?.nos_uploader,
    nosUploaderHost: imConfig?.nos_uploader_host,
    negoKeyNecaKeyParta: imConfig?.nego_key_enca_key_parta,
    negoKeyNecaKeyPartb: imConfig?.nego_key_enca_key_partb,
    negoKeyNecaKeyVersion: imConfig?.nego_key_enca_key_version,
    nosDownloader: imConfig?.nos_downloader,
    nosAccelerateHostList: imConfig?.nos_accelerate_host || [],
    nosAccelerate: imConfig?.nos_accelerate,
  }
  const rtc = {
    ...rtcConfig,
    channelServer: rtcConfig?.channelServer,
    statisticsServer: rtcConfig?.statisticsServer,
    roomServer: rtcConfig?.roomServer,
    compatServer: rtcConfig?.compatServer,
    nosLbsServer: rtcConfig?.nosLbsServer,
    nosUploadSever: rtcConfig?.nosUploadSever,
    nosTokenServer: rtcConfig?.nosTokenServer,
    useIPv6: rtcConfig?.useIPv6,
  }
  const whiteboard = {
    ...whiteboardConfig,
    webServer: whiteboardConfig?.webServer,
    roomServer: whiteboardConfig?.roomServer,
    sdkLogNosServer: whiteboardConfig?.sdkLogNosServer,
    dataReportServer: whiteboardConfig?.dataReportServer,
    directNosServer: whiteboardConfig?.directNosServer,
    mediaUploadServer: whiteboardConfig?.mediaUploadServer,
    docTransServer: whiteboardConfig?.docTransServer,
    fontDownloadServer: whiteboardConfig?.fontDownloadServer,
  }
  const options: {
    imPrivateConf: typeof im
    neRtcServerAddresses: typeof rtc
    whiteboardConfig: typeof whiteboard
    roomKitServerConfig?: {
      roomServer: string
    }
  } = {
    imPrivateConf: im,
    neRtcServerAddresses: rtc,
    whiteboardConfig: whiteboard,
  }
  const roomServer = privateConfig.roomkit.roomServer

  roomServer &&
    (options.roomKitServerConfig = {
      roomServer: privateConfig.roomkit.roomServer,
    })

  return options
}

export function onInjectedMenuItemClick(
  item: CommonBar,
  eventEmitter?: EventEmitter
) {
  eventEmitter?.emit(UserEventType.OnInjectedMenuItemClick, {
    itemId: item.id,
    state: item.btnStatus ? 1 : 0,
    isChecked: item.btnStatus,
    type: item.type === 'single' ? MenuClickType.Base : MenuClickType.Stateful,
  })
}

export function ASRTranslationLanguageToString(
  lang?: NERoomCaptionTranslationLanguage
): string {
  const langMap = {
    [NERoomCaptionTranslationLanguage.NONE]: 'none',
    [NERoomCaptionTranslationLanguage.CHINESE]: 'chinese',
    [NERoomCaptionTranslationLanguage.ENGLISH]: 'english',
    [NERoomCaptionTranslationLanguage.JAPANESE]: 'japanese',
  }

  return langMap[lang || 0] || 'none'
}

export function serverLanguageToSettingASRTranslationLanguage(
  lang: string
): NERoomCaptionTranslationLanguage {
  const langMap = {
    none: NERoomCaptionTranslationLanguage.NONE,
    chinese: NERoomCaptionTranslationLanguage.CHINESE,
    english: NERoomCaptionTranslationLanguage.ENGLISH,
    japanese: NERoomCaptionTranslationLanguage.JAPANESE,
  }

  return langMap[lang || 'none'] || 0
}

export function toASRTranslationLanguage(
  lang?: NERoomCaptionTranslationLanguage
): NEMeetingASRTranslationLanguage {
  if (!lang) {
    return NEMeetingASRTranslationLanguage.none
  }

  const langMap = {
    [NERoomCaptionTranslationLanguage.NONE]:
      NEMeetingASRTranslationLanguage.none,
    [NERoomCaptionTranslationLanguage.CHINESE]:
      NEMeetingASRTranslationLanguage.chinese,
    [NERoomCaptionTranslationLanguage.ENGLISH]:
      NEMeetingASRTranslationLanguage.english,
    [NERoomCaptionTranslationLanguage.JAPANESE]:
      NEMeetingASRTranslationLanguage.japanese,
  }

  return langMap[lang] || NEMeetingASRTranslationLanguage.none
}

export function toInnerASRTranslationLanguage(
  lang: NEMeetingASRTranslationLanguage
): NERoomCaptionTranslationLanguage {
  const langMap = {
    [NEMeetingASRTranslationLanguage.none]:
      NERoomCaptionTranslationLanguage.NONE,
    [NEMeetingASRTranslationLanguage.chinese]:
      NERoomCaptionTranslationLanguage.CHINESE,
    [NEMeetingASRTranslationLanguage.english]:
      NERoomCaptionTranslationLanguage.ENGLISH,
    [NEMeetingASRTranslationLanguage.japanese]:
      NERoomCaptionTranslationLanguage.JAPANESE,
  }

  return langMap[lang] || NERoomCaptionTranslationLanguage.NONE
}

export function getMeetingPermission(value: number): MeetingPermission {
  return {
    annotationPermission: !(
      (value & MeetingSecurityCtrlValue.ANNOTATION_DISABLE) ===
      MeetingSecurityCtrlValue.ANNOTATION_DISABLE
    ),
    screenSharePermission: !(
      (value & MeetingSecurityCtrlValue.SCREEN_SHARE_DISABLE) ===
      MeetingSecurityCtrlValue.SCREEN_SHARE_DISABLE
    ),
    unmuteAudioBySelfPermission: !(
      (value & MeetingSecurityCtrlValue.AUDIO_NOT_ALLOW_SELF_ON) ===
      MeetingSecurityCtrlValue.AUDIO_NOT_ALLOW_SELF_ON
    ),
    unmuteVideoBySelfPermission: !(
      (value & MeetingSecurityCtrlValue.VIDEO_NOT_ALLOW_SELF_ON) ===
      MeetingSecurityCtrlValue.VIDEO_NOT_ALLOW_SELF_ON
    ),
    updateNicknamePermission: !(
      (value & MeetingSecurityCtrlValue.EDIT_NAME_DISABLE) ===
      MeetingSecurityCtrlValue.EDIT_NAME_DISABLE
    ),
    whiteboardPermission: !(
      (value & MeetingSecurityCtrlValue.WHILE_BOARD_SHARE_DISABLE) ===
      MeetingSecurityCtrlValue.WHILE_BOARD_SHARE_DISABLE
    ),
    videoAllOff:
      (value & MeetingSecurityCtrlValue.VIDEO_OFF) ===
      MeetingSecurityCtrlValue.VIDEO_OFF,
    audioAllOff:
      (value & MeetingSecurityCtrlValue.AUDIO_OFF) ===
      MeetingSecurityCtrlValue.AUDIO_OFF,
    playSound:
      (value & MeetingSecurityCtrlValue.PLAY_SOUND) ===
      MeetingSecurityCtrlValue.PLAY_SOUND,
    avatarHide:
      (value & MeetingSecurityCtrlValue.AVATAR_HIDE) ===
      MeetingSecurityCtrlValue.AVATAR_HIDE,
  }
}

export function getGMTTimeText(tz: string = dayjs.tz.guess()) {
  const timezoneText = timezones_zh[tz]

  return timezoneText ? timezoneText.split(' ')[0] : '(GMT+08:00)'
}
