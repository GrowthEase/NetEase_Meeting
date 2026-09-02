import { request } from '../util/request'

export function requestMeetingInfo(meetingCode: string) {
  return request({
    url: `scene/meeting/v1/invite/info/${meetingCode}`,
    method: 'GET',
  })
}
