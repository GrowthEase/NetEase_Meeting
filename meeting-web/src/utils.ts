/*
 * @Description: 工具方法
 */

import LoggerStorage, { LogName } from '@/libs/3rd/logStorage'
import axios from 'axios'
import sha1 from 'sha1'
import { version } from '../package.json'

const logger = LoggerStorage.getInstance()
;(window as any).logger = logger

const salt = 'demo'
const isDev = process.env.NODE_ENV === 'development'

/**
 * @description: 获取url参数
 * @param {*} variable
 * @return {*}
 */
export function getQueryVariable(variable) {
  // 获取浏览器参数
  const query = window.location.search.substring(1)
  const vars = query.split('&')
  for (let i = 0; i < vars.length; i += 1) {
    const pair = vars[i].split('=')
    if (pair[0] == variable) return pair[1]
  }
  return false
}

let timeout: any
/**
 * @description: 防抖
 * @param {*} fn
 * @param {*} wait
 * @return {*}
 */
export function debounce(fn, wait = 300) {
  // 防抖
  if (timeout !== null) clearTimeout(timeout as any)
  timeout = null
  timeout = setTimeout(fn, wait) as any
}

let preDate: any = null
/**
 * @description: 节流
 * @param {*} fn
 * @param {*} wait
 * @return {*}
 */
export function throttle(fn, wait = 1000) {
  const now = new Date().getTime()
  if (!preDate) {
    preDate = now
    fn()
  }
  if (now - preDate > wait) {
    preDate = now
    fn()
  }
}

/**
 * @description: 统计使用
 * @param {*} name
 * @param {*} isEnd
 * @return {*}
 */
export function timeStatistics(name = '', isEnd = false) {
  // 统计消耗时间-仅在测试环境
  if (isDev) {
    if (isEnd) {
      console.timeEnd(name)
    } else {
      console.time(name)
    }
  }
}

/**
 * @description: 删选错误码
 * @param {*} msg
 * @return {*}
 */
export function getErrCode(msg = '') {
  // 基于目前的error message去筛选错误码
  let result: any
  if (msg) {
    result = String(msg).match(/\d/g) || []
    return result.length > 0 ? result.join('') : ''
  }
  return ''
}

/**
 * @description: 格式化会议ID
 * @param {*} str
 * @return {*}
 */
export function formatMeetingId(str = '') {
  // 基于长短号会议ID格式化
  const arr = str.split('')
  let result = ''
  for (let i = 0; i < arr.length; i++) {
    const ele = arr[i]
    if (ele === '-') {
      continue
    }
    result += ele
    if (i % 3 === 2 && i < arr.length - 3) {
      result += '-'
    }
  }
  return result
}
/**
 * @description: 判断字符串协议头
 * @param {*} str
 * @return {*}
 */
