import Styles from './index.less';
import { ConfigProvider, Input } from 'antd';
import { useRef } from 'react';
import { useEffect, useState } from 'react';
import QRCode from 'react-qr-code';
import req, { QRCodeRes } from '../request';

const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

interface BeforeActivatePageProps {
  qrcode: string;
  onActivate: (code: string) => void;
}

const BeforeActivatePage: React.FC<BeforeActivatePageProps> = ({
  qrcode,
  onActivate,
}) => {
  const CODE_LENGTH = 8;

  const [values, setValues] = useState<string[]>([]);

  useEffect(() => {
    const handleKeyDown = (event: any) => {
      // 如果按下的键不是英文字符或数字，阻止默认行为
      // 获取按下的键码
      const keyCode = event.keyCode;
      // 检查键码是否是英文字符或数字的范围
      if (
        (keyCode >= 65 && keyCode <= 90) || // 大写英文字母
        (keyCode >= 96 && keyCode <= 122) || // 小写英文字母
        (keyCode >= 48 && keyCode <= 57) ||
        keyCode === 8
      ) {
        // 数字
        // 键码是英文字符或数字，执行你的逻辑
        const keyCode = event.keyCode;
        if (keyCode !== 8 && values.length < 8) {
          // 输入字符
          const char = event.key.toUpperCase();
          const newValues = [...values, char];
          setValues(newValues);
        } else if (keyCode === 8) {
          // 删除字符
          const newValues = values.slice(0, values.length - 1);
          setValues(newValues);
        }
      }
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [values]);

  useEffect(() => {
    if (values.length === CODE_LENGTH) {
      const code = values.join('');
      onActivate(code);
    }
  });

  return (
    <div className={Styles.codeWrapper}>
      <div className={Styles.roomsLogo}>
        <div className={Styles.roomsIcon}></div>
        <div className={Styles.roomsTitle}>网易会议 Rooms</div>
      </div>
      <div className={Styles.roomsRemind}>请输入Rooms激活码或使用扫码激活</div>
      <div className={Styles.code}>
        {Array(CODE_LENGTH)
          .fill(0)
          .map((item, index) => {
            return (
              <div className={Styles.codeInput} key={index}>
                {values[index]}
              </div>
            );
          })}
      </div>
      <div>
        <div className={Styles.qrCodeBox}>
          <QRCode size={200} value={qrcode} />
        </div>
      </div>
    </div>
  );
};

export default BeforeActivatePage;
