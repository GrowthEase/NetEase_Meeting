import React, { useEffect } from 'react'
import classNames from 'classnames'
import './index.less'
import { IPCEvent } from '../../../app/src/types'
import Toast from '../../common/toast'
import { useTranslation } from 'react-i18next'

interface FullScreenButtonProps {
  className?: string
  isFullScreen: boolean
}
// 会议持续时间
const FullScreenButton: React.FC<FullScreenButtonProps> = React.memo(
  ({ className, isFullScreen }: FullScreenButtonProps) => {
    const { t } = useTranslation()

    function handleFullScreen() {
      window.ipcRenderer?.send(
        isFullScreen ? IPCEvent.quiteFullscreen : IPCEvent.enterFullscreen
      )
    }

    useEffect(() => {
      function escKeydown(e: KeyboardEvent) {
        if (e.key === 'Escape') {
          handleFullScreen()
        }
      }

      if (isFullScreen) {
        Toast.info(t('enterFullscreenTips'))
        document.addEventListener('keydown', escKeydown)
        return () => {
          document.removeEventListener('keydown', escKeydown)
        }
      }
    }, [isFullScreen])

    return window.isElectronNative ? (
      <div
        className={classNames('nemeeting-full-screen-button', className)}
        onClick={() => handleFullScreen()}
      >
        {isFullScreen ? (
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconsuoxiao"></use>
          </svg>
        ) : (
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconfangda"></use>
          </svg>
        )}
      </div>
    ) : null
  }
)

FullScreenButton.displayName = 'FullScreenButton'

export default FullScreenButton
