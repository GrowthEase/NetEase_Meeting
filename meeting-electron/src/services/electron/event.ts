/*
 * @Copyright (c) 2021 NetEase, Inc.  All rights reserved.
 * Use of this source code is governed by a MIT license that can be found in the LICENSE file
 */
// import { EventEmitter } from 'events';
import EventEmitter from 'eventemitter3'

export class EnhancedEventEmitter extends EventEmitter {
  constructor() {
    super()
    // this.setMaxListeners(Infinity);
  }

  safeEmit(event: string, ...args: any[]): boolean {
    const numListeners = this.listenerCount(event)

    try {
      return this.emit(event, ...args)
    } catch (error) {
      console.log(
        'safeEmit() | event listener threw an error [event:%s]:',
        event,
        error
      )
      return Boolean(numListeners)
    }
  }

  async safeEmitAsPromise(event: string, ...args: any[]): Promise<any> {
    return new Promise((resolve, reject) =>
      this.safeEmit(event, ...args, resolve, reject)
    )
  }
}
