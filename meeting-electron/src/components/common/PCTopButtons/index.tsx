import React, { useEffect } from 'react'
import './index.less'

interface PCTopButtonsProps {
  minimizable?: boolean // 是否可最小化
  maximizable?: boolean // 是否可最大化
}

const PCTopButtons: React.FC<PCTopButtonsProps> = (props) => {
  // @ts-ignore
  const isWin = window.systemPlatform === 'win32'

  const { minimizable = true, maximizable = true } = props

  const [isMaximized, setIsMaximized] = React.useState(false)

  function handleMinimize() {
    window.ipcRenderer?.send('minimize-window')
  }

  function handleMaximize() {
    setIsMaximized(!isMaximized)
    window.ipcRenderer?.send('maximize-window', !isMaximized)
  }

  function handleClose() {
    window.close()
  }

  useEffect(() => {
    function handleMaximizeWindow(_, value) {
      setIsMaximized(value)
    }
    // @ts-ignore
    window.ipcRenderer?.on('maximize-window', handleMaximizeWindow)
    return () => {
      // @ts-ignore
      window.ipcRenderer?.off('maximize-window', handleMaximizeWindow)
    }
  }, [])

  return isWin ? (
    <div className="pc-top-buttons">
      {minimizable ? (
        <svg
          className="icon iconfont"
          aria-hidden="true"
          onClick={() => handleMinimize()}
        >
          <use xlinkHref="#iconzuixiaohua_huaban1"></use>
        </svg>
      ) : null}
      {maximizable ? (
        <svg
          className="icon iconfont"
          aria-hidden="true"
          onClick={() => handleMaximize()}
        >
          {isMaximized ? (
            <use xlinkHref="#iconzuidahua"></use>
          ) : (
            <use xlinkHref="#iconchuangti-zuidahua"></use>
          )}
        </svg>
      ) : null}
      <svg
        className="icon iconfont close"
        aria-hidden="true"
        onClick={() => handleClose()}
      >
        <use xlinkHref="#iconcross"></use>
      </svg>
    </div>
  ) : null
}

export default PCTopButtons
