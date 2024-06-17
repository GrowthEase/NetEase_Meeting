import React from 'react';
import './index.less';

interface LoginHeaderProps {
  title: string;
  icon: string;
  onClick?: () => void;
}

const LoginTypeIcon: React.FC<LoginHeaderProps> = ({
  title,
  icon,
  onClick,
}) => {
  return (
    <div className="nemeeting-login-type-icon" onClick={onClick}>
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref={`#${icon}`}></use>
      </svg>
      <div className="text">{title}</div>
    </div>
  );
};

export default LoginTypeIcon;
