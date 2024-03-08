import React, { useEffect, useMemo, useRef, useState } from 'react'
import { Button, Checkbox, Dropdown, Input, message } from 'antd'
import { MenuProps } from 'antd'
import { useTranslation } from 'react-i18next'
import classNames from 'classnames'

import { NEMeetingInfo } from '../../../../types'

import './index.less'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import Modal from '../../../common/Modal'
import Toast from '../../../common/toast'
import UpdateUserNicknameModal from '../../BeforeMeetingModal/UpdateUserNicknameModal'
import AudioIcon from '../../../common/AudioIcon'
import NEMeetingService from '../../../../services/NEMeeting'
import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface'
import UserAvatar from '../../../common/Avatar'

interface MemberItemProps {
  data: NEWaitingRoomMember
  meetingInfo: NEMeetingInfo
  neMeeting?: NEMeetingService
  handleUpdateUserNickname: (
    uuid: string,
    nickname: string,
    roomType: 'room' | 'waitingRoom'
  ) => void
}

const WaitingRoomMemberItem: React.FC<MemberItemProps> = ({
  data,
  meetingInfo,
  neMeeting,
  handleUpdateUserNickname,
}) => {
  const { t } = useTranslation()
  const [waitingTime, setWaitingTime] = useState('')
  const [updateUserNicknameModalOpen, setUpdateUserNicknameModalOpen] =
    useState(false)
  const waitingTimerRef = useRef<any>(null)
  const notAllowJoinRef = useRef(false)
  const expelMemberModalRef = useRef<any>(null)

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

  function admitMember(uuid: string) {
    neMeeting?.admitMember(uuid)?.catch((error: any) => {
      Toast.fail(error?.msg || error?.message)
      throw error
    })
  }

  function expelMember(uuid: string) {
    if (expelMemberModalRef.current) {
      return
    }
    expelMemberModalRef.current = Modal.confirm({
      title: t('removeWaitingRoomMember'),
      content: (
        <Checkbox
          className="close-checkbox-tip"
          defaultChecked={notAllowJoinRef.current}
          onChange={(e) => (notAllowJoinRef.current = e.target.checked)}
        >
          {t('notAllowJoin')}
        </Checkbox>
      ),
      afterClose() {
        expelMemberModalRef.current = null
      },
      okText: t('removeMember'),
      onOk: async () => {
        try {
          await neMeeting?.expelMember(uuid, notAllowJoinRef.current)
        } catch (e: any) {
          Toast.fail(e?.msg || e?.message)
        }
      },
    })
  }

  useEffect(() => {
    setWaitingTime(formatJoinTime(data.joinTime))
    clearInterval(waitingTimerRef.current)
    // 1分钟更新一次
    waitingTimerRef.current = setInterval(() => {
      setWaitingTime(formatJoinTime(data.joinTime))
    }, 60 * 1000)
  }, [data.joinTime])

  useEffect(() => {
    return () => {
      clearInterval(waitingTimerRef.current)
    }
  }, [])

  return (
    <div className="waiting-room-member-item">
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
            <Button
              className="wating-room-operate-btn mr-15"
              size="small"
              onClick={() => admitMember(data.uuid)}
            >
              {t('admit')}
            </Button>
            <Button
              className="wating-room-operate-btn"
              size="small"
              onClick={() => expelMember(data.uuid)}
            >
              {t('removeMember')}
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
