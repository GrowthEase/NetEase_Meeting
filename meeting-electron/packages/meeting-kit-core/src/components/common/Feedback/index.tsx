import React, { useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { Button, Checkbox, Input, Spin } from 'antd'
import { useGlobalContext, useMeetingInfoContext } from '../../../store'
import Toast from '../toast'
import './index.less'

const { TextArea } = Input

export interface FeedbackProps {
  visible: boolean
  onClose?: () => void
}

const FeedbackContent: React.FC<FeedbackProps> = ({ visible, onClose }) => {
  const { t } = useTranslation()
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()

  const [problemCategories, setProblemCategories] = useState<string[]>([])
  const [description, setDescription] = useState<string>('')
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false)
  const inMeetingRef = React.useRef<boolean>(false)
  const infoRef = React.useRef<string>('')

  inMeetingRef.current = !!meetingInfo.meetingNum

  const submitBtnEnabled = useMemo(() => {
    if (description.trim()) {
      return true
    } else {
      if (problemCategories.length > 0) {
        return !problemCategories.includes(t('otherProblems'))
      } else {
        return false
      }
    }
  }, [problemCategories, description, t])

  const problems = [
    {
      title: t('audioProblem'),
      key: 'audioProblem',
      categories: [
        t('aLargeDelay'),
        t('mechanicalSound'),
        t('stuck'),
        t('noise'),
        t('echo'),
        t('notHear'),
        t('notHearMe'),
        t('lowVolume'),
      ],
    },
    {
      title: t('videoProblem'),
      key: 'videoProblem',
      categories: [
        t('longTimeStuck'),
        t('videoIsIntermittent'),
        t('tearing'),
        t('tooBrightTooDark'),
        t('blurredImage'),
        t('obviousNoise'),
        t('notSynchronized'),
      ],
    },
    {
      title: t('other'),
      key: 'other',
      categories: [t('unexpectedExit'), t('otherProblems')],
    },
  ]

  async function submit() {
    setIsSubmitting(true)
    infoRef.current = Toast.info(t('uploadLoadingText'), 600000)

    setTimeout(async () => {
      try {
        const category = problemCategories.join(',')

        // 如果提交的problemCategories包含音频问题则需要生成dump文件
        if (
          window.isElectronNative &&
          inMeetingRef.current &&
          problems[0].categories.some((item) => category.includes(item))
        ) {
          neMeeting?.startAudioDump?.(0)
          setTimeout(async () => {
            neMeeting?.stopAudioDump()
            handleFeedback(category)
              .catch(() => {
                Toast.fail(t('uploadFailed'))
                setIsSubmitting(false)
              })
              .finally(() => {
                // window.ipcRenderer?.send(IPCEvent.deleteAudioDump, appKey)
              })
          }, 60000)
        } else {
          await handleFeedback(category)
        }
      } catch (e) {
        Toast.fail(t('uploadFailed'))
        setIsSubmitting(false)
      }
    }, 1000)
  }

  async function handleFeedback(category: string) {
    neMeeting
      ?.feedbackApi({
        description: description,
        category: category,
      })
      .finally(() => {
        Toast.destroy(infoRef.current)
        Toast.success(t('thankYourFeedback'))
        setIsSubmitting(false)
        setTimeout(() => {
          onClose?.()
        }, 1000)
      })
  }

  useEffect(() => {
    if (visible) {
      setProblemCategories([])
      setDescription('')
    }
  }, [visible])

  return (
    <Spin spinning={isSubmitting}>
      <div className="feedback-problem-wrap">
        <div className="feedback-problem-content">
          {problems.map((problem) => {
            return (
              <div
                className="feedback-problem feedback-problem-content-item"
                key={problem.title}
              >
                <div className="feedback-problem-title">{problem.title}</div>
                <div className="feedback-problem-categories">
                  {problem.categories.map((category) => {
                    return (
                      <div className="checkbox-wrap" key={category}>
                        <Checkbox
                          className="feedback-problem-category"
                          key={category}
                          value={category}
                          checked={problemCategories.includes(category)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setProblemCategories([
                                ...problemCategories,
                                category,
                              ])
                            } else {
                              setProblemCategories(
                                problemCategories.filter(
                                  (item) => item !== category
                                )
                              )
                            }
                          }}
                        >
                          <div className="category">{category}</div>
                        </Checkbox>
                      </div>
                    )
                  })}
                  {problem.key === 'other' && (
                    <div className="text-area-wrap">
                      <TextArea
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        placeholder={t('otherProblemsTips')}
                        maxLength={300}
                      />
                    </div>
                  )}
                </div>
              </div>
            )
          })}
        </div>

        <div className="feedback-footer">
          <Button
            className="feedback-submit-btn"
            type="primary"
            disabled={!submitBtnEnabled}
            onClick={submit}
            loading={isSubmitting}
          >
            {t('submit')}
          </Button>
        </div>
      </div>
    </Spin>
  )
}

export default FeedbackContent
