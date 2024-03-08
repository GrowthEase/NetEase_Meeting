import React from 'react';
import './index.less';
interface LoginHeaderProps {
  title: string;
  goBack: () => void;
}

const LoginHeader: React.FC<LoginHeaderProps> = ({ title, goBack }) => {
  return (
    <div className="loginTop">
      <div className="loginTopLeft">
        <div className="back-arrow">
          <svg
            className={'backIcon icon'}
            onClick={() => goBack?.()}
            aria-hidden="true"
          >
            <use xlinkHref="#iconyx-returnx"></use>
          </svg>
        </div>

        <span className="loginTitle">{title}</span>
      </div>
    </div>
  );
};

export default LoginHeader;
