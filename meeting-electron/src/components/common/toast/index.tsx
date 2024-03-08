/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import React, { Fragment } from 'react'
import ReactDOM from 'react-dom'
import classNames from 'classnames'
import './index.less'

interface ToastInfo {
  msg: string | 'info'
  timeout: number
  showClose: boolean
  callback?: () => void
  type: 'info' | 'success' | 'fail' | 'warning'
  id?: string
}

const DEFAULT_DELAY = 3000
// let timer: any = null
// const DomId = 'dark-toast' // 黑色版
const DomId = 'neMeetingToast'

const MAX_COUNT = 5
const MAX_CACHE_COUNT = 10
const cacheList: ToastInfo[] = []

let exitToastCount = 0

let container: HTMLDivElement | null = null

class Toast extends React.Component {
  static handleCloseToast(id, callback?: () => void) {
    if (!id) {
      return
    }
    const darkToast = document.getElementById(id)
    if (darkToast) {
      window.ipcRenderer?.send('nemeeting-sharing-screen', {
        method: 'closeToast',
      })
      darkToast.parentNode?.removeChild(darkToast)
      exitToastCount = Math.max(exitToastCount - 1, 0)
      if (cacheList.length > 0) {
        const info = cacheList.shift()
        if (info) {
          Toast[info.type](
            info.msg,
            info.timeout,
            info.showClose,
            info.callback
          )
        }
      }
    } else {
      // 还未创建元素只是在缓存队列
      const index = cacheList.findIndex((item) => item.id === id)
      if (index !== -1) {
        cacheList.splice(index, 1)
      }
    }
    callback?.()
  }
  static info(
    msg: string | 'info',
    timeout = DEFAULT_DELAY,
    showClose = false,
    callback?,
    domId?: string
  ) {
    const id = init({
      msg,
      timeout,
      showClose,
      callback,
      type: 'info',
      id: domId,
    })

    const el = document.getElementById(id)
    // 在缓存队列
    if (!el) {
      return id
    }
    setTime(timeout, id)
    ReactDOM.render(
      <Fragment>
        <div className="nemeeting-toast-fragment">
          <div className="nemeeting-toast-fragment-wrap">
            <div className="nemeeting-toast-fragment-content">
              <svg className="icon iconfont iconinfo" aria-hidden="true">
                <use xlinkHref="#icona-45 "></use>
              </svg>
              {/*<i className="iconfont icona-45 iconinfo"></i>*/}
              <span
                onClick={() => console.log('ssssss')}
                className="nemeeint-toast-content"
              >
                {msg}
              </span>
            </div>
            {showClose && (
              <svg
                id={`close-${id}`}
                className="icon nemeeting-close-icon"
                aria-hidden="true"
                onClick={() => Toast.handleCloseToast(id, callback)}
              >
                <use xlinkHref="#iconyx-pc-closex"></use>
              </svg>
            )}
          </div>
        </div>
      </Fragment>,
      el
    )
    return id
  }
  static success(
    msg: string | 'success',
    timeout = DEFAULT_DELAY,
    showClose = false,
    callback?,
    domId?: string
  ) {
    const id = init({
      msg,
      timeout,
      showClose,
      callback,
      type: 'success',
      id: domId,
    })
    const el = document.getElementById(id)
    // 在缓存队列
    if (!el || !id) {
      return id
    }
    setTime(timeout, id)
    ReactDOM.render(
      <Fragment>
        <div className="nemeeting-toast-fragment">
          <div className="nemeeting-toast-fragment-wrap">
            <div className="nemeeting-toast-fragment-content">
              <svg className="icon iconfont iconsuccess" aria-hidden="true">
                <use xlinkHref="#iconhook-y1x"></use>
              </svg>
              {/*<i className="iconfont iconhook-y1x iconsuccess"></i>*/}
              <span className="nemeeint-toast-content">{msg}</span>
            </div>
            {showClose && (
              <svg
                id={`close-${id}`}
                className="icon nemeeting-close-icon"
                aria-hidden="true"
                onClick={() => Toast.handleCloseToast(id, callback)}
              >
                <use xlinkHref="#iconyx-pc-closex"></use>
              </svg>
            )}
          </div>
        </div>
      </Fragment>,
      el
    )
    return id
  }
  static fail(
    msg: string | 'fail',
    timeout = DEFAULT_DELAY,
    showClose = false,
    callback?,
    domId?: string,
    fill?: boolean
  ) {
    const id = init({
      msg,
      timeout,
      showClose,
      callback,
      type: 'fail',
      id: domId,
    })
    const el = document.getElementById(id)
    // 在缓存队列
    if (!el || !id) {
      return id
    }
    setTime(timeout, id)
    ReactDOM.render(
      <Fragment>
        <div
          className={classNames('nemeeting-toast-fragment', {
            ['fail-fill']: fill,
          })}
        >
          <div className="nemeeting-toast-fragment-wrap">
            <div className="nemeeting-toast-fragment-content">
              {!fill && (
                <svg className="icon iconfont iconfail" aria-hidden="true">
                  <use xlinkHref="#iconcross-y1x"></use>
                </svg>
              )}
              {/*<i className="iconfont iconcross-y1x iconfail"></i>*/}
              <span className="nemeeint-toast-content">{msg}</span>
            </div>
            {showClose && (
              <svg
                className="icon nemeeting-close-icon"
                aria-hidden="true"
                onClick={() => Toast.handleCloseToast(id, callback)}
              >
                <use xlinkHref="#iconyx-pc-closex"></use>
              </svg>
            )}
          </div>
        </div>
      </Fragment>,
      el
    )
    return id
  }
  static warning(
    msg: string | 'warning',
    timeout = DEFAULT_DELAY,
    showClose = false,
    callback?,
    domId?: string
  ) {
    const id = init({
      msg,
      timeout,
      showClose,
      callback,
      type: 'warning',
      id: domId,
    })
    const el = document.getElementById(id)
    // 在缓存队列
    if (!el || !id) {
      return id
    }
    setTime(timeout, id)
    ReactDOM.render(
      <Fragment>
        <div className="nemeeting-toast-fragment">
          <div className="nemeeting-toast-fragment-wrap">
            <div className="nemeeting-toast-fragment-content">
              <svg className="icon iconfont iconwarning" aria-hidden="true">
                <use xlinkHref="#iconcross-y1x"></use>
              </svg>
              {/*<i className="iconfont iconwarning-y1x iconwarning"></i>*/}
              <span className="nemeeint-toast-content">{msg}</span>
            </div>
            {showClose && (
              <svg
                className="icon nemeeting-close-icon"
                aria-hidden="true"
                onClick={() => Toast.handleCloseToast(id, callback)}
              >
                <use xlinkHref="#iconyx-pc-closex"></use>
              </svg>
            )}
          </div>
        </div>
      </Fragment>,
      el
    )
    return id
  }
  static destroy(id: string) {
    Toast.handleCloseToast(id)
  }
}
function init(options: ToastInfo): string {
  // 如果存在id则是从缓存队列里取出
  const domId = options.id || DomId + '-' + Date.now()
  if (exitToastCount >= MAX_COUNT) {
    if (cacheList.length < MAX_CACHE_COUNT) {
      cacheList.push(options)
      return domId
    } else {
      console.log('超出缓存')
      return ''
    }
  }
  if (!container) {
    container = document.createElement('div')
    container.className = 'neMeeting-toast-container'
    document.body.appendChild(container)
  }
  exitToastCount += 1
  window.ipcRenderer?.send('nemeeting-sharing-screen', {
    method: 'openToast',
  })
  // clearTimeout(timer)
  const darkToast = document.createElement('div')
  darkToast.setAttribute('id', domId)
  darkToast.setAttribute('class', 'nemeeint-toast')
  container.appendChild(darkToast)
  // document.body.appendChild(darkToast)
  // darkToast.style.display = 'block'
  window.ipcRenderer?.once('nemeeting-sharing-screen', (_, value) => {
    if (value.method === 'openToast' && value.data) {
      darkToast.style.top = '60px'
    }
  })
  return domId
}
function setTime(timeout: number, id: string) {
  if (timeout === 0) return
  setTimeout(() => {
    Toast.handleCloseToast(id)
  }, timeout)
}
export default Toast
