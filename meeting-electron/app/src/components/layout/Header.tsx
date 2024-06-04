import React, { FC, useEffect, useState } from 'react';
import { history } from 'umi';
import styles from './index.less';
import { Button, Dropdown, Space } from 'antd';
import {
  LOCALSTORAGE_LOGIN_BACK,
  LOCALSTORAGE_USER_INFO,
  WEBSITE_URL,
} from '../../config';
import { useTranslation } from 'react-i18next';

// const newVersion =
//   window.location.href.indexOf('/v2') > -1 ||
//   window.location.href.indexOf('%2Fv2') > -1;

const newVersion = true;

interface HeaderProps {
  onLogin?: () => void;
}

const Header: FC<HeaderProps> = (props) => {
  const { onLogin } = props;
  const { t } = useTranslation();
  const [userinfo, setUserInfo] = useState<any>();

  const logout = () => {
    if (newVersion) {
      localStorage.removeItem(LOCALSTORAGE_USER_INFO);
      localStorage.removeItem('loginWayV2');
      localStorage.removeItem('loginAppNameSpaceV2');
      localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK);
    } else {
      localStorage.removeItem('userinfo');
      localStorage.removeItem('loginWay');
      localStorage.removeItem('loginAppNameSpace');
    }
    toWebsite();
  };

  const toProfile = () => {
    history.push(newVersion ? '/profile/v2' : '/profile');
  };

  const toWebsite = () => {
    window.location.href = WEBSITE_URL;
  };

  useEffect(() => {
    const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);
    if (userString) {
      const user = JSON.parse(userString);
      setUserInfo(user);
    }
  }, []);
  return (
    <div className={styles.header}>
      <img src={require('../../assets/logo.png')} onClick={toWebsite} />
      <div className={styles.menu}></div>
      {userinfo?.userUuid ? (
        <Space size="large">
          {/* <Space className={styles.linkBtn} size="small">
            <div className={styles.text} onClick={toJoin}>
              加入会议
            </div>
          </Space> */}
          <Dropdown
            dropdownRender={(menu) => (
              <>
                <ul className={styles.dropdownMenu}>
                  <li
                    className={styles.toProfile}
                    onClick={(e) => {
                      toProfile();
                    }}
                  >
                    个人信息
                  </li>
                  <li
                    className={styles.toProfile}
                    onClick={(e) => {
                      logout();
                    }}
                  >
                    退出登录
                  </li>
                </ul>
              </>
            )}
          >
            <a onClick={(e) => e.preventDefault()} className={styles.user}>
              <span>{userinfo?.nickname?.slice(0, 1) || '易'}</span>
            </a>
          </Dropdown>
        </Space>
      ) : (
        <div className={styles.loginPanel}>
          {onLogin ? (
            <Button onClick={() => onLogin?.()} type="primary">
              {t('authLogin')}
            </Button>
          ) : null}
          {/* 当前版本暂不开放注册 */}
          {/* <Button
            type="primary"
            onClick={() => {
              history.push(newVersion ? '/register/v2' : '/register');
            }}
          >
            免费注册
          </Button> */}
        </div>
      )}
    </div>
  );
};

export default Header;
