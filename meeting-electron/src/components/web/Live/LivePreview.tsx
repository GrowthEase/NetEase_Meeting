import React, { useMemo } from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
interface LivePreviewProps {
  className?: string
  memberCount: number
  model: 'gallery' | 'focus' | '' | 'shareScreen'
  isSharing: boolean
}

interface ItemProps {
  numberCountByLimit: number
  formatNumber: (index: number, limit: number) => string
  model: 'gallery' | 'focus' | '' | 'shareScreen'
}

// 画廊模式共享模式视图
const GalleryScreenViewItems: React.FC<ItemProps> = ({
  numberCountByLimit,
  formatNumber,
}) => {
  const views: JSX.Element[] = []
  for (let i = 1; i <= numberCountByLimit; i++) {
    views.push(
      <div className="per1-12 view-bg" key={i}>
        <div className="preview-index">{formatNumber(i, 4)}</div>
      </div>
    )
  }
  return (
    <div className="preview-item preview-screen-share">
      <div className="per8-12 view-bg" />
      <div className="per1-12-wrap">{views}</div>
    </div>
  )
}

const GalleryVietItems: React.FC<ItemProps> = ({
  numberCountByLimit,
  formatNumber,
  model,
}) => {
  const views: JSX.Element[] = []
  if (model === 'gallery') {
    for (let i = 1; i <= numberCountByLimit; i++) {
      views.push(
        <div className={`per1-${numberCountByLimit} view-bg`} key={i}>
          <div className="preview-index">{formatNumber(i, 4)}</div>
        </div>
      )
    }
    return <div className="preview-item preview-per">{views}</div>
  } else if (model === 'focus') {
    for (let i = 1; i <= numberCountByLimit - 1; i++) {
      views.push(
        <div className="per1-12-focus view-bg" key={i}>
          <div className="preview-index">{formatNumber(i + 1, 4)}</div>
        </div>
      )
    }
    return (
      <div className="preview-item preview-focus">
        <div className="per8-12-focus view-bg">
          <div className="preview-index">1</div>
        </div>
        <div className="per1-12-focus-wrap">{views}</div>
      </div>
    )
  }
  return <></>
}
const LivePreview: React.FC<LivePreviewProps> = (props) => {
  const { memberCount, className, model, isSharing } = props
  const { t } = useTranslation()
  const numberCountByLimit = useMemo(() => {
    if (model === 'gallery') {
      return Math.min(memberCount, 4)
    } else {
      return Math.min(memberCount, 4)
    }
  }, [model, memberCount])

  const formatNumber = (index: number, limit: number) => {
    return memberCount > limit && index === limit ? '...' : String(index)
  }

  return (
    <div className="live-preview">
      <div
        className={`live-preview-wrap ${
          memberCount === 1 ? 'live-preview-wrap-1' : ''
        }`}
      >
        {/*只选中一人*/}
        {memberCount === 1 && !isSharing && (
          <div className="per1 view-bg">
            <div className="preview-index">{memberCount}</div>
          </div>
        )}
        {(memberCount > 1 || (memberCount === 1 && isSharing)) &&
          // 画廊模式
          (isSharing ? (
            <GalleryScreenViewItems
              formatNumber={formatNumber}
              model={model}
              numberCountByLimit={numberCountByLimit}
            />
          ) : (
            <GalleryVietItems
              formatNumber={formatNumber}
              model={model}
              numberCountByLimit={numberCountByLimit}
            />
          ))}
        {memberCount < 1 && (
          <div className="preview-select-tip">{t('liveSelectTip')}</div>
        )}
      </div>
      <p className="live-preview-tip">{t('livePreview')}</p>
    </div>
  )
}

export default LivePreview
