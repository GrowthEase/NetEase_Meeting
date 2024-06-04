import HomePage from '../../../src/components/common/Homepage';
import './index.less';
import qs from 'qs';
import React, { useEffect } from 'react';
import { LOCALSTORAGE_LOGIN_BACK } from '@/config';

export default function IndexPage() {
  window.h5App = false;
  useEffect(() => {
    const query = qs.parse(window.location.href.split('?')[1]?.split('#/')[0]);
    // @ts-ignore
    if (query?.backUrl) {
      localStorage.setItem(LOCALSTORAGE_LOGIN_BACK, query.backUrl as string);
    } else {
      localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK);
    }
  }, []);
  return (
    <div
      className={`main-app ${
        // @ts-ignore
        window.ipcRenderer ? 'main-app-electron' : 'main-app-web'
      }`}
    >
      <HomePage />
    </div>
  );
}
