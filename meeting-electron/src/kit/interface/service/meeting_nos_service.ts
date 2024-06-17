import { NEResult } from 'neroom-web-sdk'

interface NEMeetingNosService {
  uploadResource: (filePath: string | Blob) => Promise<NEResult<string>>
}

export { NEMeetingNosService }
