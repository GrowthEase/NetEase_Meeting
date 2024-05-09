import { CSSProperties, useEffect, useRef, useState } from 'react'
import EditOutlined from '@ant-design/icons/EditOutlined'
import { AvatarSize } from '../../../types/innerType'
import { getUserName } from '../../../utils'
import './index.less'

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
      {isEdit && <EditOutlined className="avatar-edit-icon" />}
    </div>
  )
}

export default UserAvatar
