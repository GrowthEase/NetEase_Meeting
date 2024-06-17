import React, { useEffect } from 'react';
import { RoomsInfo } from '../request';
import Styles from './index.less';
import { ConfigProvider, message } from 'antd';
import QRCode from 'react-qr-code';

import RoomsIcon from '../../../assets/rooms-icon.png';

const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

interface RoomsBindPageProps {
  roomsInfo?: RoomsInfo;
  onUnbind: () => void;
  onNext: () => void;
}

const RoomsBindPage: React.FC<RoomsBindPageProps> = ({
  roomsInfo,
  onUnbind,
  onNext,
}) => {
  useEffect(() => {
    message.success('Rooms 激活成功，请连接绑定控制器');
  }, []);

  return (
    <div className={Styles.roomsBindWrapper}>
      {roomsInfo ? (
        <div className={Styles.roomsBindInfo}>
          <img
            className={Styles.roomsIcon}
            src={roomsInfo.brandInfo?.brandLogoUrl || RoomsIcon}
          />
          <div className={Styles.roomsTitle}>
            {roomsInfo.brandInfo?.brandName || '网易会议 Rooms'}
          </div>
          <div className={Styles.roomsPosition}>{roomsInfo?.nickname}</div>
          <div className={Styles.roomsBindRemind}>
            请在会控软件中输入共享码或扫描二维码以确认信息进行绑定
          </div>
          <div className={Styles.roomsBindCode}>{roomsInfo?.pairingCode}</div>
          <div className={Styles.qrCodeBox}>
            <QRCode size={200} value={roomsInfo?.pairingCode} />
          </div>
        </div>
      ) : null}
      <div className={Styles.back} onClick={() => onUnbind()}>
        <div className={Styles.iconWrapper}>
          <svg className={Styles.icon} aria-hidden="true">
            <use xlinkHref="#iconyx-returnx"></use>
          </svg>
        </div>
        <span className={Styles.text}>返回</span>
      </div>
      <div className={Styles.next} onClick={() => onNext()}>
        <span className={Styles.text}>跳过</span>
        <div className={Styles.iconWrapper}>
          <svg className={Styles.icon} aria-hidden="true">
            <use xlinkHref="#iconyx-allowx"></use>
          </svg>
        </div>
      </div>
    </div>
  );
};

export default RoomsBindPage;
