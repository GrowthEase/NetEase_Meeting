import EditOutlined from '@ant-design/icons/EditOutlined'
import React, { CSSProperties, useEffect, useRef, useState } from 'react'
import { AvatarSize } from '../../../types/innerType'
import { NEMeetingInviteStatus } from '../../../types/type'
import { getUserName } from '../../../utils'
import './index.less'
import { NERoomMemberInviteState } from 'neroom-types'
import { useMeetingInfoContext } from '../../../store'

interface AvatarProps {
  className?: string
  nickname?: string
  avatar?: string
  style?: CSSProperties | undefined
  size: AvatarSize
  isEdit?: boolean
  onClick?: (e: React.MouseEvent<HTMLDivElement>) => void
  onMouseEnter?: (e: React.MouseEvent<HTMLDivElement>) => void
  onFocus?: (e: React.FocusEvent<HTMLDivElement>) => void
  onMouseLeave?: (e: React.MouseEvent<HTMLDivElement>) => void
  inviteState?: NEMeetingInviteStatus | NERoomMemberInviteState
  onCallClick?: () => void
}
const UserAvatar: React.FC<AvatarProps> = ({
  nickname = '',
  avatar,
  style,
  size,
  className,
  isEdit,
  onClick,
  onFocus,
  onMouseEnter,
  onMouseLeave,
}) => {
  const [canShowImg, setCanShowImg] = useState(true)
  const imgRef = useRef<HTMLImageElement>(null)
  const [isAvatarHide, setIsAvatarHide] = useState(false)
  const { meetingInfo } = useMeetingInfoContext()

  useEffect(() => {
    setIsAvatarHide(!!meetingInfo.avatarHide)
  }, [meetingInfo.avatarHide])

  useEffect(() => {
    function handleLoad() {
      setCanShowImg(true)
    }

    function handleError() {
      setCanShowImg(false)
    }

    if (avatar && imgRef.current) {
      const imgRefDom = imgRef.current

      imgRefDom.addEventListener('load', handleLoad)
      imgRefDom.addEventListener('error', handleError)

      return () => {
        imgRefDom.removeEventListener('load', handleLoad)
        imgRefDom.removeEventListener('error', handleError)
      }
    }
  }, [avatar])

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
      {avatar && canShowImg && !isAvatarHide && (
        <img ref={imgRef} className="nemeeting-avatar-img" src={avatar} />
      )}
      {isEdit && <EditOutlined className="avatar-edit-icon" />}
    </div>
  )
}

export default UserAvatar
