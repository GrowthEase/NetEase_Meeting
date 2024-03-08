import { EventPriority, IntervalEvent as IEvent } from '@xkit-yx/utils'
import pkg from '../../package.json'

export class IntervalEvent extends IEvent {
  static appKey = ''
  constructor(options: { eventId: string; priority: EventPriority }) {
    super(options)
    super.setData({
      networkType: 'UNKNOWN',
    })
    super.setAppInfo({
      appKey: IntervalEvent.appKey,
      component: 'MeetingKit',
      version: pkg.version,
      framework: window.ipcRenderer
        ? 'Electron-native'
        : // @ts-ignore
        process.env.PLATFORM === 'h5'
        ? 'H5'
        : '',
    })
  }
}
