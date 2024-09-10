import { Button, Tabs, TabsProps, Dropdown, MenuProps } from 'antd'
import { AutoComplete } from 'antd/es'
import EventEmitter from 'eventemitter3'
import { NERoomMember } from 'neroom-types'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import BaseInput from '../../../app/src/components/input/baseInput'
import NEMeetingService from '../../../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import {
  ActionType,
  Dispatch,
  EventType,
  SaveSipCallItem,
  SearchAccountInfo,
} from '../../../types'
import { NEMeetingInviteStatus, NEMember } from '../../../types/type'
import { debounce, isLastCharacterEmoji, meetingDuration } from '../../../utils'
import UserAvatar from '../../common/Avatar'
import Toast from '../../common/toast'
import BatchSIP from './BatchSIP'
import {
  removeAllCallRecord,
  removeCallRecordItem,
  saveCallRecord,
} from '../../../utils/recordCall'
import useUserInfo from '../../../hooks/useUserInfo'

interface SIPProps {
  className?: string
  onCancel?: (e?: React.MouseEvent<HTMLButtonElement>) => void
  neMeeting: NEMeetingService
  SIPNumber?: string
  memberList: NEMember[]
  myUuid: string
  inSipInvitingMemberList?: NEMember[]
  eventEmitter?: EventEmitter
  meetingInfoDispatch?: Dispatch
}

interface SIPCallProps {
  className?: string
  neMeeting: NEMeetingService
  SIPNumber?: string
  eventEmitter?: EventEmitter
}

const SIP: React.FC<SIPProps> = (props) => {
  const {
    className,
    onCancel,
    neMeeting,
    SIPNumber,
    eventEmitter,
    myUuid,
    memberList,
    inSipInvitingMemberList,
  } = props
  const { dispatch: dispatchContext } = useMeetingInfoContext()
  const dispatch = props.meetingInfoDispatch || dispatchContext

  const { t } = useTranslation()

  const items: TabsProps['items'] = [
    {
      key: 'sipKeypad',
      label: <div className="nemeeting-tab-label-name">{t('sipKeypad')}</div>,
      children: (
        <SIPCall
          neMeeting={neMeeting}
          SIPNumber={SIPNumber}
          eventEmitter={eventEmitter}
        />
      ),
    },
    {
      key: 'sipBatchCall',
      label: (
        <div className="nemeeting-tab-label-name">{t('sipBatchCall')}</div>
      ),
      children: (
        <BatchSIP
          inSipInvitingMemberList={inSipInvitingMemberList}
          memberList={memberList}
          neMeeting={neMeeting}
          myUuid={myUuid}
          onCalled={() => {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabActiveKey: 'memberList',
                activeMemberManageTab: 'invite',
              },
            })
            onCancel?.()
          }}
        />
      ),
    },
  ]

  return (
    <div className={`nemeeting-invite-SIP-wrap ${className || ''}`}>
      <Tabs
        tabBarGutter={60}
        centered={true}
        defaultActiveKey="sipKeypad"
        items={items}
      />
    </div>
  )
}

// 批量呼叫

