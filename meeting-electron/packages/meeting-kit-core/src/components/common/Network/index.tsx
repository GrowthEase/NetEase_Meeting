import { Popover } from 'antd'
import { NERoomRtcNetworkQualityInfo, NERoomRtcStats } from 'neroom-types'
import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  EventType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  NEMeetingInfo,
  NEMember,
} from '../../../types'
import { SettingTabType } from '../../web/Setting/Setting'
import './index.less'

interface NetworkInfoProps {
  signalColor: 'green' | 'yellow' | 'red'
  networkDelay: number
  upPacketLossRate?: number
  downPacketLossRate?: number
  onSettingClick?: (type: SettingTabType) => void
}

interface PacketLossRate {
  txVideoPacketLossRate: number
  rxVideoPacketLossRate: number
  txAudioPacketLossRate: number
  rxAudioPacketLossRate: number
}
export const NetworkInfo: React.FC<NetworkInfoProps> = ({
  signalColor,
  networkDelay,
  upPacketLossRate,
  downPacketLossRate,
  onSettingClick,
}) => {
  const { i18n, t } = useTranslation()
  const title = useMemo(() => {
    const map = {
      green: t('networkStateGood'),
      yellow: t('networkStateGeneral'),
      red: t('networkStatePoor'),
    }

    return map[signalColor]
  }, [signalColor, t])

  const style = useMemo(() => {
    if (i18n.language === 'zh-CN') {
      return {}
    } else {
      return {
        width: '155px',
      }
    }
  }, [i18n.language])

  return (
    <>
      <div className="nemeeting-network-info" style={style}>
        <p className="nemeeting-title">{title}</p>
        <div className="network-content">
          <div className="network-item">
            <p className="network-item-title">{t('latency')}：</p>
            <p>{networkDelay}ms</p>
          </div>
          {!!window.isElectronNative && (
            <div className="network-packet-loss">
              <p>{t('packetLossRate')}：</p>
              <div className="network-packet-loss-rate">
                <div>
                  <svg
                    className="icon iconfont icon-up-rate"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#icona-Frame341"></use>
                  </svg>
                  {upPacketLossRate}%
                </div>
                <div>
                  <svg
                    className="icon iconfont icon-down-rate"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#icona-Frame340"></use>
                  </svg>
                  {downPacketLossRate}%
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
      {window.isElectronNative ? (
        <div
          className="more-monitoring"
          onClick={() => {
            onSettingClick?.('monitoring')
          }}
        >
          {t('moreMonitoring')}
        </div>
      ) : null}
    </>
  )
}

const Network: React.FC<{
  className?: string
  onlyIcon?: boolean
  onSettingClick?: (type: SettingTabType) => void
}> = ({ className, onlyIcon, onSettingClick }) => {
  const { eventEmitter, online } = useContext<GlobalContextInterface>(
    GlobalContext
  )
  const { meetingInfo, memberList } = useContext<MeetingInfoContextInterface>(
    MeetingInfoContext
  )
  const networkQualityTimerRef = useRef<null | ReturnType<typeof setTimeout>>(
    null
  )
  // 下行网络
  const [
    networkQualityInfo,
    setNetworkQualityInfo,
  ] = useState<NERoomRtcNetworkQualityInfo>({
    userUuid: '',
    downStatus: 0,
    upStatus: 0,
  })
  const canShowNetworkToastRef = useRef(true)
  // 下行网络延迟
  const [networkDelay, setNetworkDelay] = useState(0)
  // 上行丢包率
  const [upPacketLossRate, setUpPacketLossRate] = useState(0)
  // 下行丢包率
  const [downPacketLossRate, setDownPacketLossRate] = useState(0)
  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)
  const meetingListRef = useRef<NEMember[]>(memberList)

  meetingInfoRef.current = meetingInfo
  meetingListRef.current = memberList

  const isLocalVideoOrScreenShareOn = () => {
    const { localMember } = meetingInfoRef.current

    return localMember.isVideoOn || localMember.isSharingScreen
  }

  const isRemoteVideoOrScreenShareOn = () => {
    return meetingListRef.current.some((item) => {
      return item.isVideoOn || item.isSharingScreen
    })
  }

  useEffect(() => {
    canShowNetworkToastRef.current = !!online
  }, [online])

  const networkQualityHandle = useCallback(
    (data: NERoomRtcNetworkQualityInfo[]) => {
      if (data) {
        const localNetwork = data.find((item) => {
          return item.userUuid === meetingInfo.myUuid
        })

        if (localNetwork) {
          // 设置下行网络质量
          setNetworkQualityInfo(localNetwork)
        }
      }

      if (networkQualityTimerRef.current) {
        clearTimeout(networkQualityTimerRef.current)
        networkQualityTimerRef.current = null
      }

      networkQualityTimerRef.current = setTimeout(() => {
        // 4表示网络差，5s未收到回调表示断网或者信号差
        setNetworkQualityInfo({
          userUuid: '',
          upStatus: 4,
          downStatus: 4,
        })
      }, 4000)
    },
    [meetingInfo.myUuid]
  )

  useEffect(() => {
    eventEmitter?.on(EventType.NetworkQuality, networkQualityHandle)
    eventEmitter?.on(
      EventType.RtcStats,
      (data: NERoomRtcStats & PacketLossRate) => {
        // 计算丢包率
        const _upPacketLoss = isLocalVideoOrScreenShareOn()
          ? data.txVideoPacketLossRate
          : data.txAudioPacketLossRate
        const _downPacketLoss = isRemoteVideoOrScreenShareOn()
          ? data.rxVideoPacketLossRate
          : data.rxAudioPacketLossRate

        setUpPacketLossRate(_upPacketLoss)
        setDownPacketLossRate(_downPacketLoss)

        setNetworkDelay(data.downRtt ?? 0)
      }
    )
    return () => {
      eventEmitter?.off(EventType.NetworkQuality, networkQualityHandle)
      eventEmitter?.off(EventType.RtcStats)
    }
  }, [eventEmitter, networkQualityHandle])

  const signalColor = useMemo(() => {
    if (
      networkQualityInfo.downStatus <= 2 &&
      networkQualityInfo.upStatus <= 2
    ) {
      return 'green'
    } else if (
      networkQualityInfo.downStatus <= 3 &&
      networkQualityInfo.upStatus <= 3
    ) {
      return 'yellow'
    } else {
      return 'red'
    }
  }, [networkQualityInfo.downStatus, networkQualityInfo.upStatus])

  return (
    <div className={`meeting-network ${className || ''}`}>
      {onlyIcon ? (
        <svg
          className={`icon nemeeting-singal-icon nemeeting-${signalColor}`}
          aria-hidden="true"
        >
          <use xlinkHref="#iconxinhao"></use>
        </svg>
      ) : (
        <Popover
          trigger={'hover'}
          placement={'bottomLeft'}
          arrow={false}
          overlayClassName="nemeeting-network-popover"
          content={
            <NetworkInfo
              signalColor={signalColor}
              networkDelay={networkDelay}
              upPacketLossRate={upPacketLossRate}
              downPacketLossRate={downPacketLossRate}
              onSettingClick={onSettingClick}
            />
          }
        >
          <div className="nemeeting-signal">
            <svg
              className={`icon nemeeting-singal-icon nemeeting-${signalColor}`}
              aria-hidden="true"
            >
              <use xlinkHref="#iconxinhao"></use>
            </svg>
          </div>
        </Popover>
      )}
    </div>
  )
}

export default React.memo(Network)
