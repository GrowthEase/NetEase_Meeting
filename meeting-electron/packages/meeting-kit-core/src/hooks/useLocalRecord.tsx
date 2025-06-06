/** 本地录制功能模块（仅Electron支持）【v4.10.0版本支持】 **/
//产品PRD：https://docs.popo.netease.com/lingxi/5cf4a299d84843e7a19587ba1b836227
//视觉稿：https://mastergo.netease.com/file/120231421221887?page_id=17178%3A154883&shareId=120231421221887&devMode=true

import React, { useCallback, useEffect, useRef, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, LocalRecordState,Toast,Role } from '../kit'
import { useTranslation } from 'react-i18next'
import { NEMember } from '../types'
import {
  NERoomUpdateLocalRecordLayoutsOptions,
  NERoomsCalingMode,
  NERoomStreamLayer,
  NERoomStreamType,
} from 'neroom-types'
import CommonModal, { ConfirmModal } from '../components/common/CommonModal'
import { getWindow } from '../utils/windowsProxy'
import {
  speakerLayoutPlacementRight,
  speakerLayoutPlacementTop,
  galleryLayout,
  localRecordWhiteBoardInterval
} from '../config/localRecordConfig'
import { LOCALSTORAGE_LOCAL_RECORD_INFO } from '../config';

const TagGenerator = '[LocalRecord] '

