import React, { useEffect, useRef } from 'react'
import { useTranslation } from 'react-i18next'
import { css } from '@emotion/css'
import pkg from '../../../../../package.json'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import { EventType } from '../../../../types'

const pluginContainerCls = css`
  width: 100%;
  height: 100%;
  overflow: hidden;
  iframe {
    width: 100%;
    height: 100%;
    border: none;
  }
`

export interface MeetingPluginProps {
  url: string
  pluginId: string
  isInMeeting: boolean
  roomArchiveId?: number
}

const MeetingPlugin: React.FC<MeetingPluginProps> = (props) => {
  const { url, pluginId, isInMeeting, roomArchiveId } = props
  const { i18n } = useTranslation()
  const { neMeeting, eventEmitter } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const iframeRef = useRef<HTMLIFrameElement>(null)

  useEffect(() => {
    const iframeWindow = iframeRef.current?.contentWindow
    const localMember = meetingInfo.localMember

    if (iframeWindow) {
      iframeWindow.postMessage(
        {
          event: 'onEvent',
          payload: {
            eventType: 'inMeetingUserInfo',
            data: {
              uuid: localMember.uuid,
              nickname: localMember.name,
              avatar: localMember.avatar,
              roleType: localMember.role,
            },
          },
        },
        '*'
      )
    }
  }, [meetingInfo.localMember])

  useEffect(() => {
    const iframeWindow = iframeRef.current?.contentWindow

    eventEmitter?.on(EventType.ReceivePluginMessage, (res) => {
      const data = res.data

      if (iframeWindow && data.pluginId === pluginId) {
        iframeWindow.postMessage(
          {
            event: 'onEvent',
            payload: {
              eventType: 'customEvent',
              data: {
                content: JSON.stringify(data),
              },
            },
          },
          '*'
        )
      }
    })
  }, [eventEmitter, pluginId])

  useEffect(() => {
    const origin = new URL(url).origin

    function receiveMessage(event) {
      function onResult(res) {
        event.source.postMessage(
          {
            event: 'onResult',
            payload: res,
          },
          '*'
        )
      }

      if (event.origin !== origin) return
      const { data } = event

      try {
        const { method, methodId } = JSON.parse(data)

        if (method === 'requestAuthCode') {
          // todo
          neMeeting
            ?.getMeetingPluginAuthCode({ pluginId })
            .then((res) => {
              onResult({
                code: 0,
                data: res,
                methodId,
                message: 'success',
              })
            })
            .catch((err) => {
              onResult({
                ...err,
                methodId,
              })
            })
        }

        if (method === 'getCurrentMeetingInfo') {
          onResult({
            code: 0,
            data: {
              roomArchiveId: roomArchiveId ?? meetingInfo?.roomArchiveId,
              role: isInMeeting ? meetingInfo?.localMember.role : undefined,
              isInMeeting: isInMeeting,
            },
            methodId,
            message: 'success',
          })
        }

        if (method === 'getAppInfo') {
          onResult({
            code: 0,
            data: {
              clientLanguage: i18n.language,
              appVersion: pkg.version,
              platform: window.isElectronNative ? 'Electron' : 'Web',
            },
            methodId,
            message: 'success',
          })
        }

        if (method === 'config') {
          onResult({
            code: 0,
            data: {},
            methodId,
            message: 'success',
          })
        }
      } catch (e) {
        console.error('MeetingPlugin receiveMessage error:', e)
      }
    }

    window.addEventListener('message', receiveMessage)
    return () => {
      window.removeEventListener('message', receiveMessage)
    }
  }, [
    pluginId,
    neMeeting,
    meetingInfo,
    url,
    isInMeeting,
    roomArchiveId,
    i18n.language,
    eventEmitter,
  ])

  return (
    <div className={pluginContainerCls}>
      <iframe src={url} ref={iframeRef} />
    </div>
  )
}

export default MeetingPlugin
