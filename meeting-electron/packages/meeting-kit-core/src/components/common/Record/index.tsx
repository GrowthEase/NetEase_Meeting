import React from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
import { RecordState } from '../../../types/innerType'
import classNames from 'classnames'

interface RecordProps {
  className?: string
  stopRecord?: () => void
  recordState?: RecordState
  notShowRecordBtn: boolean
}

const Record: React.FC<RecordProps> = ({
  recordState,
  className,
  stopRecord,
  notShowRecordBtn,
}) => {
  const { t } = useTranslation()

  return (
    <div className={`nemeeting-record ${className || ''}`}>
      {
        <>
          <div className="nemeeting-record-left">
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconluzhizhong1"></use>
            </svg>
            <span
              className={classNames('nemeeting-record-title', {
                'nemeeting-record-title-starting':
                  recordState === RecordState.Starting,
              })}
            >
              {recordState === RecordState.Starting
                ? t('startingRecording')
                : t('recording')}
            </span>
          </div>
          {recordState === RecordState.Recording && !notShowRecordBtn && (
            <div className="nemeeting-record-right" onClick={stopRecord}>
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconzanting"></use>
              </svg>
            </div>
          )}
        </>
      }
    </div>
  )
}

export default React.memo(Record)
