<template>
  <div
    class="video-card"
    :class="`${showBorder ? 'show-border' : ''}`"
    :style="{
      background: theme.videoBgColor || '',
    }"
  >
    <button
      @click="cancelFocus"
      v-if="isHost && member.isFocus && showFocusBtn && isSpeaker"
      class="cancel-focus"
    >
      {{ $t('unFocusVideo') }}
    </button>
    <div class="nickname" v-if="!preview">
      <template v-if="member">
        <svg
          v-if="member.audio === 1"
          class="icon icon-white"
          aria-hidden="true"
        >
          <use xlink:href="#iconyx-tv-voice-onx"></use>
        </svg>
        <svg v-else class="icon" aria-hidden="true">
          <use xlink:href="#iconyx-tv-voice-offx"></use>
        </svg>
      </template>

      {{ member.nickName }}
    </div>
    <div
      v-show="member.isVideoOn && !main"
      ref="myVideo"
      :class="`video-card-content video-${uid}`"
    ></div>
    <div
      v-show="member.isVideoOn && !member.isSharingScreen && isMainVideo"
      ref="mainVideo"
      :class="`video-card-content video-main-${uid}`"
    ></div>
    <div
      v-show="member.isSharingScreen && isMainScreen"
      ref="myScreenVideo"
      :class="`video-card-content video-screen-${uid}`"
    ></div>
    <!--    <video-->
    <!--      v-show="(canShowPlay && (member.video === 1 || member.video === 4 || !isLocalUserInScreen || preview)) || (member.screenSharing === 1 && main)"-->
    <!--      ref="video"-->
    <!--      autoplay></video>-->
    <div
      v-show="
        (member.video !== 1 && !main) ||
        (member.video !== 1 && main && !isScreen)
      "
      :class="`center-nickname ${preview ? 'name-hide' : ''} ${
        useSmall ? 'small-name' : ''
      }`"
    >
      <div>
        {{ member.nickName }}
      </div>
    </div>
    <div v-show="isLocalUserInScreen" class="screen-share-mask">
      <div>{{ member.nickName }}{{ $t('screenShareLocalTips') }}</div>
    </div>
  </div>
</template>
<script lang="ts">
import { AttendeeOffType, Role, shareMode } from '@/libs/enum'
import Vue from 'vue'
import { Theme } from '@/types/index'

export default Vue.extend({
  props: {
    uid: {
      type: String,
    },
    myUid: {
      type: String,
    },
    preview: {
      type: Boolean,
    },
    isPresenter: {
      type: Boolean,
    },
    isScreen: {
      type: Boolean,
    },
    main: {
      type: Boolean,
    },
    muted: {
      type: Boolean,
    },
    member: {
      type: Object,
    },
    isShowVideo: {
      type: Boolean,
      default: true,
    },
    mediaType: {
      type: String,
      default: 'video',
    },
  },
  async mounted() {
    // 以下逻辑主要用于新建画布的时候：如新人入会，成员从主画面切换到顶部画面
    if (this.isMySelf) {
      this.$neMeeting.rtcController.setupLocalVideoCanvas(this.view)
      const isHost =
        this.member.role === Role.host || this.member.role === Role.coHost
      if (
        this.localInfo.isUnMutedVideo &&
        (this.$store.state.videoOff === AttendeeOffType.disable || isHost)
      ) {
        // 第一次进入会议，并且设置加入会议开启音视频
        this.$neMeeting.unmuteLocalVideo()
      }
      if (
        this.localInfo.isUnMutedAudio &&
        (this.$store.state.audioOff === AttendeeOffType.disable || isHost)
      ) {
        this.$neMeeting.unmuteLocalAudio()
      }
      // 后续设置为false
      this.$store.commit('setLocalInfo', {
        isUnMutedAudio: false,
        isUnMutedVideo: false,
      })
      if (this.member.screen !== 1) {
        // 未共享画面
        this.member.video === 1 &&
          this.$neMeeting.rtcController.playLocalStream('video')
      } else {
        if (!this.main && this.member.video === 1) {
          this.member.video === 1 &&
            this.$neMeeting.rtcController.playLocalStream('video')
        } else {
          this.$neMeeting.rtcController.playLocalStream('screen')
        }
      }
    } else {
      if (this.member.screen) {
        // 进入会议时候远端已经开始有流
        if (this.isMainScreen) {
          // 如果是主屏幕则订阅播放共享画面
          this.$neMeeting.rtcController.setupRemoteVideoSubStreamCanvas(
            this.$refs.myScreenVideo as any || (`video-screen-${this.uid}` as any),
            this.uid
          )
          this.$neMeeting.rtcController.subscribeRemoteVideoSubStream(this.uid)
        } else {
          // 如果非主屏且视频画面开启则订阅视频画面
          if (this.member.video) {
            if (this.isShowVideo) {
              //@ts-ignore
              this.$neMeeting.rtcController.stopPlayingRemoteStream(
                'video',
                this.uid
              )
              await this.playRemoteVideo()
            } else {
              // 不在当前页面不显示，取消订阅
              this.$neMeeting.rtcController.unsubscribeRemoteVideoStream(
                this.uid,
                this.streamType
              )
            }
          }
        }
      } else if (this.member.video) {
        if (this.isShowVideo) {
          //@ts-ignore
          this.$neMeeting.rtcController.stopPlayingRemoteStream(
            'video',
            this.uid
          )
          await this.playRemoteVideo()
        } else {
          // 不在当前页面不显示，取消订阅
          this.$neMeeting.rtcController.unsubscribeRemoteVideoStream(
            this.uid,
            this.streamType
          )
        }
      }
    }
  },
  data() {
    return {
      canShowPlay: false,
      timer: null as any,
    }
  },
  beforeDestroy() {
    // this.setSrcObject(null)
    this.timer && clearTimeout(this.timer)
  },
  watch: {
    muted: function (newVal) {
      this.setVideoMuted(newVal)
    },
    isShowVideo: function (newVal, oldValue) {
      // 视频不在当前页显示不订阅视频流
      if (this.member.video === 1) {
        if (!newVal) {
          this.timer = setTimeout(() => {
            this.$neMeeting.rtcController.unsubscribeRemoteVideoStream(
              this.uid,
              this.streamType
            )
            this.timer = null
          }, 10000)
        } else if (newVal) {
          if (this.timer) {
            clearTimeout(this.timer)
            this.timer = null
          } else {
            this.playRemoteVideo()
          }
        }
      }
    },
    'member.uid': function (newUid: string, oldUid: string) {
      // 主屏幕切换人员的时候需要播放相应内容
      if (!this.member) {
        // 当前画布没有人,离开房间
        return
      }
      if (this.main) {
        const el: any = this.$refs.mainVideo
        if (el && el.hasChildNodes()) {
          console.log('存在子元素进行删除')
          el.removeChild(el.firstChild)
        }
      }
      if (this.member.screen === 1 && this.isMainScreen) {
        this.playRemoteSubVideo()
      } else if (this.member.video === 1) {
        const oldMember = this.memberMap[oldUid]
        if (this.isMySelf) {
          if (oldMember) {
            // 该成员还在房间
            if (oldMember.video === 1) {
              // 主屏幕可能存在两个画面问题，所以先停止播放上一个的
              if (this.main) {
                //@ts-ignore
                this.$neMeeting.rtcController.stopPlayingRemoteStream(
                  'video',
                  oldMember.avRoomUid
                )
              }
              // 如果老的member成员video值和新的不一致会通过下面的watch member.video执行
              this.$neMeeting.rtcController.setupLocalVideoCanvas(this.view)
              this.$neMeeting.rtcController.playLocalStream('video')
            }
          } else {
            // 该成员离开房间,不会触发下放的watch.video
            this.$neMeeting.rtcController.setupLocalVideoCanvas(this.view)
            this.$neMeeting.rtcController.playLocalStream('video')
          }
        } else {
          if (oldMember && oldMember.video === 1 && this.main) {
            //@ts-ignore
            this.$neMeeting.rtcController.stopPlayingRemoteStream(
              'video',
              oldMember.avRoomUid
            )
          }
          this.playRemoteVideo()
        }
      }
    },
    'member.video': {
      handler: function (video: number) {
        if (!this.member) {
          return
        }
        if (this.member.video === 1) {
          if (this.isMySelf) {
            this.$neMeeting.rtcController.setupLocalVideoCanvas(this.view)
            this.$neMeeting.rtcController.playLocalStream('video')
          } else {
            if (this.member.screen === 1 && this.isMainScreen) {
              return
            }
            this.playRemoteVideo()
          }
        } else {
          this.canShowPlay = false
          !this.isMySelf &&
            this.$neMeeting.rtcController.unsubscribeRemoteVideoStream(
              this.uid,
              this.streamType
            )
        }
      },
      immediate: false,
    },
    isLocalUserInScreen: {
      handler: function (newVal: boolean) {
        if (!this.member) {
          return
        }
        if (!newVal) {
          // 如果本端取消共享，需要显示原本main界面内容视频
          if (this.member.video === 1) {
            if (this.isMySelf) {
              this.$neMeeting.rtcController.playLocalStream('video')
            } else {
              this.playRemoteVideo()
            }
          }
        }
      },
    },
    'member.screen': {
      handler: function (screen: number) {
        if (!this.member) {
          return
        }
        if (screen === 1) {
          this.playRemoteSubVideo()
        } else {
          !this.isMySelf &&
            this.$neMeeting.rtcController.unsubscribeRemoteVideoSubStream(
              this.uid
            )
          if (this.member.video === 1) {
            // 当在主屏幕且视频还开启的时候需要继续播放视频画面否则
            if (this.isMySelf) {
              this.$neMeeting.rtcController.setupLocalVideoCanvas(this.view)
              this.$neMeeting.rtcController.playLocalStream('video')
            } else {
              this.playRemoteVideo()
            }
          }
        }
      },
      immediate: false,
    },
  },
  methods: {
    cancelFocus() {
      this.$neMeeting.sendHostControl(31, [this.member['accountId']])
    },
    setVideoMuted(muted: boolean) {
      // 设置视频静音
      const video = this.$refs.video as any
      if (!this.$refs.video || this.isScreen) {
        // 如果是共享的也不设置静音
        return
      }
      video.muted = muted ? 'muted' : ''
    },
    async playRemoteVideo() {
      if (this.isMySelf) {
        return
      }
      if (!this.isShowVideo) {
        // 防止之前已经订阅过更换view之后没有取消
        console.warn('非当前页不播放视频')
        // this.$neMeeting.rtcController.unsubscribeRemoteVideoStream(
        //   this.uid,
        //   this.streamType
        // )
      } else {
        if (this.main) {
          const el: any = this.$refs.mainVideo
          el.innerHTML = ''
        }
        // 先停止播放
        //@ts-ignore
        this.$neMeeting.rtcController.stopPlayingRemoteStream('video', this.uid)
        this.$neMeeting.rtcController.setupRemoteVideoCanvas(
          this.view,
          this.uid
        )
        await this.$neMeeting.rtcController.subscribeRemoteVideoStream(
          this.uid,
          this.streamType
        )
      }
    },
    playRemoteSubVideo() {
      if (this.isMySelf || !this.isMainScreen) {
        return
      }
      this.$neMeeting.rtcController.setupRemoteVideoSubStreamCanvas(
        this.$refs.myScreenVideo as any || (`video-screen-${this.uid}` as any),
        this.uid
      )
      this.$neMeeting.rtcController.subscribeRemoteVideoSubStream(this.uid)
    },
  },
  computed: {
    // member (): {[key: string]: any} {
    //   // console.log('看看这个人的状态机: %o', this.$store.state.memberMap[this.uid])
    //   return this.$store.state.memberMap[this.uid] || {}
    // },
    isMainScreen(): boolean {
      return this.mediaType === 'screen' && this.main
    },
    isMainVideo(): boolean {
      return this.mediaType === 'video' && this.main
    },
    streamType(): number {
      // 如果是主屏幕订阅大流0 否则订阅小流1
      return this.main ? 0 : 1
    },
    isSpeaker(): boolean {
      // 是否主持人
      return this.$store.state.layout === 'speaker'
    },
    memberMap(): any {
      return this.$store.state.memberMap
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
    isCoHost(): boolean {
      return this.localInfo.role === Role.coHost
    },
    isHost(): boolean {
      // 是否为主持人或者联席主持人
      return this.isCoHost || this.isPresenter
    },
    showFocusBtn(): boolean {
      return this.$store.state.showFocusBtn
    },
    showBorder(): boolean {
      return this.$store.state.layout === 'gallery' && this.member['showBorder']
    },
    isLocalUserInScreen(): boolean {
      // 判断是否为本端共享从而进行展示共享内容
      const {
        state: { meetingInfo },
      } = this.$store
      return (
        meetingInfo.shareMode === shareMode.screen &&
        meetingInfo.screenSharersAvRoomUid &&
        meetingInfo.screenSharersAvRoomUid.includes(
          this.$neMeeting.avRoomUid.toString()
        ) &&
        this.main
      )
    },
    useSmall(): boolean {
      return this.$store.state.localInfo.defaultRenderMode === 'small'
    },
    theme(): Theme {
      return this.$store.state.theme
    },
    isMySelf(): boolean {
      return this.uid === this.myUid
    },
    view(): any {
      // 需要播放的画布
      return this.main
        ? this.$refs.mainVideo || `#video-main-${this.uid}`
        : this.$refs.myVideo || `#video-${this.uid}`
    },
  },
})
</script>
<style lang="stylus" scoped>
.video-card >>> .nertc-video-container
  width: 100%!important
  height: 100%!important
