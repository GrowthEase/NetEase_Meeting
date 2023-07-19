import React, { useState } from 'react';
import {
  Input,
  Button,
  Checkbox,
  Select,
  Radio,
  Divider,
  message,
  InputNumber,
} from 'antd';
import { useHistory } from 'react-router-dom';
import NEMeetingSDK, {
  NEErrorObject,
  NEJoinMeetingOptions,
  NEJoinMeetingParams,
  NEMeetingKitConfig,
  NEMAppInfo,
} from 'nemeeting-sdk';
import styles from './index.module.css';

interface IProps {
  nemeeting: NEMeetingKit;
}

const loginOptions = [
  {
    label: 'Password Login',
    value: 'password',
  },
  {
    label: 'Token Login',
    value: 'token',
  },
  // {
  //   label: 'SSO Login',
  //   value: 'ssotoken',
  // },
  // {
  //   label: 'Anon Join Meeting',
  //   value: 'anon',
  // },
];

const logTypeOptions = [
  {
    label: 'VERBOSE',
    value: 0,
  },
  {
    label: 'DEBUG',
    value: 1,
  },
  {
    label: 'INFO',
    value: 2,
  },
  {
    label: 'WARN',
    value: 3,
  },
  {
    label: 'ERROR',
    value: 4,
  },
];

const appkeyTypeOptions = [
  {
    label: 'Test',
    value: 'test',
  },
  {
    label: 'Online',
    value: 'online',
  },
  {
    label: 'Custom',
    value: 'custom',
  },
];

