import { z, ZodError } from 'zod'
import {
  FailureBody,
  NECustomSessionMessage,
  NEMessageSearchOrder,
  NEResult,
  SuccessBody,
} from 'neroom-types'
import NEMeetingMessageChannelServiceInterface, {
  NEMeetingGetMessageHistoryParams,
  NEMeetingMessageChannelListener,
  NEMeetingSessionMessage,
  NEMeetingSessionTypeEnum,
} from '../../interface/service/meeting_message_channel_service'
import { Logger } from '../../../utils/Logger'
import NEMeetingService from '../../../services/NEMeeting'
import { EventType } from '../../../types'

const MODULE_NAME = 'NEMeetingMessageChannelService'
const LISTENER_CHANNEL = `NEMeetingKitListener::${MODULE_NAME}`

export default class NEMeetingMessageChannelService
  implements NEMeetingMessageChannelServiceInterface
{
  private _logger: Logger
  private _neMeeting: NEMeetingService
  private _listeners: NEMeetingMessageChannelListener[] = []

  constructor(params: { logger: Logger; neMeeting: NEMeetingService }) {
    this._logger = params.logger
    this._neMeeting = params.neMeeting

    this._neMeeting.eventEmitter.on(
      EventType.onSessionMessageReceived,
      (data) => {
        const message = this._customSessionMessageToMeetingSessionMessage(data)

        this._listeners.forEach((listener) => {
          listener?.onSessionMessageReceived?.(message)
        })
        window.ipcRenderer?.send(LISTENER_CHANNEL, {
          module: 'NEMeetingMessageChannelService',
          event: 'onSessionMessageReceived',
          payload: [message],
        })
      }
    )
    this._neMeeting.eventEmitter.on(
      EventType.onSessionMessageRecentChanged,
      (data) => {
        this._listeners.forEach((listener) => {
          listener?.onSessionMessageRecentChanged?.(data)
        })
        window.ipcRenderer?.send(LISTENER_CHANNEL, {
          module: 'NEMeetingMessageChannelService',
          event: 'onSessionMessageRecentChanged',
          payload: [data],
        })
      }
    )
    this._neMeeting.eventEmitter.on(
      EventType.onSessionMessageDeleted,
      (data) => {
        this._listeners.forEach((listener) => {
          listener?.onSessionMessageDeleted?.(
            this._customSessionMessageToMeetingSessionMessage(data)
          )
        })
        window.ipcRenderer?.send(LISTENER_CHANNEL, {
          module: 'NEMeetingMessageChannelService',
          event: 'onSessionMessageDeleted',
          payload: [data],
        })
      }
    )
    this._neMeeting.eventEmitter.on(
      EventType.OnDeleteAllSessionMessage,
      (sessionId, sessionType) => {
        this._listeners.forEach((listener) => {
          listener?.onSessionMessageAllDeleted?.(sessionId, sessionType)
        })
        window.ipcRenderer?.send(LISTENER_CHANNEL, {
          module: 'NEMeetingMessageChannelService',
          event: 'onSessionMessageAllDeleted',
          payload: [sessionId, sessionType],
        })
      }
    )

    this._neMeeting
  }
  addMeetingMessageChannelListener(
    listener: NEMeetingMessageChannelListener
  ): void {
    this._listeners.push(listener)
  }
  removeMeetingMessageChannelListener(
    listener: NEMeetingMessageChannelListener
  ): void {
    this._listeners = this._listeners.filter((l) => l !== listener)
  }
  queryUnreadMessageList(
    sessionId: string
  ): Promise<NEResult<NEMeetingSessionMessage[]>> {
    try {
      const sessionIdSchema = z.string()

      sessionIdSchema.parse(sessionId, {
        path: ['sessionId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._neMeeting.queryUnreadMessageList(sessionId).then((res) => {
      const result = res.map((item) => {
        return this._customSessionMessageToMeetingSessionMessage(item)
      })

      return SuccessBody(result)
    })
  }
  clearUnreadCount(sessionId: string): Promise<NEResult<void>> {
    try {
      const sessionIdSchema = z.string()

      sessionIdSchema.parse(sessionId, {
        path: ['sessionId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._neMeeting.clearUnreadCount(sessionId).then(() => {
      return SuccessBody(void 0)
    })
  }
  deleteAllSessionMessage(sessionId: string): Promise<NEResult<void>> {
    try {
      const sessionIdSchema = z.string()

      sessionIdSchema.parse(sessionId, {
        path: ['sessionId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._neMeeting.deleteAllSessionMessage(sessionId).then(() => {
      return SuccessBody(void 0)
    })
  }
  getSessionMessagesHistory(
    param: NEMeetingGetMessageHistoryParams
  ): Promise<NEResult<NEMeetingSessionMessage[]>> {
    try {
      const paramSchema = z.object({
        sessionId: z.string(),
        fromTime: z.number().optional(),
        toTime: z.number(),
        limit: z.number(),
        searchOrder: z.nativeEnum(NEMessageSearchOrder).optional(),
      })

      paramSchema.parse(param, {
        path: ['param'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const options: {
      sessionId: string
      fromTime?: number
      toTime?: number
      limit?: number
      order?: NEMessageSearchOrder
    } = {
      ...param,
    }

    if (param.searchOrder !== undefined) {
      options.order = param.searchOrder
    }

    return this._neMeeting.getSessionMessagesHistory(options).then((res) => {
      const result = res.map((item) => {
        return this._customSessionMessageToMeetingSessionMessage(item)
      })

      return SuccessBody(result)
    })
  }

  private _customSessionMessageToMeetingSessionMessage(
    message: NECustomSessionMessage
  ) {
    const data =
      typeof message.data === 'string'
        ? message.data
        : JSON.stringify(message.data)

    return {
      messageId: message.messageId,
      sessionId: message.sessionId,
      sessionType: message.sessionType as unknown as NEMeetingSessionTypeEnum,
      data,
      time: message.time,
    }
  }
}
