import debug from 'debug'
import { formatDate } from '../../utils'

debug.formatters.t = () => {
  return `[${formatDate(new Date(), 'yyyy-MM-dd hh:mm:ss')}]`
}

const APP_NAME = 'NeMeeting'

export class Logger {
  private readonly _debug: debug.Debugger
  private readonly _warn: debug.Debugger
  private readonly _error: debug.Debugger

  constructor(prefix?: string, enable?: boolean) {
    if (prefix) {
      this._debug = debug(prefix)
      this._warn = debug(`${prefix}:WARN`)
      this._error = debug(`${prefix}:ERROR:`)
    } else {
      this._debug = debug(APP_NAME)
      this._warn = debug(`${APP_NAME}:WARN`)
      this._error = debug(`${APP_NAME}:ERROR`)
    }

    /* eslint-disable no-console */
    // this._debug.log = console.info.bind(console);
    // this._warn.log = console.warn.bind(console);
    // this._error.log = console.error.bind(console);
    /* eslint-enable no-console */
    if (enable) {
      this._debug.enabled = true
      this._warn.enabled = true
      this._error.enabled = true
    }
  }

  get debug(): debug.Debugger {
    return this._debug
  }

  get warn(): debug.Debugger {
    return this._warn
  }

  get error(): debug.Debugger {
    return this._error
  }
}
