import { EventPriority, IntervalEvent as IEvent } from '@xkit-yx/utils';
export declare class IntervalEvent extends IEvent {
    static appKey: string;
    constructor(options: {
        eventId: string;
        priority: EventPriority;
    });
}
