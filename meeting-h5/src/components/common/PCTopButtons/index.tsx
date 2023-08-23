import React, { useEffect } from 'react'
import CloseOutlined from '@ant-design/icons/CloseOutlined'
import MinusOutlined from '@ant-design/icons/MinusOutlined'
import { Button } from 'antd'
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
    // @ts-ignore
    window.ipcRenderer.send('minimize-window')
  }

  function handleMaximize() {
    setIsMaximized(!isMaximized)
    // @ts-ignore
    window.ipcRenderer.send('maximize-window')
  }

  function handleClose() {
    window.close()
  }

  useEffect(() => {
    if (window.ipcRenderer) {
      function handleMaximizeWindow(_, value) {
        setIsMaximized(value)
      }
      // @ts-ignore
      window.ipcRenderer.on('maximize-window', handleMaximizeWindow)
      return () => {
        // @ts-ignore
        window.ipcRenderer.off('maximize-window', handleMaximizeWindow)
      }
    }
  }, [])

  return isWin ? (
    <div className="pc-top-buttons">
      {minimizable ? <MinusOutlined onClick={() => handleMinimize()} /> : null}
      {maximizable ? (
        <i
          className={`iconfont ${
            isMaximized ? 'iconzuidahua' : 'iconchuangti-zuidahua'
          }`}
          onClick={() => handleMaximize()}
        />
      ) : null}
      <CloseOutlined onClick={() => handleClose()} />
    </div>
  ) : null
}

export default PCTopButtons
