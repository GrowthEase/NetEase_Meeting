import NEMeetingKit from 'nemeeting-core-sdk'

import NERoom from 'neroom-web-sdk'

if (!window.NERoom) {
  window.NERoom = NERoom
}

export * from 'nemeeting-core-sdk'

export default NEMeetingKit
