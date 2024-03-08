import React from 'react';
import { Modal as AntModal, ModalFuncProps } from 'antd';
import { ModalProps } from 'antd';
import './index.less';
declare type ModalType = React.FC<ModalProps> & {
    confirm: (props: ModalFuncProps) => ReturnType<typeof AntModal.confirm>;
};
declare const Modal: ModalType;
export default Modal;
