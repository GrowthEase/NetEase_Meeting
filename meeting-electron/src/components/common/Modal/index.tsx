import React from 'react'
import { Modal as AntModal, ModalFuncProps } from 'antd'
import { ModalProps } from 'antd'
import i18n from '../../../locales/i18n'
import classNames from 'classnames'

import './index.less'

type ModalType = React.FC<ModalProps> & {
  confirm: (props: ModalFuncProps) => ReturnType<typeof AntModal.confirm>
  warning: (props: ModalFuncProps) => ReturnType<typeof AntModal.warning>
  destroyAll: () => void
}

const Modal: ModalType = (props) => {
  // if (props.open) {
  //   window.ipcRenderer?.send('nemeeting-sharing-screen', {
  //     method: 'openModal',
  //   })
  // } else if (props.open === false) {
  //   setTimeout(() => {
  //     window.ipcRenderer?.send('nemeeting-sharing-screen', {
  //       method: 'closeModal',
  //     })
  //   }, 150)
  // }
  return <AntModal rootClassName="nemeeting-custom-modal" centered {...props} />
}

Modal.confirm = (props) => {
  window.ipcRenderer?.send('nemeeting-sharing-screen', {
    method: 'openModal',
  })
  return AntModal.confirm({
    wrapClassName: 'nemeeting-custom-confirm-modal',
    icon: null,
    centered: true,
    cancelText: i18n.t('cancel'),
    okText: i18n.t('ok'),
    ...props,
    onCancel: async (...args: any[]) => {
      await props.onCancel?.(...args)
    },
    afterClose: () => {
      props.afterClose?.()
      // 有个动画需要延迟
      window.ipcRenderer?.send('nemeeting-sharing-screen', {
        method: 'closeModal',
      })
      // setTimeout(() => {

      // }, 150)
    },
    onOk: async (...args: any[]) => {
      await props.onOk?.(...args)
      // 有个动画需要延迟
      // setTimeout(() => {
      //   window.ipcRenderer?.send('nemeeting-sharing-screen', {
      //     method: 'closeModal',
      //   })
      // }, 150)
    },
  })
}

Modal.warning = (props) => {
  return AntModal.warning({
    wrapClassName: 'nemeeting-custom-confirm-modal',
    icon: null,
    centered: true,
    cancelText: i18n.t('cancel'),
    okText: i18n.t('ok'),
    ...props,
  })
}

Modal.destroyAll = AntModal.destroyAll

export default Modal
