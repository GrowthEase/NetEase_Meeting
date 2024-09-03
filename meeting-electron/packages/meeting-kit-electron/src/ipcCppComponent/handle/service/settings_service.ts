import { FailureBodySync } from 'neroom-types'
import NESettingsService from '../../../kit/impl/service/settings_service'

export default class NESettingsServiceHandle {
  private _settingsService: NESettingsService

  constructor(settingsServic: NESettingsService) {
    this._settingsService = settingsServic
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 1:
        res = await this.openSettingsWindow()
        break
      case 3:
        res = await this.enableShowMyMeetingElapseTime(data)
        break
      case 5:
        res = await this.isShowMyMeetingElapseTimeEnabled()
        break
      case 7:
        res = await this.enableTurnOnMyVideoWhenJoinMeeting(data)
        break
      case 9:
        res = await this.isTurnOnMyVideoWhenJoinMeetingEnabled()
        break
      case 11:
        res = await this.enableTurnOnMyAudioWhenJoinMeeting(data)
        break
      case 13:
        res = await this.isTurnOnMyAudioWhenJoinMeetingEnabled()
        break
      case 15:
        res = await this.isMeetingLiveSupported()
        break
      case 17:
        res = await this.isMeetingWhiteboardSupported()
        break
      case 19:
        res = await this.isMeetingCloudRecordSupported()
        break
      case 21:
        res = await this.enableAudioAINS(data)
        break
      case 23:
        res = await this.isAudioAINSEnabled()
        break
      case 25:
        res = await this.enableVirtualBackground(data)
        break
      case 27:
        res = await this.isVirtualBackgroundEnabled()
        break
      case 29:
        res = await this.setBuiltinVirtualBackgroundList(data)
        break
      case 31:
        res = await this.getBuiltinVirtualBackgroundList()
        break
      case 33:
        res = await this.setExternalVirtualBackgroundList(data)
        break
      case 35:
        res = await this.getExternalVirtualBackgroundList()
        break
      case 37:
        res = await this.setCurrentVirtualBackground(data)
        break
      case 39:
        res = await this.getCurrentVirtualBackground()
        break
      case 41:
        res = await this.enableSpeakerSpotlight(data)
        break
      case 43:
        res = await this.isSpeakerSpotlightEnabled()
        break
      case 45:
        res = await this.enableCameraMirror(data)
        break
      case 47:
        res = await this.isCameraMirrorEnabled()
        break
      case 49:
        res = await this.enableFrontCameraMirror(data)
        break
      case 51:
        res = await this.isFrontCameraMirrorEnabled()
        break
      case 53:
        res = await this.enableTransparentWhiteboard(data)
        break
      case 55:
        res = await this.isTransparentWhiteboardEnabled()
        break
      case 57:
        res = await this.isBeautyFaceSupported()
        break
      case 59:
        res = await this.getBeautyFaceValue()
        break
      case 61:
        res = await this.setBeautyFaceValue(data)
        break
      case 63:
        res = await this.isWaitingRoomSupported()
        break
      case 65:
        res = await this.isVirtualBackgroundSupported()
        break
      case 67:
        res = await this.setChatroomDefaultFileSavePath(data)
        break
      case 69:
        res = await this.getChatroomDefaultFileSavePath()
        break
      case 71:
        res = await this.setGalleryModeMaxMemberCount(data)
        break
      case 73:
        res = await this.enableUnmuteAudioByPressSpaceBar(data)
        break
      case 75:
        res = await this.isUnmuteAudioByPressSpaceBarEnabled()
        break
      case 77:
        res = await this.isGuestJoinSupported()
        break
      case 79:
        res = await this.isTranscriptionSupported()
        break
      case 81:
        res = await this.getInterpretationConfig()
        break
      case 83:
        res = await this.getScheduledMemberConfig()
        break
      case 85:
        res = await this.isNicknameUpdateSupported()
        break
      case 87:
        res = await this.isAvatarUpdateSupported()
        break
      case 89:
        res = await this.isCaptionsSupported()
        break
      case 1105:
        res = await this.enableShowNotYetJoinedMembers(data)
        break
      case 1107:
        res = await this.isShowNotYetJoinedMembersEnabled()
        break

      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async openSettingsWindow() {
    return await this._settingsService.openSettingsWindow()
  }

  async enableShowMyMeetingElapseTime(data: string) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableShowMyMeetingElapseTime(enable)
  }

  async isShowMyMeetingElapseTimeEnabled() {
    return await this._settingsService.isShowMyMeetingElapseTimeEnabled()
  }

