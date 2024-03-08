import LogStorage from '@netease-yunxin/log-storage';
export declare type LogName = 'meetingLog' | 'rtcLog' | 'imLog';
export declare type LogType = 'error' | 'warn' | 'info' | 'log' | 'debug';
declare class LoggerWithStorage {
    meetingLog: LogStorage;
    rtcLog: LogStorage;
    imLog: LogStorage;
    constructor();
    log(logName: LogName, logContent: string): void;
    warn(logName: LogName, logContent: string): void;
    error(logName: LogName, logContent: string): void;
    getLog(logName: LogName, start?: number, end?: number, logType?: LogType): Promise<any>;
    deleteLog(logName: LogName, start?: number, end?: number, logType?: LogType): Promise<any>;
    private logAction;
    private baseLog;
}
declare const _default: {
    getInstance(): LoggerWithStorage;
    destroy(): void;
};
export default _default;
