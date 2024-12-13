import { BrowserWindow, ipcMain } from 'electron'
import NESettingsServiceInterface, {
  NEInterpretationConfig,
  NEMeetingASRTranslationLanguage,
  ScheduledMemberConfig,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/settings_service'
import { BUNDLE_NAME } from '../meeting_kit'
import { NEResult } from 'neroom-types'
import {
  NEChatMessageNotificationType,
  NECloudRecordConfig,
} from 'nemeeting-core-sdk'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NESettingsService'

let seqCount = 0

export default class NESettingsService
  extends ElectronBaseService
  implements NESettingsServiceInterface {
  constructor(_win: BrowserWindow) {
    super(_win)
  }

  async openSettingsWindow(type?: string): Promise<NEResult<void>> {
    const functionName = 'openSettingsWindow'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [type],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async setChatMessageNotificationType(
    type: NEChatMessageNotificationType
  ): Promise<NEResult<void>> {
    const functionName = 'setChatMessageNotificationType'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [type],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async enableShowNameInVideo(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableShowNameInVideo'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async isShowNameInVideoEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isShowNameInVideoEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isMeetingChatSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isMeetingChatSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async getChatMessageNotificationType(): Promise<
    NEResult<NEChatMessageNotificationType>
  > {
    const functionName = 'getChatMessageNotificationType'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEChatMessageNotificationType>(seqId)
  }

  /**
   * 设置应用聊天室默认文件下载保存路径
   * @param filePath 聊天室文件保存路径
   */
  async setChatroomDefaultFileSavePath(
    filePath: string
  ): Promise<NEResult<void>> {
    const functionName = 'setChatroomDefaultFileSavePath'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [filePath],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  /**
   * 查询应用聊天室文件下载默认保存路径
   */
  async getChatroomDefaultFileSavePath(): Promise<NEResult<string>> {
    const functionName = 'getChatroomDefaultFileSavePath'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }

  async setCloudRecordConfig(
    config: NECloudRecordConfig
  ): Promise<NEResult<void>> {
    const functionName = 'setCloudRecordConfig'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [config],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async getCloudRecordConfig(): Promise<NEResult<NECloudRecordConfig>> {
    const functionName = 'getCloudRecordConfig'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NECloudRecordConfig>(seqId)
  }

  async getScheduledMemberConfig(): Promise<NEResult<ScheduledMemberConfig>> {
    const functionName = 'getScheduledMemberConfig'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<ScheduledMemberConfig>(seqId)
  }

  async getInterpretationConfig(): Promise<NEResult<NEInterpretationConfig>> {
    const functionName = 'getInterpretationConfig'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEInterpretationConfig>(seqId)
  }

  async isGuestJoinSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isGuestJoinSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async getAppNotifySessionId(): Promise<NEResult<string>> {
    const functionName = 'getAppNotifySessionId'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }

  async isMeetingCloudRecordSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isMeetingCloudRecordSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isMeetingWhiteboardSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isMeetingWhiteboardSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isWaitingRoomSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isWaitingRoomSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isNicknameUpdateSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isNicknameUpdateSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isAvatarUpdateSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isAvatarUpdateSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isCaptionsSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isCaptionsSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableShowMyMeetingElapseTime(
    enable: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'enableShowMyMeetingElapseTime'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isShowMyMeetingElapseTimeEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isShowMyMeetingElapseTimeEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableShowMyMeetingParticipationTime(
    enable: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'enableShowMyMeetingParticipationTime'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isShowMyMeetingParticipationTimeEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isShowMyMeetingParticipationTimeEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableHideVideoOffAttendees(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableHideVideoOffAttendees'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isHideVideoOffAttendeesEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isHideVideoOffAttendeesEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableHideMyVideo(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableHideMyVideo'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isHideMyVideoEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isHideMyVideoEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableLeaveTheMeetingRequiresConfirmation(
    enable: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'enableHideMyVideo'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isLeaveTheMeetingRequiresConfirmationEnabled(): Promise<
    NEResult<boolean>
  > {
    const functionName = 'isHideMyVideoEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableAudioAINS(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableAudioAINS'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isAudioAINSEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isAudioAINSEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async enableTurnOnMyVideoWhenJoinMeeting(
    enable: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'enableTurnOnMyVideoWhenJoinMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isTurnOnMyVideoWhenJoinMeetingEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isTurnOnMyVideoWhenJoinMeetingEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async enableTurnOnMyAudioWhenJoinMeeting(
    enable: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'enableTurnOnMyAudioWhenJoinMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isTurnOnMyAudioWhenJoinMeetingEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isTurnOnMyAudioWhenJoinMeetingEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async isBeautyFaceSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isBeautyFaceSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isCallOutRoomSystemDeviceSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isCallOutRoomSystemDeviceSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async getBeautyFaceValue(): Promise<NEResult<number>> {
    const functionName = 'getBeautyFaceValue'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<number>(seqId)
  }
  async setBeautyFaceValue(value: number): Promise<NEResult<void>> {
    const functionName = 'setBeautyFaceValue'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [value],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isMeetingLiveSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isMeetingLiveSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async isWaitingRoomEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isWaitingRoomEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async isMeetingWhiteboardEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isMeetingWhiteboardEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async isMeetingCloudRecordEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isMeetingCloudRecordEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async enableVirtualBackground(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableVirtualBackground'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isVirtualBackgroundEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isVirtualBackgroundEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async isVirtualBackgroundSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isVirtualBackgroundSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  shouldUnpubOnAudioMute(): Promise<NEResult<boolean>> {
    const functionName = 'shouldUnpubOnAudioMute'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async setBuiltinVirtualBackgroundList(
    pathList: string[]
  ): Promise<NEResult<void>> {
    const functionName = 'setBuiltinVirtualBackgroundList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [pathList],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  getBuiltinVirtualBackgroundList(): Promise<NEResult<string[]>> {
    const functionName = 'getBuiltinVirtualBackgroundList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<string[]>(seqId)
  }
  setCurrentVirtualBackground(path: string): Promise<NEResult<void>> {
    const functionName = 'setCurrentVirtualBackground'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [path],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  getCurrentVirtualBackground(): Promise<NEResult<string>> {
    const functionName = 'getCurrentVirtualBackground'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }
  setExternalVirtualBackgroundList(
    pathList: string[]
  ): Promise<NEResult<void>> {
    const functionName = 'setExternalVirtualBackgroundList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [pathList],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  getExternalVirtualBackgroundList(): Promise<NEResult<string[]>> {
    const functionName = 'getExternalVirtualBackgroundList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<string[]>(seqId)
  }
  async enableSpeakerSpotlight(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableSpeakerSpotlight'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isSpeakerSpotlightEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isSpeakerSpotlightEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableShowNotYetJoinedMembers(
    enable: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'enableShowNotYetJoinedMembers'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isShowNotYetJoinedMembersEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isShowNotYetJoinedMembersEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async enableTransparentWhiteboard(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableTransparentWhiteboard'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isTransparentWhiteboardEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isTransparentWhiteboardEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async enableCameraMirror(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableCameraMirror'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  async isCameraMirrorEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isCameraMirrorEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  enableFrontCameraMirror(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableFrontCameraMirror'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  isFrontCameraMirrorEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isFrontCameraMirrorEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  setGalleryModeMaxMemberCount(count: number): Promise<NEResult<void>> {
    const functionName = 'setGalleryModeMaxMemberCount'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [count],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  isTranscriptionSupported(): Promise<NEResult<boolean>> {
    const functionName = 'isTranscriptionSupported'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  enableUnmuteAudioByPressSpaceBar(enable: boolean): Promise<NEResult<void>> {
    const functionName = 'enableUnmuteAudioByPressSpaceBar'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  isUnmuteAudioByPressSpaceBarEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isUnmuteAudioByPressSpaceBarEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async setASRTranslationLanguage(
    language: NEMeetingASRTranslationLanguage
  ): Promise<NEResult<number>> {
    const functionName = 'setASRTranslationLanguage'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [language],
      seqId,
    })

    return this._IpcMainListener<number>(seqId)
  }
  async getASRTranslationLanguage(): Promise<
    NEResult<NEMeetingASRTranslationLanguage>
  > {
    const functionName = 'getASRTranslationLanguage'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEMeetingASRTranslationLanguage>(seqId)
  }
  async enableCaptionBilingual(enable: boolean): Promise<NEResult<number>> {
    const functionName = 'enableCaptionBilingual'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<number>(seqId)
  }
  async isCaptionBilingualEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isCaptionBilingualEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }
  async enableTranscriptionBilingual(
    enable: boolean
  ): Promise<NEResult<number>> {
    const functionName = 'enableTranscriptionBilingual'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [enable],
      seqId,
    })

    return this._IpcMainListener<number>(seqId)
  }
  async isTranscriptionBilingualEnabled(): Promise<NEResult<boolean>> {
    const functionName = 'isTranscriptionBilingualEnabled'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<boolean>(seqId)
  }

  async getLiveMaxThirdPartyCount(): Promise<NEResult<number>> {
    const functionName = 'getLiveMaxThirdPartyCount'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<number>(seqId)
  }

  private _generateSeqId(functionName: string) {
    seqCount++
    return `${BUNDLE_NAME}::${MODULE_NAME}::${functionName}::${seqCount}`
  }

  private _IpcMainListener<T>(seqId: string): Promise<NEResult<T>> {
    return new Promise((resolve, reject) => {
      ipcMain.once(seqId, (_, res) => {
        if (res.error) {
          reject(res.error)
        } else {
          resolve(res.result)
        }
      })
    })
  }
}
