import NEMeetingKit from './impl/meeting_kit'

import i18n from '../locales/i18n'
import Modal from '../components/common/Modal'
import Toast from '../components/common/toast'
import UserAvatar from '../components/common/Avatar'
import usePostMessageHandle from '../hooks/usePostMessagehandle'
import UpdateUserNicknameModal from '../components/web/UpdateUserNicknameModal'
import Setting from '../components/web/Setting'
import MeetingNotification from '../components/common/Notification'
import CommonModal from '../components/common/CommonModal'

export {
  i18n,
  Modal,
  Toast,
  UserAvatar,
  usePostMessageHandle,
  UpdateUserNicknameModal,
  Setting,
  MeetingNotification,
  CommonModal,
}
import NEMeetingService from './interface/service/meeting_service'
import NEContactsService from './interface/service/meeting_contacts_service'
import NEMeetingInviteService from './interface/service/meeting_invite_service'
import NEMeetingMessageChannelService from './interface/service/meeting_message_channel_service'
import NESettingsService from './interface/service/settings_service'
import NEPreMeetingService, {
  NEMeetingItem,
} from './interface/service/pre_meeting_service'
import NEMeetingAccountService from './interface/service/meeting_account_service'

export {
  NEMeetingService,
  NEPreMeetingService,
  NEMeetingAccountService,
  NEContactsService,
  NEMeetingInviteService,
  NEMeetingMessageChannelService,
  NESettingsService,
  NEMeetingItem,
}

export * from '../utils'
export * from '../types'
export * from '../types/type'
export * from '../types/innerType'
export * from '../utils/windowsProxy'

export default NEMeetingKit
