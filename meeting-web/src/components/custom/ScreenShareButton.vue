<!--
 * @Description: 共享屏幕-公共按钮
-->
<template>
  <div class="screen-share-btn">
    <div class="button" @click="startShare">
      <div class="setting-icon">
        <template v-if="btnInfo.btnConfig">
          <template v-if="btnInfo.btnConfig[0].icon">
            <img
              class="custom-icon"
              v-if="screen"
              :src="btnInfo.btnConfig[0].icon"
              alt=""
            />
          </template>
          <template v-else>
            <svg v-if="screen" class="icon" aria-hidden="true">
              <use xlink:href="#iconyx-tv-sharescreen1x"></use>
            </svg>
          </template>
          <template v-if="btnInfo.btnConfig[1].icon">
            <img
              class="custom-icon"
              v-if="!screen"
              :src="btnInfo.btnConfig[1].icon"
              alt=""
            />
          </template>
          <template v-else>
            <svg v-if="!screen" class="icon" aria-hidden="true">
              <use xlink:href="#iconyx-tv-sharescreen1x"></use>
            </svg>
          </template>
        </template>
        <template v-else>
          <svg class="icon" aria-hidden="true">
            <use xlink:href="#iconyx-tv-sharescreen1x"></use>
          </svg>
        </template>
        <div class="custom-text" v-if="btnInfo.btnConfig">
          {{
            screen
              ? `${btnInfo.btnConfig[0].text || $t('unScreenShare')}`
              : `${btnInfo.btnConfig[1].text || $t('screenShare')}`
          }}
        </div>
        <div v-else>{{ screen ? $t('unScreenShare') : $t('screenShare') }}</div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import './button.styl'
import { NEMenuIDs, errorCodes, memberAction, shareMode } from '../../libs/enum'
import { getErrCode } from '../../utils'

