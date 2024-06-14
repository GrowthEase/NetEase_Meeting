import HomePage from '../../../src/components/common/Homepage';
import './index.less';
import qs from 'qs';
import React, { useEffect } from 'react';
import { LOCALSTORAGE_LOGIN_BACK } from '@/config';

const IndexPage: React.FC = () => {
  window.h5App = false;
  useEffect(() => {
    const query = qs.parse(window.location.href.split('?')[1]?.split('#/')[0]);

    if (query?.backUrl) {
      localStorage.setItem(LOCALSTORAGE_LOGIN_BACK, query.backUrl as string);
    } else {
      localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK);
    }
  }, []);
  return (
    <div
      className={`main-app ${
        window.ipcRenderer ? 'main-app-electron' : 'main-app-web'
      }`}
    >
      <HomePage />
    </div>
  );
};

export default IndexPage;
