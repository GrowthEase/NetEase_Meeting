import React, { useEffect, useMemo, useState } from 'react'
import {
  InterpretationRes,
  NEMeetingInterpreterInfo,
} from '../../../../types/type'
import './index.less'
import { useTranslation } from 'react-i18next'
import { Button } from 'antd'
import NEMeetingService from '../../../../services/NEMeeting'
import UserAvatar from '../../../common/Avatar'
import { useDefaultLanguageOptions } from '../../../../hooks/useInterpreterLang'

interface PreviewInterpreterListProps {
  className?: string
  interpretation?: InterpretationRes
  neMeeting?: NEMeetingService
}

const PreviewInterpreterList: React.FC<PreviewInterpreterListProps> = ({
  neMeeting,
  interpretation,
}) => {
  const [selectedMembers, setSelectedMembers] = useState<
    NEMeetingInterpreterInfo[]
  >([])
  const { languageMap } = useDefaultLanguageOptions()
  const memberCount = useMemo(() => {
    if (interpretation && interpretation.interpreters) {
      return Object.keys(interpretation.interpreters).length
    } else {
      return 0
    }
  }, [interpretation])

  useEffect(() => {
    if (interpretation?.interpreters && neMeeting) {
      const keys = Object.keys(interpretation.interpreters)
      const tmpList: NEMeetingInterpreterInfo[] = []

      neMeeting?.getAccountInfoList(keys).then((data) => {
        keys.forEach((key) => {
          const interpreter = interpretation.interpreters[key]
          const list = data.meetingAccountListResp || []

          tmpList.push({
            userId: key,
            firstLang: interpreter.length >= 1 ? interpreter[0] : '',
            secondLang: interpreter.length >= 2 ? interpreter[1] : '',
            userInfo: list.find((item) => item.userUuid === key),
          })
        })
        setSelectedMembers(tmpList)
      })
    }
  }, [neMeeting, interpretation?.interpreters])
  const [isOpen, setIsOpen] = useState(false)
  const { t } = useTranslation()

  return (
    <div className="ne-preview-interp-list">
      <div className="ne-preview-interp-list-header">
        <div className="nemeeting-schedule-participant-meeting-attendees">
          <span>{t('interpInterpreter')}</span>
        </div>
        <div>
          <span className="ne-preview-interp-list-header-count">
            {t('meetingAttendeeCount', {
              count: memberCount,
            })}
          </span>
          <Button
            style={{ padding: '0' }}
            type="link"
            onClick={() => setIsOpen(!isOpen)}
          >
            {isOpen ? t('meetingClose') : t('meetingOpen')}
          </Button>
        </div>
      </div>
      {isOpen && (
        <div className="ne-preview-interp-content">
          {selectedMembers.map((item) => {
            return (
              <div className="ne-preview-interp-content-item" key={item.userId}>
                <div className="ne-preview-interp-item">
                  <UserAvatar
                    size={24}
                    nickname={item.userInfo?.name || ''}
                    avatar={item.userInfo?.avatar}
                  />
                  <div className="ne-preview-interp-item-name">
                    {item.userInfo?.name}
                  </div>
                </div>
                <div className="ne-preview-interp-lang">
                  <div className="ne-preview-interp-item">
                    {languageMap[item.firstLang] || item.firstLang}
                  </div>
                  <svg
                    className="icon iconfont ne-interpreter-switch"
                    aria-hidden="true"
                    style={{ margin: '0 12px', color: '#999999' }}
                  >
                    <use xlinkHref="#iconqiehuan"></use>
                  </svg>
                  <div className="ne-preview-interp-item">
                    {languageMap[item.secondLang] || item.secondLang}
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}

export default PreviewInterpreterList