const Login = (props: IProps) => {
  const history = useHistory();

  const [appkey, setAppkey] = useState('4649991c6ab7cc5a4309ccf25d8793e5');
  const [appkeyDisplay, setAppkeyDisplay] = useState('');
  const [appkeyDisabled, setAppkeyDisabled] = useState(true);
  const [appkeyOptions, setAppkeyOptions] = useState('test');

  const [adminPri, setAdminPri] = useState(false);
  const [logPath, setLogPath] = useState('');
  const [logType, setLogType] = useState(2);
  const [aliveTime, setAliveTime] = useState(10);
  const [runAdminHidden, setRunAdminHidden] = useState(
    process.platform === 'win32'
  );

  const [accountId, setAccountId] = useState(
    process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true'
      ? 'wjzh'
      : ''
  );
  const [accountIdPlaceholder, setAccountIdPlaceholder] = useState('userName');
  const [accountIdHidden, setAccountIdHidden] = useState(false);

  const [token, setToken] = useState(
    process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true'
      ? '123456'
      : ''
  );
  const [tokenPlaceholder, setTokenPlaceholder] = useState('password');
  const [tokenHidden, setTokenHidden] = useState(false);

  const [meetingIdd, setMeetingIdd] = useState(
    process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true'
      ? '8931242428'
      : ''
  );
  const [meetingIdHidden, setMeetingIdHidden] = useState(true);

  const [meetingPassword, setMeetingPassword] = useState('');
  const [meetingPasswordHidden, setMeetingPasswordHidden] = useState(true);

  const [loginType, setLoginType] = useState('password');

  const [nickName, setNickname] = useState('nickname');
  const [nickNameHidden, setNicknameHidden] = useState(true);

  const [userTag, setUserTag] = useState('');
  const [userTagHidden, setUserTagHidden] = useState(true);

  const [loginBtnText, setLoginBtnText] = useState('Login');

  const handleLoginEx = () => {
    switch (loginType) {
      case 'password':
        props.nemeeting
          ?.getAuthService()
          ?.loginWithNEMeeting(
            accountId,
            token,
            (errorObjectLoginWithNEMeeting: NEErrorObject) => {
              if (errorObjectLoginWithNEMeeting.code !== 0) {
                message.error(
                  `loginWithNEMeeting failed: ${errorObjectLoginWithNEMeeting.code}(${errorObjectLoginWithNEMeeting.msg})`
                );
              } else {
                history.push('/meeting');
              }
            }
          );
        break;
      case 'token':
        props.nemeeting
          ?.getAuthService()
          ?.login(accountId, token, (errorObjectLogin: NEErrorObject) => {
            if (errorObjectLogin.code !== 0) {
              message.error(
                `login failed: ${errorObjectLogin.code}(${errorObjectLogin.msg})`
              );
            } else {
              history.push('/meeting');
            }
          });
        break;
      case 'ssotoken':
        props.nemeeting
          ?.getAuthService()
          ?.loginWithSSOToken(
            accountId,
            (errorObjectLoginWithSSOToken: NEErrorObject) => {
              if (errorObjectLoginWithSSOToken.code !== 0) {
                message.error(
                  `loginWithSSOToken failed: ${errorObjectLoginWithSSOToken.code}(${errorObjectLoginWithSSOToken.msg})`
                );
              } else {
                history.push('/meeting');
              }
            }
          );
        break;
      case 'anon':
        {
          const param: NEJoinMeetingParams = {
            meetingId: meetingIdd,
            displayName: nickName,
            password: meetingPassword,
            tag: userTag,
          };
          const opts: NEJoinMeetingOptions = {};
          props.nemeeting
            ?.getMeetingService()
            ?.joinMeeting(
              param,
              opts,
              (errorObjectJoinMeeting: NEErrorObject) => {
                if (errorObjectJoinMeeting.code !== 0) {
                  message.error(
                    `joinMeeting failed: ${errorObjectJoinMeeting.code}(${errorObjectJoinMeeting.msg})`
                  );
                } else {
                  // history.push('/meeting');
                }
              }
            );
        }
        break;
      default:
        message.error('登陆类型错误');
        break;
    }
  };

  const handleLogin = () => {
    const sdkConfig: NEMeetingKitConfig = {
      appKey: appkey,
      appInfo: {
        productName: 'NetEase Meeting',
        organizationName: 'NetEase',
        applicationName: 'Meeting',
        sdkPath: '',
      },
      domain: 'yunxin.163.com',
      useAssetServerConfig: false,
      keepAliveInterval: aliveTime,
      loggerConfig: { path: logPath, level: logType },
      runAdmin: adminPri,
    };

    if (!props.nemeeting.isInitialized()) {
      props.nemeeting.initialize(sdkConfig, (errorObject: NEErrorObject) => {
        if (errorObject.code !== 0) {
          message.error(
            `initialize failed: ${errorObject.code}(${errorObject.msg})`
          );
        } else {
          if (!props.nemeeting.isInitialized()) {
            message.error('Please initialize first!');
            return;
          }
          handleLoginEx();
        }
      });
    } else {
      handleLoginEx();
    }
  };

  const handleLoginType = (value: string) => {
    setLoginType(value);
    switch (value) {
      case 'password':
        setAccountIdHidden(false);
        setAccountIdPlaceholder('userName');
        setTokenPlaceholder('password');
        setTokenHidden(false);
        setMeetingIdHidden(true);
        setMeetingPasswordHidden(true);
        setNicknameHidden(true);
        setUserTagHidden(true);
        setLoginBtnText('Login');
        break;
      case 'token':
        setAccountIdHidden(false);
        setAccountIdPlaceholder('accoundId');
        setTokenPlaceholder('token');
        setTokenHidden(false);
        setMeetingIdHidden(true);
        setMeetingPasswordHidden(true);
        setNicknameHidden(true);
        setUserTagHidden(true);
        setLoginBtnText('Login');
        break;
      case 'ssotoken':
        setAccountIdHidden(false);
        setAccountIdPlaceholder('ssoToken');
        setTokenHidden(true);
        setMeetingIdHidden(true);
        setMeetingPasswordHidden(true);
        setNicknameHidden(true);
        setUserTagHidden(true);
        setLoginBtnText('Login');
        break;
      case 'anon':
        setAccountIdHidden(true);
        setTokenHidden(true);
        setMeetingIdHidden(false);
        setMeetingPasswordHidden(false);
        setNicknameHidden(false);
        setUserTagHidden(false);
        setLoginBtnText('Join');
        break;
      default:
        message.error('登陆类型错误');
        break;
    }
  };

  const handleAppkeyOptions = (value: string) => {
    setAppkeyOptions(value);
    setAppkeyDisplay('');
    if (value === 'custom') {
      setAppkey('');
      setAppkeyDisabled(false);
    } else if (value === 'test') {
      setAppkey('4649991c6ab7cc5a4309ccf25d8793e5');
      setAppkeyDisabled(true);
    } else if (value === 'online') {
      setAppkey('91d597b20132e6fa131615aa2d229388');
      setAppkeyDisabled(true);
    }
  };

  return (
    <div className={styles.wrapper}>
      <div className={styles.content}>
        <div className={styles.row}>
          <Select
            style={{ width: 200 }}
            className={styles.mr10}
            options={loginOptions}
            value={loginType}
            onChange={handleLoginType}
          />
        </div>
        <div className={styles.row}>
          <Input
            // style={{ width: 500 }}
            placeholder="appKey"
            value={appkeyDisplay}
            disabled={appkeyDisabled}
            onChange={(e) => {
              if (appkeyOptions === 'custom') {
                setAppkey(e.target.value);
                setAppkeyDisplay(e.target.value);
              }
            }}
          />
          <Select
            className={styles.mr10}
            style={{ width: 140 }}
            options={appkeyTypeOptions}
            value={appkeyOptions}
            onChange={handleAppkeyOptions}
          />
        </div>
        <div className={styles.row}>
          <Input
            className={styles.mr10}
            placeholder="SDK Log path"
            value={logPath}
            onChange={(e) => {
              setLogPath(e.target.value);
            }}
          />
          <Select
            className={styles.mr10}
            style={{ width: 140 }}
            options={logTypeOptions}
            value={logType}
            onChange={setLogType}
          />
        </div>
        <div className={`${styles.row} ${styles.flexLeft}`}>
          <InputNumber
            // className={styles.mr10}
            style={{ width: 150 }}
            placeholder="keep alive time(s)"
            value={aliveTime}
            onChange={setAliveTime}
          />
          {runAdminHidden ? (
            <Checkbox
              style={{ width: 260 }}
              checked={adminPri}
              onChange={(e) => {
                setAdminPri(e.target.checked);
              }}
            >
              Admin privileges
            </Checkbox>
          ) : null}
        </div>
        <Divider style={{ color: 'blue' }}> Divider </Divider>
        {!accountIdHidden ? (
          <div className={styles.row}>
            <Input
              className={styles.mr10}
              placeholder={accountIdPlaceholder}
              value={accountId}
              onChange={(e) => {
                setAccountId(e.target.value);
              }}
            />
          </div>
        ) : null}
        <div className={styles.row}>
          {!tokenHidden ? (
            <Input
              className={styles.mr10}
              placeholder={tokenPlaceholder}
              value={token}
              onChange={(e) => {
                setToken(e.target.value);
              }}
            />
          ) : null}
        </div>
        <div className={styles.row}>
          {!meetingIdHidden ? (
            <Input
              className={styles.mr10}
              placeholder="meetingId"
              value={meetingIdd}
              onChange={(e) => {
                setMeetingIdd(e.target.value);
              }}
            />
          ) : null}
        </div>
        <div className={styles.row}>
          {!meetingPasswordHidden ? (
            <Input
              className={styles.mr10}
              placeholder="meetingPassword"
              value={meetingPassword}
              onChange={(e) => {
                setMeetingPassword(e.target.value);
              }}
            />
          ) : null}
        </div>
        <div className={styles.row}>
          {!nickNameHidden ? (
            <Input
              className={styles.mr10}
              placeholder="nickname"
              value={nickName}
              onChange={(e) => {
                setNickname(e.target.value);
              }}
            />
          ) : null}
        </div>
        <div className={styles.row}>
          {!userTagHidden ? (
            <Input
              className={styles.mr10}
              placeholder="userTag"
              value={userTag}
              onChange={(e) => {
                setUserTag(e.target.value);
              }}
            />
          ) : null}
        </div>
        <div className={styles.row}>
          <Button
            style={{ width: '100%' }}
            type="primary"
            onClick={handleLogin}
          >
            {loginBtnText}
          </Button>
        </div>
      </div>
    </div>
  );
};

export default Login;
