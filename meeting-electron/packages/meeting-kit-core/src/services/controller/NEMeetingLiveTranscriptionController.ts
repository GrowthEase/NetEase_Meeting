import {
  FailureBody,
  NERoomCaptionErrorCode,
  NERoomCaptionMessage,
  NERoomCaptionState,
  NERoomMember,
} from 'neroom-types'
import NEMeetingService from '../NEMeeting'
import { EventType } from '../../types'
import { Logger } from '../../utils/Logger'
import { getLocalStorageSetting } from '../../kit'

export default class NEMeetingLiveTranscriptionController {
  private _neMeeting?: NEMeetingService
  private _isCaptionsEnabled: boolean = false
  private _isAllowParticipantsEnableCaption: boolean = true
  private _listeners: NEMeetingLiveTranscriptionControllerListener[] = []
  private _logger: Logger
  private _roomUuid: string
  private _enableCaptionByMySelf = false

  // 无操作权限
  static codeNoPermission = 1041

  constructor(params: {
    neMeeting: NEMeetingService
    roomUuid: string
    isAllowParticipantsEnableCaption: boolean
    isCaptionsEnabled: boolean
    logger: Logger
  }) {
    this._roomUuid = params.roomUuid
    this._logger = params.logger
    this._neMeeting = params.neMeeting
    this._isAllowParticipantsEnableCaption =
      params.isAllowParticipantsEnableCaption
    this._isCaptionsEnabled = params.isCaptionsEnabled
    this._neMeeting?.eventEmitter.on(
      EventType.ReceiveCaptionMessages,
      (messages, channel) => {
        this._listeners.forEach((listener) => {
          listener.onReceiveCaptionMessages?.(messages, channel)
        })
      }
    )
    this._neMeeting?.eventEmitter.on(
      EventType.CaptionStateChanged,
      (
        state: NERoomCaptionState,
        code: NERoomCaptionErrorCode,
        message: string
      ) => {
        this._logger.debug(
          'onCaptionStateChanged',
          state,
          code,
          message,
          this._enableCaptionByMySelf
        )

        // 表示点击开启字幕触发的状态变更，而不是开启转写引起的变更
        if (this._enableCaptionByMySelf) {
          if (state === NERoomCaptionState.STATE_ENABLE_CAPTION_SUCCESS) {
            this._isCaptionsEnabled = true
          } else if (
            state === NERoomCaptionState.STATE_DISABLE_CAPTION_SUCCESS
          ) {
            this._isCaptionsEnabled = false
          }

          this._listeners.forEach((listener) => {
            listener.onMySelfCaptionEnableChanged?.(this._isCaptionsEnabled)
          })

          this._enableCaptionByMySelf = false
        }
      }
    )
    this._neMeeting?.eventEmitter.on(
      EventType.RoomPropertiesChanged,
      this._handleRoomPropertiesChanged.bind(this)
    )
    this._neMeeting?.eventEmitter.on(
      EventType.RoomPropertiesDeleted,
      this._handleRoomPropertiesDeleted.bind(this)
    )
    this._neMeeting?.eventEmitter.on(
      EventType.MemberRoleChanged,
      this._handleRoleChanged.bind(this)
    )
  }

  /** 本端是否可以开启/关闭转写，仅管理员有权限 */
  isTranscriptionEnabled(): boolean {
    const roomProperties = this._neMeeting?.roomContext?.roomProperties

    return roomProperties?.transcript?.value === '1'
  }

  /**
   * 开启转写
   * @param enable 是否开启转写
   */
  async enableTranscription(enable: boolean): Promise<void> {
    this._logger.debug('enableTranscription', enable)
    if (this.isTranscriptionEnabled() === enable) {
      return
    }

    if (!this.canMySelfEnableTranscription()) {
      return FailureBody(
        null,
        '',
        NEMeetingLiveTranscriptionController.codeNoPermission
      )
    }

    if (enable) {
      const setting = getLocalStorageSetting()

      if (setting && setting.captionSetting.targetLanguage) {
        await this._neMeeting
          ?.setCaptionTranslationLanguage(setting.captionSetting.targetLanguage)
          .catch((e) => {
            console.log('setCaptionTranslationLanguage>>>>', e)
          })
      }

      if (!this.isCaptionsEnabled()) {
        console.log('开始打开enableCaption')
        await this._neMeeting?.rtcController?.enableCaption(true)
      }

      await this._neMeeting?.roomContext?.updateRoomProperty('transcript', '1')
    } else {
      if (!this.isCaptionsEnabled()) {
        await this._neMeeting?.rtcController?.enableCaption(false)
      }

      await this._neMeeting?.roomContext?.deleteRoomProperty('transcript')
    }
  }

