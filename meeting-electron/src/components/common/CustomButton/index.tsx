import React from 'react'
import './index.less'

interface CustomButtonProps {
  customData: any
  isSmallBtn: boolean
}

const CustomButton: React.FC<CustomButtonProps> = ({
  customData,
  isSmallBtn,
}) => {
  const handleItemClick = (data) => {
    data?.injectItemClick?.(data)
  }

  return (
    <div
      className={`custom-button controller-item ${
        isSmallBtn ? 'small-button' : ''
      }`}
      onClick={() => handleItemClick(customData)}
    >
      {customData.type === 'single' ? (
        <div className="setting-block">
          <img
            className="custom-icon"
            src={customData.btnConfig.icon}
            alt=""
            srcSet=""
          />
          {!isSmallBtn && (
            <div className="custom-text">{customData.btnConfig.text}</div>
          )}
        </div>
      ) : (
        customData.type === 'multiple' && (
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
