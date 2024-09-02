import React, { useEffect, useMemo, useRef, useState } from 'react'

import { Button, ModalProps } from 'antd'
import Modal from '../../common/Modal'

import EventEmitter from 'eventemitter3'
import { useTranslation } from 'react-i18next'
import NEMeetingService from '../../../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import {
  Dispatch,
  GetMeetingConfigResponse,
  NEMeetingInfo,
  NEMember,
  Role,
} from '../../../types'
import { formatDate, getGMTTimeText } from '../../../utils'
import Toast from '../../common/toast'
import AddressInvitation from './AddressInvitation'
import './index.less'
import SIP from './SIP'
import useWatermark from '../../../hooks/useWatermark'

const InviteModal: React.FC<ModalProps> = ({ onCancel, ...restProps }) => {
  const { t } = useTranslation()
  const { meetingInfo, memberList, inInvitingMemberList, dispatch } =
    useMeetingInfoContext()
  const { globalConfig, neMeeting } = useGlobalContext()
  const SIPNumber = globalConfig?.appConfig.outboundPhoneNumber
  const localMember = meetingInfo?.localMember

  return (
    <Modal
      title={t('inviteBtn')}
      footer={null}
      onCancel={onCancel}
      width={498}
      wrapClassName="invite-modal"
      {...restProps}
    >
      {neMeeting && (
        <InviteContent
          myUuid={localMember.uuid || ''}
          memberList={memberList}
          inSipInvitingMemberList={inInvitingMemberList}
          neMeeting={neMeeting}
          onCancel={onCancel}
          meetingInfo={meetingInfo}
          SIPNumber={SIPNumber}
          meetingInfoDispatch={dispatch}
        />
      )}
    </Modal>
  )
}

interface InviteInfoProps {
  meetingInfo?: NEMeetingInfo
  onCancel?: (e: React.MouseEvent<HTMLButtonElement>) => void
  globalConfig?: GetMeetingConfigResponse
  className?: string
  style?: React.CSSProperties
  isHostOrCoHost?: boolean
}

interface TabsProps {
  activeTab?: string
  changeTab: (tab: string) => void
  className?: string
  globalConfig?: GetMeetingConfigResponse
}
const Tabs: React.FC<TabsProps> = ({
  changeTab,
  className,
  activeTab,
  globalConfig,
}) => {
  const { t } = useTranslation()

  const config = globalConfig?.appConfig?.APP_ROOM_RESOURCE

  return config?.appInvite || config?.sipInvite ? (
    <div className={`nemeeting-local-tabs ${className || ''}`}>
      <div
        className={`nemeeting-local-tab ${
          activeTab == 'invite' ? 'nemeeting-tab-selected' : ''
        }`}
        onClick={() => changeTab('invite')}
      >
        {t('sipInviteInfo')}
      </div>
      {config?.appInvite && (
        <div
          className={`nemeeting-local-tab ${
            activeTab == 'contact' ? 'nemeeting-tab-selected' : ''
          }`}
          onClick={() => changeTab('contact')}
        >
          {t('sipAddressInvite')}
        </div>
      )}
      {config.sipInvite && (
        <div
          className={`nemeeting-local-tab ${
            activeTab == 'SIP' ? 'nemeeting-tab-selected' : ''
          }`}
          onClick={() => changeTab('SIP')}
        >
          {t('sipCallByPhone')}
        </div>
      )}
    </div>
  ) : null
}

