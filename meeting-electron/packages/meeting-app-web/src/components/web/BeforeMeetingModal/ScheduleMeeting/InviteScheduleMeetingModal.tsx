import React, { useMemo } from 'react';
import { Button, ModalProps, Tag } from 'antd';
import { useTranslation } from 'react-i18next';

import Modal from '@meeting-module/components/common/Modal';

import '../index.less';
import {
  Toast,
  formatDate,
  copyElementValueLineBreak,
  NEMeetingItem,
} from 'nemeeting-web-sdk';
import { getGMTTimeText } from '@meeting-module/kit';

interface InviteScheduleMeetingModalProps extends ModalProps {
  visible: boolean;
  meetingInfo?: NEMeetingItem;
  onClose: () => void;
}

const InviteScheduleMeetingModal: React.FC<InviteScheduleMeetingModalProps> = ({
  meetingInfo,
  onClose,
  ...restProps
}) => {
  const { t } = useTranslation();

  const displayId = useMemo(() => {
    if (meetingInfo?.meetingNum) {
      const id = meetingInfo.meetingNum;

      return id.slice(0, 3) + '-' + id.slice(3, 6) + '-' + id.slice(6);
    }

    return '';
  }, [meetingInfo?.meetingNum]);

  return (
    <Modal
      title={
        <div className="title-content">
          <div className="icon-dui-gou">
            <svg className="icon iconfont iconduigou" aria-hidden="true">
              <use xlinkHref="#iconchenggong"></use>
            </svg>
          </div>
          <span>{t('scheduleMeetingSuccessTip')}</span>
        </div>
      }
      width={490}
      wrapClassName="invite-schedule-meeting-modal-wrap"
      maskClosable={false}
      footer={null}
      onCancel={onClose}
      {...restProps}
    >
      <div>
        <div className="schedule-meeting-invite-content">
          <div className="schedule-meeting-invite-item default-meeting-info-title">
            <div
              style={{
                fontWeight: 'bold',
              }}
            >
              {t('defaultMeetingInfoTitle')}
            </div>
          </div>

          <div className="schedule-meeting-invite-item">
            <div className="schedule-meeting-invite-item-title">
              {t('inviteSubject')}
            </div>
            <div className="schedule-meeting-invite-item-content schedule-meeting-invite-subject">
              {meetingInfo?.subject}
            </div>
          </div>
          <div className="schedule-meeting-invite-item">
            <div className="schedule-meeting-invite-item-title">
              {t('inviteTime')}
            </div>
            <div className="schedule-meeting-invite-item-content">
              <div>
                {formatDate(meetingInfo?.startTime as number)} -{' '}
                {formatDate(meetingInfo?.endTime as number)}
              </div>
              <div>{getGMTTimeText(meetingInfo?.timezoneId)}</div>
            </div>
          </div>

          {meetingInfo?.shortMeetingNum && (
            <div className="schedule-meeting-invite-item">
              <div className="schedule-meeting-invite-item-title">
                {t('meetingShortNum')}
              </div>
              <div className="schedule-meeting-invite-item-content">
                {meetingInfo.shortMeetingNum}{' '}
                <Tag color="#EBF2FF" className="custom-tag">
                  {t('internal')}
                </Tag>
              </div>
            </div>
          )}
          <div className="schedule-meeting-invite-item">
            <div className="schedule-meeting-invite-item-title">
              {t('meetingId')}
            </div>
            <div className="schedule-meeting-invite-item-content">
              {displayId}{' '}
            </div>
          </div>

          {meetingInfo?.password && (
            <div className="schedule-meeting-invite-item">
              <div className="schedule-meeting-invite-item-title">
                {t('meetingPassword')}
              </div>
              <div className="schedule-meeting-invite-item-content">
                {meetingInfo.password}{' '}
              </div>
            </div>
          )}
          {meetingInfo?.sipCid && (
            <div className="schedule-meeting-invite-item">
              <div className="schedule-meeting-invite-item-title">
                {t('sip')}
              </div>
              <div className="schedule-meeting-invite-item-content">
                {meetingInfo?.sipCid}
              </div>
            </div>
          )}

          {meetingInfo?.inviteUrl ? (
            <div className="schedule-meeting-invite-item">
              <div className="schedule-meeting-invite-item-title">
                {t('meetingInviteUrl')}
              </div>
              <div className="schedule-meeting-invite-item-content">
                {meetingInfo?.inviteUrl}
              </div>
            </div>
          ) : null}
        </div>
        <div className="schedule-meeting-invite-footer">
          <Button
            style={{
              marginRight: 8,
            }}
            onClick={() => {
              let copiedValue = `${t('meetingId')}\n${displayId}`;

              if (meetingInfo?.inviteUrl) {
                copiedValue += `\n\n${t('meetingInviteUrl')}\n${
                  meetingInfo.inviteUrl
                }`;
              }

              if (meetingInfo?.password) {
                copiedValue += `\n\n${t('meetingPassword')}\n${
                  meetingInfo.password
                }`;
              }

              copyElementValueLineBreak(`${copiedValue}`, () => {
                Toast.success(t('copySuccess'));
              });
            }}
            className="schedule-meeting-invite-footer-button"
          >
            {t('copyMeetingIdAndLink')}
          </Button>
          <Button
            type="primary"
            className="schedule-meeting-invite-footer-button schedule-meeting-invite-footer-button-primary"
            onClick={() => {
              const ownerNickname = meetingInfo?.ownerNickname || '';
              const defaultMeetingInfoTitle = t('defaultMeetingInfoTitle');
              const inviteSubject = `${t('inviteSubject')}\n${
                meetingInfo?.subject || ''
              }`;
              const inviteTime = `${t('inviteTime')}\n${formatDate(
                meetingInfo?.startTime as number,
              )} - ${formatDate(
                meetingInfo?.endTime as number,
              )} ${getGMTTimeText(meetingInfo?.timezoneId)}`;
              const meetingId = `${t('meetingId')}\n${displayId}`;

              let copiedValue = `${ownerNickname}${defaultMeetingInfoTitle}\n\n${inviteSubject}\n\n${inviteTime}\n\n${meetingId}`;

              if (meetingInfo?.sipCid) {
                const sip = `${t('sip')}\n${meetingInfo?.sipCid}`;

                copiedValue += `\n\n${sip}`;
              }

              if (meetingInfo?.password) {
                copiedValue += `\n\n${t('meetingPassword')}\n${
                  meetingInfo.password
                }`;
              }

              if (meetingInfo?.inviteUrl) {
                copiedValue += `\n\n${t('meetingInviteUrl')}\n${
                  meetingInfo.inviteUrl
                }`;
              }

              copyElementValueLineBreak(`${copiedValue}`, () => {
                Toast.success(t('copySuccess'));
              });
            }}
          >
            {t('copyAll')}
          </Button>
        </div>
      </div>
    </Modal>
  );
};

export default InviteScheduleMeetingModal;
