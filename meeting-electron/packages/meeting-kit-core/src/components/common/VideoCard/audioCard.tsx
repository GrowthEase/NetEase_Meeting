import React, { useMemo } from 'react'
import { AvatarSize, NEMember } from '../../../types'
import UserAvatar from '../Avatar'
import AudioIcon from '../AudioIcon'
import './index.less'
import { useTranslation } from 'react-i18next'
import { NEMeetingInviteStatus } from '../../../kit'
import Emoticons from '../Emoticons'

interface AudioCardProps {
  className?: string
  member: NEMember
  size?: AvatarSize
  style?: React.CSSProperties
  onClick?: (e: React.MouseEvent<HTMLDivElement>) => void
  ref?: React.RefObject<HTMLDivElement>
  children?: React.ReactNode
  onCallClick?: (member: NEMember) => void
}
const AudioCard: React.FC<AudioCardProps> = (props) => {
  const { member, className, size, style, onClick, ref, onCallClick } = props
  const { t } = useTranslation()
  const isInPhone = useMemo(() => {
    return member.properties?.phoneState?.value == '1'
  }, [member.properties?.phoneState?.value])

  const inviteStateContent = useMemo(() => {
    switch (member.inviteState) {
      case NEMeetingInviteStatus.waitingCall:
      case NEMeetingInviteStatus.calling:
      case NEMeetingInviteStatus.waitingJoin:
        return (
          <div
            className="invite-state-wrapper"
            style={{
              fontSize: '14px',
              borderRadius: '50%',
            }}
          >
            {t('sipCalling')}
          </div>
        )
      case NEMeetingInviteStatus.rejected:
      case NEMeetingInviteStatus.noAnswer:
      case NEMeetingInviteStatus.error:
      case NEMeetingInviteStatus.canceled:
      case NEMeetingInviteStatus.busy:
        return (
          <div
            className="invite-state-wrapper"
            onClick={() => onCallClick?.(member)}
            style={{
              borderRadius: '50%',
            }}
          >
            {t('notJoined')}
          </div>
        )
      default:
        return null
    }
  }, [member.inviteState])

  const CallingIcon = useMemo(() => {
    switch (member.inviteState) {
      case NEMeetingInviteStatus.rejected:
      case NEMeetingInviteStatus.noAnswer:
      case NEMeetingInviteStatus.error:
      case NEMeetingInviteStatus.canceled:
      case NEMeetingInviteStatus.busy:
        return (
          <div
            className="invite-state-icon"
            onClick={() => onCallClick?.(member)}
          >
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconhujiao1"></use>
            </svg>
          </div>
        )
      default:
        return null
    }
  }, [member.inviteState])

  return (
    <div
      ref={ref}
      onClick={onClick}
      style={style}
      className={`nemeeting-audio-card ${className || ''}`}
    >
      <Emoticons
        size={40}
        userUuid={member.uuid}
        isHandsUp={member.isHandsUp}
        className="nemeeting-audio-card-emoticons"
      />
      <div className="nemeeting-audio-card-content">
        <div className="nemeeting-audio-card-avatar">
          <UserAvatar
            nickname={member.name}
            avatar={member.avatar}
            inviteState={member.inviteState}
            onCallClick={() => onCallClick?.(member)}
            size={size || 64}
          />
          {inviteStateContent}
          {CallingIcon}
          {isInPhone && (
            <div
              className="invite-state-wrapper"
              style={{
                fontSize: '24px',
                borderRadius: '50%',
              }}
            >
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#icondaihujiao"></use>
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
