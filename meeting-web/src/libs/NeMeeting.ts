import { Logger } from './3rd/Logger'
import { EnhancedEventEmitter } from './3rd/EnhancedEventEmitter'
import { AttendeeOffType, hostAction, memberAction, Role } from './enum'
import { checkType, debounce } from '../utils'
import {
  AccountInfo,
  AnonymousLoginResponse,
  CreateMeetingResponse,
  DeviceInfo,
  GetMeetingConfigResponse,
  LoginResponse,
  NeRtcServerAddresses,
  VideoProfile,
} from '@/types'
import axios, { AxiosInstance } from 'axios'
import { Md5 } from 'ts-md5/dist/md5'
import WebRoomkit from 'neroom-web-sdk'
import {
  NERoomContext,
  NERoomService,
  NERoomMember,
  NEAuthService,
  NERoomRtcController,
  NEMessageChannelService,
  NERoomWhiteboardController,
  NERoomChatController,
} from 'neroom-web-sdk'
// @ts-ignore

const logger = new Logger('Meeting-NeMeeting', true)

export class NeMeeting extends EnhancedEventEmitter {
  // private _siganling: NeMeetingSignaling;
  protected _meetingStatus = 'unlogin'
  protected _isAnonymous = false
  private _webrtc: any
  private _time = 0
  private _isActive = false
  private _isBindRtcEvent = false
  private _roomkit: WebRoomkit
  private _appKey = ''
  private _userUuid = ''
  private _token = ''
  private neRtcServerAddresses: NeRtcServerAddresses = {}
  private roomService: NERoomService | null = null
  private authService: NEAuthService | null = null
  private messageService: NEMessageChannelService | null = null
  private _meetingServerDomain: string
  private _request: AxiosInstance
  private _mapMeetingInfo: Map<string, any> = new Map()
  private _globalConfig: Map<string, any> = new Map()
  private _meetingInfo: CreateMeetingResponse | Record<string, any> = {} // 会议接口返回的会议信息，未包含sdk中的信息
  private _privateMeetingNum = '' // 个人id
  private _meetingType = 0 // 1.随机会议，2.个人会议，3.预约会议
  private _isReuseIM = false // 是否复用im
  roomContext: NERoomContext | null = null
  rtcController: NERoomRtcController | null = null
  chatController: NERoomChatController | null = null
  whiteboardController: NERoomWhiteboardController | null = null
  previewController: any

  constructor(roomkit: any) {
    super()
    logger.debug('constructor() %t')
    this._roomkit = roomkit

    this._meetingServerDomain = 'https://roomkit.netease.im'
    this._request = this.createRequest()
    this._bindSignalEvent()
  }

  private get _config(): Map<string, any> {
    return this._globalConfig
  }

  get webrtc(): any {
    // return this._webrtc;
    console.log('webrtc')
    return null
  }

  get localMember(): any {
    return this.roomContext ? this.roomContext.localMember : null
  }

  get webRTC2(): any {
    // return this._webrtc.webRTC2;
    console.log('getwebrtc2')
    return ''
  }

  get meetingId(): string {
    //logger.warn('meetingId: ', this._siganling.mapMeetingInfo)
    // return this._siganling.mapMeetingInfo.get('meetingId') || ''
    return this._meetingInfo.meetingNum
  }
  set meetingId(val) {
    // this._siganling.mapMeetingInfo.set('meetingId', val || '');
    console.warn('setmeetingid', val)
  }

  get roomDeviceId() {
    return WebRoomkit.getDeviceId()
  }

  get personalMeetingId(): string {
    // return this._siganling.mapMeetingInfo.get('personalMeetingId') || ''
    console.warn('personalMeetingId')
    return ''
  }

  get meetingInfo(): any {
    return this._mapMeetingInfo
  }

  get imInfo(): any {
    // todo  添加逻辑
    if (this.meetingStatus !== 'unlogin') {
      return {
        nim: (this._roomkit as any)._im.nim,
        imAccid: this.authService
          ? (this.authService as any).roomAccountId
          : '',
        imAppKey: this.authService ? (this.authService as any).roomAppKey : '',
        imToken: this.authService
          ? (this.authService as any).roomAccountToken
          : '',
        nickName: this.localMember.name,
        chatRoomId: this.roomContext
          ? this.roomContext.roomProperties?.chatRoom?.chatRoomId
          : '',
      }
    }
    return null
  }

  get recordGlobalConfig(): any {
    const result: any = {}
    if (checkType(this._config.get('meetingRecord.status'), 'number')) {
      result.status = this._config.get('meetingRecord.status')
    }
    if (
      checkType(
        this._config.get('meetingRecord.meetingRecordAudioEnable'),
        'boolean'
      )
    ) {
      result.recordAudio = this._config.get(
        'meetingRecord.meetingRecordAudioEnable'
      )
    }
    if (
      checkType(
        this._config.get('meetingRecord.meetingRecordVideoEnable'),
        'boolean'
      )
    ) {
      result.recordVideo = this._config.get(
        'meetingRecord.meetingRecordVideoEnable'
      )
    }
    if (
      checkType(this._config.get('meetingRecord.meetingRecordMode'), 'number')
    ) {
      result.recordType = this._config.get('meetingRecord.meetingRecordMode')
    }
    return result
  }

  get whiteBoardGlobalConfig(): any {
    const result: any = {}
    if (checkType(this._config.get('whiteboard.status'), 'number')) {
      result.status = this._config.get('whiteboard.status')
    }
    return result
  }

  get avRoomUid(): string {
    // return this._siganling.mapMeetingInfo.get('avRoomUid') || ''
    return this.roomContext ? this.roomContext.localMember.uuid : ''
  }

  get meetingStatus(): string {
    return this._meetingStatus
  }

  get microphoneId(): string {
    // return this._webrtc.microphoneId
    return this.rtcController
      ? this.rtcController.getSelectedRecordDevice()
      : ''
  }

  get cameraId(): string {
    // return this._webrtc.cameraId
    return this.rtcController
      ? this.rtcController.getSelectedCameraDevice()
      : ''
  }

  get speakerId(): string {
    // return this._webrtc.speakerId
    return this.rtcController
      ? this.rtcController.getSelectedPlayoutDevice()
      : ''
  }
  get NIMconf(): any {
    // return this._siganling.mapMeetingInfo.get('NIMconf') || {};
    return {}
  }

