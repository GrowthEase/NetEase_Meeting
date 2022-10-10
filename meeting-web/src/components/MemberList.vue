<template>
  <div class="member-list" :style="showStyle">
    <div class="title">{{ $t('memberListTitle') }}({{ memberCount }})</div>
    <div class="search">
      <input
        tabindex="-1"
        class="search-input"
        type="text"
        placeholder="输入姓名进行搜索"
        @focus="onSearchFocused"
        @blur="onSearchBlur"
        @keyup="changeSearchNickName"
      />
    </div>
    <ul :class="`list ${isHost ? 'isPresenter' : ''}`">
      <li class="member" v-for="uid in memberIdList" :key="uid">
        <div class="nick">
          <p :title="localeExtraMsg(memberMap[uid])">
            {{ memberMap[uid].nickName || uid
            }}{{ localeExtraMsg(memberMap[uid]) }}
          </p>
          <svg
            v-if="
              meetingInfo.shareMode === 2 &&
              meetingInfo.whiteboardAvRoomUid.includes(uid.toString())
            "
            class="icon whiteboard-icon open"
            aria-hidden="true"
          >
            <use xlink:href="#iconyx-baiban"></use>
          </svg>
          <!-- <svg v-else-if="memberMap[uid].whiteBoardInteract === 1" class="icon whiteboard-icon" aria-hidden="true">
            <use xlink:href="#iconyx-baiban"></use>
          </svg> -->
        </div>
        <div class="hands">
          <span
            class="up"
            v-if="isHost && handsUpStatus(memberMap[uid].handsUps) == '1'"
          >
            <svg class="icon hands-icon" aria-hidden="true">
              <use xlink:href="#iconraisehands1x"></use>
            </svg>
          </span>
          <span
            v-if="isHost && handsUpStatus(memberMap[uid].handsUps) == '1'"
            class="down"
            @click="handleHandsDown(memberMap[uid].accountId)"
            >手放下</span
          >
        </div>
        <div class="state" :name="`state-${memberMap[uid].nickName}`">
          <svg
            class="icon"
            aria-hidden="true"
            style="color: #337eff; margin: 0 3px 0 0"
            v-if="memberMap[uid].screen === 1"
          >
            <use xlink:href="#iconyx-tv-sharescreen1x"></use>
          </svg>
          <svg
            class="icon"
            aria-hidden="true"
            style="color: #337eff; margin: 0 3px 0 0"
            v-if="memberMap[uid].clientType === 'SIP'"
          >
            <use xlink:href="#iconSIP-copy"></use>
          </svg>
          <svg
            v-if="memberMap[uid].video !== 1"
            class="icon icon-close"
            aria-hidden="true"
          >
            <use xlink:href="#iconyx-tv-video-offx"></use>
          </svg>
          <svg v-else class="icon" aria-hidden="true">
            <use xlink:href="#iconyx-tv-video-onx"></use>
          </svg>
          <svg
            v-if="memberMap[uid].audio === 1"
            class="icon"
            aria-hidden="true"
          >
            <use xlink:href="#iconyx-tv-voice-onx"></use>
          </svg>
          <svg v-else class="icon icon-close" aria-hidden="true">
            <use xlink:href="#iconyx-tv-voice-offx"></use>
          </svg>
        </div>
        <v-popover class="member-more-popover" placement="bottom-start">
          <template slot="popover">
            <div class="more-popover">
              <ul>
                <li
                  v-for="item in memberMoreBtns"
                  :key="item.id"
                  v-show="
                    item.isShow(memberMap[uid], localInfo, isWhiteSharer, uid)
                  "
                  :name="
                    item.testName(memberMap[uid], localInfo, isWhiteSharer, uid)
                  "
                  @click="handleMemberMore(memberMap[uid], uid, item.id)"
                >
                  {{ item.name }}
                </li>
              </ul>
              <ul v-if="isHost">
                <li
                  v-for="item in moreBtns"
                  :key="item.id"
                  v-show="item.isShow(memberMap[uid], meetingInfo)"
                  :name="item.testName(memberMap[uid], meetingInfo)"
                  @click="handleMore(memberMap[uid], uid, item.id)"
                >
                  {{ item.name }}
                </li>
              </ul>
            </div>
          </template>
          <div
            v-if="
              showMore ||
              (uid !== $neMeeting.avRoomUid && isWhiteSharer) ||
              (!localInfo.noRename && uid === $neMeeting.avRoomUid)
            "
            :name="memberMap[uid].nickName"
            class="more"
          >
            {{ $t('more') }}
          </div>
        </v-popover>
      </li>
    </ul>
    <div v-if="isHost" class="member-list-lock">
      <span>{{ $t('lockMeeting') }}</span>
      <!-- <div :class="`switch ${meetingLock ? 'on' : 'off'}`">
        {{meetingLock ? '开' : '关'}}
      </div> -->
      <VSwitch :value="meetingLock" @toggleChange="toggleMeetingLock" />
    </div>
    <footer class="member-list-footer" v-if="showFooter">
      <button
        v-if="muteBtnConfig.showMuteAllVideo"
        tabindex="-1"
        @click="visibleMuteAllVideo = true"
      >
        {{ $t('muteVideoAll') }}
      </button>
      <button
        v-if="muteBtnConfig.showUnMuteAllVideo"
        tabindex="-1"
        @click="toggleMuteVideoType(19)"
      >
        {{ $t('unMuteVideoAll') }}
      </button>
      <button
        v-if="muteBtnConfig.showMuteAllAudio"
        tabindex="-1"
        @click="visibleMuteAllAudio = true"
      >
        {{ $t('muteAudioAll') }}
      </button>
      <button
        v-if="muteBtnConfig.showUnMuteAllAudio"
        tabindex="-1"
        @click="toggleMuteAudioType(17)"
      >
        {{ $t('unMuteAudioAll') }}
      </button>
    </footer>
    <VDialog
      :width="320"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="visibleRemoveHost"
    >
      <div slot="dialogContent" class="memberList-dialog-content">
        <h3>{{ $t('handOverHost') }}</h3>
        <p class="memberList-dialog-info">
          {{ $t('handOverHostTips') }}
          {{ (memberInfo && memberInfo.nickName) || '' }} ？
        </p>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleOK">{{ $t('sure') }}</button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="320"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="visibleRemoveMember"
    >
      <div slot="dialogContent" class="memberList-dialog-content">
        <h3>{{ $t('removeMember') }}</h3>
        <p class="memberList-dialog-info">
          {{ $t('removeMemberTips') }}
          {{ (memberInfo && memberInfo.nickName) || '' }}？
        </p>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleOK">{{ $t('sure') }}</button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="360"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="visibleMuteAllAudio"
    >
      <div slot="dialogContent" class="memberList-dialog-content">
        <h3 class="memberList-dialog-info">
          {{ $t('muteAudioAllDialogTips') }}
        </h3>
        <VCheckBox :value.sync="allowUnMuteAudioBySelf">{{
          $t('muteAllAudioTip')
        }}</VCheckBox>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleMuteAudioOk">
          {{ $t('sure') }}
        </button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="360"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="visibleMuteAllVideo"
    >
      <div slot="dialogContent" class="memberList-dialog-content">
        <h3 class="memberList-dialog-info">
          {{ $t('muteVideoAllDialogTips') }}
        </h3>
        <VCheckBox :value.sync="allowUnMuteVideoBySelf">{{
          $t('muteAllVideoTip')
        }}</VCheckBox>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleMuteVideoOk">
          {{ $t('sure') }}
        </button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="360"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="visibleCloseWhiteboard"
    >
      <div slot="dialogContent" class="memberList-dialog-content">
        <h3 class="memberList-dialog-info">{{ $t('closeWhiteBoard') }}</h3>
        <p class="memberList-dialog-info">
          {{ $t('closeCommomTips') }} {{ memberInfo && memberInfo.nickName }}
          {{ $t('closeWhiteShareTips') }}
        </p>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleOK">{{ $t('sure') }}</button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="360"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="visibleCloseScreenShare"
    >
      <div slot="dialogContent" class="memberList-dialog-content">
        <h3 class="memberList-dialog-info">{{ $t('unScreenShare') }}</h3>
        <p class="memberList-dialog-info">
          {{ $t('closeCommomTips') }} {{ memberInfo && memberInfo.nickName }}
          {{ $t('closeScreenShareTips') }}
        </p>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleOK">{{ $t('sure') }}</button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="360"
      :top="35"
      :title="$t('noRename')"
      :needHeader="true"
      :needBtns="true"
      :visible.sync="visibleModifyNickName"
    >
      <div class="memberList-dialog-content" slot="dialogContent">
        <div class="input-content">
          <input
            :class="`${nickNameErrorMsg ? 'error' : ''}`"
            type="text"
            v-model="modifyNickName"
            :placeholder="$t('pleaseInputRename')"
            maxlength="20"
          />
          <span
            v-show="modifyNickName"
            class="close-btn"
            @click="
              () => {
                modifyNickName = ''
                nickNameErrorMsg = ''
              }
            "
          >
            <svg class="icon" aria-hidden="true">
              <use xlink:href="#iconcross"></use>
            </svg>
          </span>
        </div>
        <p class="error-msg">{{ nickNameErrorMsg }}</p>
      </div>
      <div class="memberList-dialog-btns" slot="dialogFooter">
        <button class="confirm" @click="handleOK">{{ $t('sure') }}</button>
        <button class="cacel" @click="hideAll">{{ $t('cancel') }}</button>
      </div>
    </VDialog>
  </div>
