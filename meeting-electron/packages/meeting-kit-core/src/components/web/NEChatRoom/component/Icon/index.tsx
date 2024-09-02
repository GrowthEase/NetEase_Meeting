import React from 'react'

type IconProps = {
  type: string
  style?: React.CSSProperties
  width?: string | number
  height?: string | number
  color?: string
  onClick?: () => void
}

const MyIcon: React.FC<IconProps> = (props) => {
  const { type, style, width, height, color, onClick } = props

  return (
    <svg
      style={{
        width,
        height,
        color,
        ...style,
      }}
      className={`icon iconfont`}
      aria-hidden="true"
      onClick={onClick}
    >
      <use xlinkHref={`#${type}`}></use>
    </svg>
  )
}

export default MyIcon
