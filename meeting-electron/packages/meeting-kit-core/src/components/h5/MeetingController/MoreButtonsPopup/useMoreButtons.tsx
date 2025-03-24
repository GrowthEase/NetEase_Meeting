import { Badge } from 'antd-mobile/es'
import { useTranslation } from 'react-i18next'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import { ActionType, Role } from '../../../../types'
import useMeetingPlugin from '../../../../hooks/useMeetingPlugin'
import React, { useMemo } from 'react'
import { onInjectedMenuItemClick } from '../../../../utils'

export type MoreButtonItem = {
  id: number | string
  key: string
  icon: React.ReactNode
  label: string
  onClick: () => void
  hidden?: boolean
}

type onButtonClickFn = (key: string) => void

function useMoreButtons(onButtonClick?: onButtonClickFn): MoreButtonItem[] {
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { moreBarList, globalConfig, eventEmitter, noCaptions } =
    useGlobalContext()
  const { pluginList, onClickPlugin } = useMeetingPlugin()

  const notificationUnReadCount = meetingInfo.notificationMessages.filter(
    (msg) => msg.unRead
  ).length

  const moreButtons: MoreButtonItem[] = []

  const isHostOrCoHost = useMemo(() => {
    const role = meetingInfo.localMember.role

    return role === Role.host || role === Role.coHost
  }, [meetingInfo.localMember.role])

  // 通知按钮
  const notificationBtn = {
    id: 29,
    key: 'notification',
    icon: (
      <Badge
        content={
          notificationUnReadCount > 0
            ? notificationUnReadCount > 99
              ? '99+'
              : notificationUnReadCount
            : null
        }
      >
        <svg className="icon iconfont icon-image" aria-hidden="true">
          <use xlinkHref="#icontongzhi-mianxing"></use>
        </svg>
      </Badge>
    ),
    label: t('notification'),
    onClick: () => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          notificationMessages: meetingInfo.notificationMessages.map((msg) => {
            return { ...msg, unRead: false }
          }),
        },
      })
      onButtonClick?.('notification')
    },
    hidden: meetingInfo.noNotifyCenter === true,
  }

  // 同声传译
  const interpretationBtn = {
    id: 31,
    key: 'interpretation',
    icon: (
      <svg className="icon iconfont icon-image" aria-hidden="true">
        <use xlinkHref="#icontongshengchuanyi-mianxing"></use>
      </svg>
    ),
    label: t('interpretation'),
    onClick: async () => {
      onButtonClick?.('interpretation')
    },
    hidden: !(
      globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation?.enable &&
      (isHostOrCoHost || meetingInfo.interpretation?.started)
    ),
  }

  const captionBtn = {
    id: 32,
    key: 'caption',
    icon: (
      <svg className="icon iconfont icon-image" aria-hidden="true">
        <use xlinkHref="#iconkaiqizimu-mianxing"></use>
      </svg>
    ),
    label: meetingInfo.isCaptionsEnabled
      ? t('transcriptionDisableCaption')
      : t('transcriptionEnableCaption'),
    onClick: async () => {
      onButtonClick?.('caption')
    },
    hidden: !globalConfig?.appConfig.APP_ROOM_RESOURCE.caption || noCaptions,
  }

  moreBarList?.forEach((item) => {
    let btn = {
      29: notificationBtn,
      31: interpretationBtn,
      32: captionBtn,
    }[item.id]

    if (!btn) {
      // 用来更新按钮状态
      const proxyItem = new Proxy(item, {
        get: function (target, propKey, receiver) {
          return Reflect.get(target, propKey, receiver)
        },
        set: function (target, propKey, value, receiver) {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              moreBarList: [...moreBarList],
            },
          })
          return Reflect.set(target, propKey, value, receiver)
        },
      })

      let btnConfig

      if (Array.isArray(item.btnConfig)) {
        btnConfig = item.btnConfig.find((btn) => {
          return btn.status === item.btnStatus
        })
      } else {
        btnConfig = item.btnConfig
      }

      if (btnConfig) {
        btn = {
          id: item.id,
          key: String(item.id),
          icon: <img src={btnConfig.icon} className="icon-image" />,
          label: btnConfig.text,
          onClick: () => {
            onInjectedMenuItemClick(item, eventEmitter)
            item.injectItemClick?.(proxyItem)
          },
          hidden: false,
        }
      }
    }

    btn && moreButtons.push(btn)
  })
  pluginList.forEach((plugin) => {
    const pluginNotificationDot =
      meetingInfo.notificationMessages.filter(
        (msg) => msg.unRead && msg.sessionId === plugin.notifySenderAccid
      ).length > 0

    const btn = {
      id: plugin.pluginId,
      key: plugin.pluginId,
      icon: (
        <Badge content={pluginNotificationDot ? Badge.dot : null}>
          <img
            src={plugin.icon.defaultIcon}
            className="icon-image plugin-icon-image"
          />
        </Badge>
      ),
      label: plugin.name,
      onClick: () => {
        onClickPlugin(plugin, true)
      },
    }

    moreButtons.push(btn)
  })

  return moreButtons.filter((item) => item && Boolean(!item.hidden))
}

export default useMoreButtons