const Invite: React.FC<InviteInfoProps> = ({
  meetingInfo,
  className,
  globalConfig,
  isHostOrCoHost,
}) => {
  const { t } = useTranslation()

  const inviteInfoContentRef = useRef<HTMLDivElement>(null)

  const displayId = useMemo(() => {
    if (meetingInfo?.meetingNum) {
      const id = meetingInfo.meetingNum

      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }

    return ''
  }, [meetingInfo?.meetingNum])

  function handleCopy() {
    const textarea = document.createElement('textarea')
    let msg = ''

    for (const child of (inviteInfoContentRef.current as HTMLElement)
      .children) {
      const item = child as HTMLElement

      msg = msg.concat(item.innerText + '\r\n\n')
    }

    textarea.setAttribute('readonly', 'readonly')
    msg = msg.slice(0, -3)
    textarea.innerHTML = msg
    document.body.appendChild(textarea)
    textarea.setSelectionRange(0, 9999)
    textarea.select()
    if (document.execCommand) {
      document.execCommand('copy')
      Toast.success(t('copySuccess'))
    }

    document.body.removeChild(textarea)
    // onCancel?.(e) // 复制成功后不需要关闭弹窗
  }

  const inviteInfoItems = [
    {
      label: t('defaultMeetingInfoTitle'),
      isShow: true,
      className: 'invite-info-title',
    },
    {
      label: `${t('inviteSubject')}：${meetingInfo?.subject}`,
      isShow: true,
    },
    {
      label: `${t('inviteTime')}：${formatDate(
        meetingInfo?.startTime || 0,
        'YYYY-MM-DD HH:mm',
        meetingInfo?.timezoneId
      )} - ${formatDate(
        meetingInfo?.endTime || 0,
        'YYYY-MM-DD HH:mm',
        meetingInfo?.timezoneId
      )}
      ${getGMTTimeText(meetingInfo?.timezoneId)}`,
      isShow: meetingInfo?.type === 3,
    },
    {
      label: `${t('meetingNumber')}：${displayId}`,
      key: 'displayId',
      isShow: true,
    },
    {
      label: `${t('shortId')}：${meetingInfo?.shortMeetingNum}`,
      key: 'shortMeetingNum',
      isShow: meetingInfo?.type === 2 && meetingInfo?.shortMeetingNum,
    },
    {
      label: `${t('meetingPassword')}：${meetingInfo?.password}`,
      isShow: !!meetingInfo?.password,
    },
    {
      label: `${t('meetingInviteUrl')}：${meetingInfo?.meetingInviteUrl}`,
      isShow: !!meetingInfo?.meetingInviteUrl,
    },
    {
      label: `${t('meetingMobileDialInTitle')}：${t('meetingMobileDialInMsg', {
        phoneNumber: globalConfig?.appConfig.inboundPhoneNumber,
      })} ${t('meetingInputSipNumber', {
        sipNumber: meetingInfo?.sipCid,
      })}`,
      isShow:
        !!meetingInfo?.sipCid && !!globalConfig?.appConfig.inboundPhoneNumber,
    },
    {
      label: `${t('meetingSipNumber')}：${t('meetingInputSipNumber', {
        sipNumber: meetingInfo?.sipCid,
      })}`,
      isShow: !!meetingInfo?.sipCid,
    },
  ].filter((item) => Boolean(item.isShow))

  return (
    <>
      <div className={`invite-info-content ${className || ''}`}>
        <div
          ref={inviteInfoContentRef}
          className="nemeeting-info-content-scroll"
          style={
            !isHostOrCoHost ? { height: '340px', marginTop: '20px' } : undefined
          }
        >
          {inviteInfoItems.map((item) => (
            <div
              className={`invite-info-item ${item.className || ''}`}
              key={item.label}
            >
              {item.label?.split('：')?.map((text, index) => {
                return (
                  <div
                    key={text}
                    className={`${
                      index === 0
                        ? 'invite-info-item-key'
                        : 'invite-info-item-content'
                    }`}
                  >
                    {text}
                    {item.key === 'shortMeetingNum' &&
                      index === item.label?.split('：')?.length - 1 && (
                        <span className="nemeeting-invite-tag">
                          {t('internalOnly')}
                        </span>
                      )}
                    {item.key === 'displayId' &&
                      index === item.label?.split('：')?.length - 1 &&
                      meetingInfo?.enableGuestJoin && (
                        <div>{t('meetingGuestJoinSupported')}</div>
                      )}
                  </div>
                )
              })}
            </div>
          ))}
        </div>
      </div>
      <div className="invite-info-footer">
        <Button
          className="invite-info-copy-button"
          type="primary"
          shape="round"
          size="large"
          onClick={handleCopy}
        >
          {t('meetingCopyInvite')}
        </Button>
      </div>
    </>
  )
}

interface InviteContentProps {
  className?: string
  onCancel?: (e: React.MouseEvent<HTMLButtonElement>) => void
  meetingInfo?: NEMeetingInfo
  neMeeting: NEMeetingService
  SIPNumber?: string
  memberList: NEMember[]
  inSipInvitingMemberList?: NEMember[]
  myUuid: string
  eventEmitter?: EventEmitter
  meetingInfoDispatch?: Dispatch
}

const InviteContent: React.FC<InviteContentProps> = ({
  onCancel,
  meetingInfo,
  neMeeting,
  SIPNumber,
  inSipInvitingMemberList,
  memberList,
  myUuid,
  eventEmitter,
  meetingInfoDispatch,
}) => {
  const [activeTab, setActiveTab] = useState<string>('invite')
  const { globalConfig } = useGlobalContext()
  const domRef = useRef<HTMLDivElement>(null)

  useWatermark({ container: domRef })

  const onTableChange = (tab: string) => {
    setActiveTab(tab)
  }

  const isHostOrCoHost = useMemo(() => {
    const role = meetingInfo?.localMember.role

    return role === Role.host || role === Role.coHost
  }, [meetingInfo?.localMember.role])

  useEffect(() => {
    if (!isHostOrCoHost) {
      setActiveTab('invite')
    }
  }, [isHostOrCoHost])

  return (
    <div className={'nemeeting-invite-content'} ref={domRef}>
      {isHostOrCoHost && (
        <Tabs
          changeTab={onTableChange}
          className={'nemeeting-SIP-tab'}
          activeTab={activeTab}
          globalConfig={globalConfig}
        />
      )}

      {activeTab === 'invite' && (
        <Invite
          className={'nemeeting-tab-content nemeeting-tab-content-small'}
          isHostOrCoHost={isHostOrCoHost}
          meetingInfo={meetingInfo}
          onCancel={onCancel}
          globalConfig={globalConfig}
        />
      )}
      {activeTab === 'contact' && isHostOrCoHost && (
        <AddressInvitation
          neMeeting={neMeeting}
          memberList={memberList}
          inSipInvitingMemberList={inSipInvitingMemberList}
          myUuid={myUuid}
          onClose={onCancel}
          dispatch={meetingInfoDispatch}
        />
      )}
      {activeTab === 'SIP' && isHostOrCoHost && (
        <SIP
          myUuid={myUuid}
          inSipInvitingMemberList={inSipInvitingMemberList}
          memberList={memberList}
          className={'nemeeting-tab-content'}
          onCancel={onCancel}
          neMeeting={neMeeting}
          SIPNumber={SIPNumber}
          eventEmitter={eventEmitter}
          meetingInfoDispatch={meetingInfoDispatch}
        />
      )}
    </div>
  )
}

export { InviteContent }

export default InviteModal
