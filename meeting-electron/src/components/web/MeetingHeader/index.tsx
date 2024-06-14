import React, { useMemo } from 'react'
import { Drawer, DrawerProps, Popover, Divider } from 'antd'
import { useTranslation } from 'react-i18next'

import './index.less'
import { useMeetingInfoContext } from '../../../store'
import Toast from '../../common/toast'
import { copyElementValue } from '../../../utils'

const MeetingHeader: React.FC<DrawerProps> = ({ ...restProps }) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()

  const { localMember } = meetingInfo

  const displayId = useMemo(() => {
    if (meetingInfo?.meetingNum) {
      const id = meetingInfo.meetingNum

      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }

    return ''
  }, [meetingInfo?.meetingNum])

  function handleCopy(value?: string) {
    copyElementValue(value, () => {
      Toast.success('复制成功')
    })
  }

  return (
    <Drawer
      placement="top"
      closable={false}
      mask={false}
      height={50}
      rootClassName="meeting-header-container"
      {...restProps}
    >
      <div className="meeting-header-content">
        <div />
        <div className="meeting-header-title">
          {meetingInfo.subject}
          <Popover
            trigger={['click']}
            content={
              <div className="meeting-info-content">
                <div className="meeting-info-title">{meetingInfo.subject}</div>
                <div className="meeting-info-security-title">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#iconcertification1x"></use>
                  </svg>
                  {t('securityInfo')}
                </div>
                <Divider />
                <div className="meeting-info-item">
                  <div className="meeting-info-item-title">
                    {t('meetingId')}
                  </div>
                  <div className="meeting-info-item-content">
                    {displayId}{' '}
                    <svg
                      className="icon iconfont"
                      aria-hidden="true"
                      onClick={() => handleCopy(meetingInfo.meetingNum)}
                    >
                      <use xlinkHref="#iconcopy1x"></use>
                    </svg>
                  </div>
                </div>
                {meetingInfo?.password && (
                  <div className="meeting-info-item">
                    <div className="meeting-info-item-title">
                      {t('meetingPassword')}
                    </div>
                    <div className="meeting-info-item-content">
                      {meetingInfo.password}{' '}
                      <svg
                        className="icon iconfont"
                        aria-hidden="true"
                        onClick={() => handleCopy(meetingInfo.password)}
                      >
                        <use xlinkHref="#iconcopy1x"></use>
                      </svg>
                    </div>
                  </div>
                )}
                <div className="meeting-info-item">
                  <div className="meeting-info-item-title">{t('host')}</div>
                  <div className="meeting-info-item-content">
                    {meetingInfo.hostName}
                  </div>
                </div>
                <div className="meeting-info-item">
                  <div className="meeting-info-item-title">
                    {t('meetingInviteUrl')}
                  </div>
                  <div className="meeting-info-item-content">
                    {meetingInfo.meetingInviteUrl}
                  </div>
                  <svg
                    className="icon iconfont"
                    aria-hidden="true"
                    onClick={() => handleCopy(meetingInfo.meetingInviteUrl)}
                  >
                    <use xlinkHref="#iconcopy1x"></use>
                  </svg>
                </div>
              </div>
            }
            placement="bottom"
          >
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#icona-45"></use>
            </svg>
          </Popover>
        </div>
        <div className="meeting-header-avatar">
          {localMember.name.charAt(0)}
        </div>
      </div>
    </Drawer>
  )
}

export default MeetingHeader
