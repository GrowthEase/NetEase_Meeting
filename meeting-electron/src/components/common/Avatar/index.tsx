import { CSSProperties } from 'react'
import { AvatarSize } from '../../../types/innerType'
import { getUserName } from '../../../utils'
import './index.less'

interface AvatarProps {
  className?: string
  nickname: string
  avatar?: string
  style?: CSSProperties | undefined
  size: AvatarSize
  onClick?: (e: any) => void
  onMouseEnter?: (e: any) => void
  onFocus?: (e: any) => void
  onMouseLeave?: (e: any) => void
}
const UserAvatar: React.FC<AvatarProps> = ({
  nickname,
  avatar,
  style,
  size,
  className,
  onClick,
  onFocus,
  onMouseEnter,
  onMouseLeave,
}) => {
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
      {avatar && <img className="nemeeting-avatar-img" src={avatar} />}
    </div>
  )
}

export default UserAvatar
