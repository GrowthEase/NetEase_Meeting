import { useMeetingInfoContext } from '../store'
import { useUpdateEffect } from 'ahooks'
import { closeAllWindows } from '../kit'

export default function useWindowManage() {
  const { meetingInfo } = useMeetingInfoContext()

  useUpdateEffect(() => {
    // 会议号变更，或进出等候室， 关闭所有独立窗口
    closeAllWindows()
  }, [meetingInfo.meetingNum, meetingInfo.inWaitingRoom])
}
