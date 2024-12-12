import React, { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Button, Radio, Dropdown, MenuProps } from 'antd'
import { AutoComplete } from 'antd/es'
import Toast from '../../common/toast'
import EventEmitter from 'eventemitter3'
import NEMeetingService from '../../../services/NEMeeting'
import BaseInput from '../../../app/src/components/input'
import { NEMeetingInviteStatus } from '../../../types/type'
import { useGlobalContext } from '../../../store'
import { EventType, SaveRoomSipCallItem } from '../../../types'
import { NERoomMember, NERoomSipDeviceInviteProtocolType } from 'neroom-types'
import { isLastCharacterEmoji, meetingDuration } from '../../../utils'
import {
  removeAllCallRecord,
  removeCallRecordItem,
  saveRoomSIPCallRecord,
} from '../../../utils/recordCall'
import useUserInfo from '../../../hooks/useUserInfo'

interface RoomSIPCallProps {
  neMeeting: NEMeetingService
  eventEmitter?: EventEmitter
}

const RoomSIP: React.FC<RoomSIPCallProps> = ({ neMeeting }) => {
  const { t } = useTranslation()
  const [roomIP, setRoomIP] = useState('')
  const { eventEmitter: eventEmitterContext } = useGlobalContext()
  const eventEmitter = eventEmitterContext

  const [inviteName, setInviteName] = useState({ value: '', valid: false })
  const [displayName, setDisplayName] = useState({ value: '', valid: false })
  const isComposingRef = useRef(false)
  const [calling, setCalling] = useState(false)
  const [isJoin, setIsJoin] = useState(false)
  const [callingLoading, setCallingLoading] = useState(false)
  // 接听时长
  const [durationTime, setDurationTime] = useState('')
  const [callingState, setCallingState] = useState<NEMeetingInviteStatus>(
    NEMeetingInviteStatus.unknown
  )

  const { getUserInfo } = useUserInfo()
  const [roomUserUuid, setRoomUserUuid] = useState('')

  const [selectProtocol, setSelectProtocol] =
    useState<NERoomSipDeviceInviteProtocolType>(1)

  const timerRef = useRef<null | ReturnType<typeof setTimeout>>()

  const [currentCallingInfo, setCurrentCallingInfo] = useState<{
    userUuid: string
    avatar?: string
    name: string
    dept?: string
    isSelected: boolean // 是否是选择的用户信息呼叫
  }>({
    userUuid: '',
    avatar: '',
    name: '',
    dept: '',
    isSelected: false,
  })
  const [recentCallList, setRecentCallList] = useState<SaveRoomSipCallItem[]>([])
  const [openRecentCallList, setOpenRecentCallList] = useState(false)
  useEffect(() => {
    function handleMemberSipInviteStateChanged(member: NERoomMember) {
      console.log('===============handleMemberSipInviteStateChanged', member)

      // 当前呼叫的成员状态变更
      if (member.uuid === currentCallingInfo.userUuid) {
        const inviteState =
          member.inviteState as unknown as NEMeetingInviteStatus

        setCallingState(inviteState)
        setIsJoin(false)

        if (inviteState === NEMeetingInviteStatus.canceled) {
          setCalling(false)
        }
      }
    }

    function handleMemberJoinRoom(members: NERoomMember[]) {
      console.log('===============handleMemberJoinRoom', members)

      // 当前呼叫人员入会
      const member = members.find(
        (item) => item.uuid === currentCallingInfo.userUuid
      )

      // 当前呼叫的成员状态变更
      if (member) {
        setIsJoin(true)
      }
    }

    function handleMemberLeaveRoom(members: NERoomMember[]) {
      console.log('===============handleMemberLeaveRoom', members)

      // 当前呼叫人员离开
      const member = members.find(
        (item) => item.uuid === currentCallingInfo.userUuid
      )

      // 当前呼叫的成员状态变更
      if (member) {
        setCalling(false)
      }
    }

    eventEmitter?.on(EventType.MemberJoinRoom, handleMemberJoinRoom)
    eventEmitter?.on(EventType.MemberLeaveRoom, handleMemberLeaveRoom)
    eventEmitter?.on(
      EventType.MemberSipInviteStateChanged,
      handleMemberSipInviteStateChanged
    )
    return () => {
      eventEmitter?.off(EventType.MemberJoinRoom, handleMemberJoinRoom)
      eventEmitter?.off(EventType.MemberLeaveRoom, handleMemberLeaveRoom)
      eventEmitter?.off(
        EventType.MemberSipInviteStateChanged,
        handleMemberSipInviteStateChanged
      )
    }
  }, [currentCallingInfo.userUuid, eventEmitter])

  useEffect(() => {
    if (isJoin) {
      const startTime = new Date().getTime()

      setDurationTime(meetingDuration(startTime))
      timerRef.current = setInterval(() => {
        setDurationTime(meetingDuration(startTime))
      }, 1000)

      return () => {
        setDurationTime('')
        timerRef.current && clearInterval(timerRef.current)
        timerRef.current = undefined
      }
    }
  }, [isJoin])

  useEffect(() => {
    updateRecentCallList()
  }, [])

  const updateRecentCallList = () => {
    //从localStorage中获取最近的通话列表
    const userInfo = getUserInfo()
    const _recentCallList = localStorage.getItem(
      `nemeeting-room-sip-call-${userInfo?.userUuid as string}`
    )
    if (_recentCallList) {
      setRecentCallList(JSON.parse(_recentCallList))
    }
  }

  const items: MenuProps['items'] = [
    ...recentCallList.map((item, index) => ({
      key: item.userUuid + index,
      label: (
        <div className="recent-call-item">
          <div className="recent-call-item-title">
          <span className="recent-sip-call-item-protocol-name">
              {item.protocol == 1 ? "SIP" : "H.323"}
            </span>
            <span className="recent-sip-call-item-phone-number">
              {item.roomIP}
            </span>
            <span className="recent-call-item-title-name">{item.name}</span>
          </div>
          <div
            onClick={(e) => {
              e.stopPropagation()
              const userInfo = getUserInfo()

              removeCallRecordItem(
                `nemeeting-room-sip-call-${userInfo?.userUuid as string}`,
                index
              )
              updateRecentCallList()
            }}
          >
            <svg
              style={{
                color: '#8D90A0',
              }}
              className="icon iconfont"
              aria-hidden="true"
            >
              <use xlinkHref="#iconqingkong"></use>
            </svg>
          </div>
        </div>
      ),
      onClick: () => {
        //设置ip呼叫地址、呼叫协议、呼叫名称
        setRoomIP(item.roomIP)
        setSelectProtocol(item.protocol)
        setInviteName({
          value: item.name,
          valid: true,
        })
      },
    })),

    {
      key: 'clear',
      label: <div className="recent-meeting-clear">{t('clearAll')}</div>,
      onClick: () => {
        const userInfo = getUserInfo()

        removeAllCallRecord(`nemeeting-room-sip-call-${userInfo?.userUuid as string}`)
        setRecentCallList([])
        Toast.success(t('clearAllSuccess'))
      },
    },
  ]

  const handleNameInputChange = (name: string) => {
    let userName = name

    if (!isComposingRef.current) {
      let inputLength = 0

      for (let i = 0; i < userName.length; i++) {
        // 检测字符是否为中文字符
        if (userName.charCodeAt(i) > 127) {
          inputLength += 2
        } else {
          inputLength += 1
        }

        // 判断当前字符长度是否超过限制，如果超过则终止 for 循环
        if (inputLength > 20) {
          // 是否表情结尾
          if (isLastCharacterEmoji(userName)) {
            userName = userName.slice(0, -2)
          } else {
            userName = userName.slice(0, i)
          }

          break
        }
      }
    }

    setInviteName({
      value: userName,
      valid: true,
    })
  }

  const handleSipInputChange = (value:string) => {
    //const value = e.target.value.trim()
    console.log('handleSipInputChange value: ', value)
    // 使用正则表达式来检查输入是否包含中文
    if (!/[\u4e00-\u9fa5]/.test(value)) {
      setRoomIP(value)
    }
  }

  // 点击呼叫处理函数
  const onCallingHandler = () => {
    setCallingLoading(true)
    setIsJoin(false)
    console.log(
      '===============onCallingHandler selectProtocol: ',
      selectProtocol
    )
    neMeeting
      ?.callOutRoomSystem({
        protocol: selectProtocol,
        deviceAddress: roomIP,
        name: inviteName.value,
      })
      ?.then((res) => {
        console.log('=======callOutRoomSystem===res==', res)

        if (!res) return
        const data = res.data
        //显示名称为服务器返回的name（如果邀请时没有设置name，服务器会分配一个）
        setDisplayName({value: data.name, valid: true})
        //将呼叫历史存储到localStorage
        const userInfo = getUserInfo()
        //限制存10条记录
        saveRoomSIPCallRecord(`nemeeting-room-sip-call-${userInfo?.userUuid as string}`, [
          {
            ...data,
            name: inviteName.value,
            protocol: selectProtocol,
            roomIP: roomIP,
          },
        ], 10)

        updateRecentCallList()
        setRoomUserUuid(data.userUuid)
        // 呼叫人已被呼叫中
        if (data.isRepeatedCall) {
          Toast.info(t('roomSipCallIsInInviting'))
          return
        }

        setCallingState(NEMeetingInviteStatus.calling)
        setCalling(true)
        setCurrentCallingInfo((info) => {
          return {
            ...info,
            userUuid: data.userUuid,
          }
        })
        //清除入会前填写的内容
        setRoomIP('')
        setSelectProtocol(NERoomSipDeviceInviteProtocolType.SIP)
        setInviteName({
          value: '',
          valid: true,
        })
      })
      .catch((e) => {
        console.warn('房间呼叫: ', e)
        let message = e.message
        switch(e.code) {
          case 1022:
            message = t('roomSipCallrLimit')
            break
          case 601011:
            message = t('roomSipCallIsInBlacklist')
            break
          case 3006:
            message = t('roomSipCallIsInMeeting')
            break
          default:
            if(message == 'kFailed_connect_server' || message == 'Network Error'){
              message = t('roomSipCallrNetworkError')
            } else if(e.message.includes('name length')) {
              message = t('roomSipCallrNickNameLimit')
            }
            break
        }
        Toast.fail(message)
      })
      .finally(() => {
        setCallingLoading(false)
      })
  }

  const isCalling = useMemo(() => {
    return (
      callingState === NEMeetingInviteStatus.calling ||
      callingState === NEMeetingInviteStatus.waitingCall ||
      isJoin
    )
  }, [callingState, isJoin])

  const isCallBusy = useMemo(() => {
    console.log('callingState: ', callingState)
    return (
      callingState === NEMeetingInviteStatus.busy
    )
  }, [callingState])

  const isSipProtocol = useMemo(() => {
    return (
      selectProtocol === NERoomSipDeviceInviteProtocolType.SIP
    )
  }, [selectProtocol])

  // 点击其他成员处理函数
  const onCallOtherHandler = () => {
    setCalling(false)
  }

  // 取消呼叫
  const onCallingCancelHandler = () => {
    if (roomUserUuid) {
      if (isCalling) {
        console.log('==========roomUserUuid=======', roomUserUuid)
        if (isJoin) {
          neMeeting?.hangUpCall(roomUserUuid)?.catch((e) => {
            Toast.fail(e.message)
          })
        } else {
          neMeeting
            ?.cancelCall(roomUserUuid)
            .then((res) => {
              console.log('==========res==', res)
              setCalling(false)
            })
            ?.catch((e) => {
              Toast.fail(e.message)
            })
        }
        setCalling(false)
      } else {
        //此时处于呼叫失败的状态，点击动作应该是重新呼叫
        //内部重新呼叫似乎使用callByUserUuid
        neMeeting?.callByUserUuid(roomUserUuid)?.catch((e) => {
          Toast.fail(e.message)
        })
        setCalling(true)
      }
    }
  }

  const onProtocolChange = (e) => {
    console.log('==========onProtocolChange===', e.target.value)
    setSelectProtocol(e.target.value)
  }

  return (
    <div>
      {!calling ? (
        <div className="nemeeting-room-sip-wrap">
          <div
            className="nemeeting-room-sip-line"
            style={{
              marginBottom: '16px',
            }}
          >
            <div className="room-sip-line-label">{t('sipCallRoom')}</div>
            <Dropdown
              trigger={openRecentCallList ? ['click'] : []}
              menu={{ items }}
              placement="bottom"
              autoAdjustOverflow={false}
              open={openRecentCallList && recentCallList.length > 0}
              onOpenChange={(open) => setOpenRecentCallList(open)}
              rootClassName="recent-call-dropdown"
              getPopupContainer={(node) => node}
              destroyPopupOnHide
            >
              <div className="nmemeeting-SIP-phone-select-wrap">
                {/* <Input
                  className="room-sip-line-input"
                  value={roomIP}
placeholder={t('sipCallOutRoomInputTip')}
                  allowClear
                  onChange={handleSipInputChange}
                ></Input> */}

                <AutoComplete
                  value={roomIP}
                  className={'nemeeting-room-SIP-phone-select'}
                  size="large"
                  defaultActiveFirstOption={false}
                  suffixIcon={null}
                  placeholder={isSipProtocol ? t('sipCallOutRoomInputTip') : t('h323CallOutRoomInputTip')}
                  onChange={handleSipInputChange}
                  notFoundContent={null}
                />

                {recentCallList.length > 0 ? (
                    <span
                      style={{
                        cursor: 'pointer',
                        position: 'absolute',
                        right: '0px',
                        fontSize: '16px',
                      }}
                      onClick={() => {
                        setTimeout(() => {
                          setOpenRecentCallList(!openRecentCallList)
                        }, 250)
                      }}
                      className="iconxiajiantou-up"
                    >
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconxiajiantou-shixin"></use>
                      </svg>
                    </span>
                ) : null}
              </div>
            </Dropdown>


          </div>



          <div className="nemeeting-room-choose">
            <div className="room-sip-line-label room-sip-display-name">
              {t('sipProtocol')}
            </div>
            <div>
              <Radio.Group onChange={onProtocolChange} value={selectProtocol}>
                <Radio value={1}>SIP</Radio>
                <Radio value={2}>H.323</Radio>
              </Radio.Group>
            </div>
          </div>
          <div className="nemeeting-room-sip-line nemeeting-room-sip-display-name">
            <div className="room-sip-line-label">{t('sipDisplayName')}</div>

            <BaseInput
              size="middle"
              value={inviteName.value}
              onChange={(e) => handleNameInputChange(e.currentTarget.value)}
              onCompositionStart={() => (isComposingRef.current = true)}
              onCompositionEnd={(e) => {
                isComposingRef.current = false
                handleNameInputChange(e.currentTarget.value)
              }}
              placeholder={t('sipNamePlaceholder')}
              set={setInviteName}
            />
          </div>
          <Button
            disabled={!roomIP}
            type="primary"
            className="nemeeting-room-sip-btn"
            onClick={onCallingHandler}
            loading={callingLoading}
          >
            {t('sipCall')}
          </Button>
        </div>
      ) : (
        // 呼叫界面
        <div className="nemeeting-SIP-calling-wrap">
          <div className="nemeeting-SIP-calling-num">{displayName.value}</div>

          {/* 呼叫状态 */}

          {isJoin ? (
            <div className="nemeeting-SIP-duration-time">{durationTime}</div>
          ) : (
            <div
              className={`${ isCalling ? 'nemeeting-SIP-calling' : 'nemeeting-SIP-calling-failed' }`}
            >
              {isCalling ? t('sipCalling') : (isCallBusy ?  t('sipCallStatusBusy') : t('sipCallFailed'))}
            </div>
          )}

          <div className="nemeeting-SIP-call-icon-wrap">
            <svg
              className="icon iconfont nemeeting-SIP-call-icon"
              aria-hidden="true"
              onClick={onCallingCancelHandler}
            >
              <use
                xlinkHref={isCalling ? '#iconguaduan' : '#iconjieting'}
              ></use>
            </svg>
            <div className="nemeeting-sip-call-status"
            onClick={onCallOtherHandler}
            >
              {isCalling
                ? isJoin
                  ? t('sipCallTerm')
                  : t('sipCallCancel')
                : t('sipCallAgain')}
            </div>
          </div>
          <div className="nemeeting-SIP-call-other-wrap">
            <span
              className="nemeeting-SIP-call-other"
              onClick={onCallOtherHandler}
            >
              {t('sipCallOthers') + ' >'}
            </span>
          </div>
        </div>
      )}
    </div>
  )
}

export default RoomSIP
