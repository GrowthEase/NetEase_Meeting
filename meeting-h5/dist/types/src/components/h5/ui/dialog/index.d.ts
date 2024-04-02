import React, { ReactNode } from 'react';
import './index.less';
interface DialogProps {
    visible: boolean;
    ifShowCancel?: boolean;
    onCancel?: () => void;
    onConfirm: () => void;
    title?: string;
    popupClassName?: string;
    cancelText?: string;
    confirmText?: string;
    width?: number;
    children: ReactNode;
}
declare const Dialog: React.FC<DialogProps>;
export default Dialog;
