import { NEResult } from 'neroom-types'

export type NEFeedback = {
  category: string
  description: string
  time?: number
  imageList?: string[]
  needAudioDump?: boolean
}

interface NEFeedbackService {
  /**
   * 意见反馈接口
   * @param feedback 意见反馈的内容
   */
  feedback(feedback: NEFeedback): Promise<NEResult<void>>
  /**
   * 展示意见反馈界面
   */
  showFeedbackView(): Promise<NEResult<void>>
}

export default NEFeedbackService
