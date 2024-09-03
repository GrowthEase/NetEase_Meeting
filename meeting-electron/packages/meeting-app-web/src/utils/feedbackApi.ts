import axios from 'axios';
import pkg from '../../package.json';

const feedbackUrl = 'https://statistic.live.126.net/statics/report/common/form';

export function feedbackApi(data: {
  appKey: string;
  [key: string]: unknown;
}): Promise<null> {
  return axios.post<null, null>(
    feedbackUrl,
    {
      event: {
        feedback: {
          app_key: data.appKey,
          device_id: window.NERoom.getDeviceId?.(),
          ver: pkg.version,
          platform: data.platform || 'Web',
          client: 'Meeting',
          paired_id: '',
          log: '',
          time: new Date().getTime(),
          ...data,
        },
      },
    },
    {
      headers: {
        sdktype: 'meeting',
        ver: pkg.version,
        appkey: data.appKey,
        deviceId: window.NERoom.getDeviceId?.(),
      },
    },
  );
}
