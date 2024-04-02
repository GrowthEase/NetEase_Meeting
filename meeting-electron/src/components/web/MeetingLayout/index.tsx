import React, { useEffect, useMemo, useRef, useState } from 'react'
import classNames from 'classnames'
import UpOutlined from '@ant-design/icons/UpOutlined'
import { useTranslation } from 'react-i18next'

import './index.less'
import { Divider, Popover } from 'antd'
import { useMeetingInfoContext } from '../../../store'
import { ActionType, LayoutTypeEnum } from '../../../types'
interface MeetingLayoutProps {
  className?: string
}
// 会议持续时间
const MeetingLayout: React.FC<MeetingLayoutProps> = React.memo(
  ({ className }) => {
    const { t } = useTranslation()
    const { dispatch, meetingInfo } = useMeetingInfoContext()
    const [open, setOpen] = useState(false)

    const { layout, speakerLayoutPlacement } = meetingInfo

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
              if (!!meetingInfo.screenUuid) return
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

export default MeetingLayout
