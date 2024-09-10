import { FailureBodySync } from 'neroom-types'
import NEFeedbackService from '../../../kit/impl/service/feedback_service'

export default class NEFeedbackServiceHandle {
  private _feedbackService: NEFeedbackService

  constructor(feedbackService: NEFeedbackService) {
    this._feedbackService = feedbackService
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 1:
        res = await this.feedback(data)
        break
      case 3:
        res = await this.showFeedbackView()
        break
      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async feedback(data: string) {
    const { feedback } = JSON.parse(data)

    return await this._feedbackService.feedback(feedback)
  }

  async showFeedbackView() {
    return await this._feedbackService.showFeedbackView()
  }
}
