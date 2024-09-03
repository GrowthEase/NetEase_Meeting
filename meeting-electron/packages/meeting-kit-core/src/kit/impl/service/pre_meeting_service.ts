import { z, ZodError } from 'zod'
import {
  FailureBody,
  FailureBodySync,
  NEResult,
  SuccessBody,
} from 'neroom-types'
import NEMeetingService from '../../../services/NEMeeting'

import NEPreMeetingServiceInterface, {
  NERemoteHistoryMeeting,
  NERemoteHistoryMeetingDetail,
  NEMeetingItem,
  NEMeetingItemStatus,
  NEPreMeetingListener,
  NEScheduledMember,
  NEMeetingRecord,
  NEMeetingAttendeeOffType,
  NEMeetingType,
  NEMeetingLiveAuthLevel,
  NEMeetingItemLiveStatus,
  NEMeetingControl,
  NEMeetingTranscriptionInfo,
  NEMeetingTranscriptionMessage,
  NEChatroomHistoryMessageSearchOption,
  NEMeetingChatMessage,
  NEChatroomMessageSearchOrder,
  NELocalHistoryMeeting,
} from '../../interface/service/pre_meeting_service'
import {
  AttendeeOffType,
  CreateMeetingResponse,
  EventType,
  MeetingRepeatCustomStepUnit,
  MeetingRepeatType,
  NECloudRecordStrategyType,
  NEMeetingCreateOptions,
  Role,
} from '../../../types'
import { NEMeetingRoleType } from '../../interface/service/meeting_service'
import axios from 'axios'
import { NEMeetingWebAppItem } from '../../../types/type'
import { getLocalUserInfo } from '../..'
import { LOCAL_STORAGE_KEY } from '../../../config'

const MODULE_NAME = 'NEPreMeetingService'
const LISTENER_CHANNEL = `NEMeetingKitListener::${MODULE_NAME}`

class NEPreMeetingService implements NEPreMeetingServiceInterface {
  private _meetingKit: NEMeetingService
  private _listeners: NEPreMeetingListener[] = []

  constructor(meetingKit: NEMeetingService) {
    this._meetingKit = meetingKit
    this._addListening()
  }
  async getHistoryMeetingTranscriptionInfo(
    meetingId: number
  ): Promise<NEResult<NEMeetingTranscriptionInfo[]>> {
    const data = await this._meetingKit.getHistoryMeetingTranscriptionInfo(
      meetingId
    )

    return SuccessBody(data)
  }
  async getHistoryMeetingTranscriptionFileUrl(
    meetingId: number,
    fileKey: string
  ): Promise<NEResult<string>> {
    const data = await this._meetingKit.getHistoryMeetingTranscriptionFileUrl(
      meetingId,
      fileKey
    )

    return SuccessBody(data)
  }

  async getLocalHistoryMeetingList(): Promise<
    NEResult<NELocalHistoryMeeting[]>
  > {
    const userInfo = getLocalUserInfo()

    if (userInfo) {
      const data =
        JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) ?? '{}')[
          userInfo?.userUuid
        ] ?? []

