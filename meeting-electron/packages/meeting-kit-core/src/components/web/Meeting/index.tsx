import React, { useEffect } from 'react'
import './index.less'
// import '../../../assets/iconfont/iconfont.css'
import { ConfigProvider } from 'antd'

import { useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import WaitingRoom from '../WaitingRoom'
import MeetingContent from './Meeting'

const antdPrefixCls = 'nemeeting'

ConfigProvider.config({ prefixCls: antdPrefixCls })

interface AppProps {
  width: number
  height: number
}

const Meeting: React.FC<AppProps> = ({ height, width }) => {
  const { meetingInfo, dispatch } = useMeetingInfoContext()

  useEffect(() => {
    let timer: null | ReturnType<typeof setTimeout> = null
    let count = 0

    document.addEventListener('click', () => {
      if (timer) {
        clearTimeout(timer)
      }

      timer = setTimeout(() => {
        count = 0
      }, 1000)
      count++
      if (count === 30) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isDebugMode: true,
          },
        })
      }
    })
  }, [dispatch])

  return meetingInfo?.inWaitingRoom ? (
    meetingInfo.meetingNum ? (
      <WaitingRoom />
    ) : null
  ) : (
    <MeetingContent width={width} height={height} />
  )
}

export default Meeting
