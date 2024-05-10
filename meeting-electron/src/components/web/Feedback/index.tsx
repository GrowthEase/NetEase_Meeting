import React, { useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'

import './index.less'
import Modal from '../../common/Modal'
import { Button, Checkbox, Input } from 'antd'
import { feedbackApi } from '../../../utils/feedbackApi'
import Toast from '../../common/toast'
import { NEMeetingKit } from '../../../types'
import { IPCEvent } from '../../../../app/src/types'
const { TextArea } = Input

interface FeedbackProps {
  visible: boolean
  onClose: () => void
  meetingId: string
  appKey: string
  nickname: string
  neMeeting: { actions: NEMeetingKit }
  loadingChange: (loading: boolean) => void
  inMeeting?: boolean
  systemAndManufacturer?: {
    manufacturer: string
    version: string
    model: string
  }
}

const Feedback: React.FC<FeedbackProps> = ({
  visible,
  onClose,
  meetingId,
  nickname,
  appKey,
  neMeeting,
  loadingChange,
  systemAndManufacturer,
  inMeeting,
}) => {
  const { t } = useTranslation()

  const [problemCategories, setProblemCategories] = useState<string[]>([])
  const [description, setDescription] = useState<string>('')
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false)
  const inMeetingRef = React.useRef<boolean>(false)
  inMeetingRef.current = !!inMeeting
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
  }, [problemCategories, description])

  const problems = [
    {
      title: t('audioProblem'),
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
      categories: [t('unexpectedExit'), t('otherProblems')],
    },
  ]

  async function submit() {
    onClose()
    setIsSubmitting(true)
    loadingChange(true)
    setTimeout(async () => {
      try {
        const category = problemCategories.join(',')
        // 如果提交的problemCategories包含音频问题则需要生成dump文件
        if (
          window.isElectronNative &&
          inMeetingRef.current &&
          problems[0].categories.some((item) => category.includes(item))
        ) {
          //@ts-ignore
          neMeeting?.actions.neMeeting?.roomContext?.rtcController.startAudioDump(
            0
          )
          setTimeout(async () => {
            //@ts-ignore
            neMeeting?.actions.neMeeting?.roomContext?.rtcController.stopAudioDump()
            handleFeedback(category)
              .catch(() => {
                Toast.fail(t('uploadFailed'))
                loadingChange(false)
                setIsSubmitting(false)
              })
              .finally(() => {
                window.ipcRenderer?.send(IPCEvent.deleteAudioDump, appKey)
              })
          }, 60000)
        } else {
          await handleFeedback(category)
        }
      } catch (e) {
        console.log('e>>>>', e)
        Toast.fail(t('uploadFailed'))
        loadingChange(false)
        setIsSubmitting(false)
      }
    }, 1000)
  }

  async function handleFeedback(category: string) {
    let res
    if (window.isElectronNative) {
      res = await neMeeting?.actions.uploadLog()
    }
    feedbackApi({
      appKey: appKey,
      category,
      description: description,
      nickname: nickname,
      meeting_id: meetingId,
      log: res?.data,
      platform: 'PC-Electron',
      ...systemAndManufacturer,
    })
      .then(() => {
        Toast.success(t('thankYourFeedback'))
      })
      .finally(() => {
        loadingChange(false)
        setIsSubmitting(false)
      })
  }

  useEffect(() => {
    if (visible) {
      setProblemCategories([])
      setDescription('')
    }
  }, [visible])

  return (
    <Modal
      title={t('feedback')}
      open={visible}
      maskClosable={isSubmitting ? true : false}
      footer={null}
      width={375}
      onCancel={() => onClose()}
      destroyOnClose
    >
      {isSubmitting ? (
        <>
          <div className="feedback-problem">{t('uploadLoadingText')}</div>
        </>
      ) : (
        <>
          {problems.map((problem) => {
            return (
              <div className="feedback-problem" key={problem.title}>
                <div className="feedback-problem-title">{problem.title}</div>
                <div className="feedback-problem-categories">
                  {problem.categories.map((category) => {
                    return (
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
                        {category}
                      </Checkbox>
                    )
                  })}
                </div>
              </div>
            )
          })}
          <TextArea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder={t('otherProblemsTips')}
            maxLength={300}
          />
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
        </>
      )}
    </Modal>
  )
}
export default Feedback
