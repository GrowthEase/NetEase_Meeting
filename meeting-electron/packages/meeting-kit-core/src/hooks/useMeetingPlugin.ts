import { NECustomSessionMessage } from 'neroom-types'
import { useCallback, useEffect, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, NEMeetingInfo } from '../types'
import { objectToQueryString } from '../utils'
import { openWindow } from '../utils/windowsProxy'

export type PluginInfo = {
  description: string
  homeUrl: string
  icon: {
    defaultIcon: string
    pcIcon: {
      icon_dark: string
      icon_light: string
    }
  }
  name: string
  pluginId: string
  type: number //0 官方插件；1 企业自建插件
  notifySenderAccid: string
}

function useMeetingPlugin(): {
  pluginList: PluginInfo[]
  onClickPlugin: (plugin: PluginInfo | string, isH5?: boolean) => void
} {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const [pluginList, setPluginList] = useState<PluginInfo[]>([])

  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const pluginListRef = useRef<PluginInfo[]>(pluginList)

  pluginListRef.current = pluginList

  const notificationMessagesRef = useRef<
    Array<
      NECustomSessionMessage & {
        unRead: boolean
        beNotified: boolean
        noShowInNotificationCenter: boolean
      }
    >
  >(meetingInfo.notificationMessages)

  notificationMessagesRef.current = meetingInfo.notificationMessages

  useEffect(() => {
    if (meetingInfo.meetingNum && meetingInfo.noWebApps !== true) {
      neMeeting?.getMeetingPluginList().then((res) => {
        if (res.pluginInfos) {
          setPluginList(res.pluginInfos)
        }
      })
    }
  }, [neMeeting, meetingInfo.meetingNum, meetingInfo.noWebApps])

  const onClickPlugin = useCallback(
    (value: PluginInfo | string, isH5?: boolean): PluginInfo | undefined => {
      let plugin
      let pluginUrlSearch = ''

      if (typeof value === 'string') {
        // 创建URL对象
        const urlObj = new URL(value)
        // 获取查询字符串参数
        const searchParams = new URLSearchParams(urlObj.search)

        pluginUrlSearch = urlObj.search
        pluginUrlSearch = pluginUrlSearch.replace('?', '')
        // 获取pluginId的值
        const pluginId = searchParams.get('pluginId')

        plugin = pluginListRef.current.find(
          (item) => item.pluginId === pluginId
        )
      } else {
        plugin = value
      }

      if (!plugin) {
        return
      }

      notificationMessagesRef.current.forEach((msg) => {
        if (msg.sessionId === plugin.notifySenderAccid) {
          msg.unRead = false
        }
      })

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          notificationMessages: [...notificationMessagesRef.current],
        },
      })

      // 如果是electron共享屏幕，则打开新窗口

      if (isH5) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            rightDrawerTabActiveKey: plugin.pluginId,
            pluginUrlSearch,
          },
        })
        return
      }

      if (
        window.isElectronNative &&
        meetingInfoRef.current.localMember.isSharingScreen
      ) {
        const url =
          '#/plugin?' +
          objectToQueryString({
            pluginId: plugin.pluginId,
          })
        const pluginWin = openWindow(plugin.pluginId, url)
        const pluginWinOpenData = {
          event: 'updateData',
          payload: {
            meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
            pluginId: plugin.pluginId,
            url: plugin.homeUrl,
            roomArchiveId: meetingInfoRef.current.roomArchiveId,
            isInMeeting: true,
            title: plugin.name,
          },
        }

        if (pluginWin?.firstOpen === false) {
          pluginWin.postMessage(pluginWinOpenData, pluginWin.origin)
        } else {
          pluginWin?.addEventListener('load', () => {
            pluginWin?.postMessage(pluginWinOpenData, pluginWin.origin)
          })
        }

        const messageListener = (e) => {
          const { event, payload } = e.data

          if (event === 'neMeeting' && neMeeting) {
            const { replyKey, fnKey, args } = payload

            neMeeting[fnKey]?.(...args)
              .then((res) => {
                pluginWin?.postMessage(
                  {
                    event: replyKey,
                    payload: {
                      result: res,
                      error: null,
                    },
                  },
                  pluginWin.origin
                )
              })
              .catch((error) => {
                pluginWin?.postMessage(
                  {
                    event: replyKey,
                    payload: {
                      error,
                    },
                  },
                  pluginWin.origin
                )
              })
          }
        }

        pluginWin?.removeEventListener('message', messageListener)
        pluginWin?.addEventListener('message', messageListener)

        return plugin
      }

      const rightDrawerTabs = meetingInfoRef.current.rightDrawerTabs

      const item = rightDrawerTabs.find((item) => item.key === plugin.pluginId)

      // 没有添加
      if (!item) {
        rightDrawerTabs.push({
          label: plugin.name,
          key: plugin.pluginId,
        })
      }

      if (item && rightDrawerTabs.length === 1) {
        // 只有一个，不处理这里
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            rightDrawerTabActiveKey: plugin.pluginId,
            pluginUrlSearch,
          },
        })
      } else {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            rightDrawerTabs: [...rightDrawerTabs],
            rightDrawerTabActiveKey: plugin.pluginId,
            pluginUrlSearch,
          },
        })
      }

      return
    },
    [dispatch, neMeeting]
  )

  return { pluginList, onClickPlugin }
}

export default useMeetingPlugin
