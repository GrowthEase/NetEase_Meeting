import React, { useState, useEffect } from 'react';
import {
  Input,
  Radio,
  Button,
  Select,
  Checkbox,
  message,
  Modal,
  List,
  Divider,
} from 'antd';
import { useHistory } from 'react-router-dom';

import NEMeetingKit, {
  NEAccountInfo,
  NEErrorObject,
  NEHistoryMeetingItem,
  NEJoinMeetingOptions,
  NEJoinMeetingParams,
  NEMeetingInfo,
  NEMeetingItem,
  NEMeetingWindowMode,
  NEShowMeetingIdOption,
  NEMeetingItemStatus,
  NEStartMeetingParams,
  NEStartMeetingOptions,
} from 'nemeeting-sdk';

import moment from 'moment';
import console from 'console';
import Schedule from './schedule';
import styles from './index.module.css';

interface IProps {
  nemeeting: NEMeetingKit;
}

const statusMap = {
  [NEMeetingItemStatus.MeetingInvalid]: 'Invalid',
  [NEMeetingItemStatus.MeetingCancel]: 'Canceled',
  [NEMeetingItemStatus.MeetingEnded]: 'Ended',
  [NEMeetingItemStatus.MeetingInit]: 'Init',
  [NEMeetingItemStatus.MeetingRecycled]: 'Recycled',
  [NEMeetingItemStatus.MeetingStarted]: 'Started',
};

