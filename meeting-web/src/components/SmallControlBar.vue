
<template>
  <div
    class="control-bar-small"
    :style="{
      background: theme.controlBarBgColor || '',
    }"
  >
    <div class="button-box">
      <template v-for="item in smallBarList">
        <div
          :key="item.id"
          class="button-list"
          :style="{
            color: theme.controlBarColor || '',
          }"
        >
          <div
            v-if="item.id === NEMenuIDs.mic && btnVisibile(item.visibility)"
            class="button"
            :name="`${
              audio === 1 || audio === 4
                ? 'mute-audio-byself'
                : 'unmute-audio-byself'
            }`"
            @click="debounce(toggleMuteAudio)"
          >
            <div
              :class="`setting-icon ${
                audio === 1 || audio === 4 ? '' : 'setting-icon-close'
              }`"
            >
              <template v-if="item.btnConfig">
                <template v-if="item.btnConfig[0].icon">
                  <img
                    class="custom-icon"
                    v-if="audio === 1 || audio === 4"
                    :src="item.btnConfig[0].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg
                    v-if="audio === 1 || audio === 4"
                    class="icon"
                    aria-hidden="true"
                  >
                    <use xlink:href="#iconyx-tv-voice-onx"></use>
                  </svg>
                </template>
                <template v-if="item.btnConfig[1].icon">
                  <img
                    class="custom-icon"
                    v-if="audio === 2 || audio === 3"
                    :src="item.btnConfig[1].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg
                    v-if="audio === 2 || audio === 3"
                    class="icon"
                    aria-hidden="true"
                  >
                    <use xlink:href="#iconyx-tv-voice-offx"></use>
                  </svg>
                </template>
              </template>
              <template v-else>
                <svg
                  v-if="audio === 1 || audio === 4"
                  class="icon"
                  aria-hidden="true"
                >
                  <use xlink:href="#iconyx-tv-voice-onx"></use>
                </svg>
                <svg v-else class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-voice-offx"></use>
                </svg>
              </template>
            </div>
          </div>
          <div
            class="button button-for-setting"
            v-if="item.id === NEMenuIDs.mic && btnVisibile(item.visibility)"
            :data-bordercolor="theme.controlBarColor || '#fff'"
          >
            <v-popover
              :delay="300"
              popoverWrapperClass="setting-popover-out"
              style="display: inline-block"
              placement="top"
              @apply-hide="toggleSettingOnBar(1, false)"
            >
              <template slot="popover">
                <div
                  class="setting-outer"
                  :style="{
                    background: theme.controlBarBgColor || '',
                    color: theme.controlBarColor || '#fff',
                  }"
                >
                  <SettingInBar v-if="showSoundSetting" :devicesType="1" />
                  <!-- <ul class="setting-enter">
                    <li @click="showDialog">音频设置</li>
                  </ul> -->
                </div>
              </template>
              <span
                @click="toggleSettingOnBar(1, true)"
                :class="`bar-setting mute-setting ${isDev ? '' : 'need-top'} ${
                  showSoundSetting && 'setting-select'
                }`"
              ></span>
            </v-popover>
          </div>
          <div
            class="button"
            :name="`${
              video === 1 || video === 4
                ? 'mute-video-byself'
                : 'unmute-video-byself'
            }`"
            @click="debounce(toggleMuteVideo)"
            v-if="item.id === NEMenuIDs.camera && btnVisibile(item.visibility)"
          >
            <div
              :class="`setting-icon ${
                video === 1 || video === 4 ? '' : 'setting-icon-close'
              }`"
            >
              <template v-if="item.btnConfig">
                <template v-if="item.btnConfig[0].icon">
                  <img
                    class="custom-icon"
                    v-if="video === 1 || video === 4"
                    :src="item.btnConfig[0].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg
                    v-if="video === 1 || video === 4"
                    class="icon"
                    aria-hidden="true"
                  >
                    <use xlink:href="#iconyx-tv-video-onx"></use>
                  </svg>
                </template>
                <template v-if="item.btnConfig[1].icon">
                  <img
                    class="custom-icon"
                    v-if="video === 2 || video === 3"
                    :src="item.btnConfig[1].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg
                    v-if="video === 2 || video === 3"
                    class="icon"
                    aria-hidden="true"
                  >
                    <use xlink:href="#iconyx-tv-video-offx"></use>
                  </svg>
                </template>
              </template>
              <template v-else>
                <svg
                  v-if="video === 1 || video === 4"
                  class="icon"
                  aria-hidden="true"
                >
                  <use xlink:href="#iconyx-tv-video-onx"></use>
                </svg>
                <svg v-else class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-video-offx"></use>
                </svg>
              </template>
            </div>
          </div>
          <div
            class="button button-for-setting"
            v-if="item.id === NEMenuIDs.camera && btnVisibile(item.visibility)"
          >
            <v-popover
              :delay="300"
              popoverWrapperClass="setting-popover-out"
              style="display: inline-block"
              placement="top"
              @apply-hide="toggleSettingOnBar(2, false)"
            >
              <template slot="popover">
                <div
                  class="setting-outer"
                  :style="{
                    background: theme.controlBarBgColor || '',
                    color: theme.controlBarColor || '#fff',
                  }"
                >
                  <SettingInBar v-if="showVideoSetting" :devicesType="2" />
                  <!-- <ul class="setting-enter">
                    <li @click="showDialog">视频设置</li>
                  </ul> -->
                </div>
              </template>
              <span
                @click="toggleSettingOnBar(2, true)"
                :class="`bar-setting mute-setting ${
                  showVideoSetting && 'setting-select'
                }`"
              ></span>
            </v-popover>
          </div>
          <div
            class="button"
            @click="debounce(changeMyVideo)"
            v-if="
              item.id === NEMenuIDs.myVideoControl &&
              btnVisibile(item.visibility)
            "
          >
            <div class="setting-icon">
              <template v-if="item.btnConfig">
                <template v-if="item.btnConfig[0].icon">
                  <img
                    class="custom-icon"
                    v-if="showMySmallVideo"
                    :src="item.btnConfig[0].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg v-if="showMySmallVideo" class="icon" aria-hidden="true">
                    <use xlink:href="#iconshipin-xianshi"></use>
                  </svg>
                </template>
                <template v-if="item.btnConfig[1].icon">
                  <img
                    class="custom-icon"
                    v-if="!showMySmallVideo"
                    :src="item.btnConfig[1].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg v-if="!showMySmallVideo" class="icon" aria-hidden="true">
                    <use xlink:href="#iconshipin-yincang"></use>
                  </svg>
                </template>
              </template>
              <template v-else>
                <svg v-if="showMySmallVideo" class="icon" aria-hidden="true">
                  <use xlink:href="#iconshipin-xianshi"></use>
                </svg>
                <svg v-else class="icon" aria-hidden="true">
                  <use xlink:href="#iconshipin-yincang"></use>
                </svg>
              </template>
            </div>
          </div>
          <CustomButton
            :isSmallBtn="true"
            :btnInfo="item"
            v-if="
              !Object.values(NEMenuIDs).includes(item.id) &&
              btnVisibile(item.visibility)
            "
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import SettingInBar from './SettingInBar.vue'
import CustomButton from './custom/CustomButton.vue'
import { NEMenuVisibility, NEMenuIDs, errorCodes, RoleType } from '../libs/enum'
import { getErrCode, debounce } from '../utils'
import { Logger } from '@/libs/3rd/Logger'
import { Theme } from '@/types/index'

const logger = new Logger('smallControl', true)

export default Vue.extend({
  name: 'SmallControlBar',
  data() {
    return {
      NEMenuIDs,
      showSoundSetting: false,
      showVideoSetting: false,
    }
  },
  components: {
    SettingInBar,
    CustomButton,
  },
  computed: {
    errorCodes(): any {
      return errorCodes(this.$i18n)
    },
    audio: {
      get: function () {
        return this.$store.state.localInfo.audio
      },
      set: function (value) {
        const { state, commit } = this.$store
        state.localInfo.audio = value
        const uid = state.localInfo.avRoomUid
        // console.error('uid: %s, value: %s', uid, value)
        let m = state.memberMap[uid]
        m = m ? Object.assign({}, m) : {}
        m['audio'] = value
        commit('updateMember', m)
      },
    },
    video: {
      get: function () {
        return this.$store.state.localInfo.video
      },
      set: function (value) {
        const { state, commit } = this.$store
        state.localInfo.video = value
        const uid = state.localInfo.avRoomUid
        // console.error('uid: %s, value: %s', uid, value)
        let m = state.memberMap[uid]
        m = m ? Object.assign({}, m) : {}
        m['video'] = value
        // const test  = m
        // console.log('m: ', test)
        commit('updateMember', m)
      },
    },
    smallBarList(): Array<any> {
      return this.$store.state.localInfo.smallBarList
    },
    isPresenter(): boolean {
      const result = this.$store.state.localInfo.role
      return result === 'host'
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
    isCoHost(): boolean {
      return this.localInfo.roleType === RoleType.coHost
    },
    isHost(): boolean {
      // 是否为主持人或者联席主持人
      return this.isCoHost || this.isPresenter
    },
    isDev(): boolean {
      return process.env.NODE_ENV === 'development'
    },
    showMySmallVideo(): boolean {
      return this.$store.state.localInfo.showMySmallVideo
    },
    theme(): Theme {
      return this.$store.state.theme
    },
  },
  methods: {
    debounce,
    toggleSettingOnBar(type, value) {
      // 1 音频 2 视频
      switch (type) {
        case 1:
          this.showSoundSetting = value

          this.$store.commit('setSettingSelect', 'audio')
          break
        case 2:
          this.showVideoSetting = value
          this.$store.commit('setSettingSelect', 'video')
          break
        default:
          this.showSoundSetting = value
          this.showVideoSetting = value
          break
      }
    },
    btnVisibile(visibility = 0) {
      let result = false
      switch (true) {
        case NEMenuVisibility.VISIBLE_ALWAYS === visibility:
          result = true
          break
        case NEMenuVisibility.VISIBLE_EXCLUDE_HOST === visibility &&
          this.isHost:
          result = true
          break
        case NEMenuVisibility.VISIBLE_TO_HOST_ONLY === visibility &&
          !this.isHost:
          result = true
          break
        default:
          break
      }
      return result
    },
    async toggleMuteAudio() {
      const { microphoneId } = this.$store.state
      const status = this.audio
      let p: any, callback: any
      if (status === 1 || status === 4) {
        p = this.$neMeeting.muteLocalAudio()
        callback = () => {
          this.$store.commit('setLocalInfo', {
            audio: 2,
          })
          this.audio = 2
        }
        // this.$store.state.localInfo.audio = 2
      } else {
        p = this.$neMeeting.unmuteLocalAudio(microphoneId)
        callback = () => {
          this.$store.commit('setLocalInfo', {
            audio: 1,
          })
          this.audio = 1
        }
        // this.$store.state.localInfo.audio = 1
      }
      if (p) {
        p.then(() => {
          callback()
        }).catch((e) => {
          this.$toast(
            this.errorCodes[getErrCode(e.code)] || e.msg || '设置音频失败'
          )
          console.error(
            'toggleMuteAudio',
            status ? 'mute' : 'unmute',
            'error',
            e
          )
        })
      }
    },
    toggleMuteVideo() {
      // if (this.screen) {
      //   this.$toast(this.$t('screenShareModeForbiddenOp'))
      //   return
      // }
      const { cameraId } = this.$store.state
      const status = this.video
      let p, callback: () => void
      if (status === 1) {
        p = this.$neMeeting.muteLocalVideo()
        callback = () => {
          this.$store.commit('setLocalInfo', {
            video: 2,
          })
        }
        // this.$store.state.localInfo.video = 2
        this.video = 2
      } else if (status === 3 && this.$store.state.localInfo.role !== 'host') {
        this.$toast(`${this.$t('openCameraFailByHost')}`)
      } else {
        p = this.$neMeeting.unmuteLocalVideo(cameraId)
        callback = () => {
          this.$store.commit('setLocalInfo', {
            video: 1,
          })
          // this.$store.state.localInfo.video = 1
          this.video = 1
        }
      }
      if (p) {
        p.then(() => {
          callback()
        }).catch((e) => {
          this.$toast(
            this.errorCodes[getErrCode(e.code)] || e.msg || '设置视频失败'
          )
          console.error(
            'toggleMuteVideo',
            status ? 'mute' : 'unmute',
            'error',
            e
          )
        })
      }
    },
    changeMyVideo() {
      const {
        commit,
        state: { localInfo },
      } = this.$store
      commit('setLocalInfo', {
        showMySmallVideo: !localInfo.showMySmallVideo,
      })
    },
  },
})
</script>

<style lang="stylus" scoped>
.hands-popover
  .hands-action
    position relative
    text-align center
    width 36px
    height 40px
    background #337EFF
    color #fff
    box-shadow: 0 2px 6px 0 rgba(23,23,26,0.10);
    cursor pointer
    .hands-icon
      display block
      margin 3px auto 0
      font-size 20px
    &:after
      content ''
      display inline-block
      position absolute
      left 15px
      bottom -12px
      border-color #337EFF transparent transparent transparent
      border-width 6px 4px 6px 4px
      border-style solid
    .hands-up-tip
      display inline-block
    .hands-down-tip
      display none
      // margin-left -30px
      background #337EFF
    &:hover .hands-down-tip, & .hands-down-tip:hover, &.no-hover:hover .hands-up-tip, &.no-hover:hover .hands-up-tip:hover
      display inline-block
    &:hover .hands-up-tip, & .hands-up-tip:hover, &.no-hover:hover .hands-down-tip, &.no-hover:hover .hands-down-tip:hover
      display none
    .hands-up-tip,.hands-down-tip
      span
        display block
        font-size 12px
        transform scale(.8)
.setting-popover-out
  .setting-outer
    background-image: linear-gradient(180deg, #33333F 0%, #292933 100%);
    border-radius: 4px;
    color: #fff;
    box-shadow: 0 5px 30px rgba(0, 0, 0, 0.1);
  .setting-enter
    padding 0 14px 14px
    li:hover
      cursor pointer
      background: rgba(0, 0, 0, 0.2);
h = 48px
.control-bar-small
  height h
  width 100%
  background-image: linear-gradient(180deg, #33333F 0%, #292933 100%)
  font-size: 12px
  color: #ffffff
  position relative
  z-index 1001
  // bottom 0
  .button-box
    // margin 0 auto
    display flex
    justify-content flex-end
    align-items center
    .button-list
      display flex
      justify-content center
      align-items center
      color: #fff
  .button
    position relative
    display flex
    width 40px
    margin 0 8px
    height h
    // line-height h
    text-align center
    cursor pointer
    align-items center
    justify-content center
    .member-num
      position absolute
      top 5px
      left 40px
      font-size 9px
    &:hover
      background: rgba(0, 0, 0, 0.3)
    .setting-icon
      vertical-align: middle
      display: inline-block
      .custom-icon
        display block
        width 26px
        margin 0 auto 2px
        user-select none
      .custom-text
        text-overflow ellipsis
        overflow hidden
        white-space pre
        max-width 78px
        user-select none
    .setting-icon-close
      color: #FE3B30
    .white
      // color #fff
    .icon
      font-size 26px
    .bar-setting
      height: h
      line-height: 54px
      width: 12px
      display: inline-block
      position: relative
      // margin: 0 0 0 10px
      // &.need-top:before
      //   margin-top 38%
    .bar-setting:before
      content: ''
      position absolute
      top 50%
      left calc(50% - 4px)
      // display: inline-block
      border-width 4px
      border-style solid
      border-top-color transparent
      border-right-color transparent
      border-bottom-color inherit
      border-left-color transparent
    .setting-select
      opacity: 0.3;
      background inherit;
  .button-for-setting
    width 12px
    margin: 0
  .leave-button
    color red
    position absolute
    right 50px
    top 30%
    background-image: linear-gradient(179deg, #25252E 7%, #15151A 100%);
    border-radius: 4px
    padding: 6px 14px
    cursor: pointer
  .invite-content, .leave-content
    padding 24px 0
    font-size 16px
    h3
      font-size: 18px
      margin-bottom 12px
  .invite-content
    p
      font-size: 18px;
      color: #222222;
      text-align left
      font-size 14px
      padding 0 35px
      &.mt22
        margin 22px 0 0
      &.short-id
        text-indent 55px
    button
      margin 10px 0 0
      background: #337EFF;
      border: 1px solid #337EFF;
      border-radius: 20px;
      padding 10px 30px
      text-align center
      cursor pointer
      color #fff
      &:active
        opacity 0.8
    div.invite-btn-out
      margin 32px 0 0
      border-top 1px solid #EBEDF0
  .leave-content
    &-info
      padding 0 24px
      font-size 14px
  .leave-content-btns
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
</style>