      return SuccessBody(
        data.map((item) => {
          return {
            meetingNum: item.meetingNum,
            meetingId: item.meetingId,
            shortMeetingNum: item.shortMeetingNum,
            subject: item.subject,
            password: item.password,
            nickname: item.nickName,
            sipId: item.sipId,
          }
        })
      )
    } else {
      return SuccessBody([])
    }
  }

  async clearLocalHistoryMeetingList(): Promise<NEResult<void>> {
    const obj = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) ?? '{}')

    const userInfo = getLocalUserInfo()

    if (userInfo) {
      obj[userInfo.userUuid] = []
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(obj))
    }

    return SuccessBody(void 0)
  }

  async getHistoryMeetingTranscriptionMessageList(
    meetingId: number,
    fileKey: string
  ): Promise<NEResult<NEMeetingTranscriptionMessage[]>> {
    const url = await this._meetingKit.getHistoryMeetingTranscriptionFileUrl(
      meetingId,
      fileKey
    )
    const content = await axios.get(url, { responseType: 'json' })

    const list: NEMeetingTranscriptionMessage[] = []

    if (content.data) {
      console.log('content.data', content.data)
      // 只有一行的时候本身已是素组
      const lines = Array.isArray(content.data)
        ? [JSON.stringify(content.data)]
        : content.data.split('\n')

      lines.forEach((line) => {
        if (line.trim().length > 0) {
          try {
            const [timestamp, fromUserUuid, fromNickname, content] =
              JSON.parse(line)

            list.push({
              timestamp: Number(timestamp),
              fromUserUuid,
              fromNickname,
              content,
            })
          } catch (error) {
            console.log('parse msg content error', error)
          }
        }
      })
    }

    return SuccessBody(list)
  }

  async getFavoriteMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>> {
    try {
      const anchorIdSchema = z.number()
      const limitSchema = z.number()

      anchorIdSchema.parse(anchorId, {
        path: ['anchorId'],
      })

      limitSchema.parse(limit, {
        path: ['limit'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getCollectMeetingList({
      startId: anchorId,
      limit,
    })

    return SuccessBody(res.favoriteList.map(this._formatRemoteHistoryMeeting))
  }

  async addFavoriteMeeting(meetingId: number): Promise<NEResult<number>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const favoriteId = await this._meetingKit.collectMeeting(meetingId)

    return SuccessBody(favoriteId)
  }

  async removeFavoriteMeeting(meetingId: number): Promise<NEResult<void>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.cancelCollectMeeting(meetingId)

    return SuccessBody(void 0)
  }

  async getHistoryMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>> {
    try {
      const anchorIdSchema = z.number()
      const limitSchema = z.number()

      anchorIdSchema.parse(anchorId, {
        path: ['anchorId'],
      })

      limitSchema.parse(limit, {
        path: ['limit'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    const res = await this._meetingKit.getHistoryMeetingList({
      startId: anchorId,
      limit,
    })

    return SuccessBody(res.meetingList.map(this._formatRemoteHistoryMeeting))
  }

  async getHistoryMeetingDetail(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeetingDetail>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getHistoryMeetingDetail({
      roomArchiveId: meetingId,
    })

    return SuccessBody(res)
  }

  async getMeetingCloudRecordList(
    meetingId: number
  ): Promise<NEResult<NEMeetingRecord[]>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getRoomCloudRecordList(meetingId)

    return res
  }

  async getHistoryMeeting(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeeting>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getHistoryMeeting({
      meetingId,
    })

    return SuccessBody(this._formatRemoteHistoryMeeting(res))
  }

  async createScheduleMeetingItem(): Promise<NEResult<NEMeetingItem>> {
    return SuccessBody({
      meetingId: 0,
      meetingNum: '',
      subject: '',
      startTime: 0,
      endTime: 0,
      noSip: false,
      waitingRoomEnabled: false,
      enableJoinBeforeHost: true,
      enableGuestJoin: false,
      password: '',
      settings: {
        cloudRecordOn: false,
        controls: [],
        currentAudioControl: {
          type: 'audio',
          attendeeOff: NEMeetingAttendeeOffType.AttendeeOffTypeNone,
        },
        currentVideoControl: {
          type: 'video',
          attendeeOff: NEMeetingAttendeeOffType.AttendeeOffTypeNone,
        },
      },
      status: NEMeetingItemStatus.init,
      meetingType: NEMeetingType.NEMeetingTypeReservation,
      inviteUrl: '',
      roomUuid: '',
      ownerUserUuid: '',
      ownerNickname: '',
      shortMeetingNum: '',
      live: {
        enable: false,
        liveWebAccessControlLevel:
          NEMeetingLiveAuthLevel.NEMeetingLiveAuthLevelNormal,
        hlsPullUrl: '',
        httpPullUrl: '',
        rtmpPullUrl: '',
        liveUrl: '',
        pushUrl: '',
        chatRoomId: '',
        liveAVRoomUids: [],
        liveChatRoomEnable: false,
        meetingNum: '',
        state: NEMeetingItemLiveStatus.NEMeetingItemLiveStatusInit,
        taskId: '',
        title: '',
        liveChatRoomIndependent: false,
      },
      extraData: '',
      roleBinds: {},
      scheduledMemberList: [],
      timezoneId: '',
      cloudRecordConfig: {
        enable: false,
        recordStrategy: NECloudRecordStrategyType.HOST_JOIN,
      },
      sipCid: '',
    })
  }

  async scheduleMeeting(item: NEMeetingItem): Promise<NEResult<NEMeetingItem>> {
    try {
      const meetingItemSchema = this._getMeetingItemSchema()

      meetingItemSchema.parse(item, {
        path: ['item'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const opts = this._formatScheduleMeeting(item)

    const res = await this._meetingKit.scheduleMeeting(opts)

    return SuccessBody(this._formatMeetingItem(res))
  }

  async editMeeting(
    item: NEMeetingItem,
    editRecurringMeeting: boolean
  ): Promise<NEResult<NEMeetingItem>> {
    try {
      const meetingItemSchema = this._getMeetingItemSchema()
      const editRecurringMeetingSchema = z.boolean()

      meetingItemSchema.parse(item, {
        path: ['item'],
      })
      editRecurringMeetingSchema.parse(editRecurringMeeting, {
        path: ['editRecurringMeeting'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const opts = this._formatScheduleMeeting(item)

    opts.recurringRule = editRecurringMeeting ? item.recurringRule : undefined

    const res = await this._meetingKit.scheduleMeeting(opts)

    return SuccessBody(this._formatMeetingItem(res))
  }

  async cancelMeeting(
    meetingId: number,
    cancelRecurringMeeting: boolean
  ): Promise<NEResult<void>> {
    try {
      const meetingIdSchema = z.number()
      const cancelRecurringMeetingSchema = z.boolean()

      meetingIdSchema.parse(meetingId, {
        path: ['item'],
      })
      cancelRecurringMeetingSchema.parse(cancelRecurringMeeting, {
        path: ['cancelRecurringMeeting'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    await this._meetingKit.cancelMeeting(meetingId, cancelRecurringMeeting)

    return SuccessBody(void 0)
  }

  async getMeetingItemByNum(
    meetingNum: string
  ): Promise<NEResult<NEMeetingItem>> {
    try {
      const meetingNumSchema = z.string()

      meetingNumSchema.parse(meetingNum, {
        path: ['meetingNum'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getMeetingInfoByFetch(meetingNum)

    return SuccessBody(this._formatMeetingItem(res))
  }

  async getMeetingItemById(
    meetingId: number
  ): Promise<NEResult<NEMeetingItem>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getMeetingInfoByMeetingId(meetingId)

    return SuccessBody(
      this._formatMeetingItem(
        await this._meetingKit.getMeetingInfoByFetch(res.meetingNum)
      )
    )
  }

  async getMeetingList(
    status: NEMeetingItemStatus[]
  ): Promise<NEResult<NEMeetingItem[]>> {
    try {
      const statusSchema = z.array(z.nativeEnum(NEMeetingItemStatus))

      statusSchema.parse(status, {
        path: ['status'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getMeetingList({
      states: status,
    })

    return SuccessBody(res.map(this._formatMeetingItem))
  }

  async getScheduledMeetingMemberList(
    meetingNum: string
  ): Promise<NEResult<NEScheduledMember[]>> {
    try {
      const meetingNumSchema = z.string()

      meetingNumSchema.parse(meetingNum, {
        path: ['meetingNum'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const res = await this._meetingKit.getScheduledMembers(meetingNum)

    return SuccessBody(res)
  }

  async loadWebAppView(
    meetingId: number,
    item: NEMeetingWebAppItem
  ): Promise<NEResult<void>> {
    try {
      const meetingIdSchema = z.number()
      const itemSchema = z.object({
        pluginId: z.string(),
        homeUrl: z.string(),
      })

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
      itemSchema.parse(item, {
        path: ['item'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    this._meetingKit.openPluginWindow(meetingId, item)

    return SuccessBody(void 0)
  }

  async loadChatroomHistoryMessageView(
    meetingId: number
  ): Promise<NEResult<void>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    this._meetingKit.openChatWindow(meetingId)

    return SuccessBody(void 0)
  }

  async fetchChatroomHistoryMessageList(
    meetingId: number,
    option: NEChatroomHistoryMessageSearchOption
  ): Promise<NEResult<NEMeetingChatMessage[]>> {
    try {
      const meetingIdSchema = z.number()
      const optionSchema = z.object({
        startTime: z.number(),
        limit: z.number(),
        order: z.nativeEnum(NEChatroomMessageSearchOrder),
      })

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
      optionSchema.parse(option, {
        path: ['option'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._meetingKit.fetchChatroomHistoryMessageList(meetingId, option)
  }

  async exportChatroomHistoryMessageList(
    meetingId: number
  ): Promise<NEResult<string>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    return this._meetingKit.exportChatroomHistoryMessageList(meetingId)
  }

  addListener(listener: NEPreMeetingListener): void {
    this._listeners.push(listener)
  }

  removeListener(listener: NEPreMeetingListener): void {
    this._listeners = this._listeners.filter((l) => l !== listener)
  }

  private _addListening(): void {
    this._meetingKit.eventEmitter.on(
      EventType.ReceiveScheduledMeetingUpdate,
      async (res) => {
        const data = res.data

        if (data) {
          let { data: meetingItem } = await this.createScheduleMeetingItem()

          // 合并远程数据
          meetingItem.meetingId = data.meetingId
          meetingItem.status = data.state
          meetingItem.meetingNum = data.meetingNum

          try {
            const res = await this.getMeetingItemByNum(data.meetingNum)

            meetingItem = res.data
          } catch {
            // 请求失败，如房间被关闭或者取消 需要被邀请端判断当前是否打开该会议的会议详
          }

          const meetingItemList = [meetingItem]

          this._listeners.forEach((l) => {
            l.onMeetingItemInfoChanged(meetingItemList)
          })

          window.ipcRenderer?.send(LISTENER_CHANNEL, {
            module: 'NEPreMeetingService',
            event: 'onMeetingItemInfoChanged',
            payload: [meetingItemList],
          })
        }
      }
    )
  }

  private _getMeetingItemSchema() {
    return z.object({
      meetingId: z.number().optional(),
      meetingNum: z.string().optional(),
      subject: z.string(),
      startTime: z.number(),
      endTime: z.number(),
      noSip: z.boolean().optional(),
      waitingRoomEnabled: z.boolean().optional(),
      enableJoinBeforeHost: z.boolean().optional(),
      enableGuestJoin: z.boolean().optional(),
      password: z.string().optional(),
      settings: z
        .object({
          cloudRecordOn: z.boolean().optional(),
          controls: z.array(
            z.object({
              type: z.string(),
              attendeeOff: z.nativeEnum(NEMeetingAttendeeOffType),
            })
          ),
          currentAudioControl: z
            .object({
              type: z.string().regex(new RegExp('audio')),
              attendeeOff: z.nativeEnum(NEMeetingAttendeeOffType),
            })
            .optional(),
          currentVideoControl: z
            .object({
              type: z.string().regex(new RegExp('video')),
              attendeeOff: z.nativeEnum(NEMeetingAttendeeOffType),
            })
            .optional(),
        })
        .optional(),
      status: z.nativeEnum(NEMeetingItemStatus).optional(),
      meetingType: z.nativeEnum(NEMeetingType).optional(),
      inviteUrl: z.string().optional(),
      roomUuid: z.string().optional(),
      ownerUserUuid: z.string().optional(),
      ownerNickname: z.string().optional(),
      shortMeetingNum: z.string().optional(),
      live: z
        .object({
          enable: z.boolean().optional(),
          liveWebAccessControlLevel: z
            .nativeEnum(NEMeetingLiveAuthLevel)
            .optional(),
          hlsPullUrl: z.string().optional(),
          httpPullUrl: z.string().optional(),
          rtmpPullUrl: z.string().optional(),
          liveUrl: z.string().optional(),
          pushUrl: z.string().optional(),
          chatRoomId: z.string().optional(),
          liveAVRoomUids: z.array(z.string()).optional(),
          liveChatRoomEnable: z.boolean().optional(),
          meetingNum: z.string().optional(),
          state: z.nativeEnum(NEMeetingItemLiveStatus),
          taskId: z.string().optional(),
          title: z.string().optional(),
          liveChatRoomIndependent: z.boolean().optional(),
        })
        .optional(),
      extraData: z.string().optional(),
      roleBinds: z.record(z.string(), z.nativeEnum(NEMeetingRoleType)),
      recurringRule: z
        .object({
          type: z.nativeEnum(MeetingRepeatType),
          customizedFrequency: z
            .object({
              stepSize: z.number(),
              stepUnit: z.nativeEnum(MeetingRepeatCustomStepUnit),
              daysOfWeek: z.array(z.number()),
              daysOfMonth: z.array(z.number()),
            })
            .optional(),
          endRule: z.object({
            type: z.number(),
            date: z.string().optional(),
            times: z.number().optional(),
          }),
        })
        .optional(),
      scheduledMemberList: z
        .array(
          z.object({
            userUuid: z.string(),
            // 这里是 string 不要动
            role: z.nativeEnum(Role),
          })
        )
        .optional(),
      timezoneId: z.string().optional(),
      interpretationSettings: z
        .object({
          interpreterList: z.array(
            z.object({
              userId: z.string(),
              firstLang: z.string(),
              secondLang: z.string(),
              isValid: z.boolean(),
            })
          ),
        })
        .optional(),
      cloudRecordConfig: z
        .object({
          enable: z.boolean().optional(),
          recordStrategy: z.nativeEnum(NECloudRecordStrategyType).optional(),
        })
        .optional(),
      sipCid: z.string().optional(),
    })
  }

  private _formatMeetingItem(
    meetingResponse: CreateMeetingResponse
  ): NEMeetingItem {
    const interpretationString =
      meetingResponse.settings.roomInfo.roomProperties?.interpretation?.value

    let interpretationSettings

    if (interpretationString) {
      const interpretation = JSON.parse(interpretationString)

      if (interpretation) {
        interpretationSettings = {
          interpreterList: [],
        }
        if (interpretation.interpreters) {
          Object.keys(interpretation.interpreters).forEach((key) => {
            const item = {
              userId: key,
              firstLang: interpretation.interpreters[key][0],
              secondLang: interpretation.interpreters[key][1],
              isValid: true,
            }

            interpretationSettings?.interpreterList.push(item)
          })
        }
      }
    }

    let liveExtensionConfig = {
      liveChatRoomEnable: true,
      onlyEmployeesAllow: false,
    }

    if (
      meetingResponse.settings.roomInfo.roomProperties?.live?.extensionConfig
    ) {
      try {
        liveExtensionConfig = JSON.parse(
          meetingResponse.settings.roomInfo.roomProperties?.live.extensionConfig
        )
      } catch {
        //
      }
    }

    const controls: NEMeetingControl[] = []

    if (meetingResponse.settings.roomInfo.roomProperties?.audioOff?.value) {
      const audioOff =
        meetingResponse.settings.roomInfo.roomProperties?.audioOff?.value

      if (audioOff) {
        const audioOffValue = audioOff?.split('_')[0]

        if (audioOffValue && audioOffValue !== AttendeeOffType.disable) {
          controls.push({
            type: 'audio',
            attendeeOff:
              audioOffValue === AttendeeOffType.offAllowSelfOn
                ? NEMeetingAttendeeOffType.AttendeeOffTypeOffAllowSelfOn
                : NEMeetingAttendeeOffType.AttendeeOffTypeOffNotAllowSelfOn,
          })
        }
      }
    }

    const roleBinds = {}
    const meetingResponseRoleBinds = meetingResponse.settings.roomInfo.roleBinds

    if (meetingResponseRoleBinds) {
      Object.keys(meetingResponseRoleBinds).forEach((key) => {
        roleBinds[key] =
          {
            host: 0,
            cohost: 1,
            member: 2,
            guest: 3,
          }[meetingResponseRoleBinds[key]] ?? 2
      })
    }

    return {
      meetingId: meetingResponse.meetingId,
      meetingNum: meetingResponse.meetingNum,
      subject: meetingResponse.subject,
      startTime: meetingResponse.startTime,
      endTime: meetingResponse.endTime,
      noSip: !meetingResponse.settings.roomInfo.roomConfig.resource.sip,
      waitingRoomEnabled: meetingResponse.settings.roomInfo.openWaitingRoom,
      enableJoinBeforeHost:
        meetingResponse.settings.roomInfo.enableJoinBeforeHost,
      enableGuestJoin:
        meetingResponse?.settings.roomInfo.roomProperties?.guest?.value === '1',
      password: meetingResponse.settings.roomInfo.password ?? '',
      settings: {
        cloudRecordOn:
          !meetingResponse.settings.roomInfo.roomConfig.resource.record,
        controls: controls,
        currentAudioControl: {
          type: 'audio',
          attendeeOff: NEMeetingAttendeeOffType.AttendeeOffTypeNone,
        },
        currentVideoControl: {
          type: 'video',
          attendeeOff: NEMeetingAttendeeOffType.AttendeeOffTypeNone,
        },
      },
      status: meetingResponse.state,
      meetingType: meetingResponse.type,
      inviteUrl: meetingResponse.meetingInviteUrl,
      roomUuid: meetingResponse.roomUuid,
      ownerUserUuid: meetingResponse.ownerUserUuid,
      ownerNickname: meetingResponse.ownerNickname,
      shortMeetingNum: meetingResponse.shortMeetingNum ?? '',
      live: {
        enable: meetingResponse.settings.roomInfo.roomConfig.resource.live,
        liveWebAccessControlLevel: liveExtensionConfig.onlyEmployeesAllow
          ? NEMeetingLiveAuthLevel.NEMeetingLiveAuthLevelAppToken
          : NEMeetingLiveAuthLevel.NEMeetingLiveAuthLevelNormal,
        hlsPullUrl: '',
        httpPullUrl: '',
        rtmpPullUrl: '',
        liveUrl: meetingResponse.settings.liveConfig?.liveAddress ?? '',
        pushUrl: '',
        chatRoomId: '',
        liveAVRoomUids: [],
        liveChatRoomEnable: liveExtensionConfig.liveChatRoomEnable,
        meetingNum: '',
        state: NEMeetingItemLiveStatus.NEMeetingItemLiveStatusInit,
        taskId: '',
        title: '',
        liveChatRoomIndependent: false,
      },
      recurringRule: meetingResponse.recurringRule,
      extraData:
        meetingResponse.settings.roomInfo.roomProperties?.extraData?.value ??
        '',
      roleBinds,
      scheduledMemberList: meetingResponse.scheduledMembers ?? [],
      timezoneId: meetingResponse.timezoneId ?? 'Asia/Shanghai',
      cloudRecordConfig: {
        enable: meetingResponse.settings.roomInfo.roomConfig.resource.record,
        recordStrategy:
          meetingResponse.settings.recordConfig?.recordStrategy ?? 0,
      },
      interpretationSettings,
      sipCid: '',
      meetingAppKey: meetingResponse.meetingAppKey,
      meetingUserToken: meetingResponse.meetingUserToken,
      meetingUserUuid: meetingResponse.meetingUserUuid,
      meetingAuthType: meetingResponse.meetingAuthType,
      guestJoinType: meetingResponse.guestJoinType,
    }
  }

  private _formatScheduleMeeting(item: NEMeetingItem): NEMeetingCreateOptions {
    console.log('_formatScheduleMeeting', item)

    const videoControl = item.settings.controls.find(
      (item) => item.type === 'video'
    )
    const attendeeVideo = {
      off:
        videoControl &&
        videoControl.attendeeOff !==
          NEMeetingAttendeeOffType.AttendeeOffTypeNone,
      attendeeOff:
        videoControl?.attendeeOff ===
        NEMeetingAttendeeOffType.AttendeeOffTypeOffAllowSelfOn
          ? AttendeeOffType.offAllowSelfOn
          : videoControl?.attendeeOff ===
            NEMeetingAttendeeOffType.AttendeeOffTypeOffNotAllowSelfOn
          ? AttendeeOffType.offNotAllowSelfOn
          : AttendeeOffType.disable,
    }

    const audioControl = item.settings.controls.find(
      (item) => item.type === 'audio'
    )
    const attendeeAudio = {
      off:
        audioControl &&
        audioControl.attendeeOff !==
          NEMeetingAttendeeOffType.AttendeeOffTypeNone,
      attendeeOff:
        audioControl?.attendeeOff ===
        NEMeetingAttendeeOffType.AttendeeOffTypeOffAllowSelfOn
          ? AttendeeOffType.offAllowSelfOn
          : audioControl?.attendeeOff ===
            NEMeetingAttendeeOffType.AttendeeOffTypeOffNotAllowSelfOn
          ? AttendeeOffType.offNotAllowSelfOn
          : AttendeeOffType.disable,
    }

    const interpretation = {
      interpreters: {},
      started: false,
    }

    if (item.interpretationSettings) {
      item.interpretationSettings.interpreterList.forEach((item) => {
        interpretation.interpreters[item.userId] = [
          item.firstLang,
          item.secondLang,
        ]
      })
    }

    const roleBinds = {}

    if (item.roleBinds) {
      Object.keys(item.roleBinds).forEach((key) => {
        const value = item.roleBinds?.[key] ?? 2

        roleBinds[key] = ['host', 'cohost', 'member', 'guest'][value]
      })
    }

    return {
      meetingNum: '',
      meetingId: item.meetingId === 0 ? undefined : item.meetingId,
      nickName: '', // 保留字段
      subject: item.subject,
      roleBinds,
      noSip: item.noSip,
      openLive: item.live.enable,
      liveOnlyEmployees: item.live.liveWebAccessControlLevel === 2,
      extraData: item.extraData,
      attendeeVideoOff: attendeeVideo.off,
      attendeeAudioOff: attendeeAudio.off,
      attendeeAudioOffType: attendeeAudio.attendeeOff,
      startTime: item.startTime,
      endTime: item.endTime,
      enableWaitingRoom: item.waitingRoomEnabled,
      enableGuestJoin: item.enableGuestJoin,
      enableJoinBeforeHost: item.enableJoinBeforeHost,
      recurringRule: item.recurringRule,
      scheduledMembers: item.scheduledMemberList,
      timezoneId: item.timezoneId,
      interpretation: interpretation,
      cloudRecordConfig: item.cloudRecordConfig,
      password: item.password,
    }
  }

  private _formatRemoteHistoryMeeting(
    remoteHistoryMeeting: NERemoteHistoryMeeting
  ): NERemoteHistoryMeeting {
    const initData = {
      anchorId: 0,
      meetingId: 0,
      meetingNum: '',
      subject: '',
      type: 0,
      roomEntryTime: 0,
      roomStartTime: 0,
      ownerAvatar: '',
      ownerUserUuid: '',
      ownerNickname: '',
      favoriteId: 0,
      roomEndTime: 0,
      timeZoneId: '',
    }

    if (!remoteHistoryMeeting.meetingId) {
      remoteHistoryMeeting.meetingId = remoteHistoryMeeting.roomArchiveId
    }

    if (!remoteHistoryMeeting.anchorId) {
      remoteHistoryMeeting.anchorId = remoteHistoryMeeting.attendeeId
    }

    return {
      ...initData,
      ...remoteHistoryMeeting,
    }
  }
}

export default NEPreMeetingService
