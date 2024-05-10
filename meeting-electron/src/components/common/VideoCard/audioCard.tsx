import React, { useMemo } from 'react'
import { AvatarSize, NEMember } from '../../../types'
import UserAvatar from '../Avatar'
import AudioIcon from '../AudioIcon'
import './index.less'
import { useTranslation } from 'react-i18next'

interface AudioCardProps {
  className?: string
  member: NEMember
  size?: AvatarSize
  style?: React.CSSProperties
  onClick?: (e: any) => void
  ref?: any
  children?: React.ReactNode
  onCallClick?: (member: NEMember) => void
}
const AudioCard: React.FC<AudioCardProps> = (props) => {
  const { member, className, size, style, onClick, ref, onCallClick } = props
  const { t } = useTranslation()
  const isInPhone = useMemo(() => {
    return member.properties?.phoneState?.value == '1'
  }, [member.properties?.phoneState?.value])
  return (
    <div
      ref={ref}
      onClick={onClick}
      style={style}
      className={`nemeeting-audio-card ${className || ''}`}
    >
      <div className="nemeeting-audio-card-content">
        <div className="nemeeting-audio-card-avatar">
          <UserAvatar
            nickname={member.name}
            avatar={member.avatar}
            inviteState={member.inviteState}
            onCallClick={() => onCallClick?.(member)}
            size={size || 64}
          />
          {isInPhone && (
            <div className="nemeeting-audio-card-phone-icon">
              <svg
                className="icon iconfont nemeeting-icon-phone"
                aria-hidden="true"
              >
                <use xlinkHref="#icondianhua"></use>
              </svg>
            </div>
          )}
        </div>
        <div className="nemeeting-audio-card-name-wrap">
          <div className="nemeeting-audio-card-name nemeeting-ellipsis">
            {member.name}
          </div>
          {!member.inviteState && member.isAudioConnected ? (
            <div className="nemeeting-audio-card-audio-icon">
              {member.isAudioOn ? (
                <AudioIcon
                  className="icon iconfont"
                  audioLevel={member.volume || 0}
                  memberId={member.uuid}
                />
              ) : (
                <svg className="icon icon-red iconfont" aria-hidden="true">
                  <use xlinkHref="#iconyx-tv-voice-offx"></use>
                </svg>
              )}
            </div>
          ) : null}
        </div>
        {isInPhone && (
          <div
            title={t('answeringPhone')}
            className="nemeeting-in-phone-tip nemeeting-ellipsis"
          >
            {t('answeringPhone')}
          </div>
        )}
      </div>
      {props.children}
    </div>
  )
}

export default React.memo(AudioCard)