const useLocalRecord = () => {
  const { t } = useTranslation()
  const { neMeeting, showLocalRecordingUI, eventEmitter } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const showLocalRecordingUIRef = useRef<boolean>(true)
  const localRecordModalRef = useRef<ConfirmModal | null>(null)
  //MeetingCanvas反馈的布局信息
  const [mainLoyout, setMainLotout] = useState<{
    isElectronSharingScreen: boolean,
    isAudioMode: boolean,
    isShowSlider: boolean,
    sliderGroupMembers: NEMember[][],
    activeIndex: number,
    mainMember: NEMember,
    isSpeakerFull: boolean
    isSpeakerLayoutPlacementRight: boolean
  } | null>(null)
  //screenSharing/video.tsx(electron共享下的视频窗口布局)
  const [electronScreenSharevideoLayout, setElectronScreenSharevideoLayout] = useState<{
    memberListFilter:NEMember[],
    videoCount: number,
    pageNum: number
  } | null>(null)

  const meetingInfoRef = useRef(meetingInfo)
  meetingInfoRef.current = meetingInfo
  const memberListRef = useRef(memberList)
  memberListRef.current = memberList

  //白板数据获取的定时器
  const recordTimerRef = useRef<number | NodeJS.Timeout | null>(null)
  showLocalRecordingUIRef.current = showLocalRecordingUI !== false

  //监听视图布局变化，通知来源（MeetingCanvas、screenSharing/video.tsx）
  const emitEvent = () => {
    eventEmitter?.on('layoutChange', (data) => {
      setMainLotout(data)
    })
    eventEmitter?.on('electronScreenSharevideoLayoutChange', (data) => {
      setElectronScreenSharevideoLayout(data)
    })
    eventEmitter?.on('OnLocalRecorderError', (erorCode) => {
      console.log(TagGenerator, '监听到录制发生错误: ', erorCode)
      stopLocalRecord()
      Toast.fail('startLocalRecordFailed: ' + erorCode)
    })
  }

  const startLocalRecord = async () => {
    try {
      console.log(TagGenerator, 'startLocalRecord 开始录制流程')
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          localRecordState: LocalRecordState.Starting,
        },
      })
      const regex = /[\u4e00-\u9fa5a-zA-Z0-9_-]+/g
      const recordSetting = meetingInfoRef.current.setting.recordSetting
      //会议开始时间的日期格式
      const meetingStartTime = new Date(meetingInfoRef.current.startTime).toLocaleString().replaceAll('/', '-').replaceAll(':', '.')
      let filePath = recordSetting.localRecordDefaultPath || ''
      console.log(TagGenerator, 'startLocalRecord recordSetting: ', recordSetting)
      const subject = meetingInfoRef?.current?.subject.match(regex)?.join('') || ''
      let list = await window.ipcRenderer?.invoke('getCoverImage', {
        filePath: recordSetting.localRecordDefaultPath,
        //录制文件目录命名（规则参考产品文档）
        dirNmae: `${meetingStartTime} ${subject} ${meetingInfoRef.current.meetingNum}`
      })
      console.log(TagGenerator, 'startLocalRecord 获取到录制文件目录list: ', list)
      let coverConfigFilePath = ''
      let defaultCoverConfigFilePath = ''
      list.forEach(item => {
        if (item.errorMessage) {
          console.log(TagGenerator, '无法获取本地录制背景图的路径: ', item.errorMessage)
          Toast.fail('startLocalRecordFailed: ' + item.errorMessage)
          return
        } else if (item.isDefaultConver) {
          defaultCoverConfigFilePath = item.path
          //真实的录制文件路径（加上了dirNmae）
          filePath = item.dirPath
        } else {
          coverConfigFilePath = item.path
          filePath = item.dirPath
        }
        //如果应该一开始安装，或者设置了一个不存在的录制存储地址，需要自动更新成默认地址
        recordSetting.localRecordDefaultPath = item.filePath
      })

      const ret = neMeeting?.startLocalRecord({
        recordAudio: recordSetting.localRecordAudio, //是否录制单独的aac文件
        isShowTimestampCover: recordSetting.localRecordTimestamp,
        //录制文件命名（规则参考产品文档）
        fileName: `Video${meetingInfoRef.current.meetingNum}-${new Date().toLocaleString().replace(/[/: ]/g,'')}`,
        //本地录制文件的路径
        filePath,
        //背景图片路径
        coverConfigFilePath,
        //视频占位图路径
        defaultCoverConfigFilePath,
        //背景图的文案（规程参考产品文档）
        coverTitle: subject,
        coverMeetingNumber: `会议号: ${meetingInfoRef.current.meetingNum}`,
        coverCreateTime: `开始录制时间: ${new Date().toLocaleString()} (GMT+8)`
      })
      console.log(TagGenerator, 'startLocalRecord ret', ret)

      //用于保存历史记录的localRecordDefaultPath，
      const str = localStorage.getItem(LOCALSTORAGE_LOCAL_RECORD_INFO) || "{}"
      list = JSON.parse(str)
      const info = {
        meetingId: meetingInfoRef.current.meetingId,
        localRecordDefaultPath: filePath,
        recordAudio: recordSetting.localRecordAudio,
      }
      if (list[meetingInfoRef.current.myUuid]) {
        list[meetingInfoRef.current.myUuid].push(info)
      } else {
        list[meetingInfoRef.current.myUuid] = [info]
      }
      window.localStorage.setItem(LOCALSTORAGE_LOCAL_RECORD_INFO, JSON.stringify(list))

      console.log(TagGenerator, '开启录制成功, 设置isLocalRecording为true')
      //更新本地录制状态
      //通知服务器，会广播给其他人
      neMeeting?.roomContext?.updateMemberProperty(
        meetingInfoRef.current.myUuid,
        'localRecord',
        JSON.stringify({
          value: '1'
        })
      )
      const setting = meetingInfoRef.current.setting
      setting.recordSetting = recordSetting
      //本地录制状态更新
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          setting,
          isLocalRecording: true,
          localRecordState: LocalRecordState.Recording
        }
      })
      emitEvent()
    } catch(e) {
      console.log(TagGenerator, 'startLocalRecord 录制失败: ', e)
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          isLocalRecording: false,
          localRecordState: LocalRecordState.NotStart
        }
      })
      neMeeting?.roomContext?.updateMemberProperty(
        meetingInfoRef.current.myUuid,
        'localRecord',
        JSON.stringify({
          value: '0'
        })
      )
    }
  }

  const stopLocalRecord = () => {
    console.log(TagGenerator, 'stopLocalRecord 停止本地录制')
    recordTimerRef.current && clearInterval(recordTimerRef.current)
    neMeeting?.stopLocalRecord()
    eventEmitter?.off('layoutChange')
    eventEmitter?.off('electronScreenSharevideoLayoutChange')
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        isLocalRecording: false,
        localRecordState: LocalRecordState.NotStart
      }
    })
    neMeeting?.roomContext?.updateMemberProperty(
      meetingInfoRef.current.myUuid,
      'localRecord',
      JSON.stringify({
        value: '0'
      })
    )
  }

  // 获取每个视频view的坐标位置以及宽高
  function getOffsetXAndY(data) {
    const {isBigRender, index, length, isSpeakerLayoutPlacementRight} = data
    if (isBigRender) {
      if(isSpeakerLayoutPlacementRight){
        return speakerLayoutPlacementRight[index]
      } else {
        return speakerLayoutPlacementTop[length-1][index]
      }
    } else {
      return galleryLayout[length-1][index]
    }
  }

  //开启互动白板或者批注时，将白板canvas的数据传递给音视频sdk
  const pushLocalVideoStream = (isAnnotation:boolean, uid:string, streamLayer:number ) => {
    recordTimerRef.current && clearInterval(recordTimerRef.current)
    recordTimerRef.current = setInterval(function() {
      //互动白板的iframe的id（注意不能变更）
      let iframe = document.getElementById('nemeeting-whiteboard-iframe') as HTMLIFrameElement
      if (!iframe) {
        //扩展屏的窗口
        const dualMonitorsWindow = getWindow('dualMonitorsWindow')
        iframe = dualMonitorsWindow?.document.getElementById('nemeeting-whiteboard-iframe') as HTMLIFrameElement
      }
      if (isAnnotation) { //当前是批注
        const annotationWindow = getWindow('annotationWindow')
        if (annotationWindow) {
          //此时是本端开启了批注
          //批注白板的iframe的id（注意不能变更）
          iframe = annotationWindow?.document.getElementById('nemeeting-annotation-iframe') as HTMLIFrameElement
        } else {
          //此时是远端开启了批注
          //批注白板的iframe的id（注意不能变更）
          iframe = document.getElementById('nemeeting-annotation-iframe') as HTMLIFrameElement
        }
      }
      console.log(TagGenerator, 'pushLocalRecorderVideoFrame 获取白板的iframe: ', iframe)
      if(iframe?.contentWindow?.document.getElementsByClassName('anchor-canvas').length){
        let canvas = iframe.contentWindow?.document.getElementsByClassName('anchor-canvas')[0] as HTMLCanvasElement
        if (canvas.width > 2) {
          let ctx = (canvas.getContext('2d') as CanvasRenderingContext2D)
          let imageData: ImageData | null
          imageData = ctx.getImageData(0,0,canvas.width,canvas.height)
          console.log(TagGenerator, 'pushLocalRecorderVideoFrame 获取到rgba数据')
          neMeeting?.pushLocalRecorderVideoFrame(uid, streamLayer, {
            format: 6, //rgba格式
            timestamp: Date.now(),
            width: canvas.width,
            height: canvas.height,
            rotation: 0,
            buffer: imageData.data
          })
          imageData = null
        }
      }
    }, localRecordWhiteBoardInterval);
  }

  //动态更新本地录制的布局
  const updateLocalRecordLayouts = () => {
    if(!meetingInfoRef.current.isLocalRecording || !mainLoyout){
      return
    }
    console.log(TagGenerator, 'updateLocalRecordLayouts 更新布局, meetingInfo: ', meetingInfoRef.current)
    console.log(TagGenerator, 'updateLocalRecordLayouts 更新布局, mainLoyout: ', mainLoyout)
    const {
      isElectronSharingScreen,
      sliderGroupMembers,
      activeIndex,
      mainMember,
      isSpeakerFull,
      //isSpeakerLayoutPlacementRight,
    } = mainLoyout
    //录制的设置属性
    const recordSetting = meetingInfoRef.current.setting.recordSetting
    const localRecordLayouts: NERoomUpdateLocalRecordLayoutsOptions[] = []
    let bgColor = 0; //默认背景色为黑色
    //speaker模式下，上面或者右面的小视频窗口list
    let list = sliderGroupMembers.length ? [...sliderGroupMembers[activeIndex]] : []
    if (isElectronSharingScreen && electronScreenSharevideoLayout) {
      //本地开启了屏幕共享，右侧的小视频窗口list
      list = [...electronScreenSharevideoLayout.memberListFilter]
    }
    //speaker为演讲者模式，gallery为画廊模式
    const isBigRender = meetingInfoRef.current.layout == 'speaker'
    const isShareOrWhiteboard = meetingInfoRef.current.screenUuid != '' || meetingInfoRef.current.whiteboardUuid != ''
    console.log(TagGenerator, '当前房间有人在共享: ', isShareOrWhiteboard)
    let isSpeakerLayoutOnlyVideo = (isBigRender && !isShareOrWhiteboard)
    let noRecordSamllVideoFlag =
      isSpeakerLayoutOnlyVideo || //产品需求：非屏幕共享、非白板共享，speaker模式下，仅仅录制视频大画面
      isSpeakerFull  || //用户选择了全屏渲染，此时不需要录制小视频画面
      (isShareOrWhiteboard && !recordSetting.localRecordScreenShareAndVideo) //当前是屏幕共享或者白板，但是用户设置了不录制视频
    if (meetingInfoRef.current.secondMonitorMember && isShareOrWhiteboard) {
      noRecordSamllVideoFlag = false
      if ((list.length == 0) && mainMember) {
        list.push(mainMember)
      }
    }
    console.log(TagGenerator, '当前不录制小视频窗口: ', noRecordSamllVideoFlag)

    const isWhiteboardTransparent =
      meetingInfoRef.current.isWhiteboardTransparent &&
      meetingInfoRef.current.whiteboardUuid != ''
    console.log(TagGenerator, '当前房间中开启了透明白板: ', isWhiteboardTransparent)
    console.log(TagGenerator, '当前房间布局是否是大屏: ', isBigRender)

    if(!isElectronSharingScreen){
      //没有白板也没有共享，就停止定时器了
      recordTimerRef.current && clearInterval(recordTimerRef.current)
    }
    if (list?.length && !noRecordSamllVideoFlag) {
      //双屏场景下单独处理
      if (meetingInfoRef.current.secondMonitorMember && mainMember && isShareOrWhiteboard) {
        let index = list.findIndex(item=>{return item.uuid === mainMember.uuid})
        if ((index == -1)) {
          list.push(mainMember)
        }
      } else if (isBigRender) {
        //sliderGroupMembers可能超过6个，大屏模式下，list需要截取一下
        list = list.slice(0, 6)

        let result:NEMember[] = []
        let obj = {}
        //兼容：双击小画面会变成大画面，此时小窗口列表中存在白板或者共享，但是白板或者共享是会单独添加layout的，所以需要将白板或者共享从小窗口列表中过滤出来
        list.map(member =>{
          //产品需求：演讲者布局，没有开启视频不要录制（过滤没有视频的member）
          if (!obj[member?.uuid] && member?.isVideoOn) {
            obj[member.uuid] = member.uuid;
            result.push(member);
          }
        })
        list = result
        if (mainMember.isVideoOn &&
          !mainMember.isSharingScreen &&
          !mainMember.isSharingWhiteboard &&
          isShareOrWhiteboard &&
          !isWhiteboardTransparent && //排除本地开启了透明白板的场景
          list.length < 6 //怕有场景没有兼容好，这里做一下处理
          ) {
          // 兼容：双击小画面会变成大画面 的业务场景，此时屏幕共享或者白板在小窗口视频中，录制时需要将这个uid的视频大画面放到小窗口的list中
          let index = list.findIndex(item=>{return item.uuid === mainMember.uuid})
          if (index == -1) {
            list.push(mainMember)
          }
        }
      }

      console.log(TagGenerator, '视频小窗口 list: ', list)
      const length = list.length
      list.forEach((member, index) => {
        const data = getOffsetXAndY({
          isBigRender: isBigRender || isShareOrWhiteboard,
          index,
          length,
          isSpeakerLayoutPlacementRight: true //本地录制要求不存在speakerLayoutPlacementTop的布局
          //isSpeakerLayoutPlacementRight: isElectronSharingScreen ? true : isSpeakerLayoutPlacementRight
        })
        const {offsetX, offsetY, width, height} = data
        localRecordLayouts.push({
          uid: member.uuid,
          streamType: NERoomStreamType.main, //video
          streamLayer: NERoomStreamLayer.high, //视频画面的层级为2
          width,
          height,
          offsetX,
          offsetY,
          isScreenShare: false,
          scalingMode: NERoomsCalingMode.fullFill, //视频
          isShowNameCover: recordSetting.localRecordNickName,
          isShowStreamDefaultCover: member?.isVideoOn ? false : true //没有视频才会显示占位图
        })
      })
    }

    if (isBigRender || isShareOrWhiteboard) {
      let uid = mainMember.uuid;
      let height = 720;
      let width = 1280;
      let offsetX = 0;
      let offsetY = 0;
      let isScreenShare = true;
      let streamLayer = 0;
      console.log(TagGenerator, '此时大画面 mainMember: ', mainMember)
      if (meetingInfoRef.current.screenUuid) {
        console.log(TagGenerator, '当前有人开启屏幕共享, 批注 annotationEnabled: ', meetingInfoRef.current.annotationEnabled)
        console.log(TagGenerator, '当前有人开启屏幕共享, 批注 annotationDrawEnabled: ', meetingInfoRef.current.annotationDrawEnabled)
        uid = meetingInfoRef.current.screenUuid
        //录制设置中配置了屏幕共享模式下，小视频窗口并排显示，不要覆盖（需要调整屏幕共享画面的宽高）
        //如果此时没有视频，则不调整宽高
        if (recordSetting.localRecordScreenShareSideBySideVideo && list?.length && !noRecordSamllVideoFlag) {
          // if(!isSpeakerLayoutPlacementRight){
          //   width = 1066
          //   height = 598
          //   offsetX = 107
          //   offsetY = 121
          // } else {
          //   width = 1066
          //   height = 598
          //   offsetX = 0
          //   offsetY = 61
          // }
          //本地录制要求不存在speakerLayoutPlacementTop的布局
          width = 1066
          height = 598
          offsetX = 0
          offsetY = 61
        }
        if (meetingInfoRef.current.annotationDrawEnabled || getWindow('annotationWindow')) {
          try {
            //当前有批注
            pushLocalVideoStream(true, uid, 1)
          } catch (e) {
            console.log('批注 error', e)
          }
          //批注需要增加layout
          localRecordLayouts.push({
            uid,
            streamType: NERoomStreamType.sub, //screen
            streamLayer: NERoomStreamLayer.meddle, //批注的层级为1
            width,
            height,
            offsetX,
            offsetY,
            isScreenShare: true,
            scalingMode: NERoomsCalingMode.fullFill, //裁剪模式
            bgColor,
            isShowNameCover: recordSetting.localRecordNickName,
            isShowStreamDefaultCover: false //是否需要渲染占位图
          })
        }
      } else if (meetingInfoRef.current.whiteboardUuid || mainMember.isSharingScreen ) {
        console.log(TagGenerator, '当前互动白板或者其他人开启了屏幕共享: ', mainMember)
        //如果当前没有小视频窗口，则不需要调整白板的宽高
        if (list?.length && !noRecordSamllVideoFlag) {
          //本地录制要求不存在speakerLayoutPlacementTop的布局
          width = 1066
          height = 598
          offsetX = 0
          offsetY = 61
        }
        //注意：白板场景或者本地共享场景，mainMember并非当前正在白板或者共享的人，而是上一次大屏展示的人
        if (meetingInfoRef.current.whiteboardUuid) {
          if (isWhiteboardTransparent) {
            //本地开启了透明白板，透明白板时盖在视频大画面上面的，需要单独增加白板的layout
            //此时不能更新uid，uid应该为大屏视频的uid
            localRecordLayouts.push({
              uid: meetingInfoRef.current.whiteboardUuid,
              streamType: NERoomStreamType.sub, //screen
              streamLayer: NERoomStreamLayer.higher, //透明白板批注的层级最高为3
              width,
              height,
              offsetX,
              offsetY,
              isScreenShare: true,
              scalingMode: NERoomsCalingMode.fullFill, //裁剪模式
              bgColor,
              isShowNameCover: recordSetting.localRecordNickName,
              isShowStreamDefaultCover: false //是否需要渲染占位图
            })
            pushLocalVideoStream(false, meetingInfoRef.current.whiteboardUuid, 3)
            //这里控制的是应该视频大画面
            isScreenShare = false
            streamLayer = 2
          } else {
            uid = meetingInfoRef.current.whiteboardUuid
            isScreenShare = false
            console.log(TagGenerator, '房间中有人开启了白板: ', uid)
            //白板需要设置为1
            streamLayer = 1
            //白色的背景色应该为白色，即parseInt("FFFFFFFF", 16)
            bgColor = 4294967295
            pushLocalVideoStream(false, uid, 1)
          }
        }
      } else {
        console.log(TagGenerator, '此时大画面为视频')
        isScreenShare = false
        streamLayer = 2
      }
      localRecordLayouts.push({
        uid,
        streamType: (isSpeakerLayoutOnlyVideo) ? NERoomStreamType.main : (isWhiteboardTransparent ? NERoomStreamType.main : NERoomStreamType.sub), //main:video、sub:screen
        streamLayer,
        width,
        height,
        offsetX,
        offsetY,
        isScreenShare,
        scalingMode: NERoomsCalingMode.fullFill, //裁剪模式
        bgColor,
        isShowNameCover: recordSetting.localRecordNickName,
        isShowStreamDefaultCover: isSpeakerLayoutOnlyVideo ? (mainMember.isVideoOn ? false : true) : false //演讲者模式，只有视频才会显示占位图
      })
    }
    console.log(TagGenerator, "更新布局 localRecordLayouts: ", localRecordLayouts);
    if (localRecordLayouts.length > 0) {
      neMeeting?.updateLocalRecordLayouts(localRecordLayouts)
    }
  }

  useEffect(()=>{
    updateLocalRecordLayouts()
  }, [
    meetingInfoRef.current.isLocalRecording,  //是否正在录制
    meetingInfoRef.current.secondMonitorMember, //扩展屏幕
    meetingInfoRef.current.annotationDrawEnabled, //批注
    meetingInfoRef.current.annotationEnabled, //批注
    mainLoyout, //布局变化
    electronScreenSharevideoLayout //屏幕共享场景下布局变化
  ])

  const noLocalRecordRemind = useCallback(
    () => {
      CommonModal.confirm({
        title: t('localRecordingUnableToStart'),
        content: t('localRecordingUnableToStartTips'),
        okText: t('participantUnmute'),
        cancelText: t('localRecordingCancelTips'),
        onOk: async () => {
          await neMeeting?.unmuteLocalAudio()
          startLocalRecord()
        },
        onCancel: ()=>{
          startLocalRecord()
        }
      })

    },
    [memberList, meetingInfo.localMember]
  )

  const noLocalRecordDisConnectAudioRemind = useCallback(
    () => {
      if (!meetingInfo.localMember.isAudioConnected && memberListRef.current.length == 1) {
        CommonModal.confirm({
          title: t('localRecordDisConnectAudioTitle'),
          content: t('localRecordDisConnectAudioContent'),
          okText: t('localRecordDisConnectAudioOkText'),
          cancelText: t('localRecordingCancelTips'),
          onOk: async () => {
            console.log('开始链接音频')
            await neMeeting?.reconnectMyAudio()
            console.log('isAudioOn: ', meetingInfo.localMember.isAudioOn)
            if (!meetingInfo.localMember.isAudioOn) {
              //noLocalRecordRemind()
              console.log('开始开启音频')
              setTimeout(()=>{
                neMeeting?.unmuteLocalAudio()
              }, 500)
              //马上调用 unmuteLocalAudio 会发现 reconnectMyAudio 还没有成功
              //await neMeeting?.unmuteLocalAudio()
            }
            startLocalRecord()
          },
          onCancel: ()=>{
            startLocalRecord()
          }
        })
      } else if (!meetingInfo.localMember.isAudioOn && memberListRef.current.length == 1) {
        noLocalRecordRemind()
      }  else  {
        startLocalRecord()
      }
    },
    [memberList, meetingInfo.localMember]
  )

  const handleLocalRecord = useCallback(() => {
    if(meetingInfoRef.current.isLocalRecordingConfirmed && !meetingInfoRef.current.isLocalRecording){
      noLocalRecordDisConnectAudioRemind()
      return
    }
    localRecordModalRef.current = CommonModal.confirm({
      width: 390,
      title: meetingInfoRef.current.isLocalRecording
        ? t('endLocalRecording')
        : t('isStartLocalRecord'),
      content: (
        <>
          <div
            style={{
              margin: `10px 0 12px 0`,
            }}
          >
            {meetingInfoRef.current.isLocalRecording
              ? t('syncLocalRecordFileAfterMeetingEnd')
              : showLocalRecordingUIRef.current
              ? t('startLocalRecordTip')
              : t('startLocalRecordTip')}
          </div>
        </>
      ),
      afterClose: () => {
        localRecordModalRef.current = null
      },
      okText: meetingInfoRef.current.isLocalRecording ? t('globalSure') : t('globalStart'),
      cancelText: t('globalCancel'),
      onOk: () => {
        if (meetingInfoRef.current.isLocalRecording) {
          stopLocalRecord()
        } else {
          console.warn('开始本地录制')
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isLocalRecordingConfirmed: true,
            }
          })
          noLocalRecordDisConnectAudioRemind()
        }
        localRecordModalRef.current?.destroy()
      },
    })
  }, [
    meetingInfo.isLocalRecording,
    dispatch,
    t,
    neMeeting,
    memberList,
    meetingInfo.localMember
  ])

  useEffect(() => {
    console.log('是否有本地录制权限 localRecordPermission:', meetingInfoRef.current.localRecordPermission)
    console.log('是否有本地录制权限 localMember:', meetingInfoRef.current.localMember)
    let localRecordAvailable = true
    if (meetingInfoRef.current.localRecordPermission?.host) {
      //房间录制权限为host，此时自己不是主持人或者联席主持人，没有本地录制设置权限
      if (meetingInfoRef.current.localMember.role !== Role.host && meetingInfoRef.current.localMember.role !== Role.coHost) {
        localRecordAvailable = false
      }
    } else if (meetingInfoRef.current.localRecordPermission?.some) {
      //房间录制权限为部分人可录制，此时判断自己的成员属性localRecordAvailable
      localRecordAvailable = meetingInfoRef.current.localMember.localRecordAvailable
    } else if (meetingInfoRef.current.localRecordPermission?.all) {
      //房间录制权限全体人可录制
      localRecordAvailable = true
    }
    if (meetingInfoRef.current.localMember.role == Role.host || meetingInfoRef.current.localMember.role == Role.coHost) {
      localRecordAvailable = true
    }
    if (!localRecordAvailable) {
      if (localRecordModalRef.current) {
        localRecordModalRef.current.destroy()
      }
      if(meetingInfoRef.current.isLocalRecording){
        console.log('本地录制权限被收回，停止录制')
        Toast.info(t('localRecordPermissionCancelTip'))
        stopLocalRecord()
      }
    }
  }, [meetingInfo.localMember.role, meetingInfo.localMember.localRecordAvailable, meetingInfo.localRecordPermission])

  return { handleLocalRecord }
}

export default useLocalRecord
