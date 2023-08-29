/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import React, { Fragment } from 'react'
import ReactDOM from 'react-dom'
import './index.less'

const DEFAULT_DELAY = 3000
let timer: any = null
// const DomId = 'dark-toast' // 黑色版
const DomId = 'neMeetingToast'

class Toast extends React.Component {
  static info(msg: string | 'info', timeout = DEFAULT_DELAY) {
    init()
    setTime(timeout)
    ReactDOM.render(
      <Fragment>
        <svg className="icon iconfont iconinfo" aria-hidden="true">
          <use xlinkHref="#icona-45 "></use>
        </svg>
        {/*<i className="iconfont icona-45 iconinfo"></i>*/}
        <span className="nemeeint-toast-content">{msg}</span>
      </Fragment>,
      document.getElementById(DomId)
    )
  }
  static success(msg: string | 'success', timeout = DEFAULT_DELAY) {
    init()
    setTime(timeout)
    ReactDOM.render(
      <Fragment>
        <svg className="icon iconfont iconsuccess" aria-hidden="true">
          <use xlinkHref="#iconhook-y1x"></use>
        </svg>
        {/*<i className="iconfont iconhook-y1x iconsuccess"></i>*/}
        <span className="nemeeint-toast-content">{msg}</span>
      </Fragment>,
      document.getElementById(DomId)
    )
  }
  static fail(msg: string | 'fail', timeout = DEFAULT_DELAY) {
    init()
    setTime(timeout)
    ReactDOM.render(
      <Fragment>
        <svg className="icon iconfont iconfail" aria-hidden="true">
          <use xlinkHref="#iconcross-y1x"></use>
        </svg>
        {/*<i className="iconfont iconcross-y1x iconfail"></i>*/}
        <span className="nemeeint-toast-content">{msg}</span>
      </Fragment>,
      document.getElementById(DomId)
    )
  }
  static warning(msg: string | 'warning', timeout = DEFAULT_DELAY) {
    init()
    setTime(timeout)
    ReactDOM.render(
      <Fragment>
        <svg className="icon iconfont iconwarning" aria-hidden="true">
          <use xlinkHref="#iconcross-y1x"></use>
        </svg>
        {/*<i className="iconfont iconwarning-y1x iconwarning"></i>*/}
        <span className="nemeeint-toast-content">{msg}</span>
      </Fragment>,
      document.getElementById(DomId)
    )
  }
  static loading(msg: string | 'loading', status: boolean) {
    init()
    setLoading(status)
    ReactDOM.render(
      <Fragment>
        <svg className="icon iconfont rotate-loop" aria-hidden="true">
          <use xlinkHref="#icon-reload"></use>
        </svg>
        {/*<i className="iconfont icon-reload rotate-loop"></i>*/}
        <span className="nemeeint-toast-content">{msg}</span>
      </Fragment>,
      document.getElementById(DomId)
    )
  }
}
function setLoading(status: boolean) {
  const darkToast: any = document.getElementById(DomId)
  if (status) darkToast.style.display = 'block'
  else darkToast.style.display = 'none'
}
function init() {
  clearTimeout(timer)
  const darkToast = document.getElementById(DomId)
  if (darkToast) {
    darkToast.style.display = 'block'
  } else {
    const div = document.createElement('div')
    div.setAttribute('id', DomId)
    document.body.appendChild(div)
  }
}
function setTime(timeout: number) {
  timer = setTimeout(() => {
    const darkToast = document.getElementById(DomId)
    if (darkToast) {
      darkToast.style.display = 'none'
    }
  }, timeout)
}
export default Toast
