/**
 * 收听语言 hooks
 */
import React, { useMemo } from 'react'
import { useTranslation } from 'react-i18next'
import { MAJOR_AUDIO } from '../config'
import {
  InterpretationRes,
  NEMeetingInterpretationSettings,
  NEMember,
} from '../types/type'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType } from '../types'
import NEMeetingService from '../services/NEMeeting'
import useWatch from './useWatch'
import { useUpdateEffect } from 'ahooks'

interface InterpreterLang extends UseInterpreterLangProps {
  listeningOptions: { label: string; value: string; disabled?: boolean }[]
  onPlayoutVolumeChange: (value: number) => void
  onMuteChange: (checked: boolean, majorVolume: number) => void
  speakerOptions: { label: string; value: string }[]
  handleListeningLanguageChange: (
    language: string,
    preLanguage?: string
  ) => void
  majorVolume: number
  handleListenMajor: () => void
}
interface UseInterpreterLangProps {
  languageOptions: { value: string; label: string }[]
  languageMap: Record<string, string>
}
export function useDefaultLanguageOptions(): UseInterpreterLangProps {
  const { t } = useTranslation()
  const languageOptions = useMemo(() => {
    return [
      { value: 'zh', label: t('langChinese') },
      { value: 'en', label: t('langEnglish') },
      { value: 'jp', label: t('langJapanese') },
      { value: 'kr', label: t('langKorean') },
      { value: 'fr', label: t('langFrench') },
      { value: 'de', label: t('langGerman') },
      { value: 'es', label: t('langSpanish') },
      { value: 'ru', label: t('langRussian') },
      { value: 'pt', label: t('langPortuguese') },
      { value: 'it', label: t('langItalian') },
      { value: 'tr', label: t('langTurkish') },
      { value: 'vi', label: t('langVietnamese') },
      { value: 'th', label: t('langThai') },
      { value: 'id', label: t('langIndonesian') },
      { value: 'ms', label: t('langMalay') },
      { value: 'ar', label: t('langArabic') },
      { value: 'hi', label: t('langHindi') },
    ]
  }, [t])

  const languageMap = useMemo(() => {
    return {
      zh: t('langChinese'),
      en: t('langEnglish'),
      jp: t('langJapanese'),
      kr: t('langKorean'),
      fr: t('langFrench'),
      de: t('langGerman'),
      es: t('langSpanish'),
      ru: t('langRussian'),
      pt: t('langPortuguese'),
      it: t('langItalian'),
      tr: t('langTurkish'),
      vi: t('langVietnamese'),
      th: t('langThai'),
      id: t('langIndonesian'),
      ms: t('langMalay'),
      ar: t('langArabic'),
      hi: t('langHindi'),
      $majorAudio: t('interpMajorAudio'),
    }
  }, [t])

  return {
    languageOptions,
    languageMap,
  }
}