  set NIMconf(val) {
    // this._siganling.mapMeetingInfo.set('NIMconf', val || {});
    console.warn('set NIMconf')
  }

  public removeGlobalEventListener() {
    ;(this._roomkit as any).removeGlobalEventListener()
  }
  public initConf(val) {
    // this._siganling.setInitConf(val);
    this._appKey = val.appKey
    val.meetingServerDomain &&
      (this._meetingServerDomain = val.meetingServerDomain)
    this._isReuseIM = !!val.im
    val.globalEventListener &&
      (this._roomkit as any).addGlobalEventListener(val.globalEventListener)
    this._roomkit.initialize({
      appKey: this._appKey,
      serverConfig: {
        roomKitServerConfig: {
          roomServer: this._meetingServerDomain,
        },
        imServerConfig: val.imPrivateConf,
        rtcServerConfig: val.neRtcServerAddresses,
        whiteboardServerConfig: val.whiteboardConfig,
      },
      im: val.im,
      // debug: true
    })
    // axios.defaults.baseURL = this._meetigServerDomain;

    this._request = this.createRequest()
    this.authService = this._roomkit.authService
    this.roomService = this._roomkit.roomService
    this.messageService = this._roomkit
      .messageChannelService as NEMessageChannelService
    this.messageService.addMessageChannelListener({
      onReceiveCustomMessage: (res) => {
        console.log('onReceiveCustomMessage', res)
        if (res.commandId !== 99) {
          return
        }
        const body = res.data.body
        if (Object.prototype.toString.call(body) == '[object String]') {
          res.data.body = JSON.parse(body)
        }
        this.emit('onReceivePassThroughMessage', res)
      },
    })
  }

  private _reset(): void {
    this._time = 0
    this.roomContext = null
    this.rtcController = null
    this.whiteboardController = null
    this.chatController = null
    this.previewController = null
    this._meetingType = 0
  }

  async login(options: any): Promise<void> {
    logger.debug('login(), options: %o %t', options)
    try {
      const { username, password } = options
      // await this._siganling.login(options)
      if (options.loginType === 1) {
        this._userUuid = options.accountId
        this._token = options.accountToken
        this.authService &&
          (await this.authService.login(
            options.accountId,
            options.accountToken
          ))
        const res: AccountInfo = await this._request.get(
          `/scene/meeting/${this._appKey}/v1/account/info`
        )
        this._privateMeetingNum = res.privateMeetingNum
      } else {
        const res: LoginResponse = await this._request.post(
          `/scene/meeting/${this._appKey}/v1/login/${username}`,
          {
            password: Md5.hashStr(password + '@yiyong.im'),
          }
        )
        this._userUuid = res.userUuid
        this._token = res.userToken
        this._privateMeetingNum = res.privateMeetingNum
        this.authService &&
          (await this.authService.login(res.userUuid, res.userToken))
      }

      logger.debug('login() successed %t')
      this._meetingStatus = 'login'
      return
    } catch (e) {
      //logger.debug('init() failed: %o', e)
      return Promise.reject(e)
    }
  }

  private createRequest(): AxiosInstance {
    const instance = axios.create({
      baseURL: this._meetingServerDomain,
    })
    instance.interceptors.request.use(
      (config) => {
        config.headers = {
          ...config.headers,
          clientType: 'web',
          user: this._userUuid,
          token: this._token,
          versionCode: '3.1.0',
          AppKey: this._appKey,
          deviceId: WebRoomkit.getDeviceId(),
        }
        return config
      },
      function (error) {
        return Promise.reject(error)
      }
    )

    instance.interceptors.response.use(
      function (response) {
        if (response.data.code !== 0) {
          return Promise.reject(response.data)
        }
        return response.data?.data
      },
      function (error) {
        return Promise.reject(error)
      }
    )

    return instance
  }
  async create(options: any): Promise<void> {
    try {
      logger.debug('create()', options)
      // await this._siganling.create(options)
      const { meetingId, password, subject, roleBinds, noSip } = options
      this._meetingType = options.meetingId
      const res: CreateMeetingResponse = await this._request.put(
        `/scene/meeting/${this._appKey}/v1/create/${meetingId}`,
        {
          password,
          subject,
          roleBinds,
          roomConfigId: 40,
          roomConfig: {
            resource: {
              rtc: true,
              chatroom: !options.nochat,
              whiteboard: true,
              record: !options.noCloudRecord,
              sip: noSip === undefined ? false : !noSip,
            },
          },
          roomProperties: {
            cloudRecord: {
              mode: 0,
              videoEnable: true,
              audioEnable: true,
            },
            extraData: { value: options.extraData },
            lock: {
              value: 0,
            },
            audioOff: {
              value:
                (options.attendeeAudioOff
                  ? AttendeeOffType.offNotAllowSelfOn
                  : AttendeeOffType.disable) + `_${new Date().getTime()}`,
            },
            videoOff: {
              value:
                (options.attendeeVideoOff
                  ? AttendeeOffType.offNotAllowSelfOn
                  : AttendeeOffType.disable) + `_${new Date().getTime()}`,
            },
          },
        }
      )
      console.log('create options', options)
      this._meetingInfo = res
      await this._joinRoomkit({
        role: 'host',
        roomUuid: res.roomUuid,
        nickname: options.nickName,
        initialProperties: {
          tag: { value: options.memberTag },
        },
      })
      this._addRoomListener()
      this._addRtcListener()
      if (options.videoProfile) {
        const { resolution, frameRate } = options.videoProfile
        await this.setVideoProfile(resolution, frameRate)
      }
      this.rtcController && (await this.rtcController.joinRtcChannel())
      console.log('create meeting ', res)
      this._meetingStatus = 'created'
      logger.debug('create() successed %t')
      // const appkey = this._siganling.mapMeetingInfo.get('nrtcAppKey')
      // logger.debug('音视频的 appkey:  %s %t', appkey)
      // if(!this._webrtc) {
      //   this._webrtc = new NeWebrtc(appkey);
      //   (window as any).webrtc = this._webrtc;
      //   this._bindWebrtcEvent()
      // }

      // const avRoomCName = this._siganling.mapMeetingInfo.get('avRoomCName')
      // const avRoomUid = this._siganling.mapMeetingInfo.get('avRoomUid')
      // const avRoomCheckSum = this._siganling.mapMeetingInfo.get('avRoomCheckSum')
      // logger.warn('join channelName: %s, uid: %s, token: %s %t', avRoomCName, avRoomUid, avRoomCheckSum)
      let recordGlobalConfig = { ...this.recordGlobalConfig }
      if (options.noCloudRecord) {
        // 外部传入关闭录屏, 如果开启录屏则走应用配置是否允许
        recordGlobalConfig = {
          isHostSpeaker: true,
          recordAudio: false,
          recordVideo: false,
          recordType: 0,
        }
      }

      this._isActive = true
      this._meetingStatus = 'joined'
    } catch (e: any) {
      if (e.code === 3100) {
        // 房间已经存在
        this._meetingType = 2
      } else {
        this._meetingType = 0
      }
      this._meetingStatus =
        this._meetingStatus === 'login' ? 'login' : 'unlogin'
      logger.debug('create() failed: %o', e)
      return Promise.reject(e)
    }
  }

