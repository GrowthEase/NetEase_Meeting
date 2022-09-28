<template>
  <div class="setting-in-bar">
    <ul v-if="devicesType === 1">
      <li>请选择扬声器</li>
      <li
        v-for="(item, index) in speakerDevicesList"
        class="setting-option"
        @click="handleSelectDevice(item, 2)"
        :key="`${item.deviceId}${index}`"
      >
        <span class="setting-label">{{ item.deviceName }}</span>
        <svg v-if="item.isSelected" class="icon" aria-hidden="true">
          <use xlink:href="#iconcheck-line-regular1x"></use>
        </svg>
      </li>
    </ul>
    <ul v-if="devicesType === 1">
      <li>请选择麦克风</li>
      <li
        v-for="(item, index) in audioDevicesList"
        class="setting-option"
        @click="handleSelectDevice(item, 1)"
        :key="`${item.deviceId}${index}`"
      >
        <span class="setting-label">{{ item.deviceName }}</span>
        <svg v-if="item.isSelected" class="icon" aria-hidden="true">
          <use xlink:href="#iconcheck-line-regular1x"></use>
        </svg>
      </li>
    </ul>
    <ul v-if="devicesType === 2">
      <li>请选择视频来源</li>
      <li
        v-for="(item, index) in videoDevicesList"
        class="setting-option"
        @click="handleSelectDevice(item, 3)"
        :key="`${item.deviceId}${index}`"
      >
        <span class="setting-label">{{ item.deviceName }}</span>
        <svg v-if="item.isSelected" class="icon" aria-hidden="true">
          <use xlink:href="#iconcheck-line-regular1x"></use>
        </svg>
      </li>
    </ul>
  </div>
</template>

<script lang="ts">
import { log } from 'debug'
import Vue from 'vue'
import { debounce } from '@/utils'