export function useInterpreterLang(data: {
  interpretation?: InterpretationRes
  interpretationSetting?: NEMeetingInterpretationSettings
  neMeeting?: NEMeetingService
  defaultMajorVolume: number
  isInterpreter?: boolean
  myUuid: string
  defaultListeningVolume: number
}): InterpreterLang {
  const {
    interpretation,
    interpretationSetting,
    neMeeting,
    defaultMajorVolume,
    isInterpreter,
    myUuid,
    defaultListeningVolume,
  } = data
  const { languageOptions, languageMap } = useDefaultLanguageOptions()
  const { t } = useTranslation()
  const { dispatch } = useGlobalContext()
  const { dispatch: meetingInfoDispatch, memberList } = useMeetingInfoContext()
  const [majorVolume, setMajorVolume] =
    React.useState<number>(defaultMajorVolume)
  const interpretationSettingRef = React.useRef(interpretationSetting)
  const memberListRef = React.useRef<NEMember[]>(memberList)

  memberListRef.current = memberList
  interpretationSettingRef.current = interpretationSetting

  const speakerOptions = useMemo(() => {
    if (!isInterpreter) {
      return []
    }

    const myLangList = interpretation?.interpreters[myUuid]
    let tmpLangList: string[] = []

    if (myLangList) {
      tmpLangList = [...myLangList]
    }

    tmpLangList?.push(MAJOR_AUDIO)
    return (
      tmpLangList?.map((lang) => {
        if (lang === MAJOR_AUDIO) {
          return {
            label: t('interpMajorChannel'),
            value: lang,
          }
        } else {
          return {
            label: languageMap[lang] || lang,
            value: lang,
          }
        }
      }) || []
    )
  }, [myUuid, interpretation, t, isInterpreter, languageMap])

  const listeningOptions = useMemo(() => {
    const interpreters = interpretation?.interpreters

    if (interpreters) {
      const keys = Object.keys(interpretation.interpreters)

      const languagesSet = new Set<string>()

      const langMap: Record<string, string[]> = {}

      // 添加原声
      languagesSet.add(MAJOR_AUDIO)
      keys.forEach((key) => {
        const langs = interpreters[key]

        if (langs.length > 0) {
          if (langs.length >= 1) {
            languagesSet.add(langs[0])
            if (langMap[langs[0]]) {
              langMap[langs[0]].push(key)
            } else {
              langMap[langs[0]] = [key]
            }
          }

          if (langs.length >= 2) {
            languagesSet.add(langs[1])
            if (langMap[langs[1]]) {
              langMap[langs[1]].push(key)
            } else {
              langMap[langs[1]] = [key]
            }
          }
        }
      })
      // 把set转换为数组
      let languages = Array.from(languagesSet)

      // 如果当前语言的译员不在会中则需要排除
      languages = languages.filter((lang) => {
        if (
          lang === MAJOR_AUDIO ||
          lang === interpretationSetting?.listenLanguage
        ) {
          return true
        }

        const interpreters = langMap[lang]

        if (interpreters && interpreters.length > 0) {
          return interpreters.some((interpreter) => {
            if (interpreter === myUuid) {
              return true
            } else {
              return memberListRef.current.find(
                (member) => member.uuid === interpreter
              )
            }
          })
        } else {
          return false
        }
      })

      return languages.map((language) => ({
        label: languageMap[language] || language,
        value: language,
        disabled:
          interpretation?.interpreters &&
          language == interpretationSetting?.speakerLanguage &&
          language !== MAJOR_AUDIO,
      }))
    } else {
      return [
        {
          label: languageMap[MAJOR_AUDIO],
          value: MAJOR_AUDIO,
        },
      ]
    }
  }, [
    interpretation?.interpreters,
    languageMap,
    myUuid,
    memberList.length,
    interpretationSetting?.speakerLanguage,
    interpretationSetting?.listenLanguage,
  ])

  const onPlayoutVolumeChange = (value: number) => {
    if (interpretationSetting?.muted) return
    dispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        interpretationSetting: {
          listenLanguage: interpretationSetting?.listenLanguage || MAJOR_AUDIO,
          majorVolume: value,
        },
      },
    })
    setMajorVolume(value)
    neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume('', value)
  }

  const onMuteChange = (checked: boolean, majorVolume?: number) => {
    if (checked) {
      neMeeting?.muteMajorAudio(true)
    } else {
      neMeeting?.muteMajorAudio(false, majorVolume)
    }

    dispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        interpretationSetting: {
          listenLanguage: interpretationSetting?.listenLanguage || MAJOR_AUDIO,
          muted: checked,
        },
      },
    })
  }

  useUpdateEffect(() => {
    // 如果切换到非译员需要重置翻译语言为主频道
    if (!isInterpreter) {
      dispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          interpretationSetting: {
            listenLanguage:
              interpretationSettingRef.current?.listenLanguage || MAJOR_AUDIO,
            speakerLanguage: MAJOR_AUDIO,
          },
        },
      })
    }
  }, [isInterpreter, dispatch])
  const handleListeningLanguageChange = async (
    language: string,
    preChannelName?: string
  ) => {
    const preListeningLang =
      interpretationSetting?.listenLanguage || MAJOR_AUDIO
    const dispatchOptions = {
      ...interpretationSetting,
      listenLanguage: language,
    }

    // 如果切到原生需要把同时监听原声去除
    if (language === MAJOR_AUDIO) {
      dispatchOptions.isListenMajor = false
    }

    dispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        interpretationSetting: dispatchOptions,
      },
    })

    try {
      // 切换收听频道需要离开上一个收听频道
      if (preListeningLang !== MAJOR_AUDIO) {
        // 如果是译员，且是配置传译频道则不需要离开
        const channelName = preChannelName
          ? preChannelName
          : interpretation?.channelNames[preListeningLang]

        if (channelName) {
          if (
            isInterpreter &&
            speakerOptions.findIndex(
              (item) => item.value === preListeningLang
            ) > -1
          ) {
            // 需要靜音
            neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
              channelName,
              0
            )
            await neMeeting?.rtcController?.enableAudioVolumeIndication(
              false,
              500,
              true,
              channelName
            )
          } else {
            await neMeeting?.leaveRtcChannel(channelName).catch((e) => {
              console.log('leaveRtcChannel error:', e)
            })
            console.warn('离开频道', channelName)
          }
        }
      } else {
        console.warn('原声静音')
        // 如果是从主频道切换到其他，不要离开主频道。只需要静音主频道
        await neMeeting?.muteMajorAudio(true)
      }

      // 加入切换的频道
      if (language !== MAJOR_AUDIO) {
        if (!interpretationSetting?.isListenMajor) {
          await neMeeting?.muteMajorAudio(true)
        }

        const channelName = interpretation?.channelNames[language]

        if (!channelName) {
          return
        }

        if (
          isInterpreter &&
          speakerOptions.findIndex((item) => item.value === language) > -1
        ) {
          neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
            channelName,
            defaultListeningVolume
          )
          await neMeeting?.rtcController?.enableAudioVolumeIndication(
            true,
            500,
            true,
            channelName
          )
          return
        }

        await neMeeting?.joinRtcChannel(channelName).catch((e) => {
          console.log('joinRtcChannel error:', e)
        })
        neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
          channelName,
          defaultListeningVolume
        )
      } else {
        await neMeeting?.muteMajorAudio(false, majorVolume)
      }
    } catch (error) {
      console.error('handleListeningLanguageChange error:', error)
      dispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          interpretationSetting: {
            listenLanguage: preListeningLang,
          },
        },
      })
    }
  }

  const handleListenMajor = () => {
    onMuteChange(!!interpretationSetting?.isListenMajor, majorVolume)
    const muted = interpretationSetting?.isListenMajor
      ? interpretationSetting?.muted
      : false

    dispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        interpretationSetting: {
          isListenMajor: !interpretationSetting?.isListenMajor,
          muted,
        },
      },
    })
  }

  useWatch(interpretation, async (preInterpretation) => {
    if (!interpretation || !interpretation?.started) {
      return
    }

    // 如果更新后的收听频道不包含当前收听的，则需要切换到原声
    const listenLanguage = interpretationSetting?.listenLanguage

    if (listenLanguage && listenLanguage !== MAJOR_AUDIO) {
      const listenerChannelName = interpretation?.channelNames[listenLanguage]

      // 如果当前收听的频道不存在了则切换到原声
      if (!listenerChannelName) {
        const preChannelName = preInterpretation?.channelNames[listenLanguage]

        // 翻译语言被删除
        meetingInfoDispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            showLanguageRemovedInfo: {
              show: true,
              language: languageMap[listenLanguage] || listenLanguage,
            },
          },
        })
        await handleListeningLanguageChange(MAJOR_AUDIO, preChannelName)
      }
    }
  })

  return {
    languageOptions,
    languageMap,
    listeningOptions,
    onPlayoutVolumeChange,
    handleListenMajor,
    onMuteChange,
    speakerOptions,
    handleListeningLanguageChange,
    majorVolume,
  }
}
