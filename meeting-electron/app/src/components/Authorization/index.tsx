import { use } from 'i18next';
import Styles from './index.less';
import { Button, ConfigProvider } from 'antd';
import { useEffect, useState, FC, useRef } from 'react';

const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

const Direction: React.FC<{ title: string }> = ({ title }) => {
  return (
    <div className={Styles.direction}>
      <div>
        <span className={Styles.number}>1</span>
        系统偏好设置
      </div>
      <div className={Styles.arrows}></div>
      <div>
        <span className={Styles.number}>2</span>
        安全性与隐私
      </div>
      <div className={Styles.arrows}></div>
      <div>
        <span className={Styles.number}>3</span>
        {title}勾选会议Rooms 授权
      </div>
    </div>
  );
};

interface AuthorizationProps {
  showBtn?: boolean;
  onCancel?: () => void;
}
const Authorization: FC<AuthorizationProps> = ({
  showBtn = true,
  onCancel,
}) => {
  const [hasMicAuthorization, setHasMicAuthorization] = useState(false);
  const [hasCameraAuthorization, setHasCameraAuthorization] = useState(false);

  useEffect(() => {
    if (showBtn) {
      askForMediaAccessOnInit('microphone');
      askForMediaAccessOnInit('camera');
      const timer = setInterval(async () => {
        // @ts-ignore
        const { ipcRenderer } = window;
        if (ipcRenderer) {
          const {
            camera: hasCameraAuthorization,
            microphone: hasMicAuthorization,
          } = await ipcRenderer.invoke('getDeviceAccessStatus');

          setHasMicAuthorization(hasMicAuthorization === 'granted');
          setHasCameraAuthorization(hasCameraAuthorization === 'granted');
        }
      }, 1000);

      // 在组件卸载时清除定时器
      return () => {
        if (timer) {
          clearInterval(timer);
        }
      };
    }
  }, [showBtn]);

  const askForMediaAccess = async (type: 'microphone' | 'camera') => {
    // @ts-ignore
    window.ipcRenderer?.send('askForMediaAccess', type);
  };

  const askForMediaAccessOnInit = async (type: 'microphone' | 'camera') => {
    // @ts-ignore
    window.ipcRenderer?.send('askForMediaAccessOnInit', type);
  };

  const jumpAuthorization = () => {
    if (showBtn) {
      // @ts-ignore
      window.ipcRenderer?.send('jump-authorization');
    } else {
      onCancel?.();
    }
  };
  return (
    <div
      style={{ borderRadius: showBtn ? '0px' : '4px' }}
      className={Styles.wrapper}
    >
      <div className={Styles.warningIcon}></div>
      <div className={Styles.warningText}>请授予会议Rooms 以下权限</div>
      <div className={Styles.warningTextWithIT}>
        请联系IT管理员，授予会议Rooms 以下权限以正常使用会议功能
      </div>
      <div className={Styles.audioWrapper}>
        <div className={Styles.iconAndTextWrapper}>
          <div className={Styles.audioIcon}></div>
          <div className={Styles.audioText}>麦克风</div>
        </div>
        {showBtn && (
          <Button
            disabled={hasMicAuthorization}
            onClick={() => askForMediaAccess('microphone')}
            type="primary"
            className={Styles.audioBtn}
          >
            {hasMicAuthorization ? '已授权' : '去授权'}
          </Button>
        )}
      </div>
      <Direction title="麦克风" />
      <div className={Styles.videoWrapper}>
        <div className={Styles.iconAndTextWrapper}>
          <div className={Styles.videoIcon}></div>
          <div className={Styles.videoText}>摄像头</div>
        </div>
        {showBtn && (
          <Button
            disabled={hasCameraAuthorization}
            onClick={() => askForMediaAccess('camera')}
            type="primary"
            className={Styles.videoBtn}
          >
            {hasCameraAuthorization ? '已授权' : '去授权'}
          </Button>
        )}
      </div>
      <Direction title="摄像头" />
      <div className={Styles.line}></div>
      <Button onClick={jumpAuthorization} className={Styles.jumpAuthorization}>
        {showBtn
          ? hasCameraAuthorization && hasMicAuthorization
            ? '进入应用'
            : '跳过授权'
          : '取消'}
      </Button>
    </div>
  );
};

export default Authorization;
