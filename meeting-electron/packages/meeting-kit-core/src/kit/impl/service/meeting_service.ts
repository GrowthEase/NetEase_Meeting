import { z, ZodError, ZodRawShape } from 'zod'
import { FailureBodySync, NEResult, SuccessBody } from 'neroom-types'
import {
  CommonBar,
  CreateOptions,
  JoinOptions,
  NEMeetingInfo as ReducerMeetingInfo,
  NEMeetingKit,
  UserEventType,
  Role,
  NECloudRecordStrategyType,
  NEMeetingIdDisplayOption,
  AttendeeOffType,
  EventType,
} from '../../../types'
import {
  NEJoinMeetingParams,
  NEMeetingStatus,
  NEMeetingStatusListener,
  NELocalHistoryMeeting,
} from '../../../types/type'
import NEMeetingServiceInterface, {
  NEEncryptionMode,
  NEJoinMeetingOptions,
  NEMeetingInfo,
  NEMeetingOnInjectedMenuItemClickListener,
  NEMeetingOptions,
  NEMeetingRoleType,
  NEMeetingServiceListener,
  NEStartMeetingOptions,
  NEStartMeetingParams,
  NEWindowMode,
  NESingleStateMenuItem,
  NECheckableMenuItem,
  NEMeetingMenuItem,
} from '../../interface/service/meeting_service'
import MeetingService from '../../../services/NEMeeting'
import { LOCAL_STORAGE_KEY } from '../../../config'
import { getLocalUserInfo } from '../../../utils'
import { NEMeetingAttendeeOffType } from '../../interface/service/pre_meeting_service'

const MODULE_NAME = 'NEMeetingService'
const LISTENER_CHANNEL = `NEMeetingKitListener::${MODULE_NAME}`

export default class NEMeetingService implements NEMeetingServiceInterface {
  private _neMeeting: MeetingService
  private _meetingKit: NEMeetingKit
  private _meetingStatus: NEMeetingStatus = NEMeetingStatus.MEETING_STATUS_IDLE
  private _listeners: NEMeetingServiceListener[] = []
  private _menuItemClickListeners: NEMeetingOnInjectedMenuItemClickListener[] =
    []
  private _meetingStatusListeners: NEMeetingStatusListener[] = []

