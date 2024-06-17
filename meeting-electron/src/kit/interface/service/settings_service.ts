interface NESettingsService {
  /**
   * 设置是否显示会议时长
   *
   * @param enable true-开启，false-关闭
   */
  enableShowMyMeetingElapseTime: (enable: boolean) => Promise<void>
  /**
   * 查询显示会议时长功能开启状态
   */
  isShowMyMeetingElapseTimeEnabled: () => Promise<boolean>
  /**
   *  开启或关闭音频智能降噪
   * @param enable
   */
  enableAudioAINS: (enable: boolean) => Promise<void>
  /**
   * 查询音频智能降噪开启状态
   */
  isAudioAINSEnabled: () => Promise<boolean>
  /**
   * 设置入会时是否打开本地视频
   *
   * @param enable true: 开启本地视频 false: 关闭本地视频
   */
  enableTurnOnMyVideoWhenJoinMeeting: (enable: boolean) => Promise<void>
  /**
   * 查询入会时本地视频开关状态
   */
  isTurnOnMyVideoWhenJoinMeetingEnabled: () => Promise<boolean>
  /**
   * 设置入会时是否打开本地音频
   *
   * enable true-入会时打开音频，false-入会时关闭音频
   */
  enableTurnOnMyAudioWhenJoinMeeting: (enable: boolean) => Promise<void>
  /*
   * 查询入会时本地音频开关状态
   */
  isTurnOnMyAudioWhenJoinMeetingEnabled: () => Promise<boolean>
  /**
   * 查询美颜服务开关状态，关闭在隐藏会中美颜按钮
   */
  isBeautyFaceEnabled: () => Promise<boolean>
  /**
   * 设置美颜服务开关状态
   */
  getBeautyFaceValue: () => Promise<number>
  /**
   * 设置美颜参数
   * @param value 传入美颜等级，参数规则为[0,10]整数
   */
  setBeautyFaceValue: (value: number) => Promise<void>
  /**
   * 查询会议是否拥有直播权限
   */
  isMeetingLiveEnabled: () => Promise<boolean>
  /**
   * 查询应用是否支持等候室
   */
  isWaitingRoomEnabled: () => Promise<boolean>
  /**
   * 查询白板功能是否开启
   */
  isMeetingWhiteboardEnabled: () => Promise<boolean>
  /**
   * 查询云端录制服务开关状态
   */
  isMeetingCloudRecordEnabled: () => Promise<boolean>
  /**
   * 虚拟背景是否显示
   * @param enable
   */
  enableVirtualBackground: (enable: boolean) => Promise<void>
  /**
   * 查询虚拟背景是否开启
   */
  isVirtualBackgroundEnabled: () => Promise<boolean>
  /**
   * 查询静音时是否需要关闭音频流pub
   */
  shouldUnpubOnAudioMute: () => boolean
  /**
   * 设置内置虚拟背景图片路径列表
   *
   * @param pathList 虚拟背景图片路径列表
   */
  setBuiltinVirtualBackgroundList: (pathList: string[]) => Promise<void>
  /**
   * 获取内置虚拟背景图片路径列表
   */
  getBuiltinVirtualBackgroundList(): Promise<string[]>
  /**
   * 设置最近选择的虚拟背景图片路径
   *
   * @param path 虚拟背景图片路径,为空代表不设置虚拟背景
   */
  setCurrentVirtualBackground(path: string): Promise<void>
  /**
   * 获取最近选择的虚拟背景图片路径
   */
  getCurrentVirtualBackground(): Promise<string>
  /**
   * 设置外部虚拟背景图片路径列表
   *
   * @param pathList 虚拟背景图片路径列表
   */
  setExternalVirtualBackgroundList(pathList: string[]): Promise<void>
  /**
   * 获取外部虚拟背景图片路径列表
   */
  getExternalVirtualBackgroundList(): Promise<string[]>
  /**
   * 设置是否打开语音激励
   *
   * @param enable true-开启，false-关闭
   */
  enableSpeakerSpotlight: (enable: boolean) => Promise<void>
  /**
   * 查询是否打开语音激励
   */
  isSpeakerSpotlightEnabled: () => Promise<boolean>
  /**
   * 设置是否打开白板透明
   *
   * @param enable true-开启，false-关闭
   */
  enableTransparentWhiteboard(enable: boolean): Promise<void>
  /**
   * 查询是否开启透明白板
   */
  isTransparentWhiteboardEnabled: () => Promise<boolean>
  /**
   * 设置是否打开摄像头镜像
   *
   * @param enable true-开启，false-关闭
   */
  enableCameraMirror(enable: boolean): Promise<void>
  /**
   * 查询摄像头镜像是否打开
   */
  isCameraMirrorEnabled(): Promise<boolean>
  /**
   * 设置是否打开前置摄像头镜像(仅H5支持)
   *
   * @param enable true-开启，false-关闭
   */
  enableFrontCameraMirror(enable: boolean): void
  /**
   * 查询是否开启共享时开启摄像头
   */
  isFrontCameraMirrorEnabled: () => boolean
}

export default NESettingsService
