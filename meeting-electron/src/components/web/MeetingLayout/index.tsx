import React, { useMemo, useState } from 'react'
import classNames from 'classnames'
import { useTranslation } from 'react-i18next'

import { Button, Divider, Popover, Switch, Dropdown, MenuProps } from 'antd'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import { ActionType, LayoutTypeEnum, Role } from '../../../types'
import Modal from '../../common/Modal'
import './index.less'
import Toast from '../../common/toast'
import useMeetingCanvas from '../../../hooks/useMeetingCanvas'
import { useUpdateEffect } from 'ahooks'

interface MeetingLayoutProps {
  className?: string
  onSettingClick?: () => void
}
// 会议持续时间
const MeetingLayout: React.FC<MeetingLayoutProps> = React.memo(
  ({ className, onSettingClick }) => {
    const { t } = useTranslation()
    const { dispatch, meetingInfo } = useMeetingInfoContext()
    const { neMeeting } = useGlobalContext()
    const [open, setOpen] = useState(false)

    const { layout, speakerLayoutPlacement, localMember } = meetingInfo

    const iconStr = useMemo(() => {
      if (meetingInfo.layout === LayoutTypeEnum.Gallery) {
        return '#iconyx-layout-2'
      }

      if (meetingInfo.speakerLayoutPlacement === 'top') {
        return '#iconyx-layout-1'
      }

      if (meetingInfo.speakerLayoutPlacement === 'right') {
        return '#iconyx-layout-3'
      }
    }, [meetingInfo.layout, meetingInfo.speakerLayoutPlacement])

    const enableRemoteViewOrder = useMemo(() => {
      return meetingInfo.remoteViewOrder !== undefined
    }, [meetingInfo.remoteViewOrder])

    const enableResetGalleryLayout = useMemo(() => {
      return !!meetingInfo.localViewOrder
    }, [meetingInfo.localViewOrder])

    const isHostOrCohost = useMemo(() => {
      return localMember.role === Role.host || localMember.role === Role.coHost
    }, [localMember.role])

    const handleRemoteViewOrder = (open: boolean) => {
      let viewOrder = ''

      if (localMember.role === Role.host && meetingInfo.localViewOrder) {
        viewOrder = meetingInfo.localViewOrder
      }

      neMeeting?.syncViewOrder(open, viewOrder)
    }

    /**
     * 重置画廊布局
     */
    const onResetGalleryLayout = async () => {
      // 如果开启了远程视图顺序，不允许重置
      if (enableRemoteViewOrder) {
        Modal.confirm({
          key: 'followGalleryLayoutResetConfirm',
          title: t('followGalleryLayoutResetConfirm'),
          okText: t('globalSure'),
          width: 300,
          footer: (
            <div className="nemeeting-modal-confirm-btns">
              <Button
                key="ok"
                type="primary"
                onClick={() => Modal.destroy('followGalleryLayoutResetConfirm')}
              >
                {t('globalSure')}
              </Button>
            </div>
          ),
        })
        return
      }

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          localViewOrder: '',
        },
      })
      setOpen(false)
    }

    const layoutGroups = [
      {
        key: 'galleryLayout',
        title: t('galleryLayout'),
        items: [
          {
            key: 'galleryLayoutGrid',
            icon: '#iconyx-layout-grid',
            title: t('galleryLayoutGrid'),
            active: layout === LayoutTypeEnum.Gallery,
            disable: !!meetingInfo.screenUuid,
            onClick: () => {
              if (meetingInfo.screenUuid) return
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  layout: LayoutTypeEnum.Gallery,
                },
              })
              setOpen(false)
            },
          },
        ],
      },
      {
        key: 'speakerLayout',
        title: t('speakerLayout'),
        items: [
          {
            key: 'speakerLayoutTop',
            icon: '#iconyx-layout-speaker-top',
            title: t('speakerLayoutTop'),
            active:
              layout === LayoutTypeEnum.Speaker &&
              speakerLayoutPlacement === 'top',
            onClick: () => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  layout: LayoutTypeEnum.Speaker,
                  speakerLayoutPlacement: 'top',
                },
              })
              setOpen(false)
            },
          },
          {
            key: 'speakerLayoutBottom',
            icon: '#iconyx-layout-speaker-right',
            title: t('speakerLayoutRight'),
            active:
              layout === LayoutTypeEnum.Speaker &&
              speakerLayoutPlacement === 'right',
            onClick: () => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  layout: LayoutTypeEnum.Speaker,
                  speakerLayoutPlacement: 'right',
                },
              })
              setOpen(false)
            },
          },
        ],
      },
    ]

    async function getScheduledMeetingViewOrder(): Promise<string | undefined> {
      const meetingNum = meetingInfo.meetingNum

      if (!meetingNum) return

      return neMeeting?.getMeetingInfoByFetch(meetingNum).then((res) => {
        const viewOrder = res.settings.roomInfo.viewOrder

        return viewOrder
      })
    }

    const items: MenuProps['items'] = [
      {
        key: 'save',
        label: t('save'),
        onClick: async () => {
          setOpen(false)

          const scheduledMeetingViewOrder = await getScheduledMeetingViewOrder()

          Modal.confirm({
            key: 'saveViewOrderConfirm',
            title: t('saveGalleryLayoutTitle'),
            content: scheduledMeetingViewOrder
              ? t('replaceGalleryLayoutContent')
              : t('saveGalleryLayoutContent'),
            okText: t('save'),
            width: 300,
            onOk: async () => {
              try {
                if (meetingInfo.remoteViewOrder) {
                  await neMeeting?.saveViewOrderInMeeting(
                    meetingInfo.remoteViewOrder
                  )
                }

                Toast.success(t('saveSuccess'))
              } catch {
                Toast.fail(t('saveFail'))
              }
            },
          })
        },
      },
      {
        key: 'load',
        label: t('load'),
        onClick: async () => {
          const scheduledMeetingViewOrder = await getScheduledMeetingViewOrder()

          if (!scheduledMeetingViewOrder) {
            Toast.info(t('noLoadGalleryLayout'))
          } else {
            setOpen(false)
            Modal.confirm({
              key: 'loadGalleryLayout',
              title: t('loadGalleryLayoutTitle'),
              content: t('loadGalleryLayoutContent'),
              okText: t('load'),
              width: 300,
              onOk: async () => {
                try {
                  if (scheduledMeetingViewOrder) {
                    await neMeeting?.syncViewOrder(
                      true,
                      scheduledMeetingViewOrder
                    )
                  }

                  Toast.success(t('loadSuccess'))
                } catch {
                  Toast.fail(t('loadFail'))
                }
              },
            })
          }
        },
      },
    ]

    return (
      <Popover
        overlayClassName="nemeeting-layout-list-popover"
        placement="topRight"
        arrow={false}
        open={open}
        onOpenChange={(open) => {
          setOpen(open)
        }}
        trigger="click"
        getPopupContainer={(node) => node}
        content={
          <>
            <div className="nemeeting-layout-header">
              <div>{t('layout')}</div>
              <div className="link-button" onClick={() => onSettingClick?.()}>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#iconyx-tv-settingx1"></use>
                </svg>
                {t('layoutSettings')}
              </div>
            </div>
            <div className="nemeeting-layout-list-content">
              {layoutGroups.map((layoutGroup, groupIndex) => (
                <div className="nemeeting-layout-group" key={layoutGroup.key}>
                  <div className="nemeeting-layout-group-title">
                    {layoutGroup.title}
                  </div>
                  <div className="nemeeting-layout-group-content">
                    {layoutGroup.items.map((item) => (
                      <div
                        className={classNames('nemeeting-layout-group-item', {
                          ['nemeeting-layout-group-item-active']: item.active,
                          ['nemeeting-layout-group-item-disable']: item.disable,
                        })}
                        key={item.key}
                        onClick={item.onClick}
                      >
                        <svg
                          className={classNames(
                            'icon iconfont nemeeting-layout-group-item-icon'
                          )}
                          aria-hidden="true"
                        >
                          <use xlinkHref={item.icon} />
                        </svg>
                        <div className="nemeeting-layout-group-item-text">
                          <svg
                            className={classNames(
                              'icon iconfont nemeeting-layout-group-item-radio'
                            )}
                            aria-hidden="true"
                          >
                            <use
                              xlinkHref={
                                item.active
                                  ? '#iconradiobuttonselect'
                                  : '#iconradiobuttonunselect'
                              }
                            />
                          </svg>
                          {item.title}
                        </div>
                      </div>
                    ))}
                    {groupIndex !== layoutGroups.length - 1 && (
                      <Divider
                        type="vertical"
                        className="nemeeting-layout-group-line"
                      />
                    )}
                  </div>
                </div>
              ))}
            </div>
            {enableResetGalleryLayout || isHostOrCohost ? (
              <div
                className="nemeeting-layout-footer"
                style={
                  localMember.role === 'member'
                    ? { justifyContent: 'center' }
                    : undefined
                }
              >
                {isHostOrCohost ? (
                  <div className="nemeeting-layout-footer-left">
                    <Switch
                      checked={enableRemoteViewOrder}
                      onChange={(checked) => {
                        handleRemoteViewOrder(checked)
                      }}
                    />
                    <span className="nemeeting-layout-footer-text">
                      {t('followGalleryLayout')}
                    </span>
                    <Popover content={t('followGalleryLayoutTips')}>
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#icona-45"></use>
                      </svg>
                    </Popover>
                    {enableRemoteViewOrder &&
                    meetingInfo.isScheduledMeeting !== 0 ? (
                      <Dropdown menu={{ items }}>
                        <svg
                          className={classNames('icon iconfont')}
                          aria-hidden="true"
                        >
                          <use xlinkHref="#icona-xialajiantou-xianxing-14px1"></use>
                        </svg>
                      </Dropdown>
                    ) : null}
                  </div>
                ) : null}
                {enableResetGalleryLayout ? (
                  <div
                    className="link-button"
                    onClick={() => onResetGalleryLayout()}
                  >
                    {t('resetGalleryLayout')}
                  </div>
                ) : null}
              </div>
            ) : null}
          </>
        }
      >
        <div className={classNames('nemeeting-layout-button', className)}>
          <svg className={classNames('icon iconfont')} aria-hidden="true">
            <use xlinkHref={iconStr}></use>
          </svg>
          <span className="nemeeting-layout-button-text">{t('layout')}</span>
          <svg
            className={classNames(
              'icon iconfont nemeeting-layout-button-allow'
            )}
            aria-hidden="true"
          >
            <use xlinkHref="#iconyx-allowx"></use>
          </svg>
        </div>
      </Popover>
    )
  }
)

export function useMeetingViewOrder(): void {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const { groupMembers } = useMeetingCanvas({
    isSpeaker: false,
    isSpeakerLayoutPlacementRight: false,
    isAudioMode: false,
    groupNum: 4,
    resizableWidth: 0,
    groupType: 'web',
  })

  const { localMember } = meetingInfo

  useUpdateEffect(() => {
    // 主持人同步本地视图顺序
    if (localMember.role === Role.host && meetingInfo.remoteViewOrder === '') {
      const members = groupMembers[0]
      const viewOrder = members.map((member) => member.uuid).join(',')

      neMeeting?.syncViewOrder(true, viewOrder)
    }
  }, [meetingInfo.remoteViewOrder, localMember.role])

  useUpdateEffect(() => {
    // 同步主持人的本地拖动
    if (
      localMember.role === Role.host &&
      meetingInfo.remoteViewOrder !== undefined &&
      meetingInfo.localViewOrder
    ) {
      neMeeting?.syncViewOrder(true, meetingInfo.localViewOrder)
    }
  }, [meetingInfo.localViewOrder])
}

export default MeetingLayout
