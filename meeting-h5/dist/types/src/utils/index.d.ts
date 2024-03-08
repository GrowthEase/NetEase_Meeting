import { LogName } from './logStorage';
import { BrowserType } from '../types';
export declare type LogType = 'error' | 'warn' | 'info' | 'log' | 'debug';
/**
 * @description: 获取日志
 * @param {LogName} logName
 * @param {*} start
 * @param {*} end
 * @return {*}
 */
export declare function getLog(logName: LogName, start?: number, end?: number): Promise<string>;
export declare function throttle(fn: (...args: any) => void, delay?: number): (...args: any) => void;
/**
 * @description: 防抖
 * @param {*} fn
 * @param {*} wait
 * @return {*}
 */
export declare function debounce<T>(fn: T, wait?: any): T;
/**
 * @description: 时间格式化
 * @param {*} time
 * @param {*} fmt
 * @return {*}
 */
export declare function formatDate(time: Date | number, fmt?: any): any;
export declare function copyElementValue(value: any, callback: () => void): void;
/**
 * @description: 上传日志
 * @param {*} start
 * @param {*} end
 * @param {Array} logNames
 * @return {*}
 */
export declare function uploadLog(logNames?: Array<LogName>, start?: number, end?: number): Promise<any[]>;
/**
 * @description: 下载日志
 * @param {*} start
 * @param {*} end
 * @param {Array} logName
 * @return {*}
 */
export declare function downloadLog(logNames?: Array<LogName>, start?: number, end?: number): Promise<void>;
export declare function getClientType(): 'Android' | 'IOS' | 'PC';
export declare function getBrowserType(): BrowserType;
export declare function getIosVersion(): string;
export declare function getDefaultLanguage(): string;
export declare function getMeetingDisplayId(meetingNum: string | undefined): string;
