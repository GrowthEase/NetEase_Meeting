import { Modal as AntModal, ModalFuncProps, ModalProps } from 'antd'
import classNames from 'classnames'
import React from 'react'
import i18n from '../../../locales/i18n'

import './index.less'
import { IPCEvent } from '../../../../app/src/types'

export type ConfirmModal = ReturnType<typeof AntModal.confirm>
export type WarningModal = ReturnType<typeof AntModal.confirm>

const modalMaps = new Map<string, any>()

type ModalType = React.FC<ModalProps> & {
  confirm: (props: ModalFuncProps & { key?: string }) => ConfirmModal
  warning: (props: ModalFuncProps & { key?: string }) => WarningModal
  destroyAll: () => void
  destroy: (key: string) => void
}

const Modal: ModalType = (props) => {
  return (
    <AntModal
      {...props}
      rootClassName={classNames('nemeeting-custom-modal', props.rootClassName)}
      centered
    />
  )
}

Modal.confirm = (props) => {
  window.ipcRenderer?.send(IPCEvent.sharingScreen, {
    method: 'openModal',
  })
  if (props.key && modalMaps.has(props.key)) {
    return modalMaps.get(props.key)
  }

  const modal = AntModal.confirm({
    wrapClassName: 'nemeeting-custom-confirm-modal',
    icon: null,
    centered: true,
    cancelText: i18n.t('globalCancel'),
    okText: i18n.t('globalSure'),
    ...props,
    onCancel: async (...args: any[]) => {
      await props.onCancel?.(...args)
    },
    afterClose: () => {
      props.key && modalMaps.delete(props.key)
      props.afterClose?.()
      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'closeModal',
      })
    },
    onOk: async (...args: any[]) => {
      await props.onOk?.(...args)
    },
  })

  if (props.key) {
    modalMaps.set(props.key, modal)
  }

  return modal
}

Modal.warning = (props) => {
  if (props.key && modalMaps.has(props.key)) {
    return modalMaps.get(props.key)
  }

  const modal = AntModal.warning({
    wrapClassName: 'nemeeting-custom-confirm-modal',
    icon: null,
    centered: true,
    cancelText: i18n.t('globalCancel'),
    okText: i18n.t('globalSure'),
    ...props,
    afterClose: () => {
      props.key && modalMaps.delete(props.key)
      props.afterClose?.()
      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'closeModal',
      })
    },
  })

  if (props.key) {
    modalMaps.set(props.key, modal)
  }

  return modal
}

Modal.destroyAll = AntModal.destroyAll

Modal.destroy = (key: string) => {
  const modal = modalMaps.get(key)

  modal?.destroy()
  modalMaps.delete(key)
}

export default Modal
