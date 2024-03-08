import EventEmitter from 'eventemitter3';
export declare class EnhancedEventEmitter extends EventEmitter {
    constructor();
    safeEmit(event: string, ...args: any[]): boolean;
    safeEmitAsPromise(event: string, ...args: any[]): Promise<any>;
}
