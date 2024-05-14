import React, { useContext, useEffect, useMemo, useRef, useState } from 'react'
import { Badge, Button, Dropdown, Input, MenuProps, Spin, Tag } from 'antd'
import dayjs from 'dayjs'
import { useTranslation } from 'react-i18next'
import classNames from 'classnames'

import NEMeetingKit from '../../../index'
import { getDefaultDeviceId } from '../../../utils'
import './index.less'

import {
  LOCALSTORAGE_USER_INFO,
  NOT_FIRST_LOGIN,
} from '../../../../app/src/config'

import { NEPreviewController, NERoomService } from 'neroom-web-sdk'
import qs from 'qs'
import { IPCEvent } from '../../../../app/src/types'
import {
  CreateMeetingResponse,
  CreateOptions,
  EventType,
  GlobalContext as GlobalContextInterface,
  GetMeetingConfigResponse,
  JoinOptions,
  MeetingSetting,
} from '../../../types'
import { NEMeetingStatus } from '../../../types/type'
import UserAvatar from '../../common/Avatar'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import { ActionSheet, Popup } from 'antd-mobile/es'
import { Action } from 'antd-mobile/es/components/action-sheet'
import Dialog from '../ui/dialog'
import { errorCodeMap } from '../../../config'

const domain = process.env.MEETING_DOMAIN

type MeetingListGroupByDate = {
  date: string
  list: CreateMeetingResponse[]
}[]

interface BeforeMeetingHomeProps {
  onLogout: () => void
}

