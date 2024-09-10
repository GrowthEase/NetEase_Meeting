import React from 'react'
import './index.less'
import { onInjectedMenuItemClick } from '../../../utils'
import { useGlobalContext } from '../../../store'
import { CommonBar } from '../../../kit'

interface CustomButtonProps {
  customData: CommonBar
  isSmallBtn: boolean
}

const CustomButton: React.FC<CustomButtonProps> = ({
  customData,
  isSmallBtn,
}) => {
  const { eventEmitter } = useGlobalContext()
  const handleItemClick = (data) => {
    onInjectedMenuItemClick(data, eventEmitter)
    data?.injectItemClick?.(data)
  }

  return (
    <div
      className={`custom-button controller-item ${
        isSmallBtn ? 'small-button' : ''
      }`}
      onClick={() => handleItemClick(customData)}
    >
      {customData.type === 'single' && !Array.isArray(customData.btnConfig) ? (
        <div className="setting-block">
          <img
            className="custom-icon"
            src={customData.btnConfig?.icon}
            alt=""
            srcSet=""
          />
          {!isSmallBtn && (
            <div className="custom-text">{customData.btnConfig?.text}</div>
          )}
        </div>
      ) : (
        customData.type === 'multiple' &&
        Array.isArray(customData.btnConfig) && (
          <>
            {customData.btnConfig?.map(
              (item, index) =>
                item.status === customData.btnStatus && (
                  <div className="setting-block" key={`${item.status}${index}`}>
                    <img
                      className="custom-icon"
                      src={item.icon}
                      alt=""
                      srcSet=""
                    />
                    {!isSmallBtn && (
                      <div className="custom-text">{item.text}</div>
                    )}
                  </div>
                )
            )}
          </>
        )
      )}
    </div>
  )
}

export default CustomButton