.video-card >>> .nertc-video-container-local
  width: 100%!important
  height: 100%!important
.video-card >>> .nertc-video-container-remote
  width: 100%!important
  height: 100%!important
.video-card >>> .nertc-screen-container
  width: 100%!important
  height: 100%!important
.video-card
  position relative
  box-sizing border-box
  margin 1px 2px
  color #fff
  background #292933
  &.show-border
    border 4px solid #59F20C
  video
    height 100%
    width 100%
    // object-fit cover
  .nickname
    position absolute
    bottom 3px
    left 3px
    z-index 1000
    font-size 12px
    background rgba(0, 0, 0, 0.5)
    border-radius: 2px
    height h = 21px
    line-height h
    padding 0 6px
    max-width 60%
    text-overflow ellipsis
    overflow hidden
    white-space nowrap
    .icon
      color: #fe3b30
    .icon-white
      color: #fff
  .cancel-focus
    position absolute
    top 3px
    left 3px
    font-size 14px
    color #fff
    border none
    padding 2px 4px
    background rgba(0, 0, 0, 0.3)
    z-index 11
    cursor pointer
  .video-card-content
    height 100%
    width 100%
  .center-nickname, .screen-share-mask
    width 100%
    height: 100%
    position absolute
    text-align center
    font-size 40px
    z-index 10
    background inherit
    top 0
    bottom 0
    &>div
      position absolute
      transform translate(-50%, -50%)
      top 50%
      left 50%
    &.name-hide
      z-index -1
    &.small-name
      font-size 14px
</style>
