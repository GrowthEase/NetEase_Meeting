import { EventPriority, IntervalEvent as IEvent } from '@xkit-yx/utils'
import pkg from '../../package.json'

export class IntervalEvent extends IEvent {
  static appKey = ''
  constructor(options: { eventId: string; priority: EventPriority }) {
    super(options)
    // let networkType = ''
    // try {
    //   // @ts-ignore
    //   networkType = navigator.connection.effectiveType
    //   networkType = networkType.toUpperCase()
    // }catch (e) {}
    // super.setData({
    //   networkType: networkType
    // })
    super.setData({
      networkType: 'UNKNOWN',
    })
    super.setAppInfo({
      appKey: IntervalEvent.appKey,
      component: 'MeetingKit',
      version: pkg.version,
    })
  }
}
