<template>
  <div class="setting-content">
    <aside class="setting-content-aside">
      <ul class="aslide-list">
        <li
          v-for="(item, index) in settingList"
          @click="handleChooseNav(item)"
          :key="`${item.value}${index}`"
          :class="`${item.isSelected && 'current-select'}`"
        >
          <svg class="icon" aria-hidden="true">
            <use :xlink:href="`#${item.icon}`"></use>
          </svg>
          {{ item.name }}
        </li>
      </ul>
    </aside>
    <section class="setting-content-detail">
      <div v-if="currentSelect === 'normal'">常规</div>
      <div v-else-if="currentSelect === 'video'">
        <div class="setting-audio-row">
          <div class="setting-audio-col1">摄像头</div>
          <div class="setting-audio-col2">
            <div class="setting-select-outer">
              <select
                class="setting-select"
                @change="(e) => handleSelectDevice(e, 3)"
                v-model="defaultVideo"
              >
                <option
                  v-for="item in videoDevicesList"
                  :key="item.deviceId"
                  :value="item.deviceId"
                >
                  {{ item.deviceName }}
                </option>
              </select>
            </div>
            <!-- TODO 添加本地摄像头信息 -->
            <video ref="video" style="width: 320px; height: 240px"></video>
            <!--            <video-card :stream="stream" :preview="true" style="width: 320px; height: 240px"></video-card>-->
          </div>
        </div>
        <div></div>
      </div>
      <div v-else-if="currentSelect === 'audio'">
        <div class="setting-audio-row">
          <div class="setting-audio-col1">扬声器</div>
          <div class="setting-audio-col2">
            <div class="setting-select-outer">
              <select
                class="setting-select"
                @change="(e) => handleSelectDevice(e, 2)"
                v-model="defaultSpeaker"
              >
                <option
                  v-for="item in speakerDevicesList"
                  :key="item.deviceId"
                  :value="item.deviceId"
                >
                  {{ item.deviceName }}
                </option>
              </select>
              <button disabled>检测扬声器</button>
            </div>
            <div class="setting-slider-outer">
              <i class="mgt20" />输出级别
              <VProgress :width="358" :percent="0" :showSlider="false" />
              <br />
              <i class="mgt20" />输出音量
              <svg class="icon" aria-hidden="true">
                <use xlink:href="#iconsound-soft1x"></use>
              </svg>
              <VProgress
                :width="327"
                :percent="localSpeakerPercent"
                @percentChange="(percent) => handlePercentChange(percent, 2)"
              />
              <svg class="icon" aria-hidden="true">
                <use xlink:href="#iconsound-loud1x"></use>
              </svg>
            </div>
          </div>
        </div>
        <div class="setting-audio-row">
          <div class="setting-audio-col1">麦克风</div>
          <div class="setting-audio-col2">
            <div class="setting-select-outer">
              <select
                class="setting-select"
                @change="(e) => handleSelectDevice(e, 1)"
                v-model="defaultAudio"
              >
                <option
                  v-for="item in audioDevicesList"
                  :key="item.deviceId"
                  :value="item.deviceId"
                >
                  {{ item.deviceName }}
                </option>
              </select>
              <button disabled>检测麦克风</button>
            </div>
            <div class="setting-slider-outer">
              <i class="mgt20" />输入级别
              <VProgress :width="358" :percent="0" :showSlider="false" />
              <br />
              <i class="mgt20" />输入音量
              <svg class="icon" aria-hidden="true">
                <use xlink:href="#iconsound-soft1x"></use>
              </svg>
              <VProgress
                :width="327"
                :percent="localAudioPercent"
                @percentChange="(percent) => handlePercentChange(percent, 1)"
              />
              <svg class="icon" aria-hidden="true">
                <use xlink:href="#iconsound-loud1x"></use>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import VProgress from './ui/Progress.vue'
// import VideoCard from './VideoCard.vue';
import { timeStatistics, debounce } from '@/utils'

