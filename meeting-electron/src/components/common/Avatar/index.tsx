import EditOutlined from '@ant-design/icons/EditOutlined'
import { CSSProperties, useEffect, useMemo, useRef, useState } from 'react'
import { AvatarSize } from '../../../types/innerType'
import { NEMeetingInviteStatus } from '../../../types/type'
import { getUserName } from '../../../utils'
import './index.less'
import { NERoomMemberInviteState } from 'neroom-web-sdk'

interface AvatarProps {
  className?: string
  nickname: string
  avatar?: string
  style?: CSSProperties | undefined
  size: AvatarSize
  isEdit?: boolean
  onClick?: (e: any) => void
  onMouseEnter?: (e: any) => void
  onFocus?: (e: any) => void
  onMouseLeave?: (e: any) => void
  inviteState?: NEMeetingInviteStatus | NERoomMemberInviteState
  onCallClick?: () => void
}
const UserAvatar: React.FC<AvatarProps> = ({
  nickname,
  avatar,
  style,
  size,
  className,
  isEdit,
  onClick,
  onFocus,
  onMouseEnter,
  onMouseLeave,
  inviteState,
  onCallClick,
}) => {
  const [canShowImg, setCanShowImg] = useState(true)
  const imgRef = useRef<HTMLImageElement>(null)
  useEffect(() => {
    function handleLoad() {
      setCanShowImg(true)
    }
    function handleError() {
      setCanShowImg(false)
    }
    if (avatar && imgRef.current) {
      imgRef.current.addEventListener('load', handleLoad)
      imgRef.current.addEventListener('error', handleError)

      return () => {
        imgRef.current?.removeEventListener('load', handleLoad)
        imgRef.current?.removeEventListener('error', handleError)
      }
    }
  }, [avatar])

  const inviteStateContent = useMemo(() => {
    switch (inviteState) {
      case NEMeetingInviteStatus.waitingCall:
      case NEMeetingInviteStatus.calling:
      case NEMeetingInviteStatus.waitingJoin:
        return <div className="invite-state-wrapper">...</div>
      case NEMeetingInviteStatus.rejected:
      case NEMeetingInviteStatus.noAnswer:
      case NEMeetingInviteStatus.error:
      case NEMeetingInviteStatus.canceled:
        return (
          <div className="invite-state-wrapper" onClick={() => onCallClick?.()}>
            <svg
              className="icon iconfont nemeeting-icon-phone"
              aria-hidden="true"
            >
              <use xlinkHref="#icondianhua"></use>
            </svg>
          </div>
        )
      default:
        return null
    }
  }, [inviteState])
  return (
    <div
      onClick={onClick}
      onFocus={onFocus}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
      style={{ ...style }}
      className={`nemeeting-avatar nemeeting-avatar-${size} ${className || ''}`}
    >
      {getUserName(nickname)}
      {avatar && canShowImg && (
        <img ref={imgRef} className="nemeeting-avatar-img" src={avatar} />
      )}
      {inviteStateContent}
      {isEdit && <EditOutlined className="avatar-edit-icon" />}
    </div>
  )
}

export default UserAvatar
