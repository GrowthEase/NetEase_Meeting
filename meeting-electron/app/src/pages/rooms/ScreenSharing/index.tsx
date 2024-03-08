import Styles from './index.less';
import { RoomsInfo } from '../request';
import CloseOutlined from '@ant-design/icons/CloseOutlined';
import ArrowImage from '../../../assets/rooms-arrow.png';
import { Tag } from 'antd';

interface RoomPageProps {
  roomsInfo?: RoomsInfo;
  inMeeting?: boolean;
  onClose?: () => void;
}

const ScreenSharing: React.FC<RoomPageProps> = ({
  roomsInfo,
  inMeeting,
  onClose,
}) => {
  return (
    <div
      className={Styles.screenSharingWrapper}
      style={{
        background: inMeeting
          ? 'rgba(0, 0, 0, 0.7)'
          : 'rgba(255, 255, 255, 0.1)',
      }}
    >
      <CloseOutlined
        className={Styles.screenSharingClose}
        onClick={() => onClose?.()}
      />
      <div className={Styles.screenSharingTitle}>共享码</div>
      <div className={Styles.screenSharingCode}>{roomsInfo?.pairingCode}</div>
      <div className={Styles.screenSharingSubTitle}>操作流程图示</div>
      <div className={Styles.screenSharingSteps}>
        <div>
          <Tag className={Styles.screenSharingStepTag} color="#337EFF">
            1
          </Tag>
          打开POPO或者小易助手
        </div>
        <img src={ArrowImage} />
        <div>
          <Tag className={Styles.screenSharingStepTag} color="#337EFF">
            2
          </Tag>
          打开易投屏
        </div>
        <img src={ArrowImage} />
        <div>
          <Tag className={Styles.screenSharingStepTag} color="#337EFF">
            3
          </Tag>
          输入投屏码进行投屏
        </div>
      </div>
    </div>
  );
};

export default ScreenSharing;
