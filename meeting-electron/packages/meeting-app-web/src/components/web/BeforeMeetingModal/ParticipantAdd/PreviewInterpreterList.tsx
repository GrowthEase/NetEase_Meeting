import React, { useEffect, useMemo, useState } from 'react';
import {
  InterpretationRes,
  NEMeetingInterpreterInfo,
} from '@meeting-module/types/type';
import './index.less';
import { useTranslation } from 'react-i18next';
import { Button } from 'antd';
import UserAvatar from '@meeting-module/components/common/Avatar';
import { useDefaultLanguageOptions } from '@meeting-module/hooks/useInterpreterLang';
import NEContactsService from '@meeting-module/kit/impl/service/meeting_contacts_service';

interface PreviewInterpreterListProps {
  className?: string;
  interpretation?: InterpretationRes;
  meetingContactsService?: NEContactsService;
}

const PreviewInterpreterList: React.FC<PreviewInterpreterListProps> = ({
  meetingContactsService,
  interpretation,
}) => {
  const [selectedMembers, setSelectedMembers] = useState<
    NEMeetingInterpreterInfo[]
  >([]);
  const { languageMap } = useDefaultLanguageOptions();
  const memberCount = useMemo(() => {
    if (interpretation && interpretation.interpreters) {
      return Object.keys(interpretation.interpreters).length;
    } else {
      return 0;
    }
  }, [interpretation]);

  useEffect(() => {
    if (interpretation?.interpreters && meetingContactsService) {
      const keys = Object.keys(interpretation.interpreters);
      const tmpList: NEMeetingInterpreterInfo[] = [];

      meetingContactsService?.getContactsInfo(keys).then((res) => {
        keys.forEach((key) => {
          const interpreter = interpretation.interpreters[key];
          const list = res.data.foundList || [];

          tmpList.push({
            userId: key,
            firstLang: interpreter.length >= 1 ? interpreter[0] : '',
            secondLang: interpreter.length >= 2 ? interpreter[1] : '',
            userInfo: list.find((item) => item.userUuid === key),
          });
        });
        setSelectedMembers(tmpList);
      });
    }
  }, [meetingContactsService, interpretation?.interpreters]);
  const [isOpen, setIsOpen] = useState(false);
  const { t } = useTranslation();

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
            );
          })}
        </div>
      )}
    </div>
  );
};

export default PreviewInterpreterList;
