import { css } from '@emotion/css'
import { Popup, PopupProps } from 'antd-mobile/es'
import { MoreButtonItem } from './useMoreButtons'

const popupBodyClassName = css`
  background-image: linear-gradient(180deg, #33333f, #292933);
  height: 80px;
`

const moreButtonListWrapperCls = css`
  display: flex;
  flex-wrap: wrap;
`
const moreButtonItemWrapperCls = css`
  width: 25%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 80px;
  .icon-image {
    display: block;
    height: 24px;
    width: 24px;
    box-sizing: border-box;
    font-size: 24px;
    color: #fff;
  }
  .more-button-item-text {
    font-size: 12px;
    margin-top: 8px;
    width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: pre;
    display: inline-block;
    color: #fff;
    text-align: center;
  }
`

interface MoreButtonsPopupProps extends PopupProps {
  moreButtons: MoreButtonItem[]
}

const MoreButtonsPopup: React.FC<MoreButtonsPopupProps> = ({
  moreButtons,
  ...restProps
}) => {
  return (
    <Popup bodyClassName={popupBodyClassName} {...restProps}>
      <div className={moreButtonListWrapperCls}>
        {moreButtons.map((item) => {
          return (
            <div
              className={moreButtonItemWrapperCls}
              key={item.key}
              onClick={() => {
                restProps.onClose?.()
                item.onClick()
              }}
            >
              {item.icon}
              <div className="more-button-item-text">{item.label}</div>
            </div>
          )
        })}
      </div>
    </Popup>
  )
}

export default MoreButtonsPopup
