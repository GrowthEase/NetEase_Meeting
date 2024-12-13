import React, { useEffect, useState, useRef } from 'react'
import { useMeetingInfoContext } from '../../../store'
import Emoji from '../Emoji'

interface EmoticonsProps {
  userUuid: string
  onlyHandsUp?: boolean
  isHandsUp?: boolean
  className?: string
  size?: number
}

const Emoticons: React.FC<EmoticonsProps> = ({
  isHandsUp = false,
  onlyHandsUp = false,
  userUuid,
  className,
  size = 30,
}) => {
  const { meetingInfo } = useMeetingInfoContext()
  const [emojiKey, setEmojiKey] = useState('')
  const disappearRef = useRef<NodeJS.Timeout | null>(null)
  const isHandsUpRef = useRef<boolean>(false)

  useEffect(() => {
    isHandsUpRef.current = isHandsUp

    if (isHandsUp) {
      setEmojiKey('[举手]')
    } else {
      emojiKey === '[举手]' && setEmojiKey('')
    }
  }, [isHandsUp])

  useEffect(() => {
    if (!onlyHandsUp) {
      const emoticons = meetingInfo.emoticons
      const emoticon = emoticons?.[userUuid]

      if (emoticon) {
        const time = 10000 - (Date.now() - emoticon.time)

        if (time > 0) {
          setEmojiKey(emoticon.emojiKey)
          disappearRef.current && clearTimeout(disappearRef.current)
          disappearRef.current = setTimeout(() => {
            isHandsUpRef.current ? setEmojiKey('[举手]') : setEmojiKey('')
          }, time)
        } else {
          isHandsUpRef.current ? setEmojiKey('[举手]') : setEmojiKey('')
        }
      }
    }
  }, [meetingInfo.emoticons])

  return emojiKey ? (
    <div className={className}>
      <Emoji type={2} animate size={size} emojiKey={emojiKey} />
    </div>
  ) : null
}

export default React.memo(Emoticons)