  async enableShowNotYetJoinedMembers(data: string) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableShowNotYetJoinedMembers(enable)
  }

  async isShowNotYetJoinedMembersEnabled() {
    return await this._settingsService.isShowNotYetJoinedMembersEnabled()
  }

  async enableTurnOnMyVideoWhenJoinMeeting(data: string) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableTurnOnMyVideoWhenJoinMeeting(
      enable
    )
  }

  async isTurnOnMyVideoWhenJoinMeetingEnabled() {
    return await this._settingsService.isTurnOnMyVideoWhenJoinMeetingEnabled()
  }

  async enableTurnOnMyAudioWhenJoinMeeting(data: string) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableTurnOnMyAudioWhenJoinMeeting(
      enable
    )
  }

  async isTurnOnMyAudioWhenJoinMeetingEnabled() {
    return await this._settingsService.isTurnOnMyAudioWhenJoinMeetingEnabled()
  }

  async isMeetingLiveSupported() {
    return await this._settingsService.isMeetingLiveSupported()
  }

  async isMeetingWhiteboardSupported() {
    return await this._settingsService.isMeetingWhiteboardSupported()
  }

  async isMeetingCloudRecordSupported() {
    return await this._settingsService.isMeetingCloudRecordSupported()
  }

  async enableAudioAINS(data: string) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableAudioAINS(enable)
  }

  async isAudioAINSEnabled() {
    return await this._settingsService.isAudioAINSEnabled()
  }

  async enableVirtualBackground(data: string) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableVirtualBackground(enable)
  }

  async isVirtualBackgroundEnabled() {
    return await this._settingsService.isVirtualBackgroundEnabled()
  }

  async setBuiltinVirtualBackgroundList(data) {
    const { pathList } = JSON.parse(data)

    return await this._settingsService.setBuiltinVirtualBackgroundList(pathList)
  }

  async getBuiltinVirtualBackgroundList() {
    return await this._settingsService.getBuiltinVirtualBackgroundList()
  }

  async setExternalVirtualBackgroundList(data) {
    const { pathList } = JSON.parse(data)

    return await this._settingsService.setExternalVirtualBackgroundList(
      pathList
    )
  }

  async getExternalVirtualBackgroundList() {
    return await this._settingsService.getExternalVirtualBackgroundList()
  }

  async setCurrentVirtualBackground(data) {
    const { path } = JSON.parse(data)

    return await this._settingsService.setCurrentVirtualBackground(path)
  }

  async getCurrentVirtualBackground() {
    return await this._settingsService.getCurrentVirtualBackground()
  }

  async enableSpeakerSpotlight(data) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableSpeakerSpotlight(enable)
  }

  async isSpeakerSpotlightEnabled() {
    return await this._settingsService.isSpeakerSpotlightEnabled()
  }

  async enableCameraMirror(data) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableCameraMirror(enable)
  }

  async isCameraMirrorEnabled() {
    return await this._settingsService.isCameraMirrorEnabled()
  }

  async enableFrontCameraMirror(data) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableFrontCameraMirror(enable)
  }

  async isFrontCameraMirrorEnabled() {
    return await this._settingsService.isFrontCameraMirrorEnabled()
  }

  async enableTransparentWhiteboard(data) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableTransparentWhiteboard(enable)
  }

  async isTransparentWhiteboardEnabled() {
    return await this._settingsService.isTransparentWhiteboardEnabled()
  }

  async isBeautyFaceSupported() {
    return await this._settingsService.isBeautyFaceSupported()
  }

  async setBeautyFaceValue(data) {
    const { value } = JSON.parse(data)

    return await this._settingsService.setBeautyFaceValue(value)
  }

  async getBeautyFaceValue() {
    return await this._settingsService.getBeautyFaceValue()
  }

  async isWaitingRoomSupported() {
    return await this._settingsService.isWaitingRoomSupported()
  }

  async isVirtualBackgroundSupported() {
    return await this._settingsService.isVirtualBackgroundSupported()
  }

  async setChatroomDefaultFileSavePath(data) {
    const { filePath } = JSON.parse(data)

    return await this._settingsService.setChatroomDefaultFileSavePath(filePath)
  }

  async getChatroomDefaultFileSavePath() {
    return await this._settingsService.getChatroomDefaultFileSavePath()
  }

  async setGalleryModeMaxMemberCount(data) {
    const { count } = JSON.parse(data)

    return await this._settingsService.setGalleryModeMaxMemberCount(count)
  }

  async enableUnmuteAudioByPressSpaceBar(data) {
    const { enable } = JSON.parse(data)

    return await this._settingsService.enableUnmuteAudioByPressSpaceBar(enable)
  }

  async isUnmuteAudioByPressSpaceBarEnabled() {
    return await this._settingsService.isUnmuteAudioByPressSpaceBarEnabled()
  }

  async isGuestJoinSupported() {
    return await this._settingsService.isGuestJoinSupported()
  }

  async isTranscriptionSupported() {
    return await this._settingsService.isTranscriptionSupported()
  }

  async getInterpretationConfig() {
    return await this._settingsService.getInterpretationConfig
  }

  async getScheduledMemberConfig() {
    return await this._settingsService.getScheduledMemberConfig()
  }

  async isNicknameUpdateSupported() {
    return await this._settingsService.isNicknameUpdateSupported()
  }

  async isAvatarUpdateSupported() {
    return await this._settingsService.isAvatarUpdateSupported()
  }

  async isCaptionsSupported() {
    return await this._settingsService.isCaptionsSupported()
  }
}
