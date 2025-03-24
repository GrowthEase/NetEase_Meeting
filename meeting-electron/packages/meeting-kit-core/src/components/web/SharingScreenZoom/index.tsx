import React, { useEffect, useMemo, useRef } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { useTranslation } from 'react-i18next'
import './index.less'
import { ActionType, CommonModal, hostAction, Role, Toast } from '../../../kit'
import { Popover } from 'antd'
import useMouseInsideWindow from '../../../hooks/useMouseInsideWindow'
import classNames from 'classnames'

const SharingScreenZoom = () => {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const { t } = useTranslation()
  const { isMouseInsideWindow } = useMouseInsideWindow()

  const meetingInfoRef = useRef(meetingInfo)
  const [popoverOpen, setPopoverOpen] = React.useState(false)

  meetingInfoRef.current = meetingInfo
  const localMember = meetingInfo.localMember

  const isHostOrCoHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  const screenMember = useMemo(() => {
    if (!window.isElectronNative) {
      return
    }

    if (meetingInfo.pinVideoUuid) {
      return
    }

    if (meetingInfo.screenUuid !== meetingInfo.myUuid) {
      return memberList.find((item) => item.uuid === meetingInfo.screenUuid)
    }

    return
  }, [
    meetingInfo.screenUuid,
    meetingInfo.myUuid,
    meetingInfo.pinVideoUuid,
    memberList,
  ])

  const zoomList = useMemo(() => {
    return [
      {
        value: 0,
        label: t('adaptToTheWindow'),
        isChecked: meetingInfo.screenZoom === 0,
      },
      {
        value: 0.5,
        label: '50%',
        isChecked: meetingInfo.screenZoom === 0.5,
      },
      {
        value: 1,
        label: `100%（${t('actualSize')}）`,
        isChecked: meetingInfo.screenZoom === 1,
      },
      {
        value: 1.5,
        label: '150%',
        isChecked: meetingInfo.screenZoom === 1.5,
      },
      {
        value: 2,
        label: '200%',
        isChecked: meetingInfo.screenZoom === 2,
      },
      {
        value: 3,
        label: '300%',
        isChecked: meetingInfo.screenZoom === 3,
      },
    ]
  }, [meetingInfo.screenZoom])

  // const isAnnotationBtnShow = useMemo(() => {
  //   if (meetingInfo.screenUuid) {
  //     const screenMember = memberList.find(
  //       (item) => item.uuid === meetingInfo.screenUuid
  //     )

  //     if (
  //       screenMember?.clientType === NEClientType.MAC ||
  //       screenMember?.clientType === NEClientType.PC
  //     ) {
  //       if (
  //         meetingInfo.annotationPermission ||
  //         localMember.isSharingScreen ||
  //         isHostOrCoHost
  //       ) {
  //         return true
  //       }
  //     }
  //   }

  //   return false
  // }, [
  //   meetingInfo.annotationEnabled,
  //   meetingInfo.screenUuid,
  //   meetingInfo.annotationPermission,
  //   localMember.isSharingScreen,
  //   memberList,
  //   isHostOrCoHost,
  // ])

  function onZoom(zoom: number) {
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        screenZoom: zoom,
      },
    })
  }

  useEffect(() => {
    if (meetingInfo.screenUuid) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          screenZoom: 0,
        },
      })
    }
  }, [meetingInfo.screenUuid])

  return screenMember && isMouseInsideWindow ? (
    <div className="sharing-screen-zoom-wrapper">
      {t('youAreWatchingTheScreen', { name: screenMember.name })}
      <Popover
        rootClassName="sharing-screen-zoom-popover"
        trigger={['click']}
        placement="bottomRight"
        open={popoverOpen}
        onOpenChange={() => setPopoverOpen(!popoverOpen)}
        getPopupContainer={() =>
          document.getElementById('meeting-web') as HTMLElement
        }
        arrow={false}
        content={
          <div className={classNames('sharing-screen-zoom-content')}>
            <div className="sharing-screen-zoom-list">
              <div className="sharing-screen-zoom-content-title">
                {t('sharedScreenZoom')}
              </div>
              {zoomList.map((item) => (
                <div
                  className="sharing-screen-zoom-content-item"
                  key={item.value}
                  onClick={() => {
                    onZoom(item.value)
                    setPopoverOpen(false)
                  }}
                >
                  {item.label}
                  {item.isChecked && (
                    <svg
                      className="icon iconfont icongouxuan"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#icongouxuan"></use>
                    </svg>
                  )}
                </div>
              ))}
            </div>
            {isHostOrCoHost ? (
              <>
                <div className="sharing-screen-zoom-content-divider" />
                <div className="sharing-screen-zoom-list">
                  {/* {isAnnotationBtnShow && (
                    <Spin spinning={!meetingInfo.annotationEnabled}>
                      <div
                        className="sharing-screen-zoom-content-item"
                        onClick={() => {
                          if (!meetingInfo.annotationEnabled) {
                            return
                          }

                          const annotationDrawEnabled =
                            meetingInfoRef.current.annotationDrawEnabled

                          neMeeting?.setAnnotationEnableDraw(
                            !annotationDrawEnabled
                          )
                          dispatch?.({
                            type: ActionType.UPDATE_MEETING_INFO,
                            data: {
                              annotationDrawEnabled: !annotationDrawEnabled,
                            },
                          })
                          setPopoverOpen(false)
                        }}
                      >
                        {t('annotation')}
                      </div>
                    </Spin>
                  )} */}
                  {isHostOrCoHost ? (
                    <div
                      className="sharing-screen-zoom-content-item red"
                      onClick={() => {
                        CommonModal.confirm({
                          key: 'screenShareStop',
                          title: t('screenShareStop'),
                          content:
                            t('closeCommonTips') + t('closeScreenShareTips'),
                          onOk: async () => {
                            try {
                              await neMeeting?.sendHostControl(
                                hostAction.closeScreenShare,
                                meetingInfo.screenUuid
                              )
                            } catch {
                              Toast.fail(t('screenShareStopFail'))
                            }
                          },
                        })
                        setPopoverOpen(false)
                      }}
                    >
                      {t('screenShareStop')}
                    </div>
                  ) : null}
                </div>
              </>
            ) : null}
          </div>
        }
      >
        <div
          className={classNames('sharing-screen-zoom-button', {
            active: popoverOpen,
          })}
        >
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconzimugengduo"></use>
          </svg>
        </div>
      </Popover>
    </div>
  ) : null
}

export default SharingScreenZoom
