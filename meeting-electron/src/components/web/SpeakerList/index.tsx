import React, { useMemo } from 'react'
import { Speaker } from '../../../types'
import { useTranslation } from 'react-i18next'
import './index.less'
interface SpeakerListProps {
  className?: string
  speakerList: Speaker[]
  onClick?: () => void
}
const SpeakerList: React.FC<SpeakerListProps> = ({
  speakerList,
  onClick,
  className,
}) => {
  const { t } = useTranslation()
  const speakerStr = useMemo(() => {
    let str = ''
    speakerList.forEach((speaker, index) => {
      str += (index > 0 ? '、' : '') + speaker.nickName
    })
    return str
  }, [speakerList])
  const handleClick = () => {
    onClick?.()
  }
  return (
    <div className={`speaker-list-wrap ${className}`} onClick={handleClick}>
      <div className={'speaker-list-mic'}>
        <svg className={'icon speaker-icon'} aria-hidden="true">
          <use xlinkHref="#iconyx-tv-voice-onx"></use>
        </svg>
      </div>
      <span className={'speaker-title'}>{t('meetingSpeakingPrefix')}：</span>
      <span className={'speaker-info'} title={speakerStr}>
        {speakerStr}
      </span>
    </div>
  )
}

export default React.memo(SpeakerList)
