import React from 'react'
import { Modal as AntModal, ModalFuncProps } from 'antd'
import { ModalProps } from 'antd'
import classNames from 'classnames'

import './index.less'

type ModalType = React.FC<ModalProps> & {
  confirm: (props: ModalFuncProps) => ReturnType<typeof AntModal.confirm>
}

const Modal: ModalType = (props) => {
  return <AntModal rootClassName="nemeeting-custom-modal" centered {...props} />
}

Modal.confirm = (props) => {
  return AntModal.confirm({
    wrapClassName: 'nemeeting-custom-confirm-modal',
    icon: null,
    centered: true,
    ...props,
  })
}

export default Modal
