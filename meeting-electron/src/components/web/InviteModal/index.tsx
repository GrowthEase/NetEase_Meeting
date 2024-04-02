import React, { useMemo, useRef } from 'react'

import Modal from '../../common/Modal'
import { Button, ModalProps } from 'antd'

import './index.less'
import { useTranslation } from 'react-i18next'
import { useMeetingInfoContext } from '../../../store'
import { formatDate } from '../../../utils'
import Toast from '../../common/toast'
import { NEMeetingInfo } from '../../../types'

const InviteModal: React.FC<ModalProps> = ({ onCancel, ...restProps }) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()

  return (
    <Modal
      title={t('inviteBtn')}
      footer={null}
      onCancel={onCancel}
      width={400}
      wrapClassName="invite-modal"
      {...restProps}
    >
      <Invite meetingInfo={meetingInfo} onCancel={onCancel} />
    </Modal>
  )
}

interface InviteInfoProps {
  meetingInfo?: NEMeetingInfo
  onCancel?: (e: React.MouseEvent<HTMLButtonElement>) => void
}

const Invite: React.FC<InviteInfoProps> = ({ meetingInfo, onCancel }) => {
  const { t } = useTranslation()

  const inviteInfoContentRef = useRef<HTMLDivElement>(null)

  const displayId = useMemo(() => {
    if (meetingInfo?.meetingNum) {
      const id = meetingInfo.meetingNum
      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6)
    }
    return ''
  }, [meetingInfo?.meetingNum])

  function handleCopy(e) {
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
        'yyyy-MM-dd hh:mm'
      )} - ${formatDate(meetingInfo?.endTime || 0, 'yyyy-MM-dd hh:mm')}`,
      isShow: meetingInfo?.type === 3,
    },
    {
      label: `${t('meetingNumber')}：${displayId}`,
      isShow: true,
    },
    {
      label: `${t('shortId')}：${meetingInfo?.shortMeetingNum}`,
      key: 'shortMeetingNum',
      isShow: meetingInfo?.type === 2 && meetingInfo?.shortMeetingNum,
    },
    {
      label: `${t('sip')}：${meetingInfo?.sipCid}`,
      isShow: !!meetingInfo?.sipCid,
    },
    {
      label: `${t('meetingPassword')}：${meetingInfo?.password}`,
      isShow: !!meetingInfo?.password,
    },
    {
      label: `${t('meetingInviteUrl')}：${meetingInfo?.meetingInviteUrl}`,
      isShow: !!meetingInfo?.meetingInviteUrl,
    },
  ].filter((item) => Boolean(item.isShow))

  return (
    <>
      <div className="invite-info-content" ref={inviteInfoContentRef}>
        {inviteInfoItems.map((item) => (
          <div
            className={`invite-info-item ${item.className || ''}`}
            key={item.label}
          >
            {item.label?.split('：')?.map((text, index) => {
              return (
                <div
                  key={text}
                  className={`${index === 0 ? 'invite-info-item-key' : ''}`}
                >
                  {text}
                  {item.key === 'shortMeetingNum' &&
                    index === item.label?.split('：')?.length - 1 && (
                      <span className="tag">{t('internalOnly')}</span>
                    )}
                </div>
              )
            })}
          </div>
        ))}
      </div>
      <div className="invite-info-footer">
        <Button
          className="invite-info-copy-button"
          type="primary"
          onClick={handleCopy}
        >
          {t('meetingCopyInvite')}
        </Button>
      </div>
    </>
  )
}

export { Invite }

export default InviteModal
