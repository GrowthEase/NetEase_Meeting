import React, { useCallback, useEffect, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import { ActionType, RecordState, Role, Toast } from '../kit'
import { useTranslation } from 'react-i18next'
import { Popover, Checkbox } from 'antd'
import CommonModal, { ConfirmModal } from '../components/common/CommonModal'
import useAISummary from './useAISummary'

const useCloudRecord = () => {
  const { t } = useTranslation()
  const { neMeeting, showCloudRecordingUI } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const {
    isAISummarySupported,
    isAISummaryStarted,
    startAISummary,
  } = useAISummary()

  const showCloudRecordingUIRef = useRef<boolean>(true)
  const cloudRecordModalRef = useRef<ConfirmModal | null>(null)

  const localMember = meetingInfo.localMember

  showCloudRecordingUIRef.current = showCloudRecordingUI !== false

  // true 可以开启； false: 无法开启
  const noCloudRecordRemind = useCallback(
    (checkedAISummary) => {
      const noCloudRecord =
        memberList.findIndex(
          (item) =>
            item.isAudioOn ||
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

        neMeeting
          ?.startCloudRecord()
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

            await neMeeting?.unmuteLocalAudio()
            startRecording()
          },
        })
      } else {
        startRecording()
      }
    },
    [memberList, meetingInfo.localMember.isAudioConnected]
  )

  // 重复开启云录制

  const handleRecord = useCallback(() => {
    let checkedAISummary = false

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
