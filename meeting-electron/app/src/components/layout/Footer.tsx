import React from 'react';
import styles from './index.less';
import classnames from 'classnames';

interface FooterProps {
  className?: string;
  logo?: boolean;
}

const Content: React.FC<FooterProps> = ({ className = '', logo = true }) => {
  const nowYear = new Date().getFullYear();

  return (
    <div
      className={classnames(
        styles.baseFooter,
        className ? styles[className] : '',
      )}
    >
      {logo && (
        <div>
          <img
            src={require('../../assets/botLogo.png')}
            alt="logo"
            title="底部logo图片"
          />
        </div>
      )}
      <div className={styles.text}>
        <div className={styles.text}>
          {/* <a
          href="http://note.youdao.com/s/Jlgfge2n"
          target="_blank"
          title="更新日志"
        >
          更新日志
        </a>
        &nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
        <a
          href="http://note.youdao.com/s/6lmuazJd"
          target="_blank"
          title="使用手册"
        >
          使用手册
        </a> */}
          <a
            href="https://netease.im/meeting/clauses?serviceType=0"
            target="_blank"
            title="用户服务协议"
            rel="noreferrer"
          >
            用户服务协议
          </a>
          &nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
          <a
            href="https://meeting.163.com/privacy/agreement_mobile_ysbh_wap.shtml"
            target="_blank"
            title="隐私政策"
            rel="noreferrer"
          >
            隐私政策
          </a>
        </div>
      </div>
      <p className={styles.desc}>
        &copy;&nbsp;1997-{nowYear}
        &nbsp;网易公司&nbsp;&nbsp;&nbsp;&nbsp;增值电信业务许可证B1-20180288&nbsp;&nbsp;&nbsp;&nbsp;浙B1.B2-20090185&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;网易公司&nbsp;&nbsp;版权所有
      </p>
    </div>
  );
};

export default Content;