export default Vue.extend({
  name: 'SettingInBar',
  props: {
    devicesType: {
      // 1 音频 2 视频
      type: Number,
      default: 1,
    },
  },
  data() {
    return {
      audioDevicesList: [] as any[], // 麦克风
      speakerDevicesList: [] as any[], // 扬声器
      videoDevicesList: [] as any[], // 视频源
      microphoneId: '',
      cameraId: '',
      speakerId: '',
      defaultAudio: '',
      defaultSpeaker: '',
      defaultVideo: '',
    }
  },
  mounted() {
    const eventArr = ['initMicr', 'initCamera', 'initSpeaker']
    for (const item of eventArr) {
      this.$EventBus.$on(item, () => {
        this[item]()
      })
    }
    this.init()
    this.$neMeeting.on('deviceChange', async (data) => {
      this.$nextTick(() => {
        this.deviceChange()
      })
    })
    // this.addListener();
  },
  beforeMount() {
    const eventArr = ['initMicr', 'initCamera', 'initSpeaker']
    for (const item of eventArr) {
      this.$EventBus.$off(item)
    }
  },
  beforeDestroy() {
    this.$neMeeting.removeAllListeners('deviceChange')
  },
  methods: {
    async addListener() {
      this.$neMeeting.on('onCameraDeviceChanged', async (data) => {
        this.changeDevice(data, 'camera')
      })
      this.$neMeeting.on('onSpeakerDeviceChanged', async (data) => {
        console.log('onSpeakerDeviceChanged', data)
        this.changeDevice(data, 'speaker')
      })
      this.$neMeeting.on('onRecordDeviceChanged', async (data) => {
        this.changeDevice(data, 'mic')
      })
    },
    async changeDevice(data, type: 'camera' | 'mic' | 'speaker') {
      const infoMap = {
        camera: {
          dataId: 'cameraId',
          listId: 'videoDevicesList',
          storeId: 'setVideoDevicesList',
          getDeviceId: 'getCameras',
        },
        mic: {
          dataId: 'microphoneId',
          listId: 'audioDevicesList',
          storeId: 'setAudioDevicesList',
          getDeviceId: 'getMicrophones',
        },
        speaker: {
          dataId: 'speakerId',
          listId: 'speakerDevicesList',
          storeId: 'setSpeakerDevicesList',
          getDeviceId: 'getSpeakers',
        },
      }
      const selectedInfo = infoMap[type]
      if (selectedInfo) {
        if (data.state === 'CHANGED') {
          this[selectedInfo.dataId] = data.device.deviceId
          // this.resetList(this[selectedInfo.listId], this.speakerId);
        } else {
          this[selectedInfo.listId] = await this.$neMeeting[
            selectedInfo.getDeviceId
          ]
          // if(data.state === 'ACTIVE') { // 添加设备
          //   if(data.device.deviceId == 'default') { // 默认排在第一项
          //     this[selectedInfo.listId].unshift(data.device)
          //   }else {
          //     this[selectedInfo.listId].push(data.device)
          //   }
          // }else { // 拔出设备
          //   const index = this[selectedInfo.listId].findIndex(item => item.deviceId === data.device.deviceId);
          //   if(index) {
          //     this[selectedInfo.listId].splice(index, 1);
          //   }
          // }
          this.$store.commit(selectedInfo.storeId, this[selectedInfo.listId])
        }
      }
    },
    async resetList(list, value?) {
      // 重置选择状态
      if (!list) {
        return []
      }
      for (const item of list) {
        item.isSelected = false
        if (value && item.deviceId === value) {
          item.isSelected = true
        }
      }
      return list.concat([])
    },
    async handleSelectDevice(
      item,
      type,
      isDeviceChange = false,
      hasToast = true
    ) {
      const {
        commit,
        state: {
          localInfo: { audio, video, avRoomUid },
          memberMap,
        },
      } = this.$store
      try {
        if (!item.isSelected || isDeviceChange) {
          switch (
            type // 1 麦克风 2 扬声器 3 视频源
          ) {
            case 1:
              this.resetList(this.audioDevicesList)
              let preDeviceId = this.microphoneId
              this.microphoneId = item.deviceId
              commit('setMicrophoneId', item.deviceId)
              if (audio === 1 || audio === 4) {
                // 处理插入耳机后默认设备id为default ，拔出设备后默认id仍旧是default造成切换无效
                let needReOpen = false
                if (
                  this.microphoneId === preDeviceId &&
                  preDeviceId === 'default'
                ) {
                  needReOpen = true
                  await this.$neMeeting.muteLocalAudio(false)
                }
                this.$neMeeting.changeLocalAudio(item.deviceId).then(() => {
                  hasToast && this.$toast(`当前麦克风设备：${item.deviceName}`)
                })
                needReOpen &&
                  (await this.$neMeeting.unmuteLocalAudio('', false))
              }
              break
            case 2:
              this.resetList(this.speakerDevicesList)
              this.speakerId = item.deviceId
              commit('setSpeakerId', item.deviceId)
              this.$neMeeting.selectSpeakers(item.deviceId).then(() => {
                hasToast && this.$toast(`当前扬声器设备：${item.deviceName}`)
              })
              break
            case 3:
              this.resetList(this.videoDevicesList)
              this.cameraId = item.deviceId
              commit('setCameraId', item.deviceId)
              if (video === 1) {
                this.$neMeeting
                  .changeLocalVideo(item.deviceId, false)
                  .then(() => {
                    hasToast && this.$toast(`当前视频设备：${item.deviceName}`)
                  })
                  .finally(() => {
                    if (memberMap[avRoomUid]) {
                      // fix 支持人开启视频，本端确定后，切换摄像头无法重新开启bug
                      let m = memberMap[avRoomUid]
                      m = m ? Object.assign({}, m) : {}
                      m['video'] = video
                      commit('updateMember', m)
                    }
                  })
              }
              break
            default:
              break
          }
          item.isSelected = true
        }
        this.$nextTick(() => {
          document.body.click()
        })
      } catch (error) {
        console.log('handleSelectDevice: %o', error)
      }
    },
    async init(needSetId = true) {
      // setTimeout(async () => {
      await this.initMicr(needSetId)
      await this.initCamera(needSetId)
      await this.initSpeaker(needSetId)
      // }, 200)
    },
    async initMicr(needSetId?: boolean) {
      const { state, commit } = this.$store
      commit('setMicrophoneId', this.$neMeeting.microphoneId)
      needSetId && (this.microphoneId = this.$neMeeting.microphoneId)
      // if (this.microphoneId) {
      //   this.$neMeeting.changeLocalAudio(this.microphoneId);
      // }
      commit(
        'setAudioDevicesList',
        await this.resetList(await this.$neMeeting.getMicrophones())
      )
      this.$set(this, 'audioDevicesList', [])
      this.$set(
        this,
        'audioDevicesList',
        await this.resetList(state.audioDevicesList, this.microphoneId)
      )
    },
    async initCamera(needSetId) {
      const { state, commit } = this.$store
      commit('setCameraId', this.$neMeeting.cameraId)
      needSetId && (this.cameraId = this.$neMeeting.cameraId)
      // if (this.cameraId) {
      //   this.$neMeeting.changeLocalVideo(this.cameraId);
      // }
      commit(
        'setVideoDevicesList',
        await this.resetList(await this.$neMeeting.getCameras())
      )
      this.$set(
        this,
        'videoDevicesList',
        await this.resetList(state.videoDevicesList, this.cameraId)
      )
    },
    async initSpeaker(needSetId) {
      const { state, commit } = this.$store
      commit('setSpeakerId', this.$neMeeting.speakerId)
      needSetId && (this.speakerId = this.$neMeeting.speakerId)
      // if (this.speakerId) {
      //   this.$neMeeting.selectSpeaker(this.speakerId);
      // }
      commit(
        'setSpeakerDevicesList',
        await this.resetList(await this.$neMeeting.getSpeakers())
      )
      this.$set(
        this,
        'speakerDevicesList',
        await this.resetList(state.speakerDevicesList, this.speakerId)
      )
    },
    async deviceChange() {
      await this.init(false)

      const _microphones = this.audioDevicesList.filter(
        (item: any) => item.deviceId === this.microphoneId
      )
      const _speakers = this.speakerDevicesList.filter(
        (item: any) => item.deviceId === this.speakerId
      )
      const _cameras = this.videoDevicesList.filter(
        (item: any) => item.deviceId === this.cameraId
      )

      switch (this.devicesType) {
        case 1:
          if (this.audioDevicesList.length > 0) {
            if (_microphones.length <= 0) {
              this.handleSelectDevice(this.audioDevicesList[0], 1, true, false)
            } else {
              this.handleSelectDevice(_microphones[0], 1, true, false)
            }
          } else {
            this.microphoneId = ''
          }
          if (this.speakerDevicesList.length > 0) {
            if (_speakers.length <= 0) {
              this.handleSelectDevice(
                this.speakerDevicesList[0],
                2,
                true,
                false
              )
            } else {
              this.handleSelectDevice(_speakers[0], 2, true, false)
            }
          } else {
            this.speakerId = ''
          }
          break
        case 2:
          if (this.videoDevicesList.length > 0) {
            console.log('_cameras', _cameras)
            if (_cameras.length <= 0) {
              this.handleSelectDevice(this.videoDevicesList[0], 3, true, false)
            } else {
              // 笔记本关上再打开会触发自带摄像头新增事件，需要重新打开下否则会黑屏
              this.handleSelectDevice(_cameras[0], 3, true, false)
            }
          } else {
            this.cameraId = ''
          }
          break
        default:
          break
      }
    },
  },
})
</script>

<style lang="stylus" scoped>
.setting-in-bar
  width 280px!important
  padding 12px
  box-sizing content-box!important
  ul
    border-bottom 1px solid rgab(255, 255, 255, 0.7)
    &:last-child
      border-bottom none
    li
      height 32px
      line-height 32px
      // color: #fff
      font-size 14px
      &.setting-option
        opacity 0.8
        text-indent 16px
        .setting-label
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: pre;
          display inline-block
          width 216px
        .icon
          vertical-align 28%
          margin-left 20px
      &:hover
        cursor pointer
        background: rgba(0, 0, 0, 0.2);
</style>