  /** 本端是否可以开启/关闭转写，仅管理员有权限 */
  canMySelfEnableTranscription(): boolean {
    return !!this._neMeeting?.isHostOrCohost
  }

  /**
   * 是否允许自己开启字幕
   */
  canMySelfEnableCaption(): boolean {
    return (
      this._isAllowParticipantsEnableCaption ||
      !!this._neMeeting?.isHostOrCohost
    )
  }
  /** 获取字幕是否开启 */
  isCaptionsEnabled(): boolean {
    return this._isCaptionsEnabled
  }

  /** 获取是否允许成员使用字幕 */
  isAllowParticipantsEnableCaption(): boolean {
    return this._isAllowParticipantsEnableCaption
  }

  addListener(listener: NEMeetingLiveTranscriptionControllerListener): void {
    console.log('addListener', listener)
    this._listeners.push(listener)
  }

  removeListener(listener: NEMeetingLiveTranscriptionControllerListener): void {
    const index = this._listeners.findIndex((item) => item === listener)

    if (index !== -1) {
      this._listeners.splice(index, 1)
    }
  }

  //** 开启/关闭字幕 */
  async enableCaption(
    enable: boolean,
    checkPermissionDone?: () => void
  ): Promise<void> {
    this._logger.debug('enableCaption', enable)
    this._enableCaptionByMySelf = true
    if (enable) {
      await this._neMeeting?.checkCaptionPermission(this._roomUuid)
      checkPermissionDone?.()
      if (this.isTranscriptionEnabled()) {
        this._isCaptionsEnabled = true
        this._enableCaptionByMySelf = false
        this._listeners.forEach((listener) => {
          listener?.onMySelfCaptionEnableChanged?.(true)
        })

        return
      }

      const code = await this._neMeeting?.rtcController?.enableCaption(true)

      if (code === 0) {
        this._isCaptionsEnabled = true
        if (!window.isElectronNative) {
          this._listeners.forEach((listener) => {
            listener?.onMySelfCaptionEnableChanged?.(true)
          })
        }
      } else {
        return FailureBody(null, '', code)
      }
    } else {
      checkPermissionDone?.()
      if (this.isTranscriptionEnabled()) {
        this._isCaptionsEnabled = false
        this._enableCaptionByMySelf = false
        this._listeners.forEach((listener) => {
          listener.onMySelfCaptionEnableChanged?.(this._isCaptionsEnabled)
        })

        return
      }

      const code = await this._neMeeting?.rtcController?.enableCaption(false)

      if (code === 0) {
        this._isCaptionsEnabled = false
        this._listeners.forEach((listener) => {
          listener?.onMySelfCaptionEnableChanged?.(false)
        })
      } else {
        return FailureBody(null, '', code)
      }
    }
  }

  /** 允许/不允许成员使用字幕，仅管理员可操作 */
  async allowParticipantsEnableCaption(allow: boolean): Promise<void> {
    this._logger.debug('allowParticipantsEnableCaption', allow)
    this._neMeeting?.allowParticipantsEnableCaption(allow)
  }

  destroy() {
    this._listeners = []
    this._isCaptionsEnabled = true
    this._isAllowParticipantsEnableCaption = true
    this._neMeeting?.eventEmitter.off(EventType.ReceiveCaptionMessages)
    this._neMeeting?.eventEmitter.off(EventType.CaptionStateChanged)
    this._neMeeting?.eventEmitter.off(
      EventType.RoomPropertiesChanged,
      this._handleRoomPropertiesChanged.bind(this)
    )
    this._neMeeting?.eventEmitter.off(
      EventType.RoomPropertiesDeleted,
      this._handleRoomPropertiesDeleted.bind(this)
    )
    this._neMeeting?.eventEmitter.off(
      EventType.MemberRoleChanged,
      this._handleRoleChanged.bind(this)
    )
    this._neMeeting = undefined
  }

