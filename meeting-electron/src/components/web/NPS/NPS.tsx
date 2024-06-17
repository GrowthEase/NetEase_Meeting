import React, { useEffect, useState } from 'react'

import { Button, Input } from 'antd'
import { feedbackApi } from '../../../utils/feedbackApi'
import Toast from '../../common/toast'

import lottie from 'lottie-web'
import score0 from './lottie/Angry_data.json'
import blushingJSON from './lottie/Blushing_data.json'
import score2 from './lottie/Happy_data.json'
import score3 from './lottie/Heart+Eyes_data.json'
import score1 from './lottie/Sad_data.json'

import { useTranslation } from 'react-i18next'
import './index.less'

const { TextArea } = Input

interface NPSProps {
  meetingId: string
  appKey: string
  nickname: string
}

const NPSContent: React.FC<NPSProps> = ({ meetingId, nickname, appKey }) => {
  console.log(meetingId, nickname, appKey)

  const { t } = useTranslation()

  const [selectedScore, setSelectedScore] = useState<number>(-1)
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false)
  const [description, setDescription] = useState<string>('')
  const [showSuccess, setShowSuccess] = useState<boolean>(false)

  const scores = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  const lottieData = {
    score0,
    score1,
    score2,
    score3,
  }

  function getLottieIndex(score: number) {
    if (score >= 0 && score <= 1) {
      return 0
    } else if (score >= 2 && score <= 6) {
      return 1
    } else if (score >= 7 && score <= 8) {
      return 2
    } else {
      return 3
    }
  }

  function onMouseEnter(item: number) {
    if (item === selectedScore) {
      return
    }

    const container = document.getElementById(
      `nps-score-${item}`
    ) as HTMLElement
    const name = `score${item}`

    lottie.destroy(`score${item}`)
    const index = getLottieIndex(item)

    lottie.loadAnimation({
      name,
      container,
      renderer: 'svg',
      loop: false,
      autoplay: true,
      animationData: lottieData[`score${index}`],
    })

    lottie.play()
  }

  function onMouseLeave(item: number) {
    if (selectedScore !== item) {
      lottie.destroy(`score${item}`)
    }
  }

  function onSetScore(item: number) {
    // 清除之前设置的动效标签
    if (selectedScore !== item) {
      lottie.destroy(`score${selectedScore}`)
    }

    setSelectedScore(item)
  }

  useEffect(() => {
    if (!showSuccess) return
    const container = document.getElementById(
      'nps-feedback-success-svg'
    ) as HTMLElement

    lottie.loadAnimation({
      container,
      renderer: 'svg',
      loop: true,
      autoplay: true,
      animationData: blushingJSON,
    })
    lottie.play()
  }, [showSuccess])

  function submit() {
    setIsSubmitting(true)
    const data = `${selectedScore}#${description}`

    feedbackApi({
      appKey: appKey,
      description: data,
      nickname: nickname,
      meeting_id: meetingId,
      platform: window.isElectronNative ? 'Electron-native' : 'Web',
    })
      .then(() => {
        setShowSuccess(true)
      })
      .catch((error) => {
        if (error.code === 'ERR_NETWORK') {
          error.message = t('networkError')
        }

        Toast.fail(error.message || error.msg || t('uploadFailed'))
      })
      .finally(() => {
        setIsSubmitting(false)
      })
  }

  useEffect(() => {
    setShowSuccess(false)
    setDescription('')
    setSelectedScore(-1)
  }, [meetingId])

  return (
    <>
      {!showSuccess ? (
        <>
          <div className="nps-score-and-tip-wrap">
            <div className="nps-score-wrap">
              {scores.map((score) => (
                <div
                  className="nps-score-item"
                  key={score}
                  onMouseEnter={() => onMouseEnter(score)}
                  onMouseLeave={() => onMouseLeave(score)}
                  onClick={() => onSetScore(score)}
                >
                  {score !== selectedScore && (
                    <div className="nps-score-text">{score}</div>
                  )}
                  <div
                    className="nps-score-animation"
                    id={`nps-score-${score}`}
                  />
                </div>
              ))}
            </div>
            <div className="nps-score-tip-wrap">
              <span>{t('nps0')}</span>
              <span>{t('nps10')}</span>
            </div>
            <TextArea
              placeholder={`${t('npsTips1')}
${t('npsTips2')}
${t('npsTips3')}
        `}
              // showCount
              maxLength={500}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              style={{ height: 145, marginBottom: 20, borderRadius: 4 }}
            />
          </div>
          <div className="nps-feedback-footer">
            <Button
              className="feedback-submit-btn"
              type="primary"
              loading={isSubmitting}
              disabled={selectedScore === -1}
              onClick={() => submit()}
            >
              {t('submit')}
            </Button>
          </div>
        </>
      ) : (
        <div className="nps-feedback-success">
          <div
            className="nps-score-animation"
            id={`nps-feedback-success-svg`}
          />
          <div className="nps-feedback-text">{t('thankYourFeedback')}</div>
        </div>
      )}
    </>
  )
}

export default NPSContent