  async addSipMember(sipNum: string, sipHost: string) {
    return this._request.post(
      `/scene/meeting/${this._appKey}/v1/sip/${this.meetingId}/invite`,
      {
        sipNum,
        sipHost,
      }
    )
  }

  async getSipMemberList() {
    return this._request.get(
      `/scene/meeting/${this._appKey}/v1/sip/${this.meetingId}/list`
    )
  }

  private async _joinRoomkit(options: {
    role: string
    roomUuid: string
    nickname: string
    password?: string
    initialProperties?: any
  }) {
    return (this.roomService as NERoomService)
      .joinRoom(
        {
          role: options.role,
          roomUuid: options.roomUuid,
          userName: options.nickname,
          password: options.password,
          initialProperties: options.initialProperties,
        },
        {}
      )
      .then(async (res) => {
        this.roomContext = (this.roomService as NERoomService).getRoomContext(
          options.roomUuid
        )
        if (this.roomContext) {
          this.rtcController = this.roomContext.rtcController
          this.whiteboardController = this.roomContext.whiteboardController
          this.whiteboardController.initWhiteboard()
          this.chatController = this.roomContext.chatController
          try {
            await this.chatController.joinChatroom()
            await this.whiteboardController.initWhiteboard()
          } catch (e) {
            console.log('joinroomkit error', e)
          }
        }
      })
  }
  private _addRoomListener() {
    this.roomContext &&
      this.roomContext.addRoomListener({
        onMemberAudioMuteChanged: (member, mute, operatorMember) => {
          member = this._generateMember(member)
          operatorMember = this._generateMember(operatorMember)
          this.emit('onMemberAudioMuteChanged', member, mute, operatorMember)
        },
        onMemberJoinChatroom: async (members) => {
          console.log('onMemberJoinChatroom', members[0])
        },
        onMemberJoinRoom: (members) => {
          console.log('onMemberJoinRoom', members)
        },
        onMemberNameChanged: (member, name) => {
          member = this._generateMember(member)
          this.emit('onMemberNameChanged', member, name)
        },
        onMemberJoinRtcChannel: async (members) => {
          console.log('onMemberJoinRtcChannel', members)
          const member = this._generateMember(members[0])
          this.emit('onMemberJoinRtcChannel', member)
        },
        onMemberLeaveChatroom: (members) => {
          console.log('onMemberLeaveChatroom', members)
        },
        onMemberLeaveRoom: (members) => {
          console.log('onMemberLeaveRoom', members)
          const member = this._generateMember(members[0])
          logger.debug('_peerLeave() 用户离开:  %i %t', member.uuid)

          if (this.avRoomUid === member.avRoomUid) {
            this._meetingStatus = 'login'
          }
          this.emit('onMemberLeaveRoom', member)
        },
        onMemberLeaveRtcChannel: (members) => {
          const member = this._generateMember(members[0])
          if (this.avRoomUid === member.avRoomUid) {
            this._meetingStatus = 'login'
          }
          this.emit('onMemberLeaveRoom', member)
        },
        onMemberRoleChanged: (member, beforeRole, afterRole) => {
          member = this._generateMember(member)
          this.emit('onMemberRoleChanged', member, beforeRole, afterRole)
        },
        onMemberScreenShareStateChanged: async (
          member,
          isSharing,
          operator
        ) => {
          member = this._generateMember(member)
          operator = this._generateMember(operator)
          this.emit(
            'onMemberScreenShareStateChanged',
            member,
            isSharing,
            operator
          )
        },
        onMemberVideoMuteChanged: async (member, mute, operator) => {
          member = this._generateMember(member)
          operator = this._generateMember(operator)
          this.emit('onMemberVideoMuteChanged', member, mute, operator)
        },
        onMemberWhiteboardStateChanged: async (member, isOpen, operator) => {
          if (member) {
            member = this._generateMember(member)
          }
          this.emit('onMemberWhiteboardStateChanged', member, isOpen, operator)
        },
        onReceiveChatroomMessages: (messages) => {
          // console.log('onReceiveChatroomMessages', messages);
          this.emit('onReceiveChatroomMessages', messages)
        },
        onRoomPropertiesChanged: (properties: any) => {
          this.emit('onRoomPropertiesChanged', properties)
        },
        onRoomLockStateChanged: (isLocked: boolean) => {
          this.emit('onRoomLockStateChanged', isLocked)
        },
        onMemberPropertiesChanged: (
          member: NERoomMember,
          properties: Record<string, any>
        ) => {
          this.emit('onMemberPropertiesChanged', member.uuid, properties)
        },
        onMemberPropertiesDeleted: (userUuid: string, properties) => {
          const keys = Object.keys(properties)
          this.emit('onMemberPropertiesDeleted', userUuid, keys)
        },
        onRoomPropertiesDeleted: (properties) => {
          const keys = Object.keys(properties)
          this.emit('onRoomPropertiesDeleted', keys)
        },
        onRoomEnded: (reason) => {
          this._meetingStatus = 'login'
          if (reason === 'kICK_BY_SELF') {
            this._clientBanned()
          } else {
            this.emit('onRoomEnded', reason)
          }
        },
        onRtcActiveSpeakerChanged: (speaker: {
          userUuid: string
          volume: number
        }) => {
          this.emit('onRtcActiveSpeakerChanged', speaker)
        },
        onRtcAudioVolumeIndication: (data) => {
          if (this.rtcController) {
            const rtc: any = (this.rtcController as any)._rtc
            const localVolume = rtc.localStream?.getAudioLevel()
            data = data.filter((item) => {
              return item.volume > 1
            })
            if (localVolume > 0) {
              const localData = {
                userUuid: this.localMember.uuid,
                volume: localVolume,
              }
              data.unshift(localData)
            }
          }
          this.emit('onRtcAudioVolumeIndication', data)
        },
        onRtcChannelError: (code) => {
          if (code === 'SOCKET_ERROR') {
            if (this._isAnonymous) {
              this._meetingStatus = 'unlogin'
              this.authService && this.authService.logout()
            } else {
              this._meetingStatus = 'login'
            }
            this.leave()
            debounce(this.emit('offline'))
          }
        },
        onRoomConnectStateChanged: (data) => {
          console.log('onRoomConnectStateChanged', data)
          this._connectionStateChange(data)
        },
        onCameraDeviceChanged: (data) => {
          // this.emit('onCameraDeviceChanged', data);
          this._deviceChange()
        },
        onPlayoutDeviceChanged: (data) => {
          // this.emit('onSpeakerDeviceChanged', data);
          this._deviceChange()
        },
        onRecordDeviceChanged: (data) => {
          // this.emit('onRecordDeviceChanged', data);
          this._deviceChange()
        },
      })
  }

