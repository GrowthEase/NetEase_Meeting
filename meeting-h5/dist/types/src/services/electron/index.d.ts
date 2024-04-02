import { EnhancedEventEmitter } from './event';
declare class EleUIUseEvent extends EnhancedEventEmitter {
    constructor();
    init(): void;
    sendMessage(channel: string, args?: any): Promise<any>;
    destroy(): void;
}
declare const _default: {
    getInstance(): EleUIUseEvent | null;
    destroy(): void;
};
export default _default;