const Meeting = (props: IProps) => {
  const history = useHistory();
  const [meetingIdd, setMeetingIdd] = useState('');
  const [nickName, setNickName] = useState('');
  const [meetingPassword, setMeetingPassword] = useState('');
  const [userTag, setUserTag] = useState('');

  const [meetingIdDisplay, setMeetingIdDisplay] = useState(0);
  const [defaultWindow, setDefaultWindow] = useState(1);
  const [enableAudio, setEnableAudio] = useState(false);
  const [enableVideo, setEnableVideo] = useState(false);
  const [enableOpenWhiteboard, setEnableOpenWhiteboard] = useState(false);
  const [enableRename, setEnableRename] = useState(false);
  const [enableChatroom, setEnableChatroom] = useState(false);
  const [enableInvitation, setEnableInvitation] = useState(false);
  const [enableScreenShare, setEnableScreenShare] = useState(false);
  const [enableView, setEnableView] = useState(false);
  const [enableOpenRecord, setEnableOpenRecord] = useState(false);

  const [enablePersonId, setEnablePersonId] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [meetingStatus, setMeetingStatus] = useState(0);
  const [modelText, setModelText] = useState('提示信息');

  const [scheduleList, setScheduleList] = useState<NEMeetingItem[]>([]);
  const [currentScheduleItem, setCurrentScheduleItem] = useState<
    NEMeetingItem | undefined
  >(undefined);
  const [scheduleVisible, setScheduleVisible] = useState(false);

  const showModal = (text: string) => {
    setModelText(text);
    setIsModalVisible(true);
  };

  useEffect(() => {
    if (!props.nemeeting) {
      return;
    }
    const initAccountInfo = () => {
      props.nemeeting
        ?.getAuthService()
        ?.getAccountInfo(
          (errorObject: NEErrorObject, accountInfo: NEAccountInfo) => {
            if (errorObject.code === 0) {
              setNickName(accountInfo.accountName);
            }
          }
        );
    };
    initAccountInfo();

    const authservice = props.nemeeting.getAuthService();
    authservice?.regEventCallback((eventName: string, eventContent: any) => {
      message.info(
        `authservice Event, eventName: ${eventName}, eventContent: ${JSON.stringify(
          eventContent,
          null,
          '\t'
        )}`
      );

      if (eventName === 'authInfoExpired') {
        history.push('/');
      }
    });

    const meetingservice = props.nemeeting?.getMeetingService();
    meetingservice?.regEventCallback(
      (
        eventName: string,
        eventContent: {
          [key: string]: any;
        }
      ) => {
        message.info(
          `meetingservice Event, eventName: ${eventName}, eventContent: ${JSON.stringify(
            eventContent,
            null,
            '\t'
          )}`
        );
      }
    );

    const preMeetingService = props.nemeeting?.getPremeetingService();
    const getMeetingList = () => {
      preMeetingService?.getMeetingList(
        [
          NEMeetingItemStatus.MeetingInit,
          NEMeetingItemStatus.MeetingStarted,
          NEMeetingItemStatus.MeetingEnded,
        ],
        (errorObject, list) => {
          if (errorObject.code !== 0) {
            message.error(
              `getMeetingList failed: ${errorObject.code}(${errorObject.msg})`
            );
            return;
          }
          setScheduleList(list);
        }
      );
    };
    getMeetingList();
    preMeetingService?.regEventCallback(
      (eventName: string, eventContent: any) => {
        if (eventName === 'meetingStatus') {
          const id = eventContent.meetingUniqueId;
          preMeetingService?.getMeetingItemById(id, (err, res) => {
            if (err.code !== 0) {
              message.error(
                `getMeetingItemById(${id}) failed: ${err.code}(${err.msg})`
              );
            }
            getMeetingList();
          });
        }
      }
    );
  }, [props.nemeeting]);

  const handleRelease = () => {
    props.nemeeting.unInitialize((errorObject: NEErrorObject) => {
      if (errorObject.code !== 0) {
        message.error(
          `unInitialize failed: ${errorObject.code}(${errorObject.msg})`
        );
      } else {
        message.success('unInitialize succeeded.');
      }
    });
  };

  const handleLogout = () => {
    props.nemeeting
      ?.getAuthService()
      ?.getAccountInfo(
        (errorObject: NEErrorObject, accountInfo: NEAccountInfo) => {
          if (errorObject.code !== 0) {
            props.nemeeting
              ?.getMeetingService()
              ?.leaveMeeting(
                false,
                (errorObjectLeaveMeeting: NEErrorObject) => {
                  if (errorObjectLeaveMeeting.code !== 0) {
                    message.error(
                      `leaveMeeting failed: ${errorObjectLeaveMeeting.code}(${errorObjectLeaveMeeting.msg})`
                    );
                  } else {
                    // handleRelease();
                    history.push('/');
                  }
                }
              );
          } else {
            props.nemeeting
              ?.getAuthService()
              ?.logout(false, (errorObjectLogout: NEErrorObject) => {
                if (errorObjectLogout.code !== 0) {
                  message.error(
                    `logout failed: ${errorObjectLogout.code}(${errorObjectLogout.msg})`
                  );
                } else {
                  // handleRelease();
                  history.push('/');
                }
              });
          }
        }
      );
  };

  const handleQuerySDKVersion = () => {
    props.nemeeting.queryKitVersion(
      (errorObject: NEErrorObject, version: string) => {
        if (errorObject.code !== 0) {
          message.error(
            `queryKitVersion failed: ${errorObject.code}(${errorObject.msg})`
          );
        } else {
          message.success(`SDK Version: ${version}`);
        }
      }
    );
  };

  const handleShowSettingWindow = () => {
    props.nemeeting
      ?.getSettingsService()
      ?.showSettingUIWnd({}, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `handleShowSettingWindow failed: ${errorObject.code}(${errorObject.msg})`
          );
        }
      });
  };

  const handleActiveWindow = () => {
    props.nemeeting.activeWindow((errorObject: NEErrorObject) => {
      if (errorObject.code !== 0) {
        message.error(
          `activeWindow failed: ${errorObject.code}(${errorObject.msg})`
        );
      }
    });
  };

  const handleSchedule = () => {
    setCurrentScheduleItem(undefined);
    setScheduleVisible(true);
  };

  const handleCreateMeeting = () => {
    const param: NEStartMeetingParams = {
      meetingId: meetingIdd,
      displayName: nickName,
      tag: userTag,
    };
    const opts: NEStartMeetingOptions = {
      noVideo: !enableVideo,
      noAudio: !enableAudio,
      noChat: !enableChatroom,
      noInvite: !enableInvitation,
      noScreenShare: !enableScreenShare,
      noView: !enableView,
      noWhiteboard: !enableOpenWhiteboard,
      noRename: !enableRename,
      defaultWindowMode: defaultWindow,
      meetingIdDisplayOption: meetingIdDisplay,
      noCloudRecord: !enableOpenRecord,
    };
    props.nemeeting
      ?.getMeetingService()
      ?.startMeeting(param, opts, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `startMeeting failed: ${errorObject.code}(${errorObject.msg})`
          );
        }
      });
  };

  const handlejoinMeeting = () => {
    const param: NEJoinMeetingParams = {
      meetingId: meetingIdd,
      displayName: nickName,
      password: meetingPassword,
      tag: userTag,
    };
    const opts: NEJoinMeetingOptions = {
      noVideo: !enableVideo,
      noAudio: !enableAudio,
      noChat: !enableChatroom,
      noInvite: !enableInvitation,
      noScreenShare: !enableScreenShare,
      noView: !enableView,
      noWhiteboard: !enableOpenWhiteboard,
      noRename: !enableRename,
      defaultWindowMode: defaultWindow,
      meetingIdDisplayOption: meetingIdDisplay,
    };
    props.nemeeting
      ?.getMeetingService()
      ?.joinMeeting(param, opts, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `joinMeeting failed: ${errorObject.code}(${errorObject.msg})`
          );
        }
      });
  };

  const handleleaveMeeting = () => {
    props.nemeeting
      ?.getMeetingService()
      ?.leaveMeeting(false, (errorObjectLeaveMeeting: NEErrorObject) => {
        if (errorObjectLeaveMeeting.code !== 0) {
          message.error(
            `leaveMeeting failed: ${errorObjectLeaveMeeting.code}(${errorObjectLeaveMeeting.msg})`
          );
        }
      });
  };

  const handleGetInfo = () => {
    props.nemeeting
      ?.getMeetingService()
      ?.getCurrentMeetingInfo(
        (errorObject: NEErrorObject, meetingInfo: NEMeetingInfo) => {
          if (errorObject.code !== 0) {
            message.error(
              `getCurrentMeetingInfo failed: ${errorObject.code}(${errorObject.msg})`
            );
          } else {
            const info = JSON.stringify(meetingInfo, null, '\t');
            showModal(`Curent Meeting Info: ${info}`);
          }
        }
      );
  };

  const handleGetStatus = () => {
    const status = props.nemeeting?.getMeetingService()?.getMeetingStatus();
    if (status) {
      setMeetingStatus(status);
      const tip = `current meeting status : ${status}`;
      message.info(tip);
    } else {
      message.error(`getMeetingStatus failed.`);
    }
  };

  const handleGetHistoryInfo = () => {
    props.nemeeting
      ?.getSettingsService()
      ?.getHistoryMeetingItem(
        (errorObject: NEErrorObject, historyInfos: NEHistoryMeetingItem[]) => {
          if (errorObject.code !== 0) {
            message.error(
              `getHistoryMeetingItem failed: ${errorObject.code}(${errorObject.msg})`
            );
          } else {
            const info = JSON.stringify(historyInfos[0], null, '\t');
            showModal(`History Meeting Info: ${info}`);
          }
        }
      );
  };

  const handleEnablePersonId = () => {
    if (!enablePersonId) {
      props.nemeeting
        ?.getAccountService()
        ?.getPersonalMeetingId(
          (errorObject: NEErrorObject, personalMeetingId: string) => {
            if (errorObject.code !== 0) {
              message.error(
                `getPersonalMeetingId failed: ${errorObject.code}(${errorObject.msg})`
              );
            } else {
              setMeetingIdd(personalMeetingId);
            }
          }
        );
    } else {
      setMeetingIdd('');
    }
  };

  const handleSubscribeAudio = () => {};

  const handleUnSubscribeAudio = () => {};

  const handleOk = () => {
    setIsModalVisible(false);
  };

  const handleCancel = () => {
    setIsModalVisible(false);
  };

  const handleJoin = (meetingId: string) => {
    const ms = props.nemeeting?.getMeetingService();
    const param: NEJoinMeetingParams = {
      meetingId,
      displayName: nickName,
      password: meetingPassword,
      tag: userTag,
    };
    const opts: NEJoinMeetingOptions = {
      noVideo: !enableVideo,
      noAudio: !enableAudio,
      noChat: !enableChatroom,
      noInvite: !enableInvitation,
      noScreenShare: !enableScreenShare,
      noView: !enableView,
      noWhiteboard: !enableOpenWhiteboard,
      noRename: !enableRename,
      defaultWindowMode: defaultWindow,
      meetingIdDisplayOption: meetingIdDisplay,
    };

    ms?.joinMeeting(param, opts, (err) => {
      if (err.code !== 0) {
        message.error(`joinMeeting fail: ${err.code} ${err.msg}`);
      }
    });
  };

  const handleEdit = (item: NEMeetingItem) => {
    setCurrentScheduleItem(item);
    setScheduleVisible(true);
  };

  return (
    <div className={styles.wrapper}>
      <div className={styles.content}>
        <Divider style={{ color: 'blue' }}> Divider </Divider>
        <div className={styles.mb10}>
          <Input
            className={styles.w300}
            placeholder="meetingId"
            onChange={(e) => {
              setMeetingIdd(e.target.value);
            }}
            value={meetingIdd}
          />
        </div>
        <div className={styles.mb10}>
          <Input
            className={`${styles.w300} ${styles.mr10}`}
            placeholder="meetingPassword"
            onChange={(e) => {
              setMeetingPassword(e.target.value);
            }}
            value={meetingPassword}
          />
        </div>
        <div className={styles.mb10}>
          <Input
            className={`${styles.w300} ${styles.mr10}`}
            placeholder="nickName"
            onChange={(e) => {
              setNickName(e.target.value);
            }}
            value={nickName}
          />
          <Input
            className={styles.w300}
            placeholder="userTag"
            onChange={(e) => {
              setUserTag(e.target.value);
            }}
            value={userTag}
          />
        </div>
        <Divider style={{ color: 'blue' }}> Divider </Divider>
        <div className={styles.mb10}>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableAudio}
            onChange={(e) => {
              setEnableAudio(e.target.checked);
            }}
          >
            enableAudio
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableVideo}
            onChange={(e) => {
              setEnableVideo(e.target.checked);
            }}
          >
            enableVideo
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableOpenWhiteboard}
            onChange={(e) => {
              setEnableOpenWhiteboard(e.target.checked);
            }}
          >
            enableOpenWhiteboard
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableRename}
            onChange={(e) => {
              setEnableRename(e.target.checked);
            }}
          >
            enableRename
          </Checkbox>
        </div>
        <div className={styles.mb10}>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableInvitation}
            onChange={(e) => {
              setEnableInvitation(e.target.checked);
            }}
          >
            enableInvitation
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableChatroom}
            onChange={(e) => {
              setEnableChatroom(e.target.checked);
            }}
          >
            enableChatroom
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableOpenRecord}
            onChange={(e) => {
              setEnableOpenRecord(e.target.checked);
            }}
          >
            enableOpenRecord
          </Checkbox>
        </div>
        <div className={styles.mb10}>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableScreenShare}
            onChange={(e) => {
              setEnableScreenShare(e.target.checked);
            }}
          >
            disableScreenShare
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enableView}
            onChange={(e) => {
              setEnableView(e.target.checked);
            }}
          >
            disableView
          </Checkbox>
          <Checkbox
            className={styles.checkboxItem}
            checked={enablePersonId}
            onChange={(e) => {
              setEnablePersonId(e.target.checked);
              handleEnablePersonId();
            }}
          >
            usePersonId
          </Checkbox>
        </div>
        <Divider style={{ color: 'blue' }}> Divider </Divider>
        <div className={styles.mb10}>
          MeetingId Show Format：
          <Select
            className={styles.selectItem}
            options={[
              { label: 'Display shordId only', value: 0 },
              { label: 'Display longId only', value: 1 },
              { label: 'Display all', value: 2 },
            ]}
            value={meetingIdDisplay}
            onChange={setMeetingIdDisplay}
          />
          Meeting Window Mode：
          <Select
            className={styles.selectItem}
            options={[
              { label: 'Whiteboard Mode', value: 0 },
              { label: 'Normal Mode', value: 1 },
            ]}
            value={defaultWindow}
            onChange={setDefaultWindow}
          />
        </div>
        {false ? (
          <div className={styles.mb10}>
            <Button
              className={styles.buttonItem}
              onClick={handleSubscribeAudio}
            >
              SubscribeAudio
            </Button>
            <Button
              className={styles.buttonItem}
              onClick={handleUnSubscribeAudio}
            >
              UnSubscribeAudio
            </Button>
          </div>
        ) : null}
        <div className={styles.mb10}>
          <Button className={styles.buttonItem} onClick={handleCreateMeeting}>
            CreateMeeting
          </Button>
          <Button className={styles.buttonItem} onClick={handlejoinMeeting}>
            JoinMeeting
          </Button>
          <Button className={styles.buttonItem} onClick={handleleaveMeeting}>
            LeaveMeeting
          </Button>
        </div>
        <div className={styles.mb10}>
          <Button className={styles.buttonItem} onClick={handleGetInfo}>
            GetInfo
          </Button>
          <Button className={styles.buttonItem} onClick={handleGetStatus}>
            GetStatus
          </Button>
          <Button className={styles.buttonItem} onClick={handleGetHistoryInfo}>
            GetHistoryInfo
          </Button>
        </div>
        <div className={styles.mb10}>
          <Button className={styles.buttonItem} onClick={handleLogout}>
            Logout
          </Button>
          <Button className={styles.buttonItem} onClick={handleSchedule}>
            ScheduleMeeting
          </Button>
          <Button className={styles.buttonItem} onClick={handleQuerySDKVersion}>
            {' '}
            QuerySDKVersion
          </Button>
          <Button
            className={styles.buttonItem}
            onClick={handleShowSettingWindow}
          >
            {' '}
            ShowSettingsWindow
          </Button>
          <Button className={styles.buttonItem} onClick={handleActiveWindow}>
            {' '}
            ActiveWindow
          </Button>
        </div>
        <Modal
          title="Toast"
          visible={isModalVisible}
          onOk={handleOk}
          onCancel={handleCancel}
        >
          <p>{modelText}</p>
        </Modal>
        {scheduleList.length ? (
          <List
            itemLayout="horizontal"
            dataSource={scheduleList}
            renderItem={(item) => {
              return (
                <List.Item>
                  <div>
                    <div>MeetingSubject: {item.subject}</div>
                    <div>
                      Meeting Start Time:
                      {moment(item.startTime).format('YYYY-MM-DD HH:mm:ss')}
                      &nbsp;&nbsp;&nbsp;&nbsp; Meeting End Time:
                      {moment(item.endTime).format('YYYY-MM-DD HH:mm:ss')}
                    </div>
                    <div>
                      MeetingId: {item.meetingId} &nbsp;&nbsp;&nbsp;&nbsp;
                      MeetingUniqueId: {item.meetingUniqueId}{' '}
                      &nbsp;&nbsp;&nbsp;&nbsp;MeetingStauts:{' '}
                      {statusMap[item.status]}
                    </div>
                    <div>scene: {JSON.stringify(item.setting)}</div>
                    <div>
                      <Button
                        className={styles.mr10}
                        onClick={() => {
                          handleJoin(item.meetingId);
                        }}
                      >
                        Join
                      </Button>
                      <Button
                        onClick={() => {
                          handleEdit(item);
                        }}
                      >
                        Edit
                      </Button>
                    </div>
                  </div>
                </List.Item>
              );
            }}
          />
        ) : null}
        <Schedule
          nemeeting={props.nemeeting}
          visible={scheduleVisible}
          data={currentScheduleItem}
          onCancel={() => {
            setScheduleVisible(false);
          }}
        />
      </div>
    </div>
  );
};

export default Meeting;
