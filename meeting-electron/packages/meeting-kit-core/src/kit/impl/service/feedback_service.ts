import { FailureBodySync, NEResult, SuccessBody } from 'neroom-types'
import NEMeetingService from '../../../services/NEMeeting'
import NEFeedbackServiceInterface, {
  NEFeedback,
} from '../../interface/service/feedback_service'
import { z, ZodError } from 'zod'

export default class NEFeedbackService implements NEFeedbackServiceInterface {
  private _neMeeting: NEMeetingService

  constructor(params: { neMeeting: NEMeetingService }) {
    this._neMeeting = params.neMeeting
  }

  async feedback(feedback: NEFeedback): Promise<NEResult<void>> {
    try {
      const feedbackSchema = z.object({
        category: z.string(),
        description: z.string(),
        time: z.number().optional(),
        imageList: z.array(z.string()).optional(),
        needAudioDump: z.boolean().optional(),
      })

      feedbackSchema.parse(feedback, {
        path: ['feedback'],
      })
    } catch (errorUnknown) {
      const error = errorUnknown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    await this._neMeeting.feedbackApi(feedback)
    return SuccessBody(void 0)
  }
  /**
   * 展示意见反馈界面
   */
  async showFeedbackView(): Promise<NEResult<void>> {
    this._neMeeting.openFeedbackWindow()

    return SuccessBody(void 0)
  }
}