export default Vue.extend({
  name: 'SettingContent',
  data() {
    return {
      settingList: [
        // {
        //   name: '常规',
        //   value: 'normal',
        //   isSelected: false,
        //   icon: 'iconyx-tv-settingx1'
        // },
        {
          name: '视频',
          value: 'video',
          isSelected: false,
          icon: 'iconyx-tv-voice-onx',
        },
        // {
        //   name: '音频',
        //   value: 'audio',
        //   isSelected: false,
        //   icon: 'iconyx-tv-video-onx'
        // }
      ],
      speakerDevicesList: [],
      audioDevicesList: [],
      videoDevicesList: [],
      defaultSpeaker: this.$store.state.speakerId,
      defaultAudio: this.$store.state.microphoneId,
      defaultVideo: this.$store.state.cameraId,
      localAudioPercent: 0,
      localSpeakerPercent: 0,
      stream: '',
    }
  },
  components: {
    VProgress,
    // VideoCard,
  },
  props: {
    defaultSelect: {
      type: String,
      default: 'video',
    },
  },
  mounted() {
    this.init()
    this.$neMeeting.on('deviceChange', this.init.bind(this))
  },
  beforeDestroy() {
    this.$neMeeting.off('deviceChange', this.init.bind(this))
    this.stream &&
      (this.stream as any).getTracks().forEach(function (track) {
        track.stop()
      })
    this.stream = ''
  },
  watch: {
    defaultSelect: function (newValue) {
      const key = newValue || 'video'
      for (const item of this.settingList) {
        if (item.value === key) {
          item.isSelected = true
        } else {
          item.isSelected = false
        }
      }
    },
    stream: function (newStream) {
      const video: HTMLVideoElement = this.$refs.video as HTMLVideoElement
      if ((video.srcObject as any)?.id !== newStream?.id) {
        debounce(this.setSrcObject(newStream), 500)
      }
    },
    cameraDevicesList: function (newList) {
      console.log('cameraDevicesList', newList)
      this.$set(this, 'videoDevicesList', newList)
    },
  },
  methods: {
    handleChooseNav(ele) {
      // 选择select
      for (const item of this.settingList) {
        item.isSelected = false
      }
      ele.isSelected = true
    },
    async init() {
      const { state } = this.$store
      this.$set(this, 'speakerDevicesList', state.speakerDevicesList)
      this.$set(this, 'audioDevicesList', state.audioDevicesList)
      this.$set(this, 'videoDevicesList', state.videoDevicesList)
      for (const item of this.settingList) {
        if (item.value === state.defaultSelect) {
          item.isSelected = true
        } else {
          item.isSelected = false
        }
      }
      // this.stream = this.$store.state.memberMap[this.$neMeeting.avRoomUid] && this.$store.state.memberMap[this.$neMeeting.avRoomUid].stream;
      this.stream = await this.$neMeeting.getCameraStram(
        this.$store.state.cameraId
      )

      this.localAudioPercent = Math.round(
        (this.$neMeeting.getAudioLevel() as any) * 100
      )
    },
    handlePercentChange(percent, type) {
      //TODO 调整扬声器麦克风输出音量 1麦克风2扬声器
      console.log('调整后音量结果', percent, type)
      switch (type) {
        case 1:
          this.$neMeeting.setCaptureVolume(percent)
          break
        default:
          break
      }
    },
    async handleSelectDevice(e, type) {
      const { value } = e.target
      const { commit } = this.$store
      try {
        switch (
          type // 1 麦克风 2 扬声器 3 视频源
        ) {
          case 1:
            commit('setMicrophoneId', value)
            this.$neMeeting.changeLocalAudio(value)
            break
          case 2:
            commit('setSpeakerId', value)
            this.$neMeeting.selectSpeakers(value)
            break
          case 3:
            commit('setCameraId', value)
            // this.$neMeeting.changeLocalVideo(value);
            this.stream = await this.$neMeeting.getCameraStram(value)
            break
          default:
            break
        }
      } catch (error) {
        console.error(error)
      }
    },
    setSrcObject(srcObject) {
      /*console.log('uid: ', this.uid)*/
      const video: HTMLVideoElement = this.$refs.video as HTMLVideoElement
      if (video && srcObject) {
        //console.warn('开始播放视频');
        video.srcObject = srcObject
        video
          .play()
          .then(() => {
            timeStatistics('入会成功-视频首帧展示时间')
          })
          .catch((e) => {
            console.error('视频播放失败: ', e)
          })
      } else {
        // 修复对端无摄像头麦克风入会后，本地显示对端的画面
        video && (video.srcObject = null)
      }
    },
  },
  computed: {
    currentSelect(): string {
      // 计算，当前选中组件
      let result = ''
      for (const item of this.settingList) {
        if (item.isSelected) {
          result = item.value
          break
        }
      }
      return result || 'noraml'
    },
    cameraDevicesList(): any[] {
      return this.$store.state.videoDevicesList
    },
  },
})
</script>
<style lang="stylus">
btnColor = #337EFF
.setting-content
  background #fff
  display flex
  justify-content space-between
  width 800px
  &-aside
    width 160px
    height 500px
    box-sizing border-box
    border-right 1px solid #EBEDF0;
    .aslide-list li
      height h = 50px
      line-height 50px
      text-align left
      text-indent 25px
      font-size 14px
      .icon
        color: #C5C8CD;
        font-size: 14px
      &:hover
        background: #F2F3F5
        cursor pointer
      &.current-select, &.current-select .icon
        color: btnColor;
  &-detail
    flex-grow 1
    padding 40px 37px
    text-align left
    .setting-select
      width: 320px
      padding: 8px 12px
      font-size 14px
      border: 1px solid #E1E3E6;
      border-radius: 2px;
    .setting-audio-row
      display flex
      justify-content space-between
      .setting-audio-col
        &1
          width 85px
          font-size: 16px;
          color: #333333;
        &2
          text-align left
          flex-grow 1
          button
            background: btnColor;
            border: 1px solid btnColor;
            border-radius: 18px;
            padding: 6px 20px
            color: #fff
            margin 0 0 0 5px
            &:hover
              cursor pointer
            &:active
              opacity 0.8
            &[disabled]
              cursor not-allowed
              opacity 0.7
          .setting-select-outer
            margin 0 0 10px
          .setting-slider-outer
            margin 10px 0
          .mgt20
            margin-top: 20px;
            display inline-block
          .v-progress
            display inline-block
            margin 0 5px 0 0
            vertical-align 5%
</style>
