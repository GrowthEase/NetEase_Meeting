import React from 'react'
import './index.less'

interface RemainTimeTipInterface {
  className?: string
  text: string
  onCloseHandler: () => void
}

const RemainTimeTip: React.FC<RemainTimeTipInterface> = (props) => {
  const { className, text, onCloseHandler } = props
  return (
    <div className={`nemeeting-remaining-time-tip ${className}`}>
      <span>{text}</span>
      <svg
        className="icon nemeeting-close-icon"
        aria-hidden="true"
        onClick={onCloseHandler}
      >
        <use xlinkHref="#iconyx-pc-closex"></use>
      </svg>
    </div>
  )
}

export default React.memo(RemainTimeTip)
