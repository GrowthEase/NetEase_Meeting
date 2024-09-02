// 通讯录邀请

import { Button } from 'antd'
import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'
import NEMeetingService from '../../../services/NEMeeting'
import {
  ActionType,
  Dispatch,
  NEMember,
  SearchAccountInfo,
} from '../../../types'
import AddressBook from '../../common/AddressBook'
import Toast from '../../common/toast'
import './index.less'
import { useMeetingInfoContext } from '../../../store'
import { NEMeetingInviteStatus } from '../../../types/type'
import { NEWaitingRoomMember } from 'neroom-types'

interface AddressInvitationProps {
  className?: string
  neMeeting: NEMeetingService
  memberList?: NEMember[]
  inSipInvitingMemberList?: NEMember[]
  myUuid: string
  onClose?: (e: React.MouseEvent<HTMLButtonElement>) => void
  dispatch?: Dispatch
}
const AddressInvitation: React.FC<AddressInvitationProps> = ({
  className,
  neMeeting,
  memberList,
  inSipInvitingMemberList,
  myUuid,
  onClose,
  dispatch,
}) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const [selectedMembers, setSelectedMembers] = useState<SearchAccountInfo[]>(
    []
  )

  const [loading, setLoading] = useState(false)

  function isInMemberList(
    memberList: NEMember[] | NEWaitingRoomMember[],
    userUuid
  ): boolean {
    const index = memberList.findIndex((item) =>
      item.uuid === userUuid
        ? item.inviteState === NEMeetingInviteStatus.calling ||
          item.inviteState === NEMeetingInviteStatus.waitingCall
        : false
    )

    return index > -1
  }

  const onMembersChange = (member: SearchAccountInfo, isChecked: boolean) => {
    if (inSipInvitingMemberList && isChecked) {
      // 判断选中的人是否有在呼叫中的且是等待呼叫或者呼叫中的状态 有的话不允许选中
      const isIn = isInMemberList(inSipInvitingMemberList, member.userUuid)

      if (isIn) {
        Toast.fail(t('sipCallIsInInviting'))
        return
      }
    }

    const tmpSelectedMembers = [...selectedMembers]

    if (isChecked) {
      if (isChecked && memberList) {
        // 判断选中的人是否有在会议中的 有的话不允许选中
        const index = memberList.findIndex(
          (item) => item.uuid === member.userUuid
        )

        if (index > -1) {
          Toast.fail(t('sipCallIsInMeeting'))
          return
        }
      }

      tmpSelectedMembers.push(member)
    } else {
      // 删除对应项
      const index = tmpSelectedMembers.findIndex(
        (item) => item.userUuid === member.userUuid
      )

      if (index > -1) {
        tmpSelectedMembers.splice(index, 1)
      }
    }

    setSelectedMembers(tmpSelectedMembers)
  }

  const onSaveHandler = () => {
    const uuids = selectedMembers.map((item) => item.userUuid)

    if (uuids.length > 0) {
      setLoading(true)
      neMeeting
        .inviteByUserUuids(uuids)
        ?.then(() => {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              rightDrawerTabActiveKey: 'memberList',
              activeMemberManageTab: 'invite',
            },
          })
          onClose?.()
        })
        .catch((e) => {
          Toast.fail(e.message)
        })
        .finally(() => {
          setLoading(false)
        })
    }
  }

  return (
    <div className={`nemeeting-address-book-invitation ${className || ''}`}>
      <AddressBook
        myUuid={myUuid}
        neMeeting={neMeeting}
        maxCount={meetingInfo.maxMembers}
        selectedMembers={selectedMembers}
        onChange={onMembersChange}
      />
      <div className={'nemeeting-address-book-invitation-btn-wrap'}>
        <Button
          className="nemeeting-address-book-invitation-btn"
          type="primary"
          size="large"
          disabled={selectedMembers.length === 0}
          loading={loading}
          onClick={onSaveHandler}
        >
          {t('globalSure')}
        </Button>
      </div>
    </div>
  )
}

export default AddressInvitation
