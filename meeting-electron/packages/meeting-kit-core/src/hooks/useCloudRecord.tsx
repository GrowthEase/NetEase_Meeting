import React, { useCallback, useEffect, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import {
  ActionType,
  getLocalStorageSetting,
  RecordState,
  Role,
  Toast,
} from '../kit'
import { useTranslation } from 'react-i18next'
import { Popover, Checkbox } from 'antd'
import CommonModal, { ConfirmModal } from '../components/common/CommonModal'
import useAISummary from './useAISummary'

export function getCloudRecordConfig() {
  const recordSetting = getLocalStorageSetting().recordSetting

  const config = {
    rtcRecordType: 100,
    modeList: [] as Array<{ mode: number }>,
  }

  if (recordSetting.cloudRecordGalleryViewWithSharedScreen) {
    config.modeList.push({
      mode: 1,
    })
  }

  if (recordSetting.cloudRecordCurrentSpeakerWithSharedScreen) {
    config.modeList.push({
      mode: 2,
    })
  }

  if (recordSetting.cloudRecordSeparateRecordingCurrentSpeaker) {
    config.modeList.push({
      mode: 3,
    })
  }

  if (recordSetting.cloudRecordSeparateRecordingGalleryView) {
    config.modeList.push({
      mode: 4,
    })
  }

  if (recordSetting.cloudRecordSeparateRecordingSharedScreen) {
    config.modeList.push({
      mode: 5,
    })
  }

  if (recordSetting.cloudRecordSeparateAudioFile) {
    config.modeList.push({
      mode: 6,
    })
  }

  if (config.modeList.length === 0) {
    config.modeList.push({
      mode: 2,
    })
  }

  return config
}

const useCloudRecord = () => {
  const { t } = useTranslation()
  const { neMeeting, showCloudRecordingUI } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const { isAISummarySupported, isAISummaryStarted, startAISummary } =
    useAISummary()

  const memberListRef = useRef(memberList)
  const showCloudRecordingUIRef = useRef<boolean>(true)
  const cloudRecordModalRef = useRef<ConfirmModal | null>(null)

  const localMember = meetingInfo.localMember

  memberListRef.current = memberList

  showCloudRecordingUIRef.current = showCloudRecordingUI !== false

  // true 可以开启； false: 无法开启
  const noCloudRecordRemind = useCallback(
    (checkedAISummary) => {
      const noCloudRecord =
        memberListRef.current.findIndex(
          (item) =>
            (item.isAudioOn && item.isAudioConnected) ||
            item.isVideoOn ||
            item.isSharingScreen ||
            item.isSharingSystemAudio
        ) === -1

      function startRecording() {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            cloudRecordState: RecordState.Starting,
          },
        })
        checkedAISummary && startAISummary()

        const config = getCloudRecordConfig()

        neMeeting
          ?.startCloudRecord(config)
          .then(() => {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                cloudRecordState: RecordState.Recording,
              },
            })
          })
          .catch((e) => {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                cloudRecordState: RecordState.NotStart,
              },
            })
            Toast.fail(e.msg || e.message || e.code || t('startRecordFailed'))
            return Promise.reject(e)
          })
      }

      if (noCloudRecord) {
        CommonModal.confirm({
          title: t('cloudRecordingUnableToStart'),
          content: t('cloudRecordingUnableToStartTips'),
          okText: t('participantUnmute'),
          onOk: async () => {
            if (!meetingInfo.localMember.isAudioConnected) {
              await neMeeting?.reconnectMyAudio()
            }

            await neMeeting?.unmuteLocalAudio(undefined, true)
            startRecording()
          },
        })
      } else {
        startRecording()
      }
    },
    [
      memberList,
      meetingInfo.localMember.isAudioConnected,
      meetingInfo.setting.recordSetting,
    ]
  )

  // 重复开启云录制

  const handleRecord = useCallback(() => {
    let checkedAISummary = false

    // 临时去除只弹一次弹窗的逻辑，否则会议纪要后面无法打开
    // if(meetingInfo.isCloudRecordingConfirmed && !meetingInfo.isCloudRecording){
    //   noCloudRecordRemind(checkedAISummary)
    //   return
    // }

    cloudRecordModalRef.current = CommonModal.confirm({
      width: 390,
      title: meetingInfo.isCloudRecording
        ? t('endCloudRecording')
        : t('isStartCloudRecord'),
      content: (
        <>
          <div
            style={{
              margin: `10px 0 12px 0`,
            }}
          >
            {meetingInfo.isCloudRecording
              ? t('syncRecordFileAfterMeetingEnd')
              : showCloudRecordingUIRef.current
              ? t('startRecordTip')
              : t('startRecordTipNoNotify')}
          </div>
          {meetingInfo.isCloudRecording ||
          !isAISummarySupported ? null : isAISummaryStarted ? (
            <span
              style={{
                color: '#8D90A0',
              }}
            >
              {t('cloudRecordingAISummaryStarted')}
            </span>
          ) : (
            <>
              <Checkbox
                onChange={(event) => {
                  checkedAISummary = event.target.checked
                }}
              >
                {t('cloudRecordingEnableAISummary')}
              </Checkbox>
              <Popover
                trigger={'hover'}
                placement={'top'}
                content={
                  <div className="toolbar-tip">
                    {t('cloudRecordingEnableAISummaryTip')}
                  </div>
                }
              >
                <span
                  style={{
                    color: '#CCCCCC',
                  }}
                >
                  <svg className="icon iconfont icona-45" aria-hidden="true">
                    <use xlinkHref="#icona-45"></use>
                  </svg>
                </span>
              </Popover>
            </>
          )}
        </>
      ),
      afterClose: () => {
        cloudRecordModalRef.current = null
      },
      okText: meetingInfo.isCloudRecording ? t('globalSure') : t('globalStart'),
      cancelText: t('globalCancel'),
      onOk: () => {
        if (meetingInfo.isCloudRecording) {
          neMeeting
            ?.stopCloudRecord()
            .then(() => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  cloudRecordState: RecordState.NotStart,
                },
              })
              return true
            })
            .catch((e) => {
              // todo 需要翻译
              Toast.fail(e.msg || e.message || e.code || t('stopRecordFailed'))
              return Promise.reject(e)
            })
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isCloudRecordingConfirmed: true,
            },
          })
          noCloudRecordRemind(checkedAISummary)
        }

        cloudRecordModalRef.current?.destroy()
      },
    })
  }, [
    meetingInfo.isCloudRecording,
    dispatch,
    t,
    neMeeting,
    isAISummaryStarted,
    isAISummarySupported,
    memberList,
  ])

  useEffect(() => {
    if (localMember.role !== Role.host && localMember.role !== Role.coHost) {
      if (cloudRecordModalRef.current) {
        cloudRecordModalRef.current.destroy()
      }
    }
  }, [localMember.role])

  return { handleRecord }
}

export default useCloudRecord
