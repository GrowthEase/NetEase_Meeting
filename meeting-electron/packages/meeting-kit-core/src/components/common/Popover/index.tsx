import React from 'react'
import { Popover, PopoverProps } from 'antd'
import './index.less'

const MeetingPopover: React.FC<PopoverProps> = (props) => {
  return <Popover rootClassName="meeting-popover" {...props} />
}

export default MeetingPopover
