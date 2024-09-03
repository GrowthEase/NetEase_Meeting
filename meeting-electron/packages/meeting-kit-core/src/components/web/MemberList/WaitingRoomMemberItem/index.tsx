import { Button, Checkbox, Dropdown, MenuProps } from 'antd'
import React, { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { NECommonError, NEWaitingRoomMember } from 'neroom-types'
import NEMeetingService from '../../../../services/NEMeeting'
import UserAvatar from '../../../common/Avatar'
import Modal, { ConfirmModal } from '../../../common/Modal'
import Toast from '../../../common/toast'
import './index.less'
import { useMeetingInfoContext } from '../../../../store'
import CommonModal from '../../../common/CommonModal'

interface MemberItemProps {
  data: NEWaitingRoomMember
  neMeeting?: NEMeetingService
  handleUpdateUserNickname: (
    uuid: string,
    nickname: string,
    roomType: 'room' | 'waitingRoom'
  ) => void
}

const WaitingRoomMemberItem: React.FC<MemberItemProps> = ({
  data,
  neMeeting,
  handleUpdateUserNickname,
}) => {
  const { t } = useTranslation()
  const { meetingInfo, memberList, inInvitingMemberList } =
    useMeetingInfoContext()
  const [waitingTime, setWaitingTime] = useState('')
  const waitingTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null)
  const notAllowJoinRef = useRef(false)
  const expelMemberModalRef = useRef<ConfirmModal | null>(null)

  function formatJoinTime(joinTime: number) {
    if (!joinTime) {
      return `${t('waiting')}--${t('hours')}--${'minutes'}`
    }

    // 根据joinTime格式化成等待x小时xx分这样的格式
    const nowTime = new Date().getTime()
    const time = nowTime - joinTime

    if (time > 0) {
      const hours = Math.floor(time / (3600 * 1000))
      const minutes = Math.floor((time - hours * 3600 * 1000) / (60 * 1000))

      if (hours === 0 && minutes === 0) {
        return ''
      }

      return `${t('waiting')}${hours > 0 ? hours + t('hours') : ''}${
        minutes > 0 ? minutes + t('minutes') : ''
      }`
    } else {
      return ''
    }
  }

  function admitMember(uuid: string, autoAdmit?: boolean) {
    const maxMembers = meetingInfo.maxMembers || 0
    const inInvitingMemberListLength = inInvitingMemberList?.length || 0
    const memberListLength = memberList.length

    if (memberListLength + inInvitingMemberListLength >= maxMembers) {
      Modal.warning({
        title: t('commonTitle'),
        content: t('participantUpperLimitTipAdmitOtherTip'),
      })
    } else {
      neMeeting?.admitMember(uuid, autoAdmit)?.catch((err: unknown) => {
        const knownError = err as { message: string; msg: string }

        Toast.fail(knownError?.msg || knownError?.message)
      })
    }
  }

  function expelMember(uuid: string) {
    if (expelMemberModalRef.current) {
      return
    }

    expelMemberModalRef.current = CommonModal.confirm({
      title: t('participantExpelWaitingMemberDialogTitle'),
      width: 400,
      content: meetingInfo.enableBlacklist && (
        <Checkbox
          className="close-checkbox-tip"
          defaultChecked={notAllowJoinRef.current}
          onChange={(e) => (notAllowJoinRef.current = e.target.checked)}
          style={{
            marginTop: '10px',
          }}
        >
          {t('notAllowJoin')}
        </Checkbox>
      ),
      afterClose() {
        expelMemberModalRef.current = null
      },
      cancelText: t('globalCancel'),
      okText: t('participantRemove'),
      onOk: async () => {
        try {
          await neMeeting?.expelMember(uuid, notAllowJoinRef.current)
        } catch (e: unknown) {
          const error = e as NECommonError

          Toast.fail(error?.msg || error?.message)
        }
      },
    })
  }

  useEffect(() => {
    setWaitingTime(formatJoinTime(data.joinTime))
    waitingTimerRef.current && clearInterval(waitingTimerRef.current)
    // 1分钟更新一次
    waitingTimerRef.current = setInterval(() => {
      setWaitingTime(formatJoinTime(data.joinTime))
    }, 60 * 1000)
  }, [data.joinTime])

  useEffect(() => {
    return () => {
      waitingTimerRef.current && clearInterval(waitingTimerRef.current)
    }
  }, [])

  const items: MenuProps['items'] = [
    {
      label: t('waitingRoomAutoAdmit'),
      key: 'waitingRoomAutoAdmit1',
    },
  ]

  return (
    <div className="waiting-room-member-item pd20">
      <div className="waiting-room-member-item-name">
        <div className="waiting-room-member-name-wrap">
          <UserAvatar
            className="waiting-room-member-item-avatar"
            nickname={data.name}
            avatar={data.avatar}
            size={24}
          />
          <div className="waiting-room-member-name">{data.name}</div>
          <svg
            className="icon iconfont icon-editx"
            aria-hidden="true"
            onClick={() =>
              handleUpdateUserNickname?.(data.uuid, data.name, 'waitingRoom')
            }
          >
            <use xlinkHref="#iconfd-editx" />
          </svg>
        </div>
        <div className="waiting-room-member-time">{waitingTime}</div>
      </div>
      <div className="waiting-room-operate">
        {data.status === 1 ? (
          <>
            <Dropdown
              rootClassName="waiting-room-auto-admit-dropdown"
              menu={{
                items,
                onClick: () => {
                  admitMember(data.uuid, true)
                },
              }}
            >
              <Button
                className="wating-room-operate-btn waiting-room-auto-admit-btn"
                size="small"
                onClick={() => admitMember(data.uuid)}
              >
                {t('admit')}
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#iconjiantou-xia-copy" />
                </svg>
              </Button>
            </Dropdown>
            <Button
              className="wating-room-operate-btn waiting-room-remove-btn"
              size="small"
              onClick={() => expelMember(data.uuid)}
            >
              {t('participantRemove')}
            </Button>
          </>
        ) : (
          <div className="waiting-room-joining">{t('joining')}</div>
        )}
      </div>
    </div>
  )
}

export default WaitingRoomMemberItem