export function hasProtocol(str) {
  // 判断是否包含协议头
  return /(http|https):\/\/([\w.]+\/?)\S*/.test(str)
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
/**
 * @description: 时间格式化
 * @param {*} time
 * @param {*} fmt
 * @return {*}
 */
export function formatDate(time, fmt = 'yyyy/MM/dd hh:mm') {
  const date = new Date(time)
  const o = {
    'M+': date.getMonth() + 1, //月份
    'd+': date.getDate(), //日
    'h+': date.getHours(), //小时
    'm+': date.getMinutes(), //分
    's+': date.getSeconds(), //秒
    'q+': Math.floor((date.getMonth() + 3) / 3), //季度
    S: date.getMilliseconds(), //毫秒
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

/**
 * @description: 格式化localStorage
 * @param {*} objectName
 * @param {*} val
 * @return {*}
 */
export function getLocalInfo(objectName, val): string | false | null {
  // 格式化local
  return JSON.parse(localStorage.getItem(objectName) || '{}')[val]
}

/**
 * @description: 获取或设置某一举手类型的状态
 * @param {number} handsUpType 1 全局静音发言举手
 * @param {Array} list
 * @param {number} value 0 手放下 1 举手 2通过
 * @return {*}
 */
export function handsUpStatus(handsUp?: { value: string }, value?: number) {
  return handsUp ? handsUp.value : 0
}

/**
 * @description: 判断当前举手类型数量
 * @param {number} handsUpType
 * @param {Record} memberMap
 * @param {*} any
 * @return {*}
 */
export function handsUpsNum(
  handsUpType: number,
  memberMap: Record<string, any>
) {
  let result = 0
  for (const key in memberMap) {
    if (Object.prototype.hasOwnProperty.call(memberMap, key)) {
      const item = memberMap[key]
      if (handsUpStatus(item.handsUps) == '1') {
        result++
      }
    }
  }
  return result
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
export function hasOwnType(obj, itemName) {
  return Object.prototype.hasOwnProperty.call(obj, itemName)
}

class Storage {
  private static instace: Storage
  private store = new Map()
  private type: 'localStorage' | 'sessionStorage' | 'memory' = 'memory'
  private salt = 'demo'

  constructor(type?: 'localStorage' | 'sessionStorage' | 'memory') {
    if (type) {
      this.type = type
    }
  }

  public get(key: string): any {
    let value
    switch (this.type) {
      case 'memory':
        return this.store.get(key)
      case 'localStorage':
        value = localStorage.getItem(`${this.salt}${key}`)
        if (value) {
          return JSON.parse(value)
        }
        return value
      case 'sessionStorage':
        value = sessionStorage.getItem(`${this.salt}${key}`)
        if (value) {
          return JSON.parse(value)
        }
        return value
    }
  }

  public set(key: string, value: any) {
    switch (this.type) {
      case 'memory':
        this.store.set(key, value)
        break
      case 'localStorage':
        localStorage.setItem(`${this.salt}${key}`, JSON.stringify(value))
        break
      case 'sessionStorage':
        sessionStorage.setItem(`${this.salt}${key}`, JSON.stringify(value))
        break
    }
  }

  public remove(key: string) {
    switch (this.type) {
      case 'memory':
        this.store.delete(key)
        break
      case 'localStorage':
        localStorage.removeItem(`${this.salt}${key}`)
        break
      case 'sessionStorage':
        sessionStorage.removeItem(`${this.salt}${key}`)
        break
    }
  }

  static getInstance(type?: 'localStorage' | 'sessionStorage' | 'memory') {
    if (!this.instace) {
      this.instace = new Storage(type)
    }
    return this.instace
  }
}

export const sessionIns = Storage.getInstance('sessionStorage')
export const localIns = Storage.getInstance('localStorage')
export const memoryIns = Storage.getInstance('memory')

/**
 * @description: 去重
 * @param {*} list
 * @return {*}
 */
export function unique(list) {
  return list.filter((item, index, arr) => {
    return arr.indexOf(item, 0) === index
  })
}

/**
 * @description: 取差值
 * @param {Array} list1
 * @param {Array} list2
 * @return {*}
 */
export function minus(list1: Array<any>, list2: Array<any>) {
  return list1.filter(function (v) {
    return list2.indexOf(v) == -1
  })
}

/**
 * @description: 日志拦截
 * @param {*}
 * @return {*}
 */
export function changeConsole() {
  const newConsole = console
  for (const key in newConsole) {
    if (
      Object.prototype.hasOwnProperty.call(newConsole, key) &&
      ['log', 'info', 'warn', 'error', 'debug'].includes(key)
    ) {
      const ele = newConsole[key]
      // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
      // @ts-ignore
      console[key] = function (...args) {
        const result = args.reduce((pre, cur) => {
          pre += ' '
          if (typeof cur === 'object') {
            try {
              let cache: any = []
              const str =
                pre +
                JSON.stringify(cur, (key, value) => {
                  if (typeof value === 'object' && value !== null) {
                    if (cache.indexOf(value) !== -1) {
                      // 移除
                      return
                    }
                    // 收集所有的值
                    cache.push(value)
                  }
                  return value
                })
              cache = []
              return str
            } catch (e) {
              console.log('this log can`t use JSON.stringify', e)
              throw e
            }
          } else {
            return pre + cur
          }
        }, '')
        switch (true) {
          case result.includes('Meeting-'):
            logger.log('meetingLog', result)
            break
          case result.includes('WEBRTC LOG'):
            logger.log('rtcLog', result)
            break
          case result.includes('NIM LOG'):
            logger.log('imLog', result)
            break
          default:
            break
        }
        ele.apply(this, args)
      }
    }
  }
}

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

/**
 * @description: 删除日志
 * @param {LogName} logName
 * @param {*} start
 * @param {*} end
 * @return {*}
 */
export async function deleteLog(logName: LogName, start = 0, end = Date.now()) {
  return await logger.deleteLog(logName, start, end)
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
        .post('url', data, {
          headers: {
            'content-type': 'application/json',
            Nonce,
            CurTime,
            CheckSum: `${sha1(JSON.stringify(data) + Nonce + CurTime + salt)}`,
          },
        })
        .then((response) => {
          const nosRes = response?.data?.data

          const file = new File([logInfo], `${CurTime}.log`, {
            type: 'application/json',
          })

        })
    })
    arr.push(fileUploadReq)
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

export function checkSystemRequirements() {
  // return WebRTC2.checkSystemRequirements();
  // todo 需要roomkit暴露接口
  return true
}

export function copyElementValue(value, callback) {
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

export function isJsonString(str) {
  try {
    if (JSON.parse(str)) {
      return true
    }
  } catch (error) {
    return false
  }
  return false
}

export default {
  getQueryVariable,
  debounce,
  getErrCode,
  formatMeetingId,
  hasProtocol,
  checkType,
  formatDate,
  getLocalInfo,
  handsUpStatus,
  handsUpsNum,
  hasOwnType,
  unique,
  minus,
  changeConsole,
  checkSystemRequirements,
  copyElementValue,
  isJsonString,
}