  constructor(params: { neMeeting: MeetingService; meetingKit: NEMeetingKit }) {
    this._neMeeting = params.neMeeting
    this._meetingKit = params.meetingKit
    this._neMeeting.eventEmitter.on(
      EventType.AcceptInviteJoinSuccess,
      (nickname) => {
        this._saveMeetingInfoIn(nickname)
      }
    )

    this._meetingKit?.on('roomEnded', (reason: number) => {
      this._meetingStatus = NEMeetingStatus.MEETING_STATUS_DISCONNECTING
      this._listeners?.forEach((listener) => {
        listener?.onRoomEnded?.(reason)
      })

      this._meetingStatusListeners?.forEach((listener) => {
        listener?.onMeetingStatusChanged?.({
          status: NEMeetingStatus.MEETING_STATUS_DISCONNECTING,
          arg: reason,
        })
      })

      window.ipcRenderer?.send(LISTENER_CHANNEL, {
        module: 'NEMeetingService',
        event: 'onMeetingStatusChanged',
        payload: [
          {
            status: NEMeetingStatus.MEETING_STATUS_DISCONNECTING,
            arg: reason,
          },
        ],
      })
    })
    this._meetingKit.on(
      UserEventType.onMeetingStatusChanged,
      (status: NEMeetingStatus) => {
        this._meetingStatus = status
        this._meetingStatusListeners?.forEach((listener) => {
          listener?.onMeetingStatusChanged?.({ status })
        })
        window.ipcRenderer?.send(LISTENER_CHANNEL, {
          module: 'NEMeetingService',
          event: 'onMeetingStatusChanged',
          payload: [{ status }],
        })
      }
    )
    this._neMeeting.eventEmitter.on(
      UserEventType.OnInjectedMenuItemClick,
      async (item) => {
        const { data: meetingInfo } = await this.getCurrentMeetingInfo()

        if (meetingInfo) {
          this._menuItemClickListeners.forEach((listener) => {
            listener.onInjectedMenuItemClick?.(item, meetingInfo)
          })

          window.ipcRenderer?.send(LISTENER_CHANNEL, {
            module: 'NEMeetingService',
            event: 'onInjectedMenuItemClick',
            payload: [item, meetingInfo],
          })
        }
      }
    )
  }
  setOnInjectedMenuItemClickListener(
    listener: NEMeetingOnInjectedMenuItemClickListener
  ): void {
    this._menuItemClickListeners.push(listener)
  }
  async startMeeting(
    param: NEStartMeetingParams,
    opts?: NEStartMeetingOptions
  ): Promise<NEResult<void>> {
    try {
      const paramSchema = this._getStartJoinParamSchema({
        meetingNum: z.string().optional(),
        extraData: z.string().optional(),
        subject: z.string().optional(),
        controls: z
          .array(
            z.object({
              type: z.string(),
              attendeeOff: z.nativeEnum(NEMeetingAttendeeOffType),
            })
          )
          .optional(),
        roleBinds: z
          .record(z.string(), z.nativeEnum(NEMeetingRoleType))
          .optional(),
      })

      const optsSchema = this._getStartJoinOptsSchema().optional()

      paramSchema.parse(param, {
        path: ['param'],
      })

      optsSchema.parse(opts, {
        path: ['opts'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    const options: CreateOptions = this._createMeetingOptionsToCreateOptions(
      param,
      opts
    )

    return new Promise((resolve, reject) => {
      this._meetingKit.create(options, (e) => {
        if (e) {
          reject(e)
        } else {
          resolve(SuccessBody(void 0))

          this._saveMeetingInfoIn(param.displayName)
        }
      })
    })
  }

  async joinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>> {
    try {
      const paramSchema = this._getStartJoinParamSchema({
        meetingNum: z.string(),
      })

      const optsSchema = this._getStartJoinOptsSchema()

      paramSchema.parse(param, {
        path: ['param'],
      })

      optsSchema.parse(opts, {
        path: ['opts'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    const options = this._joinMeetingOptionsToJoinOptions(param, opts)

    return new Promise((resolve, reject) => {
      this._meetingKit.join(options, (e) => {
        if (e) {
          reject(e)
        } else {
          resolve(SuccessBody(void 0))

          this._saveMeetingInfoIn(param.displayName)
        }
      })
    })
  }
  async anonymousJoinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>> {
    try {
      const paramSchema = this._getStartJoinParamSchema({
        meetingNum: z.string(),
      })

      const optsSchema = this._getStartJoinOptsSchema()

      paramSchema.parse(param, {
        path: ['param'],
      })

      optsSchema.parse(opts, {
        path: ['opts'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    const options = this._joinMeetingOptionsToJoinOptions(param, opts)

    return new Promise((resolve, reject) => {
      this._meetingKit.anonymousJoinMeeting(options, (e) => {
        if (e) {
          reject(e)
        } else {
          resolve(SuccessBody(void 0))

          this._saveMeetingInfoIn(param.displayName)
        }
      })
    })
  }
  async updateInjectedMenuItem(
    item: NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  ): Promise<NEResult<void>> {
    return new Promise((resolve) => {
      if (this._isNESingleStateMenuItem(item)) {
        this._neMeeting.outEventEmitter.emit(
          UserEventType.UpdateInjectedMenuItem,
          {
            id: item.itemId,
            visibility: item.visibility,
            type: 'single',
            btnConfig: {
              icon: item.singleStateItem.icon,
              lightIcon: item.singleStateItem.icon,
              text: item.singleStateItem.text,
            },
            injectItemClick: () => void 0,
          },
          () => {
            resolve(SuccessBody(void 0))
          }
        )
      } else if (this._isNECheckableMenuItem(item)) {
        this._neMeeting.outEventEmitter.emit(
          UserEventType.UpdateInjectedMenuItem,
          {
            id: item.itemId,
            visibility: item.visibility,
            type: 'multiple',
            btnConfig: [
              {
                icon: item.checkedStateItem.icon,
                text: item.checkedStateItem.text,
                status: true,
              },
              {
                icon: item.uncheckStateItem.icon,
                text: item.uncheckStateItem.text,
                status: false,
              },
            ],
            btnStatus: item.checked,
            injectItemClick: () => void 0,
          },
          () => {
            resolve(SuccessBody(void 0))
          }
        )
      } else {
        this._neMeeting.outEventEmitter.emit(
          UserEventType.UpdateInjectedMenuItem,
          {
            id: item.itemId,
            visibility: item.visibility,
          }
        )
      }
    })
  }
  async getMeetingStatus(): Promise<NEResult<NEMeetingStatus>> {
    return SuccessBody(this._meetingStatus)
  }
  async getCurrentMeetingInfo(): Promise<NEResult<NEMeetingInfo>> {
    if (!this._neMeeting?._meetingInfo) {
      throw FailureBodySync(undefined, 'not in meeting')
    } else {
      const {
        subject,
        password,
        timezoneId,
        startTime,
        endTime,
        extraData,
        type,
      } = this._neMeeting._meetingInfo
      const roomContext = this._neMeeting.roomContext
      const reducerMeetingInfo = await this.getReducerMeetingInfo()

      return SuccessBody({
        meetingId: this._neMeeting.meetingId,
        meetingNum: this._neMeeting.meetingNum,
        subject: subject,
        password: password,
        isHost: roomContext?.localMember.role.name === Role.host,
        isLocked: !!roomContext?.isRoomLocked,
        isInWaitingRoom: !!roomContext?.localMember.inWaitingRoom,
        scheduleStartTime: startTime,
        scheduleEndTime: type === 3 ? endTime : -1,
        startTime: startTime,
        duration: endTime,
        hostUserId: reducerMeetingInfo?.hostUuid ?? '',
        extraData: extraData,
        timezoneId: timezoneId,
        sipId: roomContext?.sipCid,
      })
    }
  }
  addMeetingStatusListener(listener: NEMeetingStatusListener): void {
    this._meetingStatusListeners.push(listener)
  }
  removeMeetingStatusListener(listener: NEMeetingStatusListener): void {
    this._meetingStatusListeners = this._meetingStatusListeners.filter(
      (l) => l !== listener
    )
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

  async leaveCurrentMeeting(closeIfHost: boolean): Promise<NEResult<void>> {
    try {
      const closeIfHostSchema = z.boolean()

      closeIfHostSchema.parse(closeIfHost, {
        path: ['closeIfHost'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    return new Promise((resolve, reject) => {
      this._meetingKit.leaveMeeting(closeIfHost, (e) => {
        if (e) {
          reject(e)
        } else {
          resolve(SuccessBody(void 0))
        }
      })
    })
  }

  private async _saveMeetingInfoIn(nickname: string) {
    let { data: meetingList } = await this.getLocalHistoryMeetingList()
    const { data: meeting } = await this.getCurrentMeetingInfo()

    meetingList = meetingList.filter(
      (item) => item.meetingNum !== meeting?.meetingNum
    )

    meetingList.unshift({
      ...meeting,
      nickname,
    })

    meetingList = meetingList.slice(0, 10)

    const obj = JSON.parse(localStorage.getItem(LOCAL_STORAGE_KEY) ?? '{}')

    const userInfo = getLocalUserInfo()

    if (userInfo) {
      obj[userInfo.userUuid] = meetingList
      localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(obj))
    }
  }

  private _createMeetingOptionsToCreateOptions(
    param: NEStartMeetingParams,
    opts?: NEStartMeetingOptions
  ): CreateOptions {
    const options = this._joinMeetingOptionsToJoinOptions(
      param as NEJoinMeetingParams,
      opts
    )
    const roleBinds = {}

    if (param.roleBinds) {
      Object.keys(param.roleBinds).forEach((key) => {
        const value = param.roleBinds?.[key] ?? 2

        roleBinds[key] = ['host', 'cohost', 'member', 'guest'][value]
      })
    }

    const videoControl = param.controls?.find((item) => item.type === 'video')
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

    const audioControl = param.controls?.find((item) => item.type === 'audio')
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

    const createOptions = {
      ...options,
      noCloudRecord: opts?.noCloudRecord,
      attendeeAudioOff: attendeeAudio.off ?? param.attendeeAudioOff,
      attendeeVideoOff: attendeeVideo.off ?? param.attendeeVideoOff,
      extraData: param.extraData,
      roleBinds,
      userName: param.displayName,
      enableGuestJoin: opts?.enableGuestJoin,
    }

    return createOptions
  }

  private getReducerMeetingInfo(): Promise<ReducerMeetingInfo | undefined> {
    return new Promise((resolve) => {
      this._meetingKit.getReducerMeetingInfo((data: ReducerMeetingInfo) => {
        resolve(data)
      })
    })
  }

  private _getStartJoinParamSchema(zodRawType: ZodRawShape) {
    const paramSchema = z.object({
      displayName: z.string(),
      avatar: z.string().optional(),
      tag: z.string().optional(),
      password: z.string().optional(),
      encryptionConfig: z
        .object({
          encryptionMode: z.nativeEnum(NEEncryptionMode),
          encryptKey: z.string(),
        })
        .optional(),
      watermarkConfig: z
        .object({
          name: z.string().optional(),
          phone: z.string().optional(),
          email: z.string().optional(),
          jobNumber: z.string().optional(),
        })
        .optional(),
      ...zodRawType,
    })

    return paramSchema
  }

  private _getStartJoinOptsSchema() {
    const optsSchema = z.object({
      cloudRecordConfig: z
        .object({
          enable: z.boolean(),
          recordStrategy: z.nativeEnum(NECloudRecordStrategyType),
        })
        .optional(),
      enableWaitingRoom: z.boolean().optional(),
      enableGuestJoin: z.boolean().optional(),
      noMuteAllVideo: z.boolean().optional(),
      noMuteAllAudio: z.boolean().optional(),
      noVideo: z.boolean().optional(),
      noAudio: z.boolean().optional(),
      showMeetingTime: z.boolean().optional(),
      enableSpeakerSpotlight: z.boolean().optional(),
      enableShowNotYetJoinedMembers: z.boolean().optional(),
      noInvite: z.boolean().optional(),
      noSip: z.boolean().optional(),
      noChat: z.boolean().optional(),
      noSwitchAudioMode: z.boolean().optional(),
      noWhiteBoard: z.boolean().optional(),
      noRename: z.boolean().optional(),
      noLive: z.boolean().optional(),
      showMeetingRemainingTip: z.boolean().optional(),
      showScreenShareUserVideo: z.boolean().optional(),
      enableTransparentWhiteboard: z.boolean().optional(),
      showFloatingMicrophone: z.boolean().optional(),
      showMemberTag: z.boolean().optional(),
      detectMutedMic: z.boolean().optional(),
      defaultWindowMode: z.nativeEnum(NEWindowMode).optional(),
      meetingIdDisplayOption: z.nativeEnum(NEMeetingIdDisplayOption).optional(),
      // TODO:
      // fullToolbarMenuItems
      // fullMoreMenuItems
      joinTimeout: z.number().optional(),
      // NEMeetingChatroomConfig
      showCloudRecordMenuItem: z.boolean().optional(),
      showCloudRecordingUI: z.boolean().optional(),
      noNotifyCenter: z.boolean().optional(),
      noWebApps: z.boolean().optional(),
    })

    return optsSchema
  }

  private _joinMeetingOptionsToJoinOptions(
    param: NEJoinMeetingParams,
    opts?: NEMeetingOptions
  ): JoinOptions {
    let encryptionConfig

    if (param.encryptionConfig) {
      encryptionConfig = {
        encryptionType: 'sm4-128-ecb',
        encryptKey: param.encryptionConfig.encryptKey,
      }
    }

    const formatMenuItems = (
      items: Array<NEMeetingMenuItem> | undefined
    ): CommonBar[] | undefined => {
      const list: CommonBar[] = []

      items?.forEach((item) => {
        if (this._isNESingleStateMenuItem(item)) {
          list.push({
            id: item.itemId,
            visibility: item.visibility,
            type: 'single',
            btnConfig: {
              icon: item.singleStateItem.icon,
              lightIcon: item.singleStateItem.icon,
              text: item.singleStateItem.text,
            },
            injectItemClick: () => void 0,
          })
        } else if (this._isNECheckableMenuItem(item)) {
          list.push({
            id: item.itemId,
            visibility: item.visibility,
            type: 'multiple',
            btnConfig: [
              {
                icon: item.checkedStateItem.icon,
                text: item.checkedStateItem.text,
                status: true,
              },
              {
                icon: item.uncheckStateItem.icon,
                text: item.uncheckStateItem.text,
                status: false,
              },
            ],
            btnStatus: item.checked,
            injectItemClick: () => void 0,
          })
        } else {
          list.push({
            id: item.itemId,
            visibility: item.visibility,
          })
        }
      })
      return list.length > 0 ? list : undefined
    }

    const toolBarList = formatMenuItems(opts?.fullToolbarMenuItems)
    const moreBarList = formatMenuItems(opts?.fullMoreMenuItems)

    const options: JoinOptions = {
      ...opts,
      toolBarList,
      moreBarList,
      meetingNum: param.meetingNum ?? '',
      nickName: param.displayName.trim(),

      video: opts?.noVideo !== false ? 2 : 1,
      audio: opts?.noAudio !== false ? 2 : 1,
      defaultWindowMode: opts?.defaultWindowMode,
      noRename: opts?.noRename,
      memberTag: param?.tag,
      password: param.password,
      showMemberTag: opts?.showMemberTag,
      muteBtnConfig: {
        showMuteAllAudio: !(opts?.noMuteAllAudio === true),
        showUnMuteAllAudio: !(opts?.noMuteAllAudio === true),
        showMuteAllVideo: !(opts?.noMuteAllVideo === true),
        showUnMuteAllVideo: !(opts?.noMuteAllVideo === true),
      },
      showMeetingRemainingTip: opts?.showMeetingRemainingTip,
      noSip: opts?.noSip,
      enableUnmuteBySpace: opts?.enableUnmuteBySpace,
      enableTransparentWhiteboard: opts?.enableTransparentWhiteboard,
      enableFixedToolbar: opts?.enableFixedToolbar,
      enableVideoMirror: opts?.enableVideoMirror,
      showDurationTime: opts?.showMeetingTime,
      meetingIdDisplayOption: opts?.meetingIdDisplayOption,
      encryptionConfig: encryptionConfig,
      showCloudRecordMenuItem: opts?.showCloudRecordMenuItem,
      showCloudRecordingUI: opts?.showCloudRecordingUI,
      avatar: param.avatar,
      watermarkConfig: param?.watermarkConfig,
      noNotifyCenter: opts?.noNotifyCenter,
      noWebApps: opts?.noWebApps,
      showScreenShareUserVideo: opts?.showScreenShareUserVideo,
      pluginNotifyDuration: opts?.pluginNotifyDuration,
      enableDirectMemberMediaControlByHost:
        opts?.enableDirectMemberMediaControlByHost,
    }

    return options
  }

  private _isNESingleStateMenuItem(
    item: NEMeetingMenuItem
  ): item is NESingleStateMenuItem {
    return (<NESingleStateMenuItem>item).singleStateItem !== undefined
  }

  private _isNECheckableMenuItem(
    item: NEMeetingMenuItem
  ): item is NECheckableMenuItem {
    return (
      (<NECheckableMenuItem>item).checked !== undefined ||
      (<NECheckableMenuItem>item).checkedStateItem !== undefined ||
      (<NECheckableMenuItem>item).uncheckStateItem !== undefined
    )
  }
}
