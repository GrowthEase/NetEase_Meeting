import React, { ReactNode, useEffect, useState } from 'react'
import './index.less'

interface DialogProps {
  visible: boolean
  ifShowCancel?: boolean
  onCancel?: () => void
  onConfirm: () => void
  title?: string
  popupClassName?: string
  cancelText?: string
  confirmText?: string
  width?: number
  children: ReactNode
  confirmDisabled?: boolean
  confirmClassName?: string
  cancelClassName?: string
}

const Dialog: React.FC<DialogProps> = ({
  visible,
  width,
  ifShowCancel = true,
  onCancel,
  onConfirm,
  title,
  popupClassName,
  cancelText = '否',
  confirmText = '是',
  children,
  confirmDisabled = false,
  cancelClassName,
  confirmClassName,
}) => {
  const [selfShow, setSelfShow] = useState(false)

  useEffect(() => {
    setSelfShow(visible)
  }, [visible])

  return (
    <>
      {selfShow && (
        <div
          className={`w-full dialog-com h-full fixed flex items-center justify-center`}
          onClick={(e) => {
            e.stopPropagation()
          }}
        >
          <div
            style={width ? { width: width + 'px' } : {}}
            className={`dialog-box ${popupClassName || ''}`}
          >
            <div className="dialog-title text-lg">{title}</div>
            <div className="dialog-content">{children}</div>
            <div className="dialog-foot text-base ">
              {ifShowCancel && (
                <span
                  className={`dialog-cancel ${cancelClassName || ''}`}
                  onClick={(e) => {
                    onCancel && onCancel()
                    e.stopPropagation()
                  }}
                >
                  {cancelText}
                </span>
              )}
              <span
                className={`dialog-confirm , ${
                  confirmDisabled ? 'confirm-disabled' : ''
                }  ${confirmClassName || ''}`}
                style={{ width: !ifShowCancel ? '100%' : '49%' }}
                onClick={(e) => {
                  if (confirmDisabled) return
                  onConfirm && onConfirm()
                  e.stopPropagation()
                }}
              >
                {confirmText}
              </span>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
export default Dialog
