import React from 'react';
import './index.less';
declare class Toast extends React.Component {
    static info(msg: string | 'info', timeout?: number): void;
    static success(msg: string | 'success', timeout?: number): void;
    static fail(msg: string | 'fail', timeout?: number): void;
    static warning(msg: string | 'warning', timeout?: number): void;
    static loading(msg: string | 'loading', status: boolean): void;
}
export default Toast;