  private async _handleRoleChanged(member: NERoomMember) {
    // 本端角色变更
    if (this._neMeeting?.isMySelf(member.uuid)) {
      // 如果本端变更为非主持人，如果开启字幕，且不允许成员开启字幕，则关闭字幕
      if (
        !this._neMeeting.isHostOrCohost &&
        this._isCaptionsEnabled &&
        !this._isAllowParticipantsEnableCaption
      ) {
        await this.enableCaption(false)
        this._listeners.forEach((listener) => {
          listener.onMySelfCaptionForbidden?.()
        })
      }
    }
  }

  private _handleRoomPropertiesChanged(
    properties: Record<string, { value: string }>
  ) {
    if (properties.capPerm) {
      this._isAllowParticipantsEnableCaption = properties.capPerm?.value !== '0'
      this._logger.debug(
        'onAllowParticipantsEnableCaptionChanged',
        this._isAllowParticipantsEnableCaption
      )

      if (!this.canMySelfEnableCaption() && this._isCaptionsEnabled) {
        this._isCaptionsEnabled = false
        this._listeners.forEach((listener) => {
          listener.onMySelfCaptionForbidden?.()
        })
      }

      this._listeners.forEach((listener) => {
        listener.onAllowParticipantsEnableCaptionChanged?.(
          this._isAllowParticipantsEnableCaption
        )
      })
    } else if (properties.transcript) {
      const enableTranscription = properties.transcript.value === '1'

      this._logger.debug('onTranscriptionEnableChanged', enableTranscription)

      if (enableTranscription) {
        console.log(
          '开始打开enableCaption',
          this.isTranscriptionEnabled(),
          this.isCaptionsEnabled()
        )
        // 字幕未开启情况下需要开启rtc功能
        if (!this.isCaptionsEnabled()) {
          this._neMeeting?.rtcController?.enableCaption(true)
        }

        this._listeners.forEach((listener) => {
          listener.onTranscriptionEnableChanged?.(true)
        })
      }
    }
  }

  private _handleRoomPropertiesDeleted(keys: string[]) {
    keys.forEach((key) => {
      if (key === 'capPerm') {
        this._isAllowParticipantsEnableCaption = true
        this._logger.debug(
          'onAllowParticipantsEnableCaptionDeleted',
          this._isAllowParticipantsEnableCaption
        )

        this._listeners.forEach((listener) => {
          listener.onAllowParticipantsEnableCaptionChanged?.(true)
        })
      } else if (key === 'transcript') {
        // 字幕未开启情况下需要关闭rtc功能
        if (!this.isCaptionsEnabled()) {
          this._neMeeting?.rtcController?.enableCaption(false)
        }

        this._listeners.forEach((listener) => {
          listener.onTranscriptionEnableChanged?.(false)
        })
      }
    })
  }
}

export interface NEMeetingLiveTranscriptionControllerListener {
  /**
   * 接收到字幕消息
   * @param captionMessages
   * @param channel
   */
  onReceiveCaptionMessages?(
    captionMessages: NERoomCaptionMessage[],
    channel?: string
  ): void
  /**
   * 允许成员使用字幕开关变更通知
   * @param allow 是否允许
   */
  onAllowParticipantsEnableCaptionChanged?(allow: boolean): void

  /**
   * 本地成员字幕被禁用，因为管理员禁止成员使用字幕
   */
  onMySelfCaptionForbidden?(): void

  /**
   * 本地成员字幕状态变更，比如手动开启/关闭字幕
   * @param enable
   */
  onMySelfCaptionEnableChanged?(enable: boolean): void

  /**
   * 转写状态变更
   * @param enable
   */
  onTranscriptionEnableChanged?(enable: boolean): void
}
