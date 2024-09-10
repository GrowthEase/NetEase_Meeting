import HomePage from '../components/HomePage';
import './index.less';
import qs from 'qs';
import React, { useEffect } from 'react';
import { LOCALSTORAGE_LOGIN_BACK } from '@/config';

const IndexPage: React.FC = () => {
  window.h5App = false;
  const [isGuest, setIsGuest] = React.useState(false);

  useEffect(() => {
    const query = qs.parse(window.location.href.split('?')[1]?.split('#/')[0]);

    if (query?.backUrl) {
      localStorage.setItem(LOCALSTORAGE_LOGIN_BACK, query.backUrl as string);
    } else {
      localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK);
    }
  }, []);

  useEffect(() => {
    if (!window.isElectronNative) {
      // 创建URL对象
      const qsObj = qs.parse(
        window.location.href.split('?')[1]?.split('#/')[0],
      );
      const guestJoinType = qsObj?.guestJoinType;

      if (guestJoinType === '1' || guestJoinType === '2') {
        setIsGuest(true);
      }
    }
  }, []);

  return (
    <div
      className={`main-app ${
        window.ipcRenderer ? 'main-app-electron' : 'main-app-web'
      } ${isGuest ? 'main-app-guest' : ''}`}
    >
      <HomePage />
    </div>
  );
};

export default IndexPage;
