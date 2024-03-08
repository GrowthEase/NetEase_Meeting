import { use } from 'i18next';
import Styles from './index.less';
import { Button, ConfigProvider, Modal } from 'antd';
import { useEffect, useState } from 'react';
import Authorization from '../Authorization';

const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

const AuthorizationTip = () => {
  const [showModal, setShowModal] = useState(false);
  return (
    <div>
      <div className={Styles.dialog}>
        <div className={Styles.warnIcon}></div>
        <div className={Styles.titleWrapper}>
          <div className={Styles.title}>未获取到系统权限，会议功能不可用</div>
          <div className={Styles.subTitle}>
            当前应用未获取到麦克风、摄像头的系统权限，请联系IT管理员允许会议Rooms
            访问相关权限，设置后请重启应用。
          </div>
        </div>
        <Button
          onClick={() => {
            setShowModal(true);
          }}
          type="primary"
          className={Styles.button}
        >
          查看详情
        </Button>
      </div>
      {showModal && (
        <div className={Styles.modal}>
          <Authorization
            showBtn={false}
            onCancel={() => {
              setShowModal(false);
            }}
          ></Authorization>
        </div>
      )}
    </div>
  );
};

export default AuthorizationTip;
