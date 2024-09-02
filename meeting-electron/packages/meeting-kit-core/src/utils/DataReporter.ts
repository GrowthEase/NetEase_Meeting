import axios from 'axios'
// import { version } from '../../package.json'
// import { Logger } from '@/lib/3rd/Logger';

// const log = new Logger('Meeting-DataReporter', true);
export let reporter: DataReporter | null = null
const version = '1.0.0'

class DataReporter {
  private _appkey = ''
  private _nickname = ''
  private _uid = ''
  private _meetingId = ''
  private readonly _url =
    'https://statistic.live.126.net/statics/report/common/form'
  private _os = this.getOperatingSystemInfo()

  constructor(options) {
    console.log('constructor(), options: %o', options)
    /*this._appkey = ''
    this._nickname = ''
    this._uid = ''
    this._meetingId = ''*/
  }

  init(options: {
    appKey: string
    nickName: string
    uid: string
    meetingId: string
  }) {
    console.log('init(), options: %o', options)
    if (options.appKey) {
      this._appkey = options.appKey
    }

    if (options.nickName) {
      this._nickname = options.nickName
    }

    if (options.uid) {
      this._uid = options.uid
    }

    if (options.meetingId) {
      this._meetingId = options.meetingId
    }
  }
  send(options) {
    console.log('send(), options: %o', options)
    axios
      .post(
        this._url,
        {
          event: {
            action: Object.assign({
              module: 'meeting',
              platform: 'Web',
              app_key: this._appkey,
              device_id: 'web',
              version_name: version,
              os_ver: this._os,
              manufacturer: '',
              model: '',
              network_type: '10',
              sdk_version: version,
              nickname: this._nickname,
              uid: this._uid,
              meeting_id: this._meetingId,
              occur_time: Date.now(),
            }),
          },
        },
        {
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
            ver: version,
            sdktype: 'meeting',
            appkey: this._appkey,
          },
        }
      )
      .then(() => {
        //console.log('send(), response: %o', res)
      })
      .catch((e) => {
        console.error('send() failed: %o', e)
      })
  }
  sendLog(options) {
    console.log('sendLog(), options: %o', options)
    axios
      .post(
        this._url,
        {
          event: {
            feedback: Object.assign({
              module: 'meeting',
              platform: 'Web',
              app_key: this._appkey,
              device_id: 'web',
              version_name: '1.0.0',
              os_ver: this._os,
              manufacturer: '',
              model: '',
              network_type: '10',
              sdk_version: '4.2.1',
              nickname: this._nickname,
              uid: this._uid,
              meeting_id: this._meetingId,
              occur_time: Date.now(),
            }),
          },
        },
        {
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
            ver: '1.0',
            sdktype: 'meeting',
            appkey: this._appkey,
          },
        }
      )
      .then(() => {
        //console.log('sendLog(), response: %o', res)
      })
      .catch((e) => {
        console.error('sendLog() failed: %o', e)
      })
  }
  getOperatingSystemInfo() {
    const operatingInfo = navigator.userAgent
    const isWin =
      navigator.platform == 'Win32' || navigator.platform == 'Windows'
    const isMac =
      navigator.platform == 'Mac68K' ||
      navigator.platform == 'MacPPC' ||
      navigator.platform == 'Macintosh' ||
      navigator.platform == 'MacIntel'

    if (isMac) return 'Mac'
    const isUnix = navigator.platform == 'X11' && !isWin && !isMac

    if (isUnix) return 'Unix'
    const isLinux = String(navigator.platform).indexOf('Linux') > -1

    if (isLinux) return 'Linux'
    if (isWin) {
      const isWin2K =
        operatingInfo.indexOf('Windows NT 5.0') > -1 ||
        operatingInfo.indexOf('Windows 2000') > -1

      if (isWin2K) return 'Win2000'
      const isWinXP =
        operatingInfo.indexOf('Windows NT 5.1') > -1 ||
        operatingInfo.indexOf('Windows XP') > -1

      if (isWinXP) return 'WinXP'
      const isWin2003 =
        operatingInfo.indexOf('Windows NT 5.2') > -1 ||
        operatingInfo.indexOf('Windows 2003') > -1

      if (isWin2003) return 'Win2003'
      const isWinVista =
        operatingInfo.indexOf('Windows NT 6.0') > -1 ||
        operatingInfo.indexOf('Windows Vista') > -1

      if (isWinVista) return 'WinVista'
      const isWin7 =
        operatingInfo.indexOf('Windows NT 6.1') > -1 ||
        operatingInfo.indexOf('Windows 7') > -1

      if (isWin7) return 'Win7'
      const isWin10 = operatingInfo.indexOf('Windows NT 10') != -1

      if (isWin10) return 'Win10'
    }

    return 'other'
  }
}

export default {
  getInstance(options?): DataReporter {
    if (!reporter) {
      reporter = new DataReporter(options)
    }

    return reporter
  },
  destroy(): void {
    reporter = null
  },
}
