import React from 'react';
import './index.less';
import classNames from 'classnames';

interface LoginHeaderProps {
  title: string;
  subTitle?: string;
  goBack: () => void;
}

const LoginHeader: React.FC<LoginHeaderProps> = ({
  title,
  subTitle,
  goBack,
}) => {
  return (
    <div className="loginTop">
      <div
        className={classNames('loginTopLeft', {
          'login-top-left-web': !window.isElectronNative,
        })}
      >
        <span
          className={classNames('back-icon back-icon-wrap', {
            'login-top-left--back-web': !window.isElectronNative,
          })}
        >
          <svg
            className={'back-icon icon'}
            onClick={() => goBack?.()}
            aria-hidden="true"
          >
            <use xlinkHref="#iconyx-returnx"></use>
          </svg>
        </span>
        <div className="loginSubTitle">{subTitle}</div>
        <span className="loginTitle">{title}</span>
      </div>
    </div>
  );
};

export default LoginHeader;
