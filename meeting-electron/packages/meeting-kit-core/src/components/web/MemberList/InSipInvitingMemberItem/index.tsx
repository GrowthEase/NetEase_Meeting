import { Button } from 'antd'
import React, { useMemo } from 'react'
import { useTranslation } from 'react-i18next'
import NEMeetingService from '../../../../services/NEMeeting'
import { NEMember } from '../../../../types'
import { NEMeetingInviteStatus } from '../../../../types/type'
import UserAvatar from '../../../common/Avatar'
import Toast from '../../../common/toast'
import './index.less'

interface InvitingMemberItemProps {
  className?: string
  data: NEMember
  neMeeting?: NEMeetingService
}

const InSipInvitingMemberItem: React.FC<InvitingMemberItemProps> = ({
  data,
  neMeeting,
}) => {
  const { t } = useTranslation()

  const onClickRemoveHandler = () => {
    neMeeting?.removeCall(data.uuid)?.catch((e) => {
      Toast.fail(e.message)
    })
  }

  function cancelCall(uuid: string) {
    // 应用内
    if (data.inviteType === 2) {
      neMeeting?.cancelInvite(uuid)?.catch((e) => {
        Toast.fail(e.message)
      })
    } else {
      neMeeting?.cancelCall(uuid)?.catch((e) => {
        Toast.fail(e.message)
      })
    }
  }

  function callByUserUuid(uuid: string) {
    if (data.inviteType === 2) {
      neMeeting?.inviteByUserUuid(uuid)?.catch((e) => {
        Toast.fail(e.message)
      })
    } else {
      neMeeting?.callByUserUuid(uuid)?.catch((e) => {
        Toast.fail(e.message)
      })
    }
  }

  const onClickHandler = () => {
    switch (data.inviteState) {
      case NEMeetingInviteStatus.waitingCall:
        // 取消呼叫
        cancelCall(data.uuid)
        break
      case NEMeetingInviteStatus.calling:
        // 取消呼叫
        cancelCall(data.uuid)
        break
      case NEMeetingInviteStatus.waitingJoin:
      case NEMeetingInviteStatus.rejected:
        // 挂断
        callByUserUuid(data.uuid)
        break
      case NEMeetingInviteStatus.noAnswer:
        callByUserUuid(data.uuid)
        break
      case NEMeetingInviteStatus.canceled:
      case NEMeetingInviteStatus.busy:
        // 再次呼叫
        callByUserUuid(data.uuid)
        break
      case NEMeetingInviteStatus.error:
        // 再次呼叫
        callByUserUuid(data.uuid)
        break
    }
  }

  const stateText = useMemo(() => {
    const textMap = {
      [NEMeetingInviteStatus.error]: t('sipCallStatusError'),
      [NEMeetingInviteStatus.calling]:
        data.inviteType === 1 ? t('sipCallStatusCalling') : t('sipCalling'),
      [NEMeetingInviteStatus.waitingCall]: t('sipCallStatusWaiting'),
      [NEMeetingInviteStatus.waitingJoin]: t('callStatusWaitingJoin'),
      [NEMeetingInviteStatus.noAnswer]: t('sipCallStatusUnaccepted'),
      [NEMeetingInviteStatus.rejected]: t('sipCallStatusRejected'),
      [NEMeetingInviteStatus.canceled]: t('sipCallStatusCanceled'),
      [NEMeetingInviteStatus.busy]: t('sipCallStatusBusy'),
    }
    const color =
      data.inviteState ===
      (NEMeetingInviteStatus.calling || NEMeetingInviteStatus.waitingCall)
        ? '#26BD71'
        : '#999'

    return (
      <div style={{ color }} className="nemeeting-SIP-member-state">
        {textMap[data.inviteState]}
      </div>
    )
  }, [data.inviteState, data.inviteType, t])
  const btnText = useMemo(() => {
    const btnTextMap = {
      [NEMeetingInviteStatus.waitingCall]: t('globalCancel'),
      [NEMeetingInviteStatus.calling]: t('globalCancel'),
      [NEMeetingInviteStatus.waitingJoin]: t('sipCall'),
      [NEMeetingInviteStatus.rejected]: t('sipCall'),
      [NEMeetingInviteStatus.noAnswer]: t('sipCall'),
      [NEMeetingInviteStatus.canceled]: t('sipCall'),
      [NEMeetingInviteStatus.busy]: t('sipCall'),
      [NEMeetingInviteStatus.error]: t('sipCall'),
    }
    //做一层容错
    return btnTextMap[data.inviteState] || t('sipCall')
  }, [data.inviteState, t])
  const btnColor = useMemo(() => {
    const btnColorMap = {
      [NEMeetingInviteStatus.waitingCall]: '#F24957',
      [NEMeetingInviteStatus.calling]: '#F24957',
      [NEMeetingInviteStatus.waitingJoin]: '#26BD71',
      [NEMeetingInviteStatus.rejected]: '#26BD71',
      [NEMeetingInviteStatus.noAnswer]: '#26BD71',
      [NEMeetingInviteStatus.canceled]: '#26BD71',
      [NEMeetingInviteStatus.busy]: '#26BD71',
      [NEMeetingInviteStatus.error]: '#26BD71',
    }

    return btnColorMap[data.inviteState]
  }, [data.inviteState])

  return (
    <div className="nemeeting-SIP-member-item">
      <UserAvatar
        className="member-item-avatar"
        nickname={data.name}
        avatar={data.avatar}
        size={32}
      />
      <div className="nemeeting-SIP-member-name-wrapper">
        <div className="nemeeting-SIP-member-name">{data.name}</div>
        {stateText}
      </div>
      <div className="nemeeting-SIP-member-btn-wrapper">
        <Button
          style={{
            color: btnColor,
            borderColor: btnColor,
            height: 28,
            padding: ' 5px 12px',
            letterSpacing: '-1px',
            borderRadius: '8px',
          }}
          className="wating-room-operate-btn"
          size="small"
          onClick={() => onClickHandler()}
        >
          {btnText}
        </Button>
        <Button
          className="wating-room-operate-btn-rm"
          size="small"
          onClick={() => onClickRemoveHandler()}
        >
          {t('participantRemove')}
        </Button>
      </div>
    </div>
  )
}

export default InSipInvitingMemberItem
