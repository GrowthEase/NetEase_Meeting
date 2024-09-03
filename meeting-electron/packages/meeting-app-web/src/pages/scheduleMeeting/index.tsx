import React, { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import EventEmitter from 'eventemitter3';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import ScheduleMeeting, {
  ScheduleMeetingRef,
} from '../../components/web/BeforeMeetingModal/ScheduleMeeting';
import ScheduleMeetingBgImg from '../../assets/schedule_bg.png';

import './index.less';
import { BeforeMeetingConfig, EventType } from '@meeting-module/types';
import Toast from '@meeting-module/components/common/toast';
import classNames from 'classnames';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';
import { Dropdown, MenuProps } from 'antd';
import { NEMeetingItem } from 'nemeeting-web-sdk';
import useUserInfo from '@meeting-module/hooks/useUserInfo';

const eventEmitter = new EventEmitter();

const ScheduleMeetingPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const scheduleMeetingRef = useRef<ScheduleMeetingRef>(null);
  const isCreateOrEditScheduleMeetingRef = useRef<boolean>(false);
  const [open, setOpen] = useState<boolean>(false);
  const [nickname, setNickname] = useState<string>('');
  const [submitLoading, setSubmitLoading] = useState(false);
  const [appLiveAvailable, setAppLiveAvailable] = useState<boolean>(false);
  const [globalConfig, setGlobalConfig] = useState<BeforeMeetingConfig>();
  const [editMeeting, setEditMeeting] = useState<NEMeetingItem>();
  const [pageMode, setPageMode] = useState<'detail' | 'edit' | 'create'>(
    'create',
  );

  const { userInfo } = useUserInfo();

  const [cancelMeetingOpen, setUserMenuOpen] = useState(false);

  const items: MenuProps['items'] = [
    {
      key: '1',
      label: (
        <div
          onClick={() =>
            scheduleMeetingRef.current?.setOpenRecurringModalTypeCancel()
          }
        >
          <span
            style={{
              whiteSpace: 'noWrap',
            }}
          >
            {t('cancelScheduleMeeting')}
          </span>
        </div>
      ),
    },
  ];

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'windowOpen') {
        payload.nickname && setNickname(payload.nickname);
        payload.appLiveAvailable &&
          setAppLiveAvailable(payload.appLiveAvailable);
        payload.globalConfig && setGlobalConfig(payload.globalConfig);
        setEditMeeting(payload.editMeeting);
        setOpen(true);
      } else if (event === 'createOrEditScheduleMeetingFail') {
        isCreateOrEditScheduleMeetingRef.current = false;
        Toast.fail(payload.errorMsg);
        setSubmitLoading(false);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    function ipcRenderer() {
      if (isCreateOrEditScheduleMeetingRef.current) {
        window.ipcRenderer?.send('childWindow:closed');
      } else {
        scheduleMeetingRef.current?.handleCancelEditMeeting();
      }
    }

    window.ipcRenderer?.on('scheduleMeetingWindow:close', ipcRenderer);
    return () => {
      window.ipcRenderer?.removeListener(
        'scheduleMeetingWindow:close',
        ipcRenderer,
      );
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('scheduleMeeting');
    });
  }, [t]);

  useEffect(() => {
    eventEmitter.on(EventType.OnScheduledMeetingPageModeChanged, (mode) => {
      setPageMode(mode);
    });
    return () => {
      eventEmitter.off(EventType.OnScheduledMeetingPageModeChanged);
    };
  }, []);

  return (
    <>
      <div
        className={classNames('schedule-meeting-page', {
          'schedule-meeting-page-bg': pageMode === 'detail',
        })}
        style={{
          backgroundImage:
            pageMode === 'detail' ? `url(${ScheduleMeetingBgImg})` : 'none',
        }}
      >
        <div className="schedule-electron-drag-bar">
          <div className="drag-region" />
          {pageMode !== 'detail' ? (
            <span
              style={{
                fontWeight: 'bold',
              }}
            >
              {t('scheduleMeeting')}
            </span>
          ) : editMeeting?.ownerUserUuid === userInfo?.userUuid &&
            editMeeting?.status === 1 ? (
            <div
              style={{
                right: window.systemPlatform !== 'win32' ? '12px' : '44px',
              }}
              className="schedule-meeting-pc-buttons"
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
                overlayClassName="schedule-meeting-detail-dropdown"
                getPopupContainer={() =>
                  document.getElementById(
                    'schedule-meeting-detail-buttons',
                  ) as HTMLElement
                }
              >
                <div className="icon-more icon-buttons">
                  <svg className="icon iconfont iconduigou" aria-hidden="true">
                    <use xlinkHref="#iconyx-tv-more1x"></use>
                  </svg>
                </div>
              </Dropdown>
            </div>
          ) : null}

          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <div className="schedule-meeting-page-content">
          <ScheduleMeeting
            ref={scheduleMeetingRef}
            open={open}
            nickname={nickname}
            submitLoading={submitLoading}
            appLiveAvailable={appLiveAvailable}
            globalConfig={globalConfig}
            eventEmitter={eventEmitter}
            meeting={editMeeting}
            meetingContactsService={neMeetingKit.getContactsService()}
            onCancel={() => {
              window.ipcRenderer?.send('childWindow:closed');
            }}
            onJoinMeeting={(meetingId) => {
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'joinScheduleMeeting',
                  payload: {
                    meetingId,
                  },
                },
                parentWindow.origin,
              );
            }}
            onSummit={(value) => {
              setSubmitLoading(true);
              isCreateOrEditScheduleMeetingRef.current = true;
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'createOrEditScheduleMeeting',
                  payload: {
                    value,
                  },
                },
                parentWindow.origin,
              );
            }}
            onCancelMeeting={(cancelRecurringMeeting) => {
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'cancelScheduleMeeting',
                  payload: {
                    cancelRecurringMeeting,
                    meetingId: editMeeting?.meetingId,
                  },
                },
                parentWindow.origin,
              );
            }}
          />
        </div>
      </div>
    </>
  );
};

export default ScheduleMeetingPage;