const BeforeMeetingHome: React.FC<BeforeMeetingHomeProps> = ({ onLogout }) => {
  const [accountInfo, setAccountInfo] = useState<any>()
  const [inMeeting, setInMeeting] = useState(false)
  const [isSSOLogin, setIsSSOLogin] = useState<boolean>(false)
  const isLogin = useRef<boolean>(false)
  const [loginLoading, setLoginLoading] = useState(true)
  const [previewController, setPreviewController] =
    useState<NEPreviewController>()
  const [roomService, setRoomService] = useState<NERoomService>()
  const [appName, setAppName] = useState<string>('')
  const [tipInfo, setTipInfo] = useState<{
    content: string
    title: string
    url: string
  }>()
  const [meetingListGroupByDate, setMeetingListGroupByDate] =
    useState<MeetingListGroupByDate>([])
  const [appLiveAvailable, setAppLiveAvailable] = useState<boolean>(false)
  const [globalConfig, setGlobalConfig] =
    useState<GetMeetingConfigResponse | null>(null)
  const videoPreviewRef = useRef<HTMLDivElement>(null)
  const [setting, setSetting] = useState<MeetingSetting | null>(null)
  const [openVideo, setOpenVideo] = useState<boolean>(false)
  const [openAudio, setOpenAudio] = useState<boolean>(false)
  const [openVideoSuccess, setOpenVideoSuccess] = useState<boolean>(false)
  const [cameraId, setCameraId] = useState<string>('')
  const [micId, setMicId] = useState<string>('')
  const [speakerId, setSpeakerId] = useState<string>('')
  const [submitLoading, setSubmitLoading] = useState(false)
  const [meetingNum, setMeetingNum] = useState<string>('')
  const passwordRef = React.useRef<string>('')
  const [logoutSheetVisible, setLogoutSheetVisible] = useState(false)
  const [logoutDialogVisible, setLogoutDialogVisible] = useState(false)
  let appKey = ''

  const { t, i18n: i18next } = useTranslation()

  const i18n = {
    appTitle: t('appTitle'),
    immediateMeeting: t('immediateMeeting'),
    joinMeeting: t('meetingJoin'),
    scheduleMeeting: t('scheduleMeeting'),
    scheduleMeetingSuccess: t('scheduleMeetingSuccess'),
    scheduleMeetingFail: t('scheduleMeetingFail'),
    editScheduleMeetingSuccess: t('editScheduleMeetingSuccess'),
    editScheduleMeetingFail: t('editScheduleMeetingFail'),
    cancelScheduleMeetingSuccess: t('cancelScheduleMeetingSuccess'),
    tokenExpired: t('tokenExpired'),
    cancelScheduleMeetingFail: t('cancelScheduleMeetingFail'),
    updateUserNicknameSuccess: t('updateUserNicknameSuccess'),
    updateUserNicknameFail: t('updateUserNicknameFail'),
    emptyScheduleMeeting: t('emptyScheduleMeeting'),
    meetingId: t('meetingId'),
    weekdays: [
      t('globalSunday'),
      t('globalMonday'),
      t('globalTuesday'),
      t('globalWednesday'),
      t('globalThursday'),
      t('globalFriday'),
      t('globalSaturday'),
    ],
    month: t('globalMonth'),
    historyMeeting: t('historyMeeting'),
    currentVersion: t('currentVersion'),
    personalMeetingNum: t('personalMeetingNum'),
    personalShortMeetingNum: t('personalShortMeetingNum'),
    internalUse: t('internalOnly'),
    feedback: t('feedback'),
    about: t('about'),
    logout: t('logout'),
    logoutConfirm: t('logoutConfirm'),
    today: t('today'),
    tomorrow: t('tomorrow'),
    join: t('join'),
    notStarted: t('notStarted'),
    inProgress: t('inProgress'),
    ended: t('ended'),
    copySuccess: t('copySuccess'),
    password: t('meetingPassword'),
    passwordPlaceholder: t('livePasswordTip'),
    passwordError: t('meetingWrongPassword'),
    hint: t('commonTitle'),
    gotIt: t('gotIt'),
    cancel: t('globalCancel'),
    confirm: t('globalSure'),
    networkError: t('networkAbnormalityAndCheck'),
    restoreMeetingTips: t('restoreMeetingTips'),
    restore: t('restore'),
    uploadLoadingText: t('uploadLoadingText'),
    youCanOpen: t('supportedMeetings'),
    mic: t('microphone'),
    camera: t('camera'),
    inputPlaceholder: t('meetingIDInputPlaceholder'),
  }

  const logoutActions: Action[] = [
    {
      text: t('logout'),
      danger: true,
      key: 'logout',
      onClick: async () => {
        setLogoutDialogVisible(true)
      },
    },
    {
      text: <div style={{ color: '#007AFF' }}>{i18n.cancel}</div>,
      key: 'cancel',
      onClick: () => {
        setLogoutSheetVisible(false)
      },
    },
  ]

  function init(cb) {
    const config = {
      appKey: appKey, //云信服务appkey
      meetingServerDomain: domain, //会议服务器地址，支持私有化部署
      locale: i18next.language, //语言
    }
    console.log('init config ', config)
    if (NEMeetingKit.actions.isInitialized) {
      cb()
      return
    }
    NEMeetingKit.actions.init(0, 0, config, cb) // （width，height）单位px 建议比例4:3
    NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
      if (status === NEMeetingStatus.MEETING_STATUS_IN_WAITING_ROOM) {
        // 到等候室
        // setFeedbackModalOpen(false)
      } else if (status === NEMeetingStatus.MEETING_STATUS_FAILED) {
        setInMeeting(false)
      }
    })
    NEMeetingKit.actions.on('roomEnded', (reason: any) => {
      setInMeeting(false)
      setTimeout(() => {
        window.location.reload()
      })
    })
  }

  function getMeetingList() {
    NEMeetingKit.actions.neMeeting
      ?.getMeetingList({
        startTime: dayjs().startOf('day').valueOf(),
        endTime: dayjs().add(14, 'day').endOf('day').valueOf(),
      })
      .then((data) => {
        const groupedData = data.reduce(
          (acc: Record<string, CreateMeetingResponse[]>, obj) => {
            const key = dayjs(obj.startTime).startOf('day').valueOf()
            if (!acc[key]) {
              acc[key] = []
            }
            acc[key].push(obj)
            return acc
          },
          {}
        )
        const meetingListGroupByDate: MeetingListGroupByDate = []
        Object.keys(groupedData).forEach((key) => {
          meetingListGroupByDate.push({
            date: key,
            list: groupedData[key],
          })
        })
        setMeetingListGroupByDate(meetingListGroupByDate)
      })
      .catch((e: any) => {
        // 用户被注销或者删除
        if (e.code === 404 || e.code === 401) {
          Toast.warning('tokenExpired')
          setTimeout(() => {
            logout()
          }, 1000)
        }
      })
  }
  // 登录
  function login(account, token) {
    setLoginLoading(true)
    init((e) => {
      if (!e) {
        const previewController = NEMeetingKit.actions.neMeeting
          ?.previewController as NEPreviewController
        setPreviewController(previewController)
        const roomService = NEMeetingKit.actions.neMeeting
          ?.roomService as NERoomService
        setRoomService(roomService)
        NEMeetingKit.actions.login(
          {
            // 登陆
            accountId: account,
            accountToken: token,
          },
          function (e: any) {
            if (!e) {
              isLogin.current = true
              setLoginLoading(false)
              setAccountInfo({
                //@ts-ignore
                ...NEMeetingKit.actions.accountInfo,
                account: account,
              })
              getMeetingList()

              NEMeetingKit.actions.neMeeting?.eventEmitter.on(
                EventType.ReceiveScheduledMeetingUpdate,
                (res) => {
                  console.log('收到房间状态变更', res)
                  // 账号受到限制
                  if (res.data?.type === 200) {
                    Toast.warning('tokenExpired', 3000)
                    setTimeout(() => {
                      logout()
                    }, 1000)
                  } else {
                    getMeetingList()
                  }
                }
              )

              NEMeetingKit.actions.neMeeting?.eventEmitter.on(
                EventType.ReceiveAccountInfoUpdate,
                (res) => {
                  console.log('收到账号信息变更', res)
                  setAccountInfo((prev) => {
                    return {
                      ...prev,
                      ...res.meetingAccountInfo,
                    }
                  })
                }
              )

              NEMeetingKit.actions.neMeeting?.getAppInfo().then((res) => {
                console.log('getAppInfo', res)
                setAppName(res.appName)
              })
              NEMeetingKit.actions.neMeeting?.getAppTips().then((res) => {
                setTipInfo(res.tips[0])
              })
              NEMeetingKit.actions.neMeeting?.getAppConfig().then((res) => {
                console.log('getAppConfig', res)
                setAppLiveAvailable(!!res.appConfig?.APP_ROOM_RESOURCE?.live)
              })
              const notFirstLogin = sessionStorage.getItem(NOT_FIRST_LOGIN)
              if (!notFirstLogin) {
                window.ipcRenderer?.send('isStartByUrl')
                sessionStorage.setItem(NOT_FIRST_LOGIN, 'true')
              }
              const currentMeetingStr = localStorage.getItem(
                'ne-meeting-current-info'
              )
              // 异常退出恢复会议
              if (currentMeetingStr) {
                const currentMeeting = JSON.parse(currentMeetingStr)
                // 15分钟内恢复会议
                if (currentMeeting.time > Date.now() - 1000 * 60 * 15) {
                  Modal.confirm({
                    title: 'hint',
                    content: 'restoreMeetingTips',
                    okText: 'restore',
                    onCancel: () => {
                      localStorage.removeItem('ne-meeting-current-info')
                    },
                    onOk: () => {
                      try {
                        const currentMeeting = JSON.parse(currentMeetingStr)
                        currentMeeting.joinType = 'join'
                        window.ipcRenderer?.send(
                          IPCEvent.enterRoom,
                          currentMeeting
                        )
                      } catch {}
                      localStorage.removeItem('ne-meeting-current-info')
                    },
                  })
                } else {
                  localStorage.removeItem('ne-meeting-current-info')
                }
              }
              NEMeetingKit.actions.neMeeting?.getGlobalConfig().then((res) => {
                setGlobalConfig(res)
              })
            } else {
              setLoginLoading(false)
              console.error('login fail appKey ', e, {
                // 登陆
                accountId: account,
                accountToken: token,
              })
              isLogin.current = false
              // 非网络错误才离开
              if (e.code !== 'ERR_NETWORK') {
                logout()
              }
            }
          }
        )
      }
    })
  }
  //退出登录
  function logout() {
    onLogout()
    NEMeetingKit?.actions?.destroy()
    isLogin.current = false
  }

  function getDeviceList() {
    if (previewController) {
      //@ts-ignore
      previewController.enumCameraDevices().then(({ data }) => {
        if (data.length > 0) {
          let deviceId = ''
          if (
            data.find(
              (item) => item.deviceId === setting?.videoSetting.deviceId
            )
          ) {
            deviceId = setting?.videoSetting.deviceId || data[0].deviceId
          } else {
            deviceId = data[0].deviceId
          }
          setCameraId(deviceId)
          const device = data.find((item) => item.deviceId === deviceId)
          previewController?.switchDevice({
            type: 'camera',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
      //@ts-ignore
      previewController.enumRecordDevices().then(({ data }) => {
        if (data.length > 0) {
          let deviceId = ''
          if (
            data.find(
              (item) => item.deviceId === setting?.audioSetting.recordDeviceId
            )
          ) {
            deviceId = setting?.audioSetting.recordDeviceId || data[0].deviceId
          } else {
            deviceId = data[0].deviceId
          }
          setMicId(deviceId)
          const device = data.find((item) => item.deviceId === deviceId)
          previewController?.switchDevice({
            type: 'microphone',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
      //@ts-ignore
      previewController.enumPlayoutDevices().then(({ data }) => {
        if (data.length > 0) {
          let deviceId = ''
          if (
            data.find(
              (item) => item.deviceId === setting?.audioSetting.playoutDeviceId
            )
          ) {
            deviceId = setting?.audioSetting.playoutDeviceId || data[0].deviceId
          } else {
            deviceId = data[0].deviceId
          }
          setSpeakerId(deviceId)
          const device = data.find((item) => item.deviceId === deviceId)
          previewController?.switchDevice({
            type: 'speaker',
            deviceId: getDefaultDeviceId(deviceId),
          })
        }
      })
    }
  }

  function onSettingChange(setting: MeetingSetting) {
    setSetting(setting)
    localStorage.setItem('ne-meeting-setting', JSON.stringify(setting))
  }

  function onHandleSettingChange({
    openAudio,
    openVideo,
    speakerId,
    micId,
    cameraId,
  }: {
    openAudio: boolean
    openVideo: boolean
    speakerId: string
    micId: string
    cameraId: string
  }) {
    setting &&
      onSettingChange &&
      onSettingChange({
        ...setting,
        normalSetting: {
          ...setting.normalSetting,
          openAudio,
          openVideo,
        },
        audioSetting: {
          ...setting.audioSetting,
          playoutDeviceId: speakerId,
          recordDeviceId: micId,
        },
        videoSetting: {
          ...setting.videoSetting,
          deviceId: cameraId,
        },
      })
  }

  async function joinMeeting(options: JoinOptions) {
    setSubmitLoading(true)
    await NEMeetingKit.actions.neMeeting
      ?.getMeetingInfoByFetch(options.meetingNum)
      .catch((e) => {
        console.error('join failed', options.meetingNum, e)
        // 非密码错误
        if (e?.code != 1020) {
          setSubmitLoading(false)
          Toast.fail(e.message || e.msg || e.code)
          throw e
        }
      })
    const storeNicknameStr = localStorage.getItem(
      'ne-meeting-nickname-' + accountInfo?.account
    )
    if (storeNicknameStr) {
      const storeNickname = JSON.parse(storeNicknameStr)
      if (storeNickname[options.meetingNum]) {
        options.nickName = storeNickname[options.meetingNum]
      } else {
        localStorage.removeItem('ne-meeting-nickname-' + accountInfo?.account)
      }
    }
    function fetchJoin(options: JoinOptions): Promise<void> {
      return new Promise((resolve, reject) => {
        NEMeetingKit.actions.join(
          {
            ...options,
            showCloudRecordingUI: true,
            showMeetingRemainingTip: true,
            env: 'web',
            watermarkConfig: {
              name: accountInfo.nickname,
            },
            moreBarList: [{ id: 29 }],
          },
          function (e: any) {
            if (e) {
              reject(e)
            }
            resolve()
          }
        )
      })
    }

    let modal: any

    return fetchJoin(options)
      .then(() => {
        setInMeeting(true)
        setMeetingNum('')
      })
      .catch((e) => {
        const InputComponent = (inputValue) => {
          return (
            <Input
              placeholder={i18n.passwordPlaceholder}
              value={inputValue}
              maxLength={6}
              allowClear
              onChange={(event) => {
                passwordRef.current = event.target.value.replace(/[^0-9]/g, '')
                modal.update({
                  content: <>{InputComponent(passwordRef.current)}</>,
                  okButtonProps: {
                    disabled: !passwordRef.current,
                    style: !passwordRef.current
                      ? { color: 'rgba(22, 119, 255, 0.5)' }
                      : {},
                  },
                })
              }}
            />
          )
        }
        if (e.code === 1020) {
          passwordRef.current = ''
          modal = Modal.confirm({
            title: i18n.password,
            content: <>{InputComponent('')}</>,
            okButtonProps: {
              disabled: true,
              style: { color: 'rgba(22, 119, 255, 0.5)' },
            },
            onOk: async () => {
              try {
                await fetchJoin({
                  ...options,
                  password: passwordRef.current,
                })
                setInMeeting(true)
              } catch (e: any) {
                if (e.code === 1020) {
                  modal.update({
                    content: (
                      <>
                        {InputComponent(passwordRef.current)}
                        <div
                          style={{
                            color: '#fe3b30',
                            textAlign: 'left',
                            margin: '5px 0px -10px 0px',
                          }}
                        >
                          {i18n.passwordError}
                        </div>
                      </>
                    ),
                  })
                } else if (e.code === 3102) {
                  modal.destroy()
                }
                throw e
              }
            },
          })
        } else {
          throw e
        }
      })
      .finally(() => {
        setSubmitLoading(false)
      })
  }
  // 加入会议
  function onJoinMeeting() {
    joinMeeting({
      meetingNum: meetingNum.replace(/-/g, '').replace(/\s/g, ''),
      nickName: accountInfo?.nickname,
      video: openVideo ? 1 : 2,
      audio: openAudio ? 1 : 2,
      avatar: accountInfo?.avatar,
      showSpeaker: setting?.normalSetting.showSpeakerList,
      enableUnmuteBySpace: setting?.audioSetting.enableUnmuteBySpace,
      enableFixedToolbar: setting?.normalSetting.showToolbar,
      enableVideoMirror: setting?.videoSetting.enableVideoMirroring,
      showDurationTime: setting?.normalSetting.showDurationTime,
    })
  }

  // 处理邀请链接url
  function handleInvitationUrl(url: string) {
    let meetingNum = ''
    const query = qs.parse(url.split('?')[1]?.split('#/')[0])
    meetingNum = query.meetingId as string
    if (meetingNum) {
      setMeetingNum(meetingNum)
      delete query.meetingId
      history.replaceState(
        {},
        '',
        qs.stringify(query, { addQueryPrefix: true })
      )
    }
  }

  useEffect(() => {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO)
    if (userString) {
      const user = JSON.parse(userString)
      if (user.userUuid && user.userToken && (user.appKey || user.appId)) {
        appKey = user.appKey || user.appId
        setIsSSOLogin(user.loginType === 'SSO')
        setTimeout(() => {
          login(user.userUuid, user.userToken)
        }, 100)
      } else {
        logout()
      }
    } else {
      logout()
    }
    const setting = localStorage.getItem('ne-meeting-setting')
    if (setting) {
      try {
        setSetting(JSON.parse(setting) as MeetingSetting)
      } catch (error) {}
    }
  }, [inMeeting])

  useEffect(() => {
    if (previewController && videoPreviewRef.current && openVideo) {
      previewController.setupLocalVideoCanvas(videoPreviewRef.current)
      const timer = setTimeout(() => {
        videoPreviewRef.current &&
          previewController
            .startPreview(videoPreviewRef.current)
            .then(() => {
              setOpenVideoSuccess(true)
            })
            .catch((e: any) => {
              setOpenVideoSuccess(false)
              setOpenVideo(false)
              if (e?.msg || errorCodeMap[e?.code]) {
                Toast.fail(e?.msg || t(errorCodeMap[e?.code]))
              } else if (
                e.data?.message &&
                (e.data?.message?.includes('Permission denied') ||
                  e.data?.name?.includes('NotAllowedError'))
              ) {
                //@ts-ignore
                Toast.fail(t(errorCodeMap['10212']))
              }
            })
      }, 500)

      return () => {
        clearTimeout(timer)
        previewController.stopPreview()
      }
    }

    if (!openVideo) {
      setOpenVideoSuccess(false)
    }
  }, [openVideo, previewController])

  useEffect(() => {
    if (setting) {
      setOpenAudio(setting.normalSetting.openAudio)
      setOpenVideo(setting.normalSetting.openVideo)
    }
    getDeviceList()
    navigator.mediaDevices.addEventListener('devicechange', getDeviceList)
    return () => {
      navigator.mediaDevices.removeEventListener('devicechange', getDeviceList)
    }
  }, [
    previewController,
    setting?.normalSetting.openVideo,
    setting?.normalSetting.openAudio,
  ])

  useEffect(() => {
    if (location.href) {
      handleInvitationUrl(location.href)
    }
  }, [])

  return (
    <>
      <div
        id="ne-web-meeting"
        style={{
          width: '100%',
          height: '100%',
          display: inMeeting ? 'block' : 'none',
        }}
      ></div>
      {!inMeeting && (
        <div className="ne-meeting-app-h5 before-meeting-home-container">
          <div className="before-meeting-home-header">
            <div
              className="nemeeting-header-avatar"
              onClick={() => {
                setLogoutSheetVisible(true)
              }}
            >
              <UserAvatar
                nickname={accountInfo?.nickname}
                avatar={accountInfo?.avatar}
                size={36}
              ></UserAvatar>
            </div>
            <div className="nemeeting-header-item-title">
              {i18n.joinMeeting}
            </div>
          </div>
          <div className="before-meeting-home-input">
            <Input
              placeholder={i18n.inputPlaceholder}
              value={meetingNum}
              allowClear
              onChange={(e) => {
                if (/^[0-9-]*$/.test(e.target.value)) {
                  setMeetingNum(e.target.value)
                }
              }}
              style={{
                backgroundColor: '#F2F3F5',
                height: 50,
                border: 'none',
                borderRadius: 16,
                fontSize: 16,
                // paddingLeft: '40%',
              }}
            />
          </div>
          <div className="before-meeting-home-content">
            <div
              ref={videoPreviewRef}
              className={`video-preview ${
                setting?.videoSetting.enableVideoMirroring
                  ? 'nemeeting-video-mirror'
                  : ''
              }`}
              style={{
                backgroundColor: openVideoSuccess ? '#000' : '#f4f6fc',
              }}
            >
              <UserAvatar
                style={{
                  display: openVideo ? 'none' : 'block',
                }}
                className="user-avatar"
                nickname={accountInfo?.nickname || ''}
                size={48}
                avatar={accountInfo?.avatar}
              />
            </div>
            <div className="before-meeting-home-buttons">
              <div
                className="audio-button"
                onClick={() => {
                  setOpenAudio(!openAudio)
                  onHandleSettingChange({
                    openAudio: !openAudio,
                    openVideo,
                    speakerId,
                    micId,
                    cameraId,
                  })
                }}
              >
                <svg
                  className={classNames('icon iconfont', {
                    'icon-red': !openAudio,
                  })}
                  aria-hidden="true"
                >
                  <use
                    xlinkHref={`${
                      openAudio
                        ? '#iconyx-tv-voice-onx'
                        : '#iconyx-tv-voice-offx'
                    }`}
                  ></use>
                </svg>
                <span className="device-list-title">{i18n.mic}</span>
              </div>
              <div
                className="video-button"
                onClick={() => {
                  setOpenVideo(!openVideo)
                  onHandleSettingChange({
                    openAudio,
                    openVideo: !openVideo,
                    speakerId,
                    micId,
                    cameraId,
                  })
                }}
              >
                <svg
                  className={classNames('icon iconfont', {
                    'icon-red': !openVideo,
                  })}
                  aria-hidden="true"
                >
                  <use
                    xlinkHref={`${
                      openVideo
                        ? '#iconyx-tv-video-onx'
                        : '#iconyx-tv-video-offx'
                    }`}
                  ></use>
                </svg>
                <span className="device-list-title">{i18n.camera}</span>
              </div>
            </div>
          </div>
          <div className="before-meeting-home-foot">
            <Button
              type="primary"
              className="join-meeting-button"
              onClick={onJoinMeeting}
              disabled={!meetingNum}
              loading={submitLoading}
            >
              {i18n.joinMeeting}
            </Button>
          </div>
          <ActionSheet
            visible={logoutSheetVisible}
            actions={logoutActions}
            onClose={() => setLogoutSheetVisible(false)}
          />
          <Dialog
            visible={logoutDialogVisible}
            width={305}
            confirmText={i18n.confirm}
            cancelText={i18n.cancel}
            onConfirm={() => {
              logout()
            }}
            onCancel={() => {
              setLogoutDialogVisible(false)
            }}
          >
            <div className="logout-text">{i18n.logoutConfirm}</div>
          </Dialog>
        </div>
      )}
    </>
  )
}
export default BeforeMeetingHome
