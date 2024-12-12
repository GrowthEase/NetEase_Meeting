import { Modal as AntModal, ModalFuncProps, ModalProps } from 'antd'
import classNames from 'classnames'
import React from 'react'
import i18n from '../../../locales/i18n'

import './index.less'
import { IPCEvent } from '../../../app/src/types'

export type ConfirmModal = ReturnType<typeof AntModal.confirm>
export type WarningModal = ReturnType<typeof AntModal.confirm>

const modalMaps = new Map<string, ConfirmModal | WarningModal>()

type ModalType = React.FC<ModalProps> & {
  confirm: (props: ModalFuncProps & { key?: string }) => ConfirmModal
  warning: (props: ModalFuncProps & { key?: string }) => WarningModal
  destroyAll: () => void
  destroy: (key: string) => void
}

const CommonModal: ModalType = (props: ModalProps) => {
  return (
    <AntModal
      {...props}
      rootClassName={classNames('nemeeting-custom-modal', props.rootClassName)}
      centered
    />
  )
}

CommonModal.confirm = (props) => {
  if (props.key && modalMaps.has(props.key)) {
    return modalMaps.get(props.key) as ConfirmModal
  }

  window.ipcRenderer?.send(IPCEvent.sharingScreen, {
    method: 'openModal',
  })

  const modal = AntModal.confirm({
    icon: null,
    centered: true,
    cancelText: i18n.t('globalCancel'),
    okText: i18n.t('globalSure'),
    wrapClassName: `nemeeting-common-confirm-modal ${props.wrapClassName}`,
    ...props,
    onCancel: async (...args) => {
      await props.onCancel?.(...args)
    },
    afterClose: () => {
      props.key && modalMaps.delete(props.key)
      props.afterClose?.()
      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'closeModal',
      })
    },
    onOk: async (...args) => {
      await props.onOk?.(...args)
    },
  })

  if (props.key) {
    modalMaps.set(props.key, modal)
  }

  return modal
}

CommonModal.warning = (props) => {
  if (props.key && modalMaps.has(props.key)) {
    return modalMaps.get(props.key) as WarningModal
  }

  window.ipcRenderer?.send(IPCEvent.sharingScreen, {
    method: 'openModal',
  })

  const modal = AntModal.warning({
    icon: null,
    centered: true,
    cancelText: i18n.t('globalCancel'),
    okText: i18n.t('globalSure'),
    wrapClassName: `nemeeting-common-warning-modal ${props.wrapClassName}`,
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

CommonModal.destroyAll = AntModal.destroyAll

CommonModal.destroy = (key: string) => {
  const modal = modalMaps.get(key)

  modal?.destroy()
  modalMaps.delete(key)
}

export default CommonModal
