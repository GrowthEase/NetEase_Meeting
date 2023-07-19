import React, { useState, useEffect } from 'react';
import {
  Input,
  Radio,
  Button,
  Select,
  Checkbox,
  message,
  Modal,
  DatePicker,
} from 'antd';

import NEMeetingKit, {
  NEMeetingItem,
  NEErrorObject,
  NEMeetingLiveAuthLevel,
  NEMeetingItemSetting,
  NEJoinMeetingParams,
  NEJoinMeetingOptions,
} from 'nemeeting-sdk';

import moment from 'moment';
import { SSL_OP_SSLEAY_080_CLIENT_DH_BUG } from 'constants';
import styles from './index.module.css';

interface IProps {
  nemeeting: NEMeetingKit;
  visible: boolean;
  data?: NEMeetingItem;
  onCancel: () => void;
}

const Schedule = (props: IProps) => {
  const [meetingSubject, setMeetingSubject] = useState('');
  const [meetingPassword, setMeetingPassword] = useState('');
  const [startTime, setStartTime] = useState(Date.now() + 30 * 60 * 1000);
  const [endTime, setEndTime] = useState(Date.now() + 60 * 60 * 1000);
  const [attendeeAudioOff, setAttendeeAudioOff] = useState(false);
  const [enableLive, setEnableLive] = useState(false);
  const [needLiveAuthentication, setNeedLiveAuthentication] = useState(false);
  const [enableRecord, setEnableRecord] = useState(false);
  const [meetingUniqueId, setMeetingUniqueId] = useState(0);
  const [meetingId, setMeetingId] = useState('');

  useEffect(() => {
    if (props.data) {
      setMeetingSubject(props.data.subject);
      setMeetingPassword(props.data.password);
      setStartTime(props.data.startTime);
      setEndTime(props.data.endTime);
      setAttendeeAudioOff(props.data.setting.attendeeAudioOff);
      setMeetingUniqueId(props.data.meetingUniqueId);
      setMeetingId(props.data.meetingId);
      setEnableLive(props.data.enableLive);
      setNeedLiveAuthentication(props.data.liveWebAccessControlLevel === 2);
      setEnableRecord(props.data.setting.cloudRecordOn);
    } else {
      setMeetingSubject('');
      setMeetingPassword('');
      setStartTime(Date.now() + 30 * 60 * 1000);
      setEndTime(Date.now() + 60 * 60 * 1000);
      setAttendeeAudioOff(false);
      setMeetingUniqueId(0);
      setMeetingId('');
      setEnableLive(false);
      setNeedLiveAuthentication(false);
      setEnableRecord(false);
    }
  }, [props.visible]);

  const handleEdit = () => {
    const settings: NEMeetingItemSetting = {
      attendeeAudioOff,
      cloudRecordOn: enableRecord,
    };

    const meetingItem: NEMeetingItem = {
      meetingUniqueId,
      meetingId,
      subject: meetingSubject,
      password: meetingPassword,
      startTime: Number(startTime),
      endTime: Number(endTime),
      enableLive,
      liveWebAccessControlLevel: needLiveAuthentication ? 2 : 1,
      setting: settings,
    };

    props.nemeeting
      ?.getPremeetingService()
      ?.editMeeting(meetingItem, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `editMeeting failed: ${errorObject.code}(${errorObject.msg})`
          );
          return;
        }

        props.onCancel();
      });
  };

  const handleCancel = () => {
    props.nemeeting
      ?.getPremeetingService()
      ?.cancelMeeting(meetingUniqueId, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `cancelMeeting failed: ${errorObject.code}(${errorObject.msg})`
          );
          return;
        }

        props.onCancel();
      });
  };

  const handleJoin = () => {
    const param: NEJoinMeetingParams = {
      meetingId,
      displayName: 'Demo',
    };

    const opts: NEJoinMeetingOptions = {};

    props.nemeeting
      ?.getMeetingService()
      ?.joinMeeting(param, opts, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `joinMeeting failed: ${errorObject.code}(${errorObject.msg})`
          );
          return;
        }

        props.onCancel();
      });
  };

  const handleSchedule = () => {
    const settings: NEMeetingItemSetting = {
      attendeeAudioOff,
      cloudRecordOn: enableRecord,
    };

    const meetingItem: NEMeetingItem = {
      subject: meetingSubject,
      password: meetingPassword,
      startTime: Number(startTime),
      endTime: Number(endTime),
      enableLive,
      liveWebAccessControlLevel: needLiveAuthentication ? 2 : 1,
      setting: settings,
    };

    props.nemeeting
      ?.getPremeetingService()
      ?.scheduleMeeting(meetingItem, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `scheduleMeeting failed: ${errorObject.code}(${errorObject.msg})`
          );
        }

        props.onCancel();
      });
  };

  return (
    <Modal
      title="Schedule Meeting"
      footer={null}
      visible={props.visible}
      onCancel={props.onCancel}
    >
      <div className={styles.scheduleWrapper}>
        <Input
          className={`${styles.w300} ${styles.mb10}`}
          placeholder="meetingSubject"
          value={meetingSubject}
          onChange={(e) => {
            setMeetingSubject(e.target.value);
          }}
        />
        <Input
          className={`${styles.w300} ${styles.mb10}`}
          placeholder="meetingPassword"
          value={meetingPassword}
          onChange={(e) => {
            setMeetingPassword(e.target.value);
          }}
        />
        <div className={styles.mb10}>
          <DatePicker.RangePicker
            allowClear={false}
            value={[moment(startTime), moment(endTime)]}
            format="YYYY-MM-DD HH:mm:ss"
            showTime
            onChange={(dates) => {
              // @ts-ignore
              setStartTime(moment(dates[0]).valueOf());
              // @ts-ignore
              setEndTime(moment(dates[1]).valueOf());
            }}
          />
        </div>
        <Checkbox
          style={{ marginLeft: 8 }}
          className={`${styles.w300} ${styles.mb10}`}
          checked={attendeeAudioOff}
          onChange={(e) => {
            setAttendeeAudioOff(e.target.checked);
          }}
        >
          Automatically mute after members join
        </Checkbox>
        <Checkbox
          className={`${styles.w300} ${styles.mb10}`}
          checked={enableLive}
          onChange={(e) => {
            setEnableLive(e.target.checked);
          }}
        >
          EnableLive
        </Checkbox>
        <Checkbox
          className={`${styles.w300} ${styles.mb10}`}
          checked={needLiveAuthentication}
          onChange={(e) => {
            setNeedLiveAuthentication(e.target.checked);
          }}
        >
          Only employees of company can watch
        </Checkbox>
        <Checkbox
          className={`${styles.w300} ${styles.mb10}`}
          checked={enableRecord}
          onChange={(e) => {
            setEnableRecord(e.target.checked);
          }}
        >
          EnableRecord
        </Checkbox>
        <div className={styles.buttonGroup}>
          {props.data ? (
            <>
              <Button className={styles.mr10} onClick={handleCancel}>
                Cancel Schedule
              </Button>
              <Button className={styles.mr10} onClick={handleEdit}>
                Edit Meeting
              </Button>
              <Button onClick={handleJoin}>Join Meeting</Button>
            </>
          ) : (
            <Button onClick={handleSchedule}>Schedule Meeting</Button>
          )}
        </div>
      </div>
    </Modal>
  );
};

export default Schedule;
