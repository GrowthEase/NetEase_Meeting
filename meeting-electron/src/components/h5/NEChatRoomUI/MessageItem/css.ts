import { css } from '@emotion/css'

function getCls(isMe: boolean): Record<string, string> {
  const messageItemWrapperCls = css`
    width: 100%;
    display: flex;
    flex-direction: ${isMe ? 'row-reverse' : 'row'};
  `
  const messageItemCls = css`
    display: flex;
    flex-direction: column;
    align-items: ${isMe ? 'flex-end' : 'flex-start'};
    ${isMe ? 'margin-right: 6px;' : 'margin-left: 6px;'}
  `

  const nickLabelCls = css`
    display: flex;
    font-size: 12px;
    flex-direction: ${isMe ? 'row-reverse' : 'row'};
    margin-bottom: 8px;
    max-width: 300px;
  `

  const nickTextCls = css`
    color: #333333;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  `

  const nickPrivateCls = css`
    color: rgba(51, 126, 255, 1);
  `

  const messageItemContentCls = css`
    display: flex;
    flex-direction: ${isMe ? 'row-reverse' : 'row'};
    margin-bottom: 15px;
  `

  const textCls = css`
    padding: 12px;
    font-size: 14px;
    background: ${isMe ? '#CCE1FF' : '#F2F3F5'};
    text-align: left;
    border-radius: 8px;
    word-break: break-all;
  `

  const imageWrapperCls = css`
    display: flex;
    align-items: center;
    .error-icon {
      color: #ff4d4f;
      margin-right: 4px;
      font-size: 24px;
    }
    .adm-image {
      position: relative;
      display: inline-block;
      overflow: hidden;
      border-radius: 8px;
      img {
        height: 120px;
        width: auto;
      }
    }
  `

  const fileWrapperCls = css`
    display: flex;
    align-items: center;
    .error-icon {
      color: #ff4d4f;
      margin-right: 4px;
    }
    .file-box {
      border-radius: 8px;
      border: 1px solid #dee0e2;
      height: 60px;
      width: 200px;
      display: flex;
      align-items: center;
      padding: 0 12px;
      .file-icon {
        font-size: 38px;
        width: 38px;
        height: 38px;
      }
      .file-content {
        display: flex;
        align-items: start;
        flex-direction: column;
        margin-left: 12px;
        .file-name-label {
          font-size: 14px;
          color: #333;
          max-width: 150px;
          display: flex;
          align-items: center;
          .file-name-text {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
          .file-name-ext {
            flex-shrink: 0;
          }
        }
        .file-size {
          font-size: 12px;
          color: #999;
        }
      }
    }
  `

  const notificationCls = css`
    text-align: center;
    margin: 10px 0;
    font-size: 12px;
    color: #999999;
  `

  return {
    messageItemWrapperCls,
    messageItemCls,
    nickLabelCls,
    nickTextCls,
    nickPrivateCls,
    messageItemContentCls,
    textCls,
    imageWrapperCls,
    notificationCls,
    fileWrapperCls,
  }
}

export default getCls
