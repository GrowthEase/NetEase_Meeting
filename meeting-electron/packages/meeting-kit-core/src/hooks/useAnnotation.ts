import { MutableRefObject, useEffect, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { NEMeetingInfo } from '../types'
import saveImage from '../assets/save.png'

interface AnnotationRes {
  whiteColor: string
  transparentColor: string
  meetingInfoRef: MutableRefObject<NEMeetingInfo | null>
}
export function useAnnotation(
  isEditable: boolean,
  isMain: boolean
): AnnotationRes {
  const { meetingInfo } = useMeetingInfoContext()
  const { neMeeting } = useGlobalContext()

  const whiteColor = 'rgba(255, 255, 255, 1)'
  const transparentColor = 'rgba(255, 255, 255, 0)'

  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)

  meetingInfoRef.current = meetingInfo

  function iframeDomSetColor(color: string) {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setColor","params":["${color}"],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  function iframeDomHideTool() {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"hide","params":[],"target":"toolCollection"}}`,
        '*'
      )
    }
  }

  // 隐藏上传多媒体文件和上传多媒体文件并转码的入口
  function iframeDomSetUploadPlugin() {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"addOrSetTool","params":[{"position":"left","insertAfterTool":"redo","item":{"tool":"custom-saveAnnotation","hint":"保存批注", "backgroundImage": "${saveImage}"}}],"target":"toolCollection"}}`,
        '*'
      )
    }
  }

  // 设置背景颜色
  function iframeDomSetCanvasBackgroundColor(color: string) {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setAppConfig","params":[{"canvasBgColor": "${color}"}],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }
  /*
  function iframeDomShowNickname() {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setAppConfig","params":[{"showCursorNickname": true, "showLaserNickname": true, "showSelectNickname": true}],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }
    */

  function iframeDomSetNickname(name: string) {
    const iframeDom = document.getElementById(
      'nemeeting-annotation-iframe'
    ) as HTMLIFrameElement

    if (iframeDom) {
      iframeDom.contentWindow?.postMessage(
        `{"action":"jsDirectCall","param":{"action":"setNickName","params":["${name}"],"target":"drawPlugin"}}`,
        '*'
      )
    }
  }

  useEffect(() => {
    if (!isEditable) {
      return
    }

    // 默认透明
    iframeDomSetCanvasBackgroundColor(transparentColor)
    iframeDomSetColor('rgb(224, 32, 32)')
    iframeDomSetUploadPlugin()
    iframeDomHideTool()
    // iframeDomShowNickname()

    meetingInfo.annotationDrawEnabled &&
      isMain &&
      neMeeting?.setAnnotationEnableDraw(true)
  }, [isEditable, meetingInfo.annotationDrawEnabled, isMain])

  useEffect(() => {
    if (!isEditable) {
      return
    }

    iframeDomSetNickname(meetingInfo.localMember.name)
  }, [isEditable, meetingInfo.localMember.name])

  return {
    whiteColor,
    transparentColor,
    meetingInfoRef,
  }
}
