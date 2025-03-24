import { useCallback, useEffect, useRef, useState } from 'react'
import { useGlobalContext } from '../store'
import { EventType, NEMember } from '../types'
import { NERoomRtcNetworkQualityInfo } from 'neroom-types'

export default function useNetworkQuality(member: NEMember) {
  const { eventEmitter } = useGlobalContext()
  const memberRef = useRef(member)
  const [isNetworkQualityBad, setIsNetworkQualityBad] = useState(false)

  memberRef.current = member

  const handleNetworkQuality = useCallback(
    (data: NERoomRtcNetworkQualityInfo[]) => {
      const networkQuality = data.find(
        (item) => item.userUuid === memberRef.current?.uuid
      )

      if (networkQuality) {
        setIsNetworkQualityBad(
          networkQuality.upStatus >= 4 || networkQuality.downStatus >= 4
        )
      } else {
        setIsNetworkQualityBad(false)
      }
    },
    []
  )

  useEffect(() => {
    eventEmitter?.on(EventType.NetworkQuality, handleNetworkQuality)
    return () => {
      eventEmitter?.off(EventType.NetworkQuality, handleNetworkQuality)
    }
  }, [eventEmitter, handleNetworkQuality])

  return {
    isNetworkQualityBad,
  }
}
