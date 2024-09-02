import { useLocation } from 'umi';
import './index.less';
import React from 'react';

const ScreenMarker: React.FC = () => {
  const { pathname } = useLocation();
  const index = pathname.split('/').pop() || 0;

  return <div className="screen-marker">{Number(index) + 1}</div>;
};

export default ScreenMarker;
