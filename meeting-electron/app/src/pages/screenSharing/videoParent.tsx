import { useEffect, useState } from 'react';
import classNames from 'classnames';
import './index.less';

export default function VideoParentPage() {
  const [videoCount, setVideoCount] = useState(1);

  useEffect(() => {
    window.ipcRenderer?.send('nemeeting-sharing-screen', {
      method: 'videoCountModelChange',
      data: {
        videoCount,
      },
    });
  }, [videoCount]);

  return (
    <div className="video-parent-page">
      <div className="video-parent-page-header">
        <svg
          className={classNames('icon iconfont', {
            selected: videoCount === 0,
          })}
          aria-hidden="true"
          onClick={() => setVideoCount(0)}
        >
          <use xlinkHref="#icona-Frame1"></use>
        </svg>
        <svg
          className={classNames('icon iconfont', {
            selected: videoCount === 1,
          })}
          aria-hidden="true"
          onClick={() => setVideoCount(1)}
        >
          <use xlinkHref="#icona-Frame21"></use>
        </svg>
        <svg
          className={classNames('icon iconfont', {
            selected: videoCount === 4,
          })}
          aria-hidden="true"
          onClick={() => setVideoCount(4)}
        >
          <use xlinkHref="#icona-Frame3"></use>
        </svg>
        <div className="drag-area"></div>
      </div>
    </div>
  );
}
