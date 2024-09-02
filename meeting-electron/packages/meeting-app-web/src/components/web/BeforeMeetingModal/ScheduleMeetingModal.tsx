import React, { useEffect, useMemo, useRef, useState } from 'react';

import { Dropdown, ModalProps } from 'antd';
import dayjs from 'dayjs';
import localeData from 'dayjs/plugin/localeData';
import weekday from 'dayjs/plugin/weekday';
import weekOfYear from 'dayjs/plugin/weekOfYear';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';
import { useTranslation } from 'react-i18next';
import {
  AttendeeOffType,
  BeforeMeetingConfig,
  EventType,
} from '@meeting-module/types';
import Modal from '@meeting-module/components/common/Modal';

import './index.less';

import EventEmitter from 'eventemitter3';

import classNames from 'classnames';
import ScheduleMeeting from './ScheduleMeeting';
import {
  NEMeetingScheduledMember,
  NEMeetingItem,
  NEContactsService,
} from 'nemeeting-web-sdk';
import useUserInfo from '@meeting-module/hooks/useUserInfo';
import { MenuProps } from 'antd/lib';
import { NEMeetingRecurringRule } from '@meeting-module/kit/interface/service/pre_meeting_service';

dayjs.extend(weekday);
dayjs.extend(localeData);
dayjs.extend(weekOfYear);
dayjs.extend(utc);
dayjs.extend(timezone);

type SummitValue = {
  subject: string;
  password: string;
  startTime: number;
  endTime: number;
  openLive: boolean;
  audioOff: boolean;
  liveOnlyEmployees: boolean;
  meetingId?: number;
  attendeeAudioOffType?: AttendeeOffType;
  enableWaitingRoom?: boolean;
  enableJoinBeforeHost?: boolean;
  enableGuestJoin?: boolean;
  recurringRule?: NEMeetingRecurringRule;
  scheduledMembers?: NEMeetingScheduledMember[];
};

interface ScheduleMeetingModalProps extends ModalProps {
  meeting?: NEMeetingItem;
  nickname?: string;
  submitLoading?: boolean;
  appLiveAvailable?: boolean;
  onCancelMeeting?: (cancelRecurringMeeting?: boolean) => void;
  onJoinMeeting?: (meetingNum: string) => void;
  onSummit?: (value: SummitValue) => void;
  globalConfig?: BeforeMeetingConfig;
  onCancel?: () => void;
  eventEmitter: EventEmitter;
  meetingContactsService?: NEContactsService;
}

const ScheduleMeetingModal: React.FC<ScheduleMeetingModalProps> = (props) => {
  const { eventEmitter, meeting, ...restProps } = props;
  const { userInfo } = useUserInfo();
  const { t } = useTranslation();
  const scheduleMeetingRef = useRef<ScheduleMeetingRef>(null);
  const [cancelMeetingOpen, setUserMenuOpen] = useState(false);
  const [pageMode, setPageMode] = useState<'detail' | 'edit' | 'create'>(
    'create',
  );

  useEffect(() => {
    eventEmitter.on(EventType.OnScheduledMeetingPageModeChanged, (mode) => {
      setPageMode(mode);
    });
    return () => {
      eventEmitter.off(EventType.OnScheduledMeetingPageModeChanged);
    };
  }, []);

  const showEditBtn = useMemo(() => {
    if (meeting?.status !== 1) {
      return false;
    }

    if (meeting) {
      return meeting?.ownerUserUuid === userInfo?.userUuid;
    } else {
      return true;
    }
  }, [meeting?.ownerUserUuid, userInfo?.userUuid, meeting?.status]);

  const items: MenuProps['items'] = [
    {
      key: '1',
      label: (
        <div
          style={{
            padding: '2px 10px',
          }}
          onClick={() =>
            scheduleMeetingRef.current?.setOpenRecurringModalTypeCancel()
          }
        >
          {t('cancelScheduleMeeting')}
        </div>
      ),
    },
  ];

  return (
    <Modal
      title={
        pageMode !== 'detail' ? (
          <div>{t('scheduleMeeting')}</div>
        ) : showEditBtn ? (
          <div
            id="schedule-meeting-detail-buttons"
            className="schedule-meeting-detail-buttons"
          >
            <div
              className="icon-edit icon-buttons"
              onClick={() => {
                scheduleMeetingRef.current?.handleEdit();
              }}
            >
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconbianji"></use>
              </svg>
            </div>
            <Dropdown
              menu={{ items }}
              placement="bottom"
              trigger={['click']}
              open={cancelMeetingOpen}
              onOpenChange={(open) => setUserMenuOpen(open)}
              overlayClassName="schedule-meeting-detail-web-dropdown"
            >
              <div className="icon-more icon-buttons">
                <svg className="icon iconfont iconduigou" aria-hidden="true">
                  <use xlinkHref="#iconyx-tv-more1x"></use>
                </svg>
              </div>
            </Dropdown>
          </div>
        ) : (
          <div
            id="schedule-meeting-detail-buttons"
            className="schedule-meeting-detail-buttons"
          ></div>
        )
      }
      width={375}
      maskClosable={false}
      destroyOnClose={true}
      wrapClassName={classNames(
        'user-select-none schedule-meeting-modal-wrap-class',
        {
          'schedule-meeting-modal-wrap-detail': pageMode === 'detail',
        },
      )}
      footer={null}
      {...restProps}
      onCancel={() => {
        scheduleMeetingRef.current?.handleCancelEditMeeting();
      }}
    >
      <ScheduleMeeting ref={scheduleMeetingRef} {...props} />
    </Modal>
  );
};

export type ScheduleMeetingRef = {
  handleCancelEditMeeting: () => void;
  handleEdit: () => void;
  setOpenRecurringModalTypeCancel: () => void;
};

export default ScheduleMeetingModal;
