/**
 * 译员相关的hook
 */
import { useEffect, useMemo, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import useWatch from './useWatch'
import { ActionType, AttendeeOffType } from '../types'
import { getLocalStorageSetting } from '../utils'
import { MAJOR_AUDIO } from '../config'
import { useTranslation } from 'react-i18next'
import Modal from '../components/common/Modal'

export function useMyLangList(): {
  myLangList: string[]
  firstLanguage: string
  secondLanguage: string
} {
  const { meetingInfo } = useMeetingInfoContext()
  const myLangList = useMemo(() => {
    if (meetingInfo.isInterpreter) {
      return (
        meetingInfo.interpretation?.interpreters?.[
          meetingInfo.localMember.uuid
        ] || []
      )
    } else {
      return []
    }
  }, [
    meetingInfo.isInterpreter,
    meetingInfo.interpretation,
    meetingInfo.localMember.uuid,
  ])

  const firstLanguage = myLangList[0] || ''

  const secondLanguage = myLangList[1] || ''

  return {
    myLangList,
    firstLanguage,
    secondLanguage,
  }
}

export default function useInterpreter(data: {
  openMeetingWindow: (payload: {
    name: string
    url?: string
    postMessageData?: {
      event: string
      payload: Record<string, string | number | boolean>
    }
  }) => void
}) {
  const { openMeetingWindow } = data
  const {
    meetingInfo,
    dispatch: meetingInfoDispatch,
    memberList,
    inInvitingMemberList,
  } = useMeetingInfoContext()
  const { t } = useTranslation()
  const { neMeeting, dispatch, interpretationSetting } = useGlobalContext()
  const meetingInfoRef = useRef(meetingInfo)
  const interpretationSettingRef = useRef(interpretationSetting)

  const memberListRef = useRef(memberList)
  const inInvitingMemberListRef = useRef(inInvitingMemberList)

  memberListRef.current = memberList
  inInvitingMemberListRef.current = inInvitingMemberList
  interpretationSettingRef.current = interpretationSetting

  meetingInfoRef.current = meetingInfo
  const { myLangList } = useMyLangList()

  const langChannelList = useMemo(() => {
    if (myLangList.length === 0) {
      return []
    } else {
      return myLangList.map((lang) => {
        return meetingInfo.interpretation?.channelNames[lang] || ''
      })
    }
  }, [myLangList, meetingInfo.interpretation?.channelNames])

  function setMajorVolumeBySetting() {
    const setting = getLocalStorageSetting()
    const playouOutputtVolume = setting?.audioSetting.playouOutputtVolume
    const volume =
      playouOutputtVolume || playouOutputtVolume === 0
        ? playouOutputtVolume
        : 70

    neMeeting?.muteMajorAudio(false, volume)
  }

  useWatch<boolean | undefined>(
    meetingInfo.interpretation?.started,
    async (preIsStarted) => {
      // 当前被取消译员离开对应频道
      if (
        preIsStarted &&
        !meetingInfo.interpretation?.started &&
        meetingInfoRef.current.isInterpreter
      ) {
        setMajorVolumeBySetting()

        Promise.all(
          langChannelList.map((lang) => neMeeting?.leaveRtcChannel(lang))
        ).finally(async () => {
          // 如果角色变更为非译员，则需要重新pub主频道
          if (meetingInfoRef.current.localMember.isAudioOn) {
            await neMeeting?.enableAndPubAudio(true, '')
            setMajorVolumeBySetting()
          }
        })
      }
    }
  )

  useEffect(() => {
    if (!meetingInfo.interpretation?.started) {
      const interpretationSetting = interpretationSettingRef.current
      const interpretation = meetingInfoRef.current.interpretation

      // 非译员需要离开当前收听的频道
      if (
        !meetingInfoRef.current.isInterpreter &&
        interpretationSetting?.listenLanguage !== MAJOR_AUDIO
      ) {
        const channel =
          interpretation?.channelNames[
            interpretationSetting?.listenLanguage || ''
          ] || ''

        channel && neMeeting?.leaveRtcChannel(channel)
      }

      meetingInfoDispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          isInterpreter: false,
        },
      })
    }
  }, [meetingInfo.interpretation?.started, meetingInfoDispatch, neMeeting])

  useWatch<boolean | undefined>(meetingInfo.isInterpreter, async () => {
    // 如果成为译员 此时如果在共享音频需要停止
    if (
      meetingInfo.isInterpreter &&
      meetingInfo.startSystemAudioLoopbackCapture
    ) {
      meetingInfoDispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          startSystemAudioLoopbackCapture: false,
        },
      })
      // @ts-ignore
      neMeeting?.rtcController?.stopSystemAudioLoopbackCapture?.()
    }
  })
  function rejoinChannel(
    channel: string,
    isFirstLang: boolean,
    needPub = false
  ) {
    const modal = Modal.confirm({
      title: t('commonTitle'),
      width: 270,
      content: t('interpJoinChannelErrorMsg'),
      cancelText: t('globalCancel'),
      okText: t('interpReJoinChannel'),
      onOk: async () => {
        modal?.destroy()
        await neMeeting?.joinRtcChannel(channel)
        if (needPub) {
          await neMeeting?.enableAndPubAudio(false, '')
          await neMeeting?.enableAndPubAudio(true, channel)
          neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
            channel,
            0
          )
        }
      },
      onCancel: () => {
        if (isFirstLang) {
          dispatch?.({
            type: ActionType.UPDATE_GLOBAL_CONFIG,
            data: {
              interpretationSetting: {
                speakerLanguage: MAJOR_AUDIO,
              },
            },
          })
          neMeeting?.enableAndPubAudio(true, '')
        } else {
          dispatch?.({
            type: ActionType.UPDATE_GLOBAL_CONFIG,
            data: {
              interpretationSetting: {
                listenLanguage: MAJOR_AUDIO,
              },
            },
          })
        }
      },
    })
  }

  useWatch<string[]>(
    langChannelList,
    async (preLangChannelList) => {
      const localMember = meetingInfoRef.current.localMember
      const isInterpreter = meetingInfoRef.current.isInterpreter
      const interpretation = meetingInfoRef.current.interpretation
      const langList =
        interpretation?.interpreters?.[meetingInfo.localMember.uuid] || []

      const isHost =
        localMember.role === 'host' || localMember.role === 'cohost'
      const isUnMutedAudio =
        (meetingInfoRef.current.isUnMutedAudio &&
          meetingInfoRef.current.audioOff === AttendeeOffType.disable) ||
        isHost

      if (
        (preLangChannelList?.length === 0 && langChannelList.length === 0) ||
        interpretation?.started === false
      ) {
        return
      }

      if (!preLangChannelList || preLangChannelList.length === 0) {
        // 刚成为译员
        langChannelList.forEach(async (langChannel, index) => {
          await neMeeting?.joinRtcChannel(langChannel).catch(() => {
            rejoinChannel(langChannel, index === 0, true)
          })

          // 如果是翻译员并且开启了音频 则pub 传译语言
          if (
            index === 0 &&
            isInterpreter &&
            (localMember.isAudioOn || isUnMutedAudio)
          ) {
            // 关闭主频道声音
            await neMeeting?.enableAndPubAudio(false, '')
            await neMeeting?.enableAndPubAudio(true, langChannel)
            neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
              langChannel,
              0
            )
          }
        })
        if (langList?.length > 1) {
          dispatch?.({
            type: ActionType.UPDATE_GLOBAL_CONFIG,
            data: {
              interpretationSetting: {
                listenLanguage: MAJOR_AUDIO,
                speakerLanguage: langList[0],
              },
            },
          })
          if (window.isElectronNative) {
            // 这里需要调用打开窗口，否则等待另外地方监听到变化打开数据更新会存在遗漏情况
            openMeetingWindow({
              name: 'interpreterWindow',
              postMessageData: {
                event: 'updateData',
                payload: {
                  inMeeting: true,
                  memberList: JSON.parse(JSON.stringify(memberListRef.current)),
                  inInvitingMemberList: inInvitingMemberListRef.current
                    ? JSON.parse(
                        JSON.stringify(inInvitingMemberListRef.current)
                      )
                    : undefined,
                  meetingInfo: JSON.parse(
                    JSON.stringify(meetingInfoRef.current)
                  ),
                  interpretationSetting: JSON.parse(
                    JSON.stringify({
                      listenLanguage: MAJOR_AUDIO,
                      speakerLanguage: langList[0],
                    })
                  ),
                },
              },
            })
          }
        }
      } else {
        if (langChannelList && langChannelList.length > 1) {
          // 如果是互换，不需要重新加入频道维持原状
          if (
            (langChannelList[0] === preLangChannelList[1] &&
              langChannelList[1] === preLangChannelList[0]) ||
            (langChannelList[0] === preLangChannelList[0] &&
              langChannelList[1] === preLangChannelList[1])
          ) {
            return
          }

          if (
            preLangChannelList[0] &&
            !langChannelList.includes(preLangChannelList[0])
          ) {
            await neMeeting?.leaveRtcChannel(preLangChannelList[0])
          }

          if (
            preLangChannelList[1] &&
            !langChannelList.includes(preLangChannelList[1])
          ) {
            await neMeeting?.leaveRtcChannel(preLangChannelList[1])
          }

          // 第一语言有变更
          if (
            langChannelList[0] &&
            !preLangChannelList.includes(langChannelList[0])
          ) {
            await neMeeting?.joinRtcChannel(langChannelList[0]).catch(() => {
              rejoinChannel(langChannelList[0], true)
            })
          }

          // 第二语言有变更
          if (
            langChannelList[1] &&
            !preLangChannelList.includes(langChannelList[1])
          ) {
            await neMeeting?.joinRtcChannel(langChannelList[1]).catch(() => {
              rejoinChannel(langChannelList[1], false)
            })
          }

          setMajorVolumeBySetting()
          const speakerLanguage =
            interpretationSettingRef.current?.speakerLanguage

          if (speakerLanguage && speakerLanguage !== MAJOR_AUDIO) {
            try {
              await neMeeting?.enableAndPubAudio(false, speakerLanguage)
            } catch (error) {
              console.error('开启切换传译语言失败', error)
            }

            try {
              await neMeeting?.enableAndPubAudio(true, '')
            } catch (error) {
              console.error('开启切换传译语言失败 main', error)
            }
          }

          dispatch?.({
            type: ActionType.UPDATE_GLOBAL_CONFIG,
            data: {
              interpretationSetting: {
                listenLanguage: MAJOR_AUDIO,
                speakerLanguage: MAJOR_AUDIO,
              },
            },
          })
        } else {
          // 如果最新的列表为空表示 我不是翻译员了 离开之前的频道
          Promise.all(
            preLangChannelList.map((channel) =>
              neMeeting?.leaveRtcChannel(channel)
            )
          ).finally(async () => {
            // 如果角色变更为非译员，则需要重新pub主频道
            if (meetingInfoRef.current.localMember.isAudioOn) {
              await neMeeting?.enableAndPubAudio(true, '')
              setMajorVolumeBySetting()
            }
          })
        }
      }
    },
    { immediate: true }
  )
}