  private _addRtcListener() {}

  async anonymousJoin(options: any): Promise<any> {
    if (this._isReuseIM) {
      console.warn('im复用不支持匿名入会')
      return -101
    }
    this._isAnonymous = true
    console.log('anonymousJoin', options)
    logger.debug('anonymousJoin() %t')
    // result = await this._siganling.anonymousJoin(options)
    try {
      const res: AnonymousLoginResponse = await this._request.post(
        `/scene/apps/${this._appKey}/v1/anonymous/login`
      )
      options.role = options.role || Role.participant
      this._userUuid = res.userUuid
      this._token = res.userToken
      this._privateMeetingNum = res.privateMeetingNum || ''
      try {
        this.authService &&
          (await this.authService.login(res.userUuid, res.userToken))
      } catch (e) {
        console.log('authService.login', e)
      }
      const data = await this._joinHandler(options)
      return data
    } catch (e) {
      console.log('anonymousJoin', e)
      throw e
    }
  }
  async join(options: any): Promise<any> {
    try {
      options.role = options.role || Role.participant
      logger.debug('_meetingStatus:  %s %t', this._meetingStatus)
      if (
        this._meetingStatus === 'created' ||
        this._meetingStatus === 'login'
      ) {
        logger.debug('join() %o %t', options)
        // 如果是自己创建会议时候提示会议已经存在且是个人会议则使用个人会议号
      }
      // else {
      //   logger.warn('join() meetingStatus error %t')
      //   return
      // }
      // 如果是自己创建会议时候提示会议已经存在且是个人会议则使用个人会议号
      return this._joinHandler(options)
    } catch (e: any) {
      logger.debug('join() failed: %o', e)
      return Promise.reject(e)
    }
  }

