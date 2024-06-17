import React, { useEffect, useState } from 'react';
import AnnotationView from '../../../../src/components/common/AnnotationView';
import './index.less';

const AnnotationPage: React.FC = () => {
  const [windowOpen, setWindowOpen] = useState(false);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event } = e.data;

      // 关闭统一处理页面重置逻辑
      switch (event) {
        case 'windowOpen':
          setWindowOpen(true);
          break;
        default:
          break;
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return <AnnotationView isEnable={windowOpen} />;
};

export default AnnotationPage;
