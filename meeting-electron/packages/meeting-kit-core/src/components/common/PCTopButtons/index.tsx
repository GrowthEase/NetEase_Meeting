import React, { useEffect } from 'react'
import './index.less'
import { IPCEvent } from '../../../app/src/types'
import classNames from 'classnames'

interface PCTopButtonsProps {
  minimizable?: boolean // 是否可最小化
  maximizable?: boolean // 是否可最大化
  size?: 'small' | 'normal'
}

const PCTopButtons: React.FC<PCTopButtonsProps> = (props) => {
  const isWin = window.systemPlatform == 'win32'

  const { minimizable = true, maximizable = true, size = 'small' } = props

  const [isMaximized, setIsMaximized] = React.useState(false)

  function handleMinimize() {
    window.ipcRenderer?.send(IPCEvent.minimizeWindow)
  }

  function handleMaximize() {
    setIsMaximized(!isMaximized)
    window.ipcRenderer?.send(IPCEvent.maximizeWindow, !isMaximized)
  }

  function handleClose() {
    window.close()
  }

  useEffect(() => {
    function handleMaximizeWindow(_, value) {
      setIsMaximized(value)
    }

    window.ipcRenderer?.on(IPCEvent.maximizeWindow, handleMaximizeWindow)
    return () => {
      window.ipcRenderer?.off(IPCEvent.maximizeWindow, handleMaximizeWindow)
    }
  }, [])

  return isWin ? (
    <div
      className={classNames('pc-top-buttons', {
        'pc-top-buttons-small': size === 'small',
      })}
    >
      {minimizable ? (
        <span
          className="icon-top-button icon-zuixiaohua"
          onClick={() => handleMinimize()}
        >
          <svg
            className="icon iconfont iconzuixiaohua_huaban1"
            aria-hidden="true"
          >
            <use xlinkHref="#iconzuixiaohua-win"></use>
          </svg>
        </span>
      ) : null}
      {maximizable ? (
        <span
          className="icon-top-button icon-zuidahua"
          onClick={() => handleMaximize()}
        >
          <svg className="icon iconfont" aria-hidden="true">
            {isMaximized ? (
              <use xlinkHref="#iconzuidahua"></use>
            ) : (
              <use xlinkHref="#iconchuangti-zuidahua"></use>
            )}
          </svg>
        </span>
      ) : null}
      <span
        className="icon-top-button icon-close"
        onClick={() => handleClose()}
      >
        <svg className="icon iconfont close" aria-hidden="true">
          <use xlinkHref="#iconguanbi-win"></use>
        </svg>
      </span>
    </div>
  ) : null
}

export default PCTopButtons