  private async _joinHandler(options: any) {
    const meetingId =
      this._meetingType === 2 ? this._privateMeetingNum : options.meetingId
    const res: CreateMeetingResponse = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/info/${meetingId}`
    )
    this._meetingInfo = res
    // result = await this._siganling.join(options)
    console.log('options..', options)
    await this._joinRoomkit({
      role: options.role,
      roomUuid: res.roomUuid,
      nickname: options.nickName,
      password: options.password,
      initialProperties: {
        tag: { value: options.memberTag },
      },
    })
    this._addRoomListener()
    this._addRtcListener()
    if (options.videoProfile) {
      const { resolution, frameRate } = options.videoProfile
      await this.setVideoProfile(resolution, frameRate)
    }
    this.rtcController && (await this.rtcController.joinRtcChannel())
    logger.debug('join() successed')
    logger.debug('音视频的 appkey:  %s %t', this._appKey)

    // todo 需要添加录制逻辑
    let recordGlobalConfig = { ...this.recordGlobalConfig }
    if (options.noCloudRecord) {
      // 外部传入关闭录屏, 如果开启录屏则走应用配置是否允许
      recordGlobalConfig = {
        recordAudio: false,
        recordVideo: false,
        recordType: 0,
      }
    }
    this._isActive = true
    this._meetingStatus = 'joined'
    return this.getMeetingInfo()
  }
  private _generateMember(member) {
    // 生成会议需要的成员
    member = { ...member }
    member.video = member.isVideoOn ? 1 : 0
    member.audio = member.isAudioOn ? 1 : 0
    member.screen = member.isSharingScreen ? 1 : 0
    member.screenSharing = member.screen
    member.whiteBoardShare = member.isSharingWhiteboard ? 1 : 0
    member.avRoomUid = member.uuid
    member.accountId = member.uuid
    member.nickName = member.name
    member.uid = member.uuid
    member.role = member.role.name
    member.isHost = member.role === Role.host
    member.handsUps = member.properties
      ? member.properties.handsUp
      : { value: 0 }
    member.memberTag = member.properties ? member.properties.tag?.value : ''
    member.whiteBoardInteract = member.properties
      ? member.properties.wbDrawable
        ? member.properties.wbDrawable.value
        : '0'
      : '0'
    return member
  }

  async leave(role?: string): Promise<void> {
    try {
      if (!this._isActive) {
        return
      }
      logger.debug('leave() %t')
      this._isActive = false
      this.roomContext && (await this.roomContext.leaveRoom())
      // if (this._webrtc) {
      //   await this._webrtc.leave()
      // }
      if (role === 'AnonymousParticipant' || this._isAnonymous) {
        this._meetingStatus = 'unlogin'
        // this._isAnonymous = false
        // this._siganling.logoutImServer()
        // ;(this.authService as NEAuthService).logout()
      } else {
        this._meetingStatus = 'login'
      }

      this._reset()
      logger.debug('leave() successed %t')
    } catch (e) {
      return Promise.reject(e)
    }
  }

  async end(): Promise<void> {
    try {
      logger.debug('end():  %s %t', this._isAnonymous)
      if (!this._isActive) {
        return
      }
      this._isActive = false
      this.roomContext && (await this.roomContext.endRoom())
      // await this._siganling.leave()
      if (this._isAnonymous) {
        this._meetingStatus = 'unlogin'
        // this._siganling.logoutImServer()
        //this._isAnonymous = false
      } else {
        this._meetingStatus = 'login'
      }

      this._reset()
      logger.debug('end() successed:  %s %t', this._meetingStatus)
    } catch (e) {
      return Promise.reject(e)
    }
  }

  resetStatus(): void {
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      // this._siganling.logoutImServer()
      this.authService && this.authService.logout()
      this._isAnonymous = false
    } else {
      this._meetingStatus = 'login'
    }
    // this._webrtc.destroy()
  }

  // private _bindWebrtcEvent(): void {
  //   this._webrtc.on('@playLocalStream', this._playLocalStream.bind(this))
  //   this._webrtc.on('@playRemoteStream', this._playRemoteStream.bind(this))
  //   this._webrtc.on('@peerJoin', this._peerJoin.bind(this))
  //   this._webrtc.on('@peerLeave', this._peerLeave.bind(this))
  //   this._webrtc.on('@streamAdded', this._streamAdded.bind(this))
  //   this._webrtc.on('@streamRemoved', this._streamRemoved.bind(this))
  //   this._webrtc.on('@channelClosed', this._channelClosed.bind(this))
  //   this._webrtc.on('@clientBanned', this._clientBanned.bind(this))
  //   this._webrtc.on('@connectionStateChange', this._connectionStateChange.bind(this))
  //   this._webrtc.on('@activeSpeaker', this._activeSpeaker.bind(this))
  //   this._webrtc.on('@volumeIndicator', this._volumeIndicator.bind(this));
  //   this._webrtc.on('@networkQuality', this._networkQuality.bind(this));
  //   this._webrtc.on('@deviceAdd', this._deviceAdd.bind(this))
  //   this._webrtc.on('@deviceRemove', this._deviceRemove.bind(this))
  //   this._webrtc.on('@audioTrackEnded', this._audioTrackEnded.bind(this))
  //   this._webrtc.on('@videoTrackEnded', this._videoTrackEnded.bind(this))
  //   this._webrtc.on('@stopScreenSharing', this._stopScreenSharing.bind(this))
  //   this._webrtc.on('@deviceChange', this._deviceChange.bind(this))
  //   // this._webrtc.on('@syncFinish', this._syncFinish.bind(this))
  // }

  private _bindSignalEvent(): void {
    // this._siganling.on('@controlNotify', this._controlNotify.bind(this))
  }
  private _unbindSignalEvent(): void {
    // this._siganling.removeListener('@controlNotify', this._controlNotify.bind(this))
  }

  private _controlNotify(data) {
    this.emit('controlNotify', data)
  }

  private _playLocalStream(data: any) {
    logger.debug('_playLocalStream() 播放本端视频 %t')
    this.emit('playLocalStream', data)
  }

  private _playRemoteStream(stream: any) {
    logger.debug('_playRemoteStream() 播放远端视频 %t')
    this.emit('playRemoteStream', stream)
  }

  private _peerJoin(data: any) {
    logger.debug('_peerJoin() 用户加入:  %i %t', data.uid)
    this.emit('peerJoin', data)
  }

  private _peerLeave(data: any) {
    logger.debug('_peerLeave() 用户离开:  %i %t', data.uid)
    this.emit('peerLeave', data.uid)
  }

  private _streamAdded(stream: any) {
    logger.debug('_streamAdded() 对端发布流 %t')
    this.emit('streamAdded', stream)
  }

  private _streamRemoved(stream: any) {
    logger.debug('_streamRemoved() 对端停止发布流 %t')
    this.emit('streamRemoved', stream)
  }

  private _channelClosed() {
    logger.debug('_channelClosed() 房间被关闭 %t')
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      // this._siganling.logoutImServer()
      this.authService && this.authService.logout()
      //this._isAnonymous = false
    } else {
      this._meetingStatus = 'login'
    }
    this.emit('channelClosed')
  }

  private _clientBanned() {
    logger.debug('_clientBanned() 自己被移除房间 %t')
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      // this._siganling.logoutImServer()
      this.authService && this.authService.logout()
      //this._isAnonymous = false
    } else {
      this._meetingStatus = 'login'
    }
    this.emit('clientBanned')
  }

  private _connectionStateChange(_data) {
    logger.debug('_connectionStateChange() 网络状态发生了变化: %o %t', _data)
    if (!this._isActive) {
      return
    }
    if (_data.curState === 'DISCONNECTED' && this._meetingStatus === 'joined') {
      logger.error('检测到网络中断 %t')

      // this.leave()
    } else if (
      _data.curState === 'CONNECTING' &&
      this._meetingStatus === 'joined'
    ) {
      logger.debug('正在重连中 %t')
      debounce(this.emit('networkReconnect'))
    } else if (
      ((_data.prevState === 'CONNECTED' && _data.curState === 'CONNECTED') ||
        (_data.prevState === 'CONNECTING' && _data.curState === 'CONNECTED')) &&
      this._meetingStatus === 'joined'
    ) {
      logger.debug('重连成功 %t')
      logger.debug('join() %t')
      debounce(this.emit('networkSuccess'))
      // this._siganling.join({})
    }
  }

  private _activeSpeaker(_data) {
    if (this._time++ % 2 === 0) {
      this.emit('activeSpeaker', _data)
    }
  }

  private _volumeIndicator(_data) {
    this.emit('volumeIndicator', _data)
  }
  private _networkQuality(_data) {
    this.emit('networkQuality', _data)
  }

  private _deviceAdd(_data) {
    this.emit('deviceAdd', _data)
  }

  private _deviceRemove(_data) {
    this.emit('deviceRemove', _data)
  }

  private _audioTrackEnded() {
    this.emit('audioTrackEnded')
  }

  private _videoTrackEnded() {
    this.emit('videoTrackEnded')
  }

  private _stopScreenSharing() {
    this.emit('stopScreenSharing')
  }

  private _deviceChange() {
    debounce(() => {
      this.emit('deviceChange')
    }, 1200)
  }

  // private _syncFinish() {
  //   this.emit('syncFinish');
  // }

  getMeetingInfo(avRoomUid?: string): Promise<any> {
    logger.warn('getMeetingInfo, meetingId： %s %t ', this.meetingId)
    const params: any = {
      meetingId: this.meetingId,
    }
    if (avRoomUid) params.avRoomUid = avRoomUid
    // return this._siganling.sendControlOrder('/v1/sdk/meeting/info', params)
    const remoteMembers = (this.roomContext as NERoomContext).remoteMembers
    const localMember = (this.roomContext as NERoomContext).localMember
    const roomProperties = (this.roomContext as NERoomContext).roomProperties
    if (roomProperties.audioOff) {
      roomProperties.audioOff.value =
        roomProperties.audioOff.value?.split('_')[0]
    }
    if (roomProperties.videoOff) {
      roomProperties.videoOff.value =
        roomProperties.videoOff.value?.split('_')[0]
    }
    const screenSharersAvRoomUid = (
      this.rtcController as NERoomRtcController
    ).getScreenSharingUserUuid()
    let members: any = []
    remoteMembers.forEach((member) => {
      if (member.isInRtcChannel) {
        members.push(member)
      }
    })
    members = [localMember, ...members]
    let hostAvRoomUid = ''
    const whiteboardAvRoomUid = roomProperties.wbSharingUuid
      ? roomProperties.wbSharingUuid.value
      : 0
    const focusAvRoomUid = roomProperties.focus ? roomProperties.focus.value : 0
    members = members.map((_member) => {
      const member = this._generateMember(_member)
      if (member.role === Role.host) {
        hostAvRoomUid = member.uuid
      }
      return member
    })
    let shareMode = 0
    if (screenSharersAvRoomUid && whiteboardAvRoomUid) {
      shareMode = 3
    } else if (screenSharersAvRoomUid) {
      shareMode = 1
    } else if (whiteboardAvRoomUid) {
      shareMode = 2
    }
    const { subject, startTime, endTime, type, settings, shortMeetingNum } =
      this._meetingInfo
    console.log('sip...', this.roomContext)
    return Promise.resolve({
      code: 200,
      ret: {
        members,
        meeting: {
          hostAvRoomUid,
          focusAvRoomUid,
          // screenSharingUid: 0,
          whiteboardAvRoomUid: whiteboardAvRoomUid ? [whiteboardAvRoomUid] : [],
          whiteboardOwnerImAccid: whiteboardAvRoomUid
            ? [whiteboardAvRoomUid]
            : [],
          screenSharersAvRoomUid: screenSharersAvRoomUid
            ? [screenSharersAvRoomUid]
            : [],
          screenSharersAccountId: screenSharersAvRoomUid
            ? [screenSharersAvRoomUid]
            : [],
          properties: roomProperties,
          activeSpeakerUid: 0,
          password: (this.roomContext as NERoomContext).password,
          subject,
          startTime,
          endTime,
          type, // 1即刻会议2个人会议3预约会议
          shareMode,
          shortId: shortMeetingNum,
          sipCid: (this.roomContext as NERoomContext).sipCid,
        },
      },
    })
  }
  private async _handleMemberAction(type: memberAction, userUuid?: string) {
    userUuid = userUuid || this.avRoomUid
    const rtcController = (this.roomContext as NERoomContext).rtcController
    const whiteboardController = (this.roomContext as NERoomContext)
      .whiteboardController
    switch (type) {
      case memberAction.muteAudio:
        return rtcController.muteMyAudio()
      case memberAction.unmuteAudio:
        return rtcController.unmuteMyAudio()
      case memberAction.muteVideo:
        return rtcController.muteMyVideo()
      case memberAction.unmuteVideo:
        // this.setCanvas(userUuid, 'video');
        return rtcController.unmuteMyVideo()
      case memberAction.unmuteScreen:
        // this.setCanvas(userUuid, 'screen')
        return rtcController.startScreenShare()
      case memberAction.muteScreen:
        return rtcController.stopScreenShare()
      case memberAction.openWhiteShare:
        return whiteboardController.startWhiteboardShare()
      case memberAction.closeWhiteShare:
        return whiteboardController.stopWhiteboardShare()
      case memberAction.shareWhiteShare: // 授权白板权限
        return (this.roomContext as NERoomContext).updateMemberProperty(
          userUuid,
          'wbDrawable',
          JSON.stringify({
            value: '1',
          })
        )
      case memberAction.cancelShareWhiteShare:
        return (this.roomContext as NERoomContext).updateMemberProperty(
          userUuid,
          'wbDrawable',
          JSON.stringify({
            value: '0',
          })
        )
      case memberAction.modifyMeetingNickName:
        // todo 需要添加修改逻辑
        return
      case memberAction.handsUp:
        return (this.roomContext as NERoomContext).updateMemberProperty(
          userUuid,
          'handsUp',
          JSON.stringify({
            value: '1',
          })
        )
      case memberAction.handsDown:
        return (this.roomContext as NERoomContext).deleteMemberProperty(
          userUuid,
          'handsUp'
        )
    }
  }

  private async _handleHostAction(type: hostAction, userUuid: string) {
    const roomContext = this.roomContext as NERoomContext
    switch (type) {
      case hostAction.remove:
        return roomContext.kickMemberOut(userUuid)
      case hostAction.muteMemberVideo:
        return (this.rtcController as NERoomRtcController).muteMemberVideo(
          userUuid
        )
      case hostAction.muteMemberAudio:
        return (this.rtcController as NERoomRtcController).muteMemberAudio(
          userUuid
        )
      case hostAction.muteAllAudio:
        return roomContext.updateRoomProperty(
          'audioOff',
          JSON.stringify({
            value: AttendeeOffType.offAllowSelfOn + `_${new Date().getTime()}`,
          })
        )
      case hostAction.lockMeeting:
        return roomContext.lockRoom()
      case hostAction.muteAllVideo:
        return roomContext.updateRoomProperty(
          'videoOff',
          JSON.stringify({
            value: AttendeeOffType.offAllowSelfOn + `_${new Date().getTime()}`,
          })
        )
      case hostAction.unmuteMemberVideo:
        return (
          this.messageService as NEMessageChannelService
        ).sendCustomMessage(
          this.meetingId,
          userUuid,
          99,
          JSON.stringify({
            type: 2,
            category: 'meeting_control',
          })
        )
      case hostAction.unmuteMemberAudio:
        return (
          this.messageService as NEMessageChannelService
        ).sendCustomMessage(
          this.meetingId,
          userUuid,
          99,
          JSON.stringify({
            type: 1,
            category: 'meeting_control',
          })
        )
      case hostAction.unmuteAllAudio: // 解除全体静音
        return roomContext.updateRoomProperty(
          'audioOff',
          JSON.stringify({
            value: AttendeeOffType.disable + `_${new Date().getTime()}`,
          })
        )
      case hostAction.unlockMeeting:
        return roomContext.unlockRoom()
      case hostAction.unmuteAllVideo:
        return roomContext.updateRoomProperty(
          'videoOff',
          JSON.stringify({
            value: AttendeeOffType.disable + `_${new Date().getTime()}`,
          })
        )
      case hostAction.muteVideoAndAudio:
        ;(this.rtcController as NERoomRtcController).muteMemberVideo(userUuid)
        ;(this.rtcController as NERoomRtcController).muteMemberAudio(userUuid)
        return
      case hostAction.unmuteVideoAndAudio:
        return (
          this.messageService as NEMessageChannelService
        ).sendCustomMessage(
          this.meetingId,
          userUuid,
          99,
          JSON.stringify({
            type: 3,
            category: 'meeting_control',
          })
        )
      case hostAction.transferHost:
        return roomContext.handOverMyRole(userUuid)
      case hostAction.setCoHost: // 设置联席主持人
        return roomContext.changeMemberRole(userUuid, Role.coHost)
      case hostAction.unSetCoHost: // 取消设置联席主持人
        return roomContext.changeMemberRole(userUuid, Role.participant)
      case hostAction.setFocus:
        return roomContext.updateRoomProperty(
          'focus',
          JSON.stringify({
            value: userUuid,
          }),
          userUuid
        )
      case hostAction.unsetFocus:
        return roomContext.updateRoomProperty(
          'focus',
          JSON.stringify({
            value: '',
          })
        )
      case hostAction.forceMuteAllAudio:
        return roomContext.updateRoomProperty(
          'audioOff',
          JSON.stringify({
            value:
              AttendeeOffType.offNotAllowSelfOn + `_${new Date().getTime()}`,
          })
        )
      case hostAction.rejectHandsUp:
        return roomContext.updateMemberProperty(
          userUuid,
          'handsUp',
          JSON.stringify({
            value: '2',
          })
        )
      case hostAction.forceMuteAllVideo:
        return roomContext.updateRoomProperty(
          'videoOff',
          JSON.stringify({
            value:
              AttendeeOffType.offNotAllowSelfOn + `_${new Date().getTime()}`,
          })
        )
      case hostAction.closeScreenShare:
        return (
          this.rtcController as NERoomRtcController
        ).stopMemberScreenShare(userUuid)
      case hostAction.openWhiteShare:
        return (
          this.whiteboardController as NERoomWhiteboardController
        ).startWhiteboardShare()
      case hostAction.closeWhiteShare:
        return (
          this.whiteboardController as NERoomWhiteboardController
        ).stopMemberWhiteboardShare(userUuid)
    }
  }
  // 发送成员会控操作
  sendMemberControl(type: memberAction, avRoomUids?: Array<string>) {
    logger.debug('sendMemberControl %s %t', type)
    const userUuid = avRoomUids ? avRoomUids[0] : ''
    return this._handleMemberAction(type, userUuid)
  }
  sendHostControl(
    type: hostAction,
    accountIds?: Array<string>,
    avRoomUids?: Array<string>,
    data?: any
  ) {
    logger.debug('sendHostControl %s %o %t', type, accountIds)
    const userUuid = accountIds ? accountIds[0] : ''
    return this._handleHostAction(type, userUuid)
  }
  async muteLocalAudio(need = true) {
    logger.debug('muteLocalAudio %t')
    if (need) {
      return this.sendMemberControl(memberAction.muteAudio)
    }
    if (this.rtcController) {
      await this.rtcController.muteMyAudio()
      logger.debug('muteLocalAudio success %t')
      return true
    } else {
      logger.warn('muteLocalAudio no _webrtc %t')
      return false
    }
  }
  async unmuteLocalAudio(deviceId?: string, need = true) {
    logger.debug('unmuteLocalAudio %t')
    if (need) {
      return this.sendMemberControl(memberAction.unmuteAudio)
    }
    if (this.rtcController) {
      if (deviceId) {
        await this.rtcController.switchDevice({
          type: 'microphone',
          deviceId,
        })
      } else {
        await this.rtcController.unmuteMyAudio()
      }
      logger.debug('unmuteLocalAudio success %t')
      return true
    } else {
      logger.warn('unmuteLocalAudio no _webrtc %t')
      return false
    }
  }
  async muteLocalVideo(need = true) {
    logger.debug('muteLocalVideo %t')
    if (need) {
      return this.sendMemberControl(memberAction.muteVideo)
    }
    if (this.rtcController) {
      await this.rtcController.muteMyVideo()
      logger.debug('muteLocalVideo success %t')
      return true
    } else {
      logger.warn('muteLocalVideo no _webrtc %t')
      return false
    }
  }
  async unmuteLocalVideo(
    deviceId?: string,
    need = true,
    videoProfile?: VideoProfile
  ) {
    logger.debug('unmuteLocalVideo %t')
    if (need) {
      return this.sendMemberControl(memberAction.unmuteVideo)
    }
    if (this.rtcController) {
      try {
        // this.setCanvas(this.avRoomUid, 'video');
        await this.rtcController.unmuteMyVideo()
        logger.debug('unmuteLocalVideo success %t')
        return true
      } catch (error) {
        logger.warn(error)
        return false
      }
    } else {
      logger.warn('unmuteLocalVideo no _webrtc %t')
      return false
    }
  }

  async muteLocalScreenShare() {
    logger.debug('muteLocalScreenShare')
    if (this.rtcController) {
      await this.rtcController.stopScreenShare()
      // await this.sendMemberControl(memberAction.muteScreen)
      logger.debug('muteLocalScreenShare success %t')
    } else {
      logger.warn('muteLocalScreenShare no _webrtc %t')
    }
    return
  }

  async unmuteLocalScreenShare(sourceId?: string) {
    logger.debug('unmuteLocalScreenShare %s %t', sourceId)
    if (this.rtcController) {
      await (this.rtcController as any).startScreenShare({
        sourceId: sourceId,
      })
      // await this.sendMemberControl(memberAction.unmuteScreen)
      logger.debug('unmuteLocalScreenShare success %t')
    } else {
      logger.warn('unmuteLocalScreenShare no _webrtc %t')
    }
    return
  }

  async changeLocalAudio(deviceId: string) {
    // await this.muteLocalAudio(false)
    // await this.unmuteLocalAudio(deviceId);
    if (this.rtcController) {
      await this.rtcController.switchDevice({
        type: 'microphone',
        deviceId,
      })
      logger.debug('changeLocalAudio success %t')
    } else {
      logger.warn('changeLocalAudio no _webrtc %t')
    }
  }

  async changeLocalVideo(deviceId: string, need = true) {
    if (this.rtcController) {
      await this.rtcController.switchDevice({
        type: 'camera',
        deviceId,
      })
      logger.debug('changeLocalAudio success %t')
    } else {
      logger.warn('changeLocalAudio no _webrtc %t')
    }
    // await this.muteLocalVideo(need)
    // await this.unmuteLocalVideo(deviceId, need);
    // return
  }

  async getMicrophones() {
    if (this.rtcController) {
      const res = await this.rtcController.enumRecordDevices()
      // const devices = await this._webrtc.getMicrophones()
      logger.debug('getMicrophones success, %o %t', res.data)
      return res.data.map((item) => {
        if (
          item.deviceName.indexOf('USB') < 0 &&
          item.deviceName.indexOf('Built') < 0 &&
          item.deviceName.indexOf('外置') < 0 &&
          item.deviceName.indexOf('麦克风') < 0 &&
          item.deviceName.indexOf('默认') < 0
        ) {
          item.deviceName = item.deviceName + '（不推荐）'
        }
        return item
      })
    } else {
      logger.warn('getMicrophones no previewController %t')
    }
  }
  async getCameras() {
    logger.debug('getCameras')
    if (this.rtcController) {
      const res = await this.rtcController.enumCameraDevices()
      // const devices = await this._webrtc.getCameras()
      logger.debug('getCameras success, %o %t', res.data)
      return res.data
    } else {
      logger.warn('getCameras no _webrtc %t')
    }
  }
  async getSpeakers() {
    logger.debug('getSpeakers %t')
    if (this.rtcController) {
      const res = await this.rtcController.enumPlayoutDevices()
      logger.debug('getSpeakers success, %o %t', res.data)
      return res.data.map((item) => {
        if (
          item.deviceName.indexOf('USB') < 0 &&
          item.deviceName.indexOf('Built') < 0 &&
          item.deviceName.indexOf('外置') < 0 &&
          item.deviceName.indexOf('扬声器') < 0 &&
          item.deviceName.indexOf('默认') < 0
        ) {
          item.deviceName = item.deviceName + '（不推荐）'
        }
        return item
      })
    } else {
      logger.warn('getSpeakers no _webrtc %t')
    }
  }
  //选择要使用的扬声器
  async selectSpeakers(speakerId: string) {
    logger.debug('selectSpeakers %s %t', speakerId)
    if (this.rtcController) {
      await this.rtcController.switchDevice({
        type: 'speaker',
        deviceId: speakerId,
      })
      logger.debug('selectSpeakers success %t')
      return
    } else {
      logger.warn('selectSpeakers no _webrtc %t')
    }
  }

  async setVideoProfile(resolution: number, frameRate: number) {
    if (this.rtcController) {
      await this.rtcController.setLocalVideoConfig({
        resolution: resolution as any,
        frameRate: frameRate as any,
      })
      logger.debug('setVideoProfile success %o %o %t', resolution, frameRate)
      return
    } else {
      logger.warn('setVideoProfile no _webrtc %t')
    }
  }

  //设置mic采集音量 0-100
  setCaptureVolume(volume: number): void {
    // todo
    // this._webrtc.setCaptureVolume(volume)
  }
  //获取mic的采集音量 0-1
  getAudioLevel(): void {
    // todo
    // if(!this._webrtc) return
    // return this._webrtc.getAudioLevel()
  }

  // 获取网络相关信息
  async getTransportStats(): Promise<any> {
    // todo
    // if (!this._webrtc) return;
    // return await this._webrtc.getTransportStats();
  }
  // 获取当前会话统计信息
  async getSessionStats(): Promise<any> {
    // todo
    // if (!this._webrtc) return;
    // return await this._webrtc.getSessionStats();
  }

  // 获取本端音频信息
  async getLocalAudioStats(): Promise<any> {
    // todo
    // if (!this._webrtc) return;
    // return await this._webrtc.getLocalAudioStats();
  }

  // 获取远端音频信息
  async getRemoteAudioStats(): Promise<any> {
    if (!this._webrtc) return
    return await this._webrtc.getRemoteAudioStats()
  }

  // 获取本端视频信息
  async getLocalVideoStats(): Promise<any> {
    if (!this._webrtc) return
    return await this._webrtc.getLocalVideoStats()
  }

  // 获取远端视频信息
  async getRemoteVideoStats(): Promise<any> {
    if (!this._webrtc) return
    return await this._webrtc.getRemoteVideoStats()
  }

  //获取摄像头的stream
  async getCameraStram(deviceId: string): Promise<any> {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { deviceId: deviceId ? { exact: deviceId } : undefined },
    })
    return stream
  }
  public async getGlobalConfig(): Promise<GetMeetingConfigResponse> {
    // return await this._siganling.getGlobalConfig();
    const res: GetMeetingConfigResponse = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/config`
    )
    console.log('getGlobalConfig', res)
    const meetingRecord = res.appConfig?.MEETING_RECORD
    if (meetingRecord) {
      this._globalConfig.set('meetingRecord.status', 1)
      this._globalConfig.set(
        'meetingRecord.meetingRecordAudioEnable',
        meetingRecord.audioEnabled
      )
      this._globalConfig.set(
        'meetingRecord.meetingRecordVideoEnable',
        meetingRecord.videoEnabled
      )
      this._globalConfig.set(
        'meetingRecord.meetingRecordMode',
        meetingRecord.mode
      )
    }
    this._globalConfig.set(
      'whiteboard.status',
      res.appConfig?.APP_ROOM_RESOURCE.whiteboard ? 1 : 0
    )
    return res
  }
  // 修改会中昵称
  public async modifyNickName(options: { nickName: string }) {
    return (this.roomContext as NERoomContext).changeMyName(options.nickName)
  }

  async destroyRoomContext() {
    logger.debug('destroyRoomContext() %t')
    // this.roomContext && (await this.roomContext.destroy())
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      this.authService && this.authService.logout()
      this._isAnonymous = false
    }
    this.roomContext?.destroy()
    this._reset()
  }

  async destroy(): Promise<void> {
    logger.debug('destroy() %t')
    // this._unbindWebrtcEvent()
    // this._unbindSignalEvent()
    // await this._siganling.destroy()
    // if (this.rtcController) {
    //   if (this._meetingStatus === 'joined') {
    //     await this._webrtc.leave();
    //   }
    //   await this._webrtc.destroy();
    // }
    await this.destroyRoomContext()
    this._meetingStatus = 'unlogin'
    this._isActive = false
    return
  }
}