</template>
<script lang="ts">
import Vue from 'vue'
import VDialog from './ui/Dialog.vue'
import VSwitch from './ui/Switch.vue'
import VCheckBox from './ui/CheckBox.vue'
import { getErrCode, handsUpStatus, isJsonString } from '../utils'
import {
  clientType,
  errorCodes,
  hostAction,
  memberAction,
  NEMeetingClientType,
  Role,
} from '../libs/enum'
import { Logger } from '@/libs/3rd/Logger'
import { MuteBtnConfig } from '@/types'

const logger = new Logger('Meeting-List', true)

export default Vue.extend({
  props: {
    isPresenter: {
      type: Boolean,
      default: false,
    },
    isScreen: {
      type: Boolean,
      default: false,
    },
    showMaxCount: {
      type: Boolean,
      default: false,
    },
    showMemberTag: {
      type: Boolean,
      default: false,
    },
  },
  components: {
    VDialog,
    VSwitch,
    VCheckBox,
  },
  watch: {
    '$store.state.status': function (newValue) {
      if (newValue !== 2) {
        this.hideAll()
      }
    },
    '$store.state.allowUnMuteAudioBySelf': function (newValue) {
      this.allowUnMuteAudioBySelf = newValue
    },
    '$store.state.allowUnMuteVideoBySelf': function (newValue) {
      /**
       * TODO leeing
       * 1. [x] 主持人一键开关视频
       * 2. [x] 主持人一键开启音视频
       * 3. [x] 成员收到视频会控时，进行相应的操作
       * 4. [ ] 成员收到开启会控时，无论是否自己举手，都弹窗确认开启
       * 5. [x] 成员被主持人关闭后，需要举手申请权限
       * 6. [x] 新加入的成员，根据会控决定自己音视频开关权限及开关状态
       */
      this.allowUnMuteVideoBySelf = newValue
    },
  },
  data() {
    return {
      handsUpStatus,
      settingInfo: {
        type: 0,
        uid: 0,
      },
      visibleRemoveHost: false,
      visibleRemoveMember: false,
      visibleMuteAllAudio: false,
      visibleMuteAllVideo: false,
      visibleCloseWhiteboard: false,
      visibleCloseScreenShare: false,
      visibleModifyNickName: false,
      modifyNickName: '',
      nickNameErrorMsg: '',
      allowUnMuteAudioBySelf: false,
      allowUnMuteVideoBySelf: false,
      searchNickName: '',
    }
  },
  methods: {
    onSearchFocused(e) {
      if(!this.enableUnmuteBySpace) {
        return
      }
      // 获取焦点后阻止长安空格的监听事件
      document.addEventListener('keydown', this.handleFocused, true)
      document.addEventListener('keyup', this.handleFocused, true)
    },
    onSearchBlur(e) {
      if(!this.enableUnmuteBySpace) {
        return
      }
      // 移除阻止长安空格的监听事件
      document.removeEventListener('keydown', this.handleFocused, true)
      document.removeEventListener('keyup', this.handleFocused, true)
    },
    handleFocused(e) {
      const keyNum = window.event ? e.keyCode :e.which;
      if(keyNum === 32) {
        e.stopPropagation()
      }
    },
    toggleMuteAudioType(type) {
      this.$neMeeting
        .sendHostControl(type)
        .then(() => {
          // switch (type) {
          //   case hostAction.muteAllAudio:
          //     this.$store.commit('setAllAudioMute')
          //     break;
          //   default:
          //     break;
          // }
          this.$toast(
            `${
              type === hostAction.muteAllAudio ||
              type === hostAction.forceMuteAllAudio
                ? this.$t('muteAllAudioSuccess')
                : this.$t('unMuteAllAudioSuccess')
            }`
          )
        })
        .catch((e) => {
          console.log('e', e)
          switch (type) {
            case hostAction.muteAllAudio:
              this.$toast(this.$t('muteAllAudioFail'))
              break
            case hostAction.unmuteAllAudio:
              this.$toast(this.$t('unMuteAllAudioFail'))
              break
            default:
              break
          }
        })
    },
    toggleMuteVideoType(type) {
      this.$neMeeting
        .sendHostControl(type)
        .then(() => {
          // switch (type) {
          //   case hostAction.muteAllVideo:
          //     this.$store.commit('setAllVideoMute')
          //     break;
          //   default:
          //     break;
          // }
          this.$toast(
            `${
              type === hostAction.muteAllVideo ||
              type === hostAction.forceMuteAllVideo
                ? this.$t('muteAllVideoSuccess')
                : this.$t('unMuteAllVideoSuccess')
            }`
          )
        })
        .catch((e) => {
          switch (type) {
            case hostAction.muteAllVideo:
              this.$toast(this.$t('muteAllVideoFail'))
              break
            case hostAction.unmuteAllVideo:
              this.$toast(this.$t('unMuteAllVideoFail'))
              break
            default:
              break
          }
        })
    },
    toggleMeetingLock() {
      const { commit } = this.$store
      if (this.meetingLock) {
        this.$neMeeting
          .sendHostControl(hostAction.unlockMeeting)
          .then(() => {
            commit('setMeetLockStatus', 1)
            this.$toast(`${this.$t('unLockMeetingByHost')}`)
          })
          .catch(() => {
            this.$toast(`${this.$t('lockMeetingByHostFail')}`)
          })
      } else {
        this.$neMeeting
          .sendHostControl(hostAction.lockMeeting)
          .then(() => {
            commit('setMeetLockStatus', 2)
            this.$toast(`${this.$t('lockMeetingByHost')}`)
          })
          .catch(() => {
            this.$toast(`${this.$t('unLockMeetingByHostFail')}`)
          })
      }
    },
    async handleMore(memberInfo, uid, type) {
      const { commit, dispatch } = this.$store
      let callback: () => any = () => {
        return true
      }
      switch (type) {
        case hostAction.remove:
          logger.debug('执行成员移除 %o %t', memberInfo)
          callback = () => {
            this.settingInfo.type = type
            this.settingInfo.uid = uid
            this.hideAll()
            this.visibleRemoveMember = true
          }
          break
        case hostAction.muteMemberVideo:
          logger.debug('执行成员关闭视频 %o %t', memberInfo)
          // this.$toast(`关闭 ${memberInfo.nickName} 视频`);
          callback = () => {
            // memberInfo.video = 2;
          }
          break
        case hostAction.muteMemberAudio:
          logger.debug('执行成员静音 %o %t', memberInfo)
          // this.$toast(`${memberInfo.nickName} 静音`);
          callback = () => {
            // memberInfo.audio = 2;
          }
          break
        case hostAction.unmuteMemberVideo:
          logger.debug('执行成员开启视频 %o %t', memberInfo)
          // this.$toast(`开启 ${memberInfo.nickName} 视频`);
          callback = () => {
            // memberInfo.video = 4;
          }
          break
        case hostAction.unmuteMemberAudio:
          logger.debug('执行成员取消静音 %o %t', memberInfo)
          // this.$toast(`取消 ${memberInfo.nickName} 静音`);
          callback = () => {
            // memberInfo.audio = 4;
          }
          break
        case hostAction.muteVideoAndAudio:
          logger.debug('执行成员关闭音视频 %o %t', memberInfo)
          callback = () => {
            //
          }
          break
        case hostAction.unmuteVideoAndAudio:
          logger.debug('执行成员开启音视频 %o %t', memberInfo)
          callback = () => {
            //
          }
          break
        // case hostAction.agreeHandsUp:
        //   logger.debug('执行成员取消静音', memberInfo);
        //   // this.$toast(`取消 ${memberInfo.nickName} 静音`);
        //   callback = () => {
        //     // memberInfo.audio = 4;
        //   }
        //   break;
        case hostAction.transferHost:
          logger.debug('执行成员主持人移交 %o %t', memberInfo)
          callback = () => {
            // const oldHost = state.memberMap[state.localInfo.avRoomUid]
            // oldHost.isHost = false;
            // commit('updateMember', oldHost);
            // this.$store.commit('setLocalInfo', {
            //   role: 'participant',
            // });
            // memberInfo.isHost = true;
            this.settingInfo.type = type
            this.settingInfo.uid = uid
            this.hideAll()
            if (memberInfo.clientType === clientType.SIP) {
              this.$toast('无法设置SIP设备为主持人')
            } else {
              this.visibleRemoveHost = true
            }
          }
          break
        case hostAction.closeWhiteShare:
          logger.debug('主持人关闭白板 %o %t', memberInfo)
          callback = () => {
            this.settingInfo.type = type
            this.settingInfo.uid = uid
            this.hideAll()
            this.visibleCloseWhiteboard = true
          }
          break
        case hostAction.setFocus:
          logger.debug('执行设置焦点视频 %o %t', memberInfo)
          // this.$toast(`设置 ${memberInfo.nickName} 为焦点`);
          callback = () => {
            // memberInfo.isFocus = true;
            commit('setMeetingInfo', { focusAvRoomUid: memberInfo.avRoomUid })
            // dispatch('sortMemberList');
          }
          break
        case hostAction.unsetFocus:
          logger.debug('执行移除焦点视频 %o %t', memberInfo)
          // this.$toast(`移除 ${memberInfo.nickName} 为焦点`);
          callback = () => {
            // memberInfo.isFocus = false;
            commit('setMeetingInfo', { focusAvRoomUid: 0 })
            // dispatch('sortMemberList');
          }
          break
        case hostAction.closeScreenShare:
          logger.debug('主持人关闭屏幕共享 %o %t', memberInfo)
          callback = () => {
            this.settingInfo.type = type
            this.settingInfo.uid = uid
            this.hideAll()
            this.visibleCloseScreenShare = true
          }
          break
        case hostAction.setCoHost:
          logger.debug('主持人设置联席主持人 %o %t', memberInfo)
          // 添加trycatch 捕获设置联席主持人上限错误提示
          try {
            await this.$neMeeting.sendHostControl(
              hostAction.setCoHost,
              [memberInfo.accountId],
              [memberInfo.avRoomUid],
              {
                businessParam: {
                  role: Role.coHost,
                },
              }
            )
          } catch (e: any) {
            // todo 国际化
            this.$toast(this.errorCodes[e.code] || e.msg || e.message)
          }
          break
        case hostAction.unSetCoHost:
          logger.debug('主持人取消设置联席主持人 %o %t', memberInfo)
          await this.$neMeeting.sendHostControl(
            hostAction.unSetCoHost,
            [memberInfo.accountId],
            [memberInfo.avRoomUid],
            {
              businessParam: {
                role: Role.participant,
              },
            }
          )
          break
        default:
          break
      }
      if (
        type !== hostAction.remove &&
        type !== hostAction.transferHost &&
        type !== hostAction.closeWhiteShare &&
        type !== hostAction.setCoHost &&
        type !== hostAction.unSetCoHost &&
        type !== hostAction.closeScreenShare
      ) {
        console.log('memberInfo', memberInfo)
        await this.$neMeeting.sendHostControl(
          type,
          [memberInfo.accountId],
          [memberInfo.avRoomUid]
        )
        // if( type === hostAction.unmuteMemberAudio|| type === hostAction.unmuteMemberVideo || type === hostAction.unmuteAllVideo || type === hostAction.unmuteVideoAndAudio) {
        //   this.$neMeeting.sendHostControl(hostAction.rejectHandsUp, [memberInfo.accountId]);
        // }
      }
      callback()
      // commit('updateMember', memberInfo);
      dispatch('sortMemberList')
      document.body.click()
    },
    async handleMemberMore(memberInfo, uid, type) {
      const { dispatch } = this.$store
      let callback: () => any = () => {
        return true
      }
      switch (type) {
        case memberAction.shareWhiteShare:
          logger.debug('执行白板分享 %o %t', memberInfo)
          callback = () => {
            this.hideAll()
          }
          break
        case memberAction.cancelShareWhiteShare:
          logger.debug('执行取消白板分享 %o %t', memberInfo)
          callback = () => {
            this.hideAll()
          }
          break
        case memberAction.modifyMeetingNickName:
          logger.debug('执行修改个人昵称 %o %t', memberInfo)
          callback = () => {
            this.settingInfo.type = type
            this.settingInfo.uid = uid
            this.hideAll()
            this.modifyNickName = memberInfo?.nickName
            this.visibleModifyNickName = true
          }
          break
        default:
          break
      }
      if (type !== memberAction.modifyMeetingNickName) {
        await this.$neMeeting.sendMemberControl(type, [memberInfo.avRoomUid])
      }
      callback()
      dispatch('sortMemberList')
      document.body.click()
    },
    handleOK() {
      const { commit, state, dispatch } = this.$store
      const memberInfo = this.memberMap[this.settingInfo.uid]
      try {
        const byteResult = this.modifyNickName.replace(/[\u4e00-\u9fa5]/g, 'aa')
        switch (this.settingInfo.type) {
          case hostAction.remove:
            break
          case memberAction.modifyMeetingNickName:
            if (this.modifyNickName.length <= 0) {
              this.nickNameErrorMsg = '请输入昵称'
              return
            }
            if (byteResult.length > 20) {
              this.nickNameErrorMsg =
                '请输入正确格式昵称（10个中文或20个非中文）'
              return
            }
            break
          default:
            break
        }
        if (this.settingInfo.type === memberAction.modifyMeetingNickName) {
          this.$neMeeting
            .modifyNickName({
              nickName: this.modifyNickName,
            })
            .then(() => {
              this.$toast(this.$t('reNameSuccessToast'))
            })
            .catch((e) => {
              this.$toast(e?.message === 'failure' ? '请求失败' : e?.message)
            })
        } else {
          this.$neMeeting
            .sendHostControl(
              this.settingInfo.type,
              [this.memberMap[this.settingInfo.uid].accountId],
              [this.memberMap[this.settingInfo.uid].avRoomUid]
            )
            .then(() => {
              // commit('updateMember', memberInfo);
              dispatch('sortMemberList')
              switch (this.settingInfo.type) {
                case hostAction.remove:
                  this.$toast(`移除成员 ${memberInfo.nickName}`)
                  commit('removeRealMemberList', memberInfo.avRoomUid)
                  break
                case hostAction.transferHost: {
                  const oldHost = this.memberMap[state.localInfo.avRoomUid]
                  oldHost.isHost = false
                  commit('updateMember', oldHost)
                  this.$store.commit('setLocalInfo', {
                    role: 'participant',
                  })
                  this.memberMap[this.settingInfo.uid].isHost = true
                  break
                }
                case hostAction.closeWhiteShare:
                  this.$toast(`关闭成员：${memberInfo.nickName}的共享白板`)
                  break
                case hostAction.closeScreenShare:
                  this.$toast(`关闭成员：${memberInfo.nickName}的屏幕共享`)
                  break
                default:
                  break
              }
            })
            .catch((e) => {
              console.log('主持人会控失败', e)
              switch (e.code) {
                case 2101:
                  commit('removeMember', memberInfo.avRoomUid)
                  commit('removeRealMemberList', memberInfo.avRoomUid)
                  commit('checkPresenter')
                  break
                default:
                  this.$toast(
                    `移除失败${e.code === -1 ? '' : '：' + e.message}`
                  )
                  break
              }
            })
        }
      } catch (error) {
        if (this.visibleRemoveHost) {
          this.$toast('移交失败')
        } else if (this.visibleRemoveMember) {
          this.$toast('移除失败')
        } else if (this.visibleCloseWhiteboard) {
          this.$toast('关闭白板失败')
        }
      }
      this.hideAll()
    },
    hideAll() {
      // 关闭全部弹窗
      this.visibleRemoveHost = false
      this.visibleRemoveMember = false
      this.visibleMuteAllAudio = false
      this.visibleMuteAllVideo = false
      this.visibleCloseScreenShare = false
      this.visibleCloseWhiteboard = false
      this.visibleModifyNickName = false
      this.modifyNickName = ''
      this.nickNameErrorMsg = ''
    },
    handleMuteAudioOk() {
      // 调整：补充静音可自我开启（12）和静音不可自我开启（40）
      switch (this.allowUnMuteAudioBySelf) {
        case true:
          this.toggleMuteAudioType(hostAction.muteAllAudio)
          break
        case false:
          this.toggleMuteAudioType(hostAction.forceMuteAllAudio)
          break
        default:
          break
      }
      this.hideAll()
    },
    handleMuteVideoOk() {
      switch (this.allowUnMuteVideoBySelf) {
        case true:
          this.toggleMuteVideoType(hostAction.muteAllVideo)
          break
        case false:
          this.toggleMuteVideoType(hostAction.forceMuteAllVideo)
          break
        default:
          break
      }
      this.hideAll()
    },
    handleHandsDown(accountId) {
      // 主持人操作成员手放下
      this.$neMeeting.sendHostControl(hostAction.rejectHandsUp, [accountId])
    },
    localeExtraMsg(member) {
      let extraMsg = member.extraMsg || ''
      const memberTag = member.memberTag || ''
      if (this.showMemberTag && memberTag) {
        extraMsg = extraMsg
          ? extraMsg.replace(/）$/g, `，${memberTag}）`)
          : `（${memberTag}）`
      }
      return extraMsg
        .replace(/主持人/g, this.$t('host') as string)
        .replace(/我/g, this.$t('me') as string)
    },
    changeSearchNickName(e) {
      this.searchNickName = e.target.value.trim()
    },
  },
  // watch: {
  //   '$store.state.memberIdList': function (newValue, oldValue){
  //     if (newValue && newValue.length && newValue !== oldValue) {
  //       this.checkPresenter();
  //     }
  //   }
  // },
  computed: {
    enableUnmuteBySpace(): boolean {
      return this.$store.state.enableUnmuteBySpace
    },
    errorCodes(): any {
      return errorCodes(this.$i18n)
    },
    showStyle() {
      if (this.$store.state.showList) {
        return {
          right: 0,
        }
      } else {
        return {
          right: '-320px',
          visibility: 'hidden',
        }
      }
    },
    // noMuteAllConfig(): NoMuteAllConfig {
    //   return this.$store.state.noMuteAllConfig
    // },
    muteBtnConfig(): MuteBtnConfig {
      return this.$store.state.muteBtnConfig
    },
    showFooter(): boolean {
      return (
        this.isHost &&
        (this.muteBtnConfig.showMuteAllAudio ||
          this.muteBtnConfig.showUnMuteAllAudio ||
          this.muteBtnConfig.showMuteAllVideo ||
          this.muteBtnConfig.showUnMuteAllVideo)
      )
    },
    memberMap(): Array<any> {
      return this.$store.state.memberMap
    },
    memberIdList(): Array<any> {
      //logger.debug('联系人列表 memberIdList: ', this.$store.state.memberIdList)
      return this.$store.state.memberIdList.filter((item) =>
        this.memberMap[item].nickName.includes(this.searchNickName)
      )
    },
    memberInfo(): any {
      return this.$store.state.memberMap[this.settingInfo.uid] || null
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
    meetingLock(): boolean {
      console.log('meetingLock', this.$store.state.meetLockStatus)
      return this.$store.state.meetLockStatus === 2
    },
    meetingInfo(): any {
      return this.$store.state.meetingInfo
    },
    // allowUnMuteAudio(): boolean {
    //   return this.$store.state.allowUnMuteAudioBySelf;
    // },
    isWhiteSharer(): boolean {
      return this.$store.state.meetingInfo.whiteboardAvRoomUid.includes(
        this.$neMeeting.avRoomUid
      )
    },
    isCoHost(): boolean {
      return this.localInfo.role === Role.coHost
    },
    isHost(): boolean {
      // 是否为主持人或者联席主持人
      return this.isCoHost || this.isPresenter
    },
    showMore(): boolean {
      return this.isHost
    },
    moreBtns(): any {
      let arr = [
        // isShow 预留展示逻辑
        {
          id: hostAction.muteMemberAudio,
          name: this.$t('muteAudio'),
          isShow: (item) => item.audio === 1,
          testName: (item) =>
            (item.isHost
              ? 'mute-audio-control-host'
              : 'mute-audio-control-member') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.unmuteMemberAudio,
          name: this.$t('unMuteAudio'),
          isShow: (item) => item.audio !== 1,
          testName: (item) =>
            (item.isHost
              ? 'unmute-audio-control-host'
              : 'unmute-audio-control-member') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        // {
        //   id: hostAction.agreeHandsUp, // 举手逻辑后续执行解除静音
        //   name: '解除静音',
        //   isShow: (item, allowUnMuteAudio) => !allowUnMuteAudio && (item.audio === 3 || item.audio === 2),
        //   needDialog: false,
        // },
        {
          id: hostAction.muteMemberVideo,
          name: this.$t('muteVideo'),
          isShow: (item) => item.video === 1,
          testName: (item) =>
            (item.isHost
              ? 'mute-video-control-host'
              : 'mute-video-control-member') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.unmuteMemberVideo,
          name: this.$t('unMuteVideo'),
          isShow: (item) => item.video !== 1,
          testName: (item) =>
            (item.isHost
              ? 'unmute-video-control-host'
              : 'unmute-video-control-member') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.muteVideoAndAudio,
          name: this.$t('muteVideoAndAudio'),
          isShow: (item) =>
            (item.video === 1 || item.video === 4) &&
            (item.audio === 1 || item.audio === 4),
          testName: (item) =>
            (item.isHost
              ? 'mute-video-and-audio-control-host'
              : 'mute-video-and-audio-control-member') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.unmuteVideoAndAudio,
          name: this.$t('unmuteVideoAndAudio'),
          isShow: (item) => item.video !== 1 || item.audio !== 1,
          testName: (item) =>
            (item.isHost
              ? 'unmute-video-and-audio-control-host'
              : 'unmute-video-and-audio-control-member') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.setFocus,
          name: this.$t('focusVideo'),
          isShow: (item) => !item.isFocus && !this.isScreen,
          testName: (item) =>
            (!item.isHost && 'setfocus-control') + '-' + item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.unsetFocus,
          name: this.$t('unFocusVideo'),
          isShow: (item) => item.isFocus && !this.isScreen,
          testName: (item) =>
            (item.isFocus && 'unsetfocus-control') + '-' + item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: hostAction.closeScreenShare,
          name: this.$t('unScreenShare'),
          isShow: (item) => !item.isHost && item.screenSharing === 1,
          testName: (item) =>
            (!item.isHost &&
              item.screenSharing === 1 &&
              'close-screen-control') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: true,
        },

        {
          id: hostAction.closeWhiteShare,
          name: this.$t('closeWhiteBoard'),
          isShow: (item, meetingInfo) =>
            meetingInfo.whiteboardAvRoomUid.includes(
              item.avRoomUid.toString()
            ) && !item.isHost,
          testName: (item, meetingInfo) =>
            (meetingInfo.whiteboardAvRoomUid.includes(
              item.avRoomUid.toString()
            ) && 'closewhiteboard-control') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: true,
        },
      ]
      if (this.isPresenter) {
        arr = arr.concat([
          {
            id: hostAction.remove,
            name: this.$t('removeMember'),
            isShow: (item) => !item.isHost,
            testName: (item) =>
              (!item.isHost && 'remove-member-control') + '-' + item.nickName, // 测试自动化使用
            needDialog: true,
          },
          {
            id: hostAction.transferHost,
            name: this.$t('handOverHost'),
            isShow: (item) =>
              !item.isHost && item.clientType !== clientType.SIP,
            testName: (item) =>
              (!item.isHost && 'transferhost-control') + '-' + item.nickName, // 测试自动化使用
            needDialog: true,
          },
          {
            id: hostAction.setCoHost, // 联席主持人
            name: this.$t('handSetCoHost'),
            isShow: (item) =>
              item.role !== Role.coHost &&
              !item.isHost &&
              item.clientType !== clientType.SIP,
            testName: (item) =>
              (!item.isHost && 'set-coHost-control') + '-' + item.nickName, // 测试自动化使用
            needDialog: true,
          },
          {
            id: hostAction.unSetCoHost, // 取消联席主持人
            name: this.$t('handUnSetCoHost'),
            isShow: (item) => item.role === Role.coHost && !item.isHost,
            testName: (item) =>
              (!item.isHost && 'unSet-coHost-control') + '-' + item.nickName, // 测试自动化使用
            needDialog: true,
          },
        ])
      } else {
        // 本端是联席主持人则只能移除非主持人和非联席主持人
        arr = arr.concat([
          {
            id: hostAction.remove,
            name: this.$t('removeMember'),
            isShow: (item) =>
              !item.isHost && item.avRoomUid !== this.localInfo.avRoomUid,
            testName: (item) =>
              (!item.isHost && 'remove-member-control') + '-' + item.nickName, // 测试自动化使用
            needDialog: true,
          },
        ])
      }
      return arr
    },
    memberMoreBtns(): any {
      return [
        {
          id: memberAction.modifyMeetingNickName,
          name: this.$t('noRename'),
          isShow: (item, localInfo, isWhiteSharer, uid) =>
            item.avRoomUid === localInfo.avRoomUid && !localInfo?.noRename,
          testName: (item, localInfo, isWhiteSharer, uid) =>
            (item.avRoomUid === localInfo.avRoomUid &&
              !localInfo?.noRename &&
              'member-update-meeting-nickname') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: memberAction.shareWhiteShare,
          name: this.$t('whiteBoardInteract'),
          isShow: (item, localInfo, isWhiteSharer, uid) =>
            item.whiteBoardInteract != '1' &&
            isWhiteSharer &&
            uid !== this.$neMeeting.avRoomUid,
          testName: (item, localInfo, isWhiteSharer, uid) =>
            (item.whiteBoardInteract != '1' &&
              isWhiteSharer &&
              uid !== this.$neMeeting.avRoomUid &&
              'member-share-whiteboard') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
        {
          id: memberAction.cancelShareWhiteShare,
          name: this.$t('undoWhiteBoardInteract'),
          isShow: (item, localInfo, isWhiteSharer, uid) =>
            item.whiteBoardInteract == '1' &&
            isWhiteSharer &&
            uid !== this.$neMeeting.avRoomUid,
          testName: (item, localInfo, isWhiteSharer, uid) =>
            (item.whiteBoardInteract == '1' &&
              isWhiteSharer &&
              uid !== this.$neMeeting.avRoomUid &&
              'member-cancel-share-whiteboard') +
            '-' +
            item.nickName, // 测试自动化使用
          needDialog: false,
        },
      ]
    },
    maxCountMembers(): number {
      const meetingInfo = this.$store.state.meetingInfo
      const extraData = meetingInfo.properties?.extraData?.value
      if (extraData && isJsonString(extraData)) {
        const _extraData = JSON.parse(extraData)
        return _extraData.maxCount || 0
      } else {
        return 0
      }
    },
    memberCount(): string {
      const memberLength = this.$store.state.memberIdList.length
      return this.showMaxCount && this.maxCountMembers
        ? `${memberLength}/${this.maxCountMembers}`
        : memberLength.toString()
    },
  },
})
</script>
<style lang="stylus">
bColor = #387AFF
.member-list
  position absolute
  width 320px
  top 50px
  height calc(100% - 50px)
  background #fff
  display flex
  flex-direction column
  color #333333
  transition all 0.2s ease-out
  z-index 13001
  .title
    text-align center
    font-size 28px
    height h=52px
    line-height 52px
    font-size: 16px;
    color: #333333;
    border-bottom 1px solid #EBEDF0
  .search
    padding: 0 20px
  .search-input
    border: 1px solid #ddd
    width: 100%
  ul.list
    list-style-type none
    text-align left
    padding 0 20px
    margin 0
    border-bottom 1px solid #EBEDF0
    overflow-y scroll
    height calc(100% - 53px)
    li
      display flex
      align-items center
    div
      display inline-block
      height h = 36px
      line-height h
    .nick
      // width 182px
      flex auto
      font-size 14px
      display flex
      align-items center
      p
        white-space nowrap
        text-overflow ellipsis
        overflow hidden
        max-width 180px
      .whiteboard-icon
        width 13px
        margin 0 0 0 6px
        &.open
          color: #337EFF;
    .hands
      width 36px
      text-align center
      color #337EFF
      display flex
      align-items center
      // margin-right 4px
      &:hover .down,& .down:hover
        display inline-block
      .up
        width 36px
        text-align right
      .down
        display none
        text-align center
        cursor pointer
        margin-left -56px
        background bColor
        width 56px
        height 22px
        line-height 22px
        color #ffffff
        font-size 12px
        border-radius 4px
        user-select: none;
        &:active
          background rgba(78, 136, 252, 1)
    .state
      min-width 41px
      max-width 65px
      text-align right
      display flex
      justify-content right
      align-items center
      .icon-close
        color: #FE3B30
    .more
      display none
      text-align center
      cursor pointer
      margin-left -44px
      background bColor
      border 1px solid #E1E3E6
      box-sizing border-box
      width 44px
      height 22px
      line-height 22px
      color #ffffff
      font-size 12px
      border-radius 4px
      user-select: none;
    .state:hover+.v-popover .more,.v-popover .more:hover
      display inline-block
    .v-popover.member-more-popover
      &>div
        display flex!important
        justify-content center
        flex-direction column;
  .member-list-lock
    border-bottom 1px solid #EBEDF0
    display flex
    justify-content space-between
    padding 10px 13px
  .member-list-footer
    margin-top 15px
    display flex
    justify-content flex-start
    flex-wrap: wrap
    button
      display inline-block
      background: #337EFF;
      border: 1px solid #337EFF;
      border-radius: 2px;
      width 135px
      height bh = 36px
      line-height bh
      text-align center
      cursor pointer
      color #fff
      margin: 5px 12px
      &:active
        opacity 0.8
  .memberList-dialog-content
    padding 24px 0
    font-size 16px
    h3
      font-size: 18px
      margin-bottom 12px
    p
      margin 12px 0
    div.input-content
      position relative
      padding 10px 20px 5px 20px
      & input
        width 100%
        border 1px solid #E1E3E6
        border-radius 2px
        text-indent 12px
        font-size 14px
        height 32px
        line-height 32px
        &.error
          border 1px solid #F24957;
      & .close-btn
        position absolute
        display flex
        right 25px
        top 19px
        width 16px
        height 16px
        color #fff
        background rgba(60,60,67,0.60)
        border-radius 50%
        font-size 10px
        // line-height 15px
        justify-content center
        align-items center
        color #fff
        cursor pointer
        .icon-close
          display inline-block
    .error-msg
      font-size 14px
      color #F24957
      text-align left
      margin 0
      height 20px
      padding 0 20px
  .memberList-dialog-content
    &-info
      padding 0 24px
      font-size 14px
  .memberList-dialog-btns
    display flex
    border-top: 1px solid #EBEDF0
    font-size 15px
    button
      flex 1
      border none
      background #fff
      border-right 1px solid #EBEDF0
      padding: 10px 0
      cursor pointer
      &:active
        opacity 0.8
      &:last-child
        border none
      &.confirm
        color #337EFF
      &.endall
        color #f00
.popover .more-popover
    background: #FFFFFF;
    box-shadow: 0 10px 40px 0 rgba(23,23,26,0.20);
    border-radius: 4px;
    padding 8px 0
    margin 0 20px 0 0
    ul
      li
        font-size 14px
        color #333333
        padding 6px 12px
        cursor pointer
        &:hover
          background: #F2F3F5
          color #337EFF
</style>
