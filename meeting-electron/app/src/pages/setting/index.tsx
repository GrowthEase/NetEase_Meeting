import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import SettingWeb from '../../../../src/components/electron/Setting/SettingWeb';
import Styles from './index.less';
import { ConfigProvider } from 'antd';
import antd_zh_CH from 'antd/locale/zh_CN';
import { useTranslation } from 'react-i18next';
const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

export default function IndexPage() {
  const { t } = useTranslation();

  return (
    <div className={Styles.settingWeb}>
      <div className={Styles.settingHeader}>
        <div className={Styles.electronDragBar} />
        {t('settings')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <SettingWeb />
    </div>
  );
}