export default Vue.extend({
  name: 'screenShareButton',
  data() {
    return {
      NEMenuIDs,
    }
  },
  props: {
    btnInfo: {
      type: Object,
      required: true,
    },
  },
  watch: {
    '$store.state.status': function (newValue) {
      if (newValue !== 2) {
        if (this.screen === 1) {
          this.share()
        }
      }
    },
    '$store.state.isNEMeetingInit': function (newValue) {
      if (newValue) {
        this.bindStopScreenSharingEvent()
      }
    },
  },
  destroyed() {
    // this.$neMeeting.off('stopScreenSharing')
    // fix 赞同如果移交主持人造成按钮销毁，该监听事件也会执行造成无法移交主持人后的用户无法停止共享
    this.$EventBus.$off('screen-share-stop')
    this.$EventBus.$off('enableShareScreen')
  },
  mounted() {
    this.$EventBus.$on('screen-share-stop', () => {
      if (this.screen === 1) {
        this.share()
      }
    })
    this.$EventBus.$on('enableShareScreen', (enable: boolean) => {
      if (enable) {
        this.share()
      } else {
        this.onHandleStopScreenSharing()
      }
    })
    // fix 赞同只有管理员显示共享按钮，造成watch内的监听无效。所以当渲染的时候需要重新监听，可多次监听
    if (this.$neMeeting) {
      this.bindStopScreenSharingEvent()
    }
  },
  methods: {
    bindStopScreenSharingEvent() {
      // 判断是否绑定过停止共享事件
      const eventNames = this.$neMeeting.eventNames()
      const index = eventNames.findIndex((name) => name === 'stopScreenSharing')
      if (index < 0) {
        // 未监听过该事件
        this.$neMeeting.on('stopScreenSharing', this.onHandleStopScreenSharing)
      }
    },
    onHandleStopScreenSharing() {
      console.warn('检测到屏幕共享已经停止了')
      if (this.screen === 1) {
        this.share()
      }
    },
    async startShare() {
      if (this.env === 'electron') {
        this.sendShareAction()
      } else {
        this.share()
      }
    },
    sendShareAction(): void {
      // 对外emit点击事件
      this.$EventBus.$emit('shareScreen', this.screen === 1)
    },

    async share() {
      if (this.screen) {
        console.warn('关闭屏幕共享')
        this.$neMeeting
          .muteLocalScreenShare()
          .then(() => {
            console.log('关闭共享屏幕成功')
            this.screen = 0
            this.$store.dispatch('sortMemberList')
            // if (this.$store.state.localInfo.video === 1 || this.$store.state.localInfo.video === 4) {
            //   this.$neMeeting.unmuteLocalVideo(this.$store.state.cameraId);
            // }
          })
          .catch((e) => {
            this.$toast(
              this.errorCodes[getErrCode(e.code)] ||
                this.$t('screenShareStopFail')
            )
            console.error('关闭共享屏幕失败: ', e)
            return Promise.reject(e)
          })
      } else {
        console.warn('开启屏幕共享')
        if (this.hasScreenShare) {
          this.$toast(this.$t('shareOverLimit'))
          return false
        }
        if (this.hasWhiteBoardShare) {
          this.$toast(this.$t('hasWhiteBoardShare'))
          return false
        }
        if (this.isHandsUp) {
          this.handleHandsUpAction(memberAction.handsDown, false)
        }
        // if (this.$store.state.localInfo.video === 1 || this.$store.state.localInfo.video === 4) {
        //   await this.$neMeeting.muteLocalVideo(false)
        // }
        this.$neMeeting
          .unmuteLocalScreenShare(this.screenSourceId)
          .then(() => {
            console.log('共享屏幕成功')
            this.screen = 1
            this.$store.dispatch('sortMemberList')
          })
          .catch((e) => {
            console.error('共享屏幕失败: ', e)
            const message = e.message || e.msg
            switch (true) {
              case message.includes(
                'possibly because the user denied permission'
              ):
                this.$toast(
                  '无法开启屏幕共享：进入浏览器偏好设置，屏幕共享设置调整为’请求‘，并在开启共享时允许观察屏幕'
                )
                break
              case message.includes('Permission denied by system'):
                this.$toast(
                  '无法开启屏幕共享：打开系统偏好设置-安全与隐私-隐私-屏幕录制，允许该浏览器使用录制功能'
                )
                break
              case message.includes('Permission denied'):
                this.$toast('取消开启屏幕共享')
                break
              default:
                this.$toast(this.$t('screenShareStartFail'))
                break
            }
            return Promise.reject(e)
            // if (message !== 'NotAllowedError') {
            // this.screen = 1
            // this.share()
            // }
            /*this.screen = 0
          this.$store.dispatch('sortMemberList');
          if (this.$store.state.localInfo.video) {
            this.$neMeeting.unmuteLocalVideo()
          }*/
          })
      }
    },
    handleHandsUpAction(val, needToast = true) {
      // 举手 val 58 发言申请举手发言
      // 取消举手 val 59 发言申请举手放下
      this.$neMeeting
        .sendMemberControl(val)
        .then(() => {
          switch (val) {
            case memberAction.handsUp:
              needToast && this.$toast('举手成功，等待主持人处理')
              break
            case memberAction.handsDown:
              needToast && this.$toast('取消举手成功')
              break
            default:
              break
          }
        })
        .catch((e) => {
          if (e && e.code) {
            this.$toast(
              this.errorCodes[getErrCode(e.code)] || e.msg || '操作失败'
            )
          }
          throw new Error(e)
        })
    },
  },
  computed: {
    errorCodes(): any {
      return errorCodes(this.$i18n)
    },
    env(): 'web' | 'electron' {
      return this.$store.state.env
    },
    screenSourceId(): string {
      return this.$store.state.screenSharingSourceId
    },
    screen: {
      get: function () {
        return this.$store.state.localInfo.screen
      },
      set: function (value) {
        const { state, commit } = this.$store
        state.localInfo.screen = value
        const uid = state.localInfo.avRoomUid
        // console.error('uid: %s, value: %s', uid, value)
        let m = state.memberMap[uid]
        m = m ? Object.assign({}, m) : {}
        m['screenSharing'] = value
        commit('updateMember', m)
      },
    },
    hasScreenShare(): boolean {
      // const newResult = { ...this.$store.state.memberMap };
      // let result = false;
      // for (const uid in newResult) {
      //   if (newResult[uid].screenSharing === 1) {
      //     result = true;
      //     break;
      //   }
      // }
      // return result;
      return this.$store.state.meetingInfo.shareMode === shareMode.screen
    },
    isHandsUp: {
      get: function () {
        return this.$store.state.localInfo.isHandsUp
      },
      set: function (value) {
        this.$store.commit('setLocalInfo', {
          isHandsUp: value,
        })
      },
    },
    hasWhiteBoardShare(): boolean {

      return this.$store.state.meetingInfo.shareMode === shareMode.whiteboard
    },
  },
})
</script>

<style lang="stylus" scoped>
// .screen-share-btn
</style>