const SIPCall: React.FC<SIPCallProps> = (props) => {
  const { className, SIPNumber } = props
  const { t } = useTranslation()
  const [phone, setPhone] = useState('')
  const [inviteName, setInviteName] = useState({ value: '', valid: false })
  const [calling, setCalling] = useState(false)
  const { neMeeting: neMeetingContext, eventEmitter: eventEmitterContext } =
    useGlobalContext()
  const [callingLoading, setCallingLoading] = useState(false)
  const [countryCode] = useState('+86')
  // 是否接听入会
  const [isJoin, setIsJoin] = useState(false)
  // 接听时长
  const [durationTime, setDurationTime] = useState('')
  // 接听时长定时器
  const timerRef = useRef<null | ReturnType<typeof setTimeout>>()

  const [openRecentCallList, setOpenRecentCallList] = useState(false)
  const [recentCallList, setRecentCallList] = useState<SaveSipCallItem[]>([])
  const { getUserInfo } = useUserInfo()

  const eventEmitter = eventEmitterContext
  const neMeeting = props.neMeeting || neMeetingContext

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
  const [callingState, setCallingState] = useState<NEMeetingInviteStatus>(
    NEMeetingInviteStatus.unknown
  )
  const [membersBySearch, setMembersBySearch] = useState<SearchAccountInfo[]>(
    []
  )

  const isComposingRef = React.useRef(false)

  const phoneNumFormat = useMemo(() => {
    // 把手机号格式化为 123 4567 8901 的格式
    let phoneNumber = phone?.replace(/\s/g, '')
    const length = phoneNumber.length

    // 如果大于3小于7位，格式化为 123 4567
    if (length > 3 && length <= 7) {
      phoneNumber = phoneNumber.slice(0, 3) + ' ' + phoneNumber.slice(3)
    } else if (length > 7) {
      phoneNumber =
        phoneNumber.slice(0, 3) +
        ' ' +
        phoneNumber.slice(3, 7) +
        ' ' +
        phoneNumber.slice(7)
    }

    return phoneNumber
  }, [phone])

  // 去除中间空格的电话号码，发送请求使用这个
  const getCorrectPhone = (phone: string) => {
    return phone?.replace(/\s/g, '')
  }

  const onPhoneChange = (phoneNum: string) => {
    if (phoneNum.length > 11) {
      return
    }

    // 只能输入数字
    phoneNum = phoneNum.replace(/\D/g, '')
    // 如果长度大于11，截取前11位
    if (phoneNum.length > 11) {
      phoneNum = phoneNum.slice(0, 11)
    }

    setMembersBySearch([])
    setPhone(phoneNum)
  }

  function handleInputChange(name: string) {
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

  // 手机号变化处理函数
  const onPhoneSearch = debounce((phoneNum: string) => {
    const correctPhone = getCorrectPhone(phoneNum)

    if (correctPhone.length < 11) {
      return
    }

    neMeeting
      ?.searchAccount({
        phoneNumber: correctPhone,
      })
      .then((data) => {
        if (data.length > 0) {
          // 只取第一项
          setMembersBySearch([data[0]])
        } else {
          setMembersBySearch([])
        }
      })
  }, 500)

  // 点击呼叫处理函数
  const onCallingHandler = () => {
    setCallingLoading(true)
    setIsJoin(false)
    const correctPhone = getCorrectPhone(phone)

    neMeeting
      ?.callByNumber({
        number: correctPhone,
        countryCode: countryCode,
        name: inviteName.value || correctPhone,
      })
      ?.then((res) => {
        if (!res) return

        const data = res.data
        const userInfo = getUserInfo()

        saveCallRecord(`nemeeting-call-${userInfo?.userUuid as string}`, [
          {
            ...data,
            name: inviteName.value,
            phoneNumber: correctPhone,
          },
        ])
        updateRecentCallList()
        // 呼叫人已被呼叫中
        if (data.isRepeatedCall) {
          Toast.info(t('sipCallIsInInviting'))
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
      })
      .catch((e) => {
        Toast.fail(e.message)
      })
      .finally(() => {
        setCallingLoading(false)
      })
  }

  function reset() {
    setPhone('')
    setCurrentCallingInfo({
      userUuid: '',
      name: '',
      avatar: '',
      dept: '',
      isSelected: false,
    })
    setInviteName({ value: '', valid: false })
    setIsJoin(false)
    setMembersBySearch([])
  }

  // 当切换到输入手机界面需要重置手机号
  useEffect(() => {
    if (!calling) {
      reset()
    }
  }, [calling])

  useEffect(() => {
    updateRecentCallList()
  }, [])

  const updateRecentCallList = () => {
    const userInfo = getUserInfo()
    const _recentCallList = localStorage.getItem(
      `nemeeting-call-${userInfo?.userUuid as string}`
    )

    console.log(_recentCallList)

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
            <span className="recent-call-item-phone-number">
              {item.phoneNumber}
            </span>
            <span className="recent-call-item-title-name">{item.name}</span>
          </div>
          <div
            onClick={(e) => {
              e.stopPropagation()
              const userInfo = getUserInfo()

              removeCallRecordItem(
                `nemeeting-call-${userInfo?.userUuid as string}`,
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
        setPhone(item.phoneNumber)
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

        removeAllCallRecord(`nemeeting-call-${userInfo?.userUuid as string}`)
        setRecentCallList([])
        Toast.success(t('clearAllSuccess'))
      },
    },
  ]

  // 取消呼叫
  const onCallingCancelHandler = () => {
    const userUuid = currentCallingInfo.userUuid

    if (userUuid) {
      if (isCalling) {
        neMeeting?.hangUpCall(userUuid)?.catch((e) => {
          Toast.fail(e.message)
        })
        setCalling(false)
      } else {
        neMeeting?.callByUserUuid(userUuid)?.catch((e) => {
          Toast.fail(e.message)
        })
        setCalling(true)
      }
    }
  }

  // 点击其他成员处理函数
  const onCallOtherHandler = () => {
    setCalling(false)
  }

  useEffect(() => {
    function handleMemberSipInviteStateChanged(member: NERoomMember) {
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
  const isCalling = useMemo(() => {
    return (
      callingState === NEMeetingInviteStatus.calling ||
      callingState === NEMeetingInviteStatus.waitingCall ||
      isJoin
    )
  }, [callingState, isJoin])

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
  const checkIsPhone = useMemo(() => {
    const correctPhone = getCorrectPhone(phone)

    if (!correctPhone) {
      return true
    }

    return /^1[3,4,5,6,7,8,9]\d{9}/.test(correctPhone)
  }, [phone])

  const handleSearchAccountClick = (member: SearchAccountInfo) => {
    setInviteName({
      value: member.name,
      valid: true,
    })
    setCurrentCallingInfo({
      userUuid: member.userUuid,
      name: member.name,
      avatar: member.avatar,
      dept: member.dept,
      isSelected: true,
    })
  }

  const searchOptions = useMemo(() => {
    return membersBySearch.map((item) => {
      return {
        label: (
          <div
            key={item.userUuid}
            className="nemeeting-SIP-search"
            onClick={() => handleSearchAccountClick(item)}
          >
            <div className="nemeeting-SIP-search-content">
              <UserAvatar nickname={item.name} size={32} avatar={item.avatar} />
              <div className="nemeeting-SIP-search-name-wrapper">
                <div className="nemeeting-SIP-search-name">{item.name}</div>
                {item.dept && (
                  <div className="nemeeting-SIP-search-dept">{item.dept}</div>
                )}
              </div>
            </div>
            <div className="nemeeting-SIP-search-phone">{item.phoneNumber}</div>
          </div>
        ),
        userUuid: item.userUuid,
      }
    })
  }, [membersBySearch])

  return (
    <div className={`nemeeting-invite-SIP ${className || ''}`}>
      {calling ? (
        // 呼叫界面
        <div>
          {currentCallingInfo.isSelected && isJoin ? (
            <div className="nemeeting-SIP-calling-info">
              <UserAvatar
                nickname={currentCallingInfo.name}
                size={48}
                avatar={currentCallingInfo.avatar}
              />
              <div className="nemeeting-SIP-calling-info-name">
                {currentCallingInfo.name}
              </div>
            </div>
          ) : (
            <div className="nemeeting-SIP-calling-num">
              {inviteName.value || phoneNumFormat}
            </div>
          )}
          {/* 呼叫状态 */}

          {isJoin ? (
            <div className="nemeeting-SIP-duration-time">{durationTime}</div>
          ) : (
            <div
              className={`nemeeting-SIP-calling ${
                !isCalling && 'nemeeting-SIP-calling-failed'
              }`}
            >
              {isCalling ? t('sipCalling') : t('sipCallFailed')}
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
            <div className="nemeeting-sip-call-status">
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
      ) : (
        // 手机号输入拨号界面
        <div>
          <div className={'nemeeting-SIP-item'}>
            <div className="nemeeting-SIP-item-title">
              {t('sipPhoneNumber')}
            </div>
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
                <div className="nemeeting-SIP-phone-num">{countryCode}</div>

                <AutoComplete
                  value={phone}
                  className={'nemeeting-SIP-phone-select'}
                  size="large"
                  status={checkIsPhone ? '' : 'error'}
                  defaultActiveFirstOption={false}
                  suffixIcon={null}
                  onSearch={onPhoneSearch}
                  onChange={onPhoneChange}
                  notFoundContent={null}
                  options={searchOptions}
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
            {checkIsPhone ? null : (
              <div className="nemeeting-sip-phone-tip">
                {t('sipNumberError')}
              </div>
            )}
          </div>
          <div className={'nemeeting-SIP-item'}>
            <div className="nemeeting-SIP-item-title">{t('sipName')}</div>
            <BaseInput
              size="middle"
              value={inviteName.value}
              onChange={(e) => handleInputChange(e.currentTarget.value)}
              onCompositionStart={() => (isComposingRef.current = true)}
              onCompositionEnd={(e) => {
                isComposingRef.current = false
                handleInputChange(e.currentTarget.value)
              }}
              placeholder={t('sipNamePlaceholder')}
              set={setInviteName}
            />
          </div>
          <Button
            className="nemeeting-SIP-btn"
            type="primary"
            size="large"
            loading={callingLoading}
            onClick={onCallingHandler}
            disabled={!checkIsPhone || !phone}
          >
            {t('sipCall')}
          </Button>
        </div>
      )}

      {SIPNumber && (
        <div className="nemeeting-sip-call-num">
          {t('sipCallNumber')}：{SIPNumber}
        </div>
      )}
    </div>
  )
}

export default SIP
