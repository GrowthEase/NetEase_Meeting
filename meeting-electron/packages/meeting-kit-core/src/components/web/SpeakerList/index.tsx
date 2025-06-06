import React, { useCallback, useEffect, useMemo, useRef } from 'react'
import { Speaker } from '../../../types'
import { useTranslation } from 'react-i18next'
import './index.less'

interface SpeakerListProps {
  className?: string
  speakerList: Speaker[]
  onClick?: () => void
}
const SpeakerList: React.FC<SpeakerListProps> = ({
  speakerList,
  onClick,
  className,
}) => {
  const { t } = useTranslation()
  const speakerElementRef = useRef<HTMLDivElement>(null)
  const speakerStr = useMemo(() => {
    let str = ''

    speakerList.forEach((speaker, index) => {
      str += (index > 0 ? '、' : '') + speaker.nickName
    })
    return str
  }, [speakerList])
  const stopClickRef = useRef(false)
  const handleClick = () => {
    if (stopClickRef.current) {
      return
    }

    onClick?.()
  }

  const onResize = useCallback((entries: ResizeObserverEntry[]) => {
    for (const entry of entries) {
      const { width, height } = entry.contentRect
      const speakerEle = speakerElementRef.current

      // 如果speakerElf不在当前容器内需要重新设置位置
      if (speakerEle) {
        // 获取当前speakerEle的位置
        const { left, top } = speakerEle.getBoundingClientRect()

        if (left + speakerEle.clientWidth > width) {
          speakerEle.style.left = width - speakerEle.clientWidth - 2 + 'px'
        }

        if (top + speakerEle.clientHeight > height) {
          speakerEle.style.top = height - speakerEle.clientHeight - 62 + 'px'
        }
      }
    }
  }, [])

  useEffect(() => {
    const wrapDom = document.querySelector('.meeting-web')
    let observer: ResizeObserver

    if (wrapDom) {
      observer = new ResizeObserver(onResize)
      observer.observe(wrapDom)
    }

    return () => {
      if (wrapDom && observer) {
        observer.unobserve(wrapDom)
        observer.disconnect()
      }
    }
  }, [onResize])

  useEffect(() => {
    // header 支持鼠标拖动
    const speakerEle = speakerElementRef.current
    const container = document.getElementById('meeting-web')

    if (!speakerEle || !container) return
    let disX = 0
    let disY = 0
    const handleMouseDone = (e: MouseEvent) => {
      const { left, top } = speakerEle.getBoundingClientRect()

      // 拖动窗口
      disX = e.clientX - left
      disY = e.clientY - top
      const move = (e: MouseEvent) => {
        stopClickRef.current = true
        const { clientX, clientY } = e

        // 不能超过容器左右边界
        if (clientX - disX <= 2) {
          speakerEle.style.left = '2px'
        } else if (
          clientX - disX >=
          container.clientWidth - speakerEle.clientWidth - 2
        ) {
          speakerEle.style.left =
            container.clientWidth - speakerEle.clientWidth - 2 + 'px'
        } else {
          speakerEle.style.left = clientX - disX + 'px'
        }

        // 不能超过容器上下边界
        if (clientY - disY <= 2) {
          speakerEle.style.top = '2px'
        } else if (
          clientY - disY >=
          container.clientHeight - speakerEle.clientHeight - 62
        ) {
          speakerEle.style.top =
            container.clientHeight - speakerEle.clientHeight - 62 + 'px'
        } else {
          if (window.isElectronNative) {
            speakerEle.style.top = clientY - disY - 28 + 'px'
          } else {
            speakerEle.style.top = clientY - disY + 'px'
          }
        }
      }

      const up = () => {
        setTimeout(() => {
          stopClickRef.current = false
        })
        document.removeEventListener('mousemove', move)
        document.removeEventListener('mouseup', up)
      }

      document.addEventListener('mousemove', move)
      document.addEventListener('mouseup', up)
    }

    speakerEle.addEventListener('mousedown', handleMouseDone)
    return () => {
      speakerEle.removeEventListener('mousedown', handleMouseDone)
    }
  }, [])
  return (
    <div
      className={`speaker-list-wrap ${className}`}
      onClick={handleClick}
      ref={speakerElementRef}
    >
      <div className="speaker-list-inner">
        <div className={'speaker-list-mic'}>
          <svg className={'icon speaker-icon'} aria-hidden="true">
            <use xlinkHref="#iconyinliang0hei"></use>
          </svg>
        </div>
        <span className={'speaker-title'}>{t('meetingSpeakingPrefix')}：</span>
        <span className={'speaker-info'} title={speakerStr}>
          {speakerStr}
        </span>
      </div>
    </div>
  )
}

export default React.memo(SpeakerList)
