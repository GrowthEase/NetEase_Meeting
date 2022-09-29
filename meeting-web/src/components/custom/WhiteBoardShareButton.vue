<template>
  <div class="white-board-share">
    <div class="button" @click="throttle(whiteBoardShare, 50)">
      <div class="setting-icon">
        <template v-if="btnInfo.btnConfig">
          <template v-if="btnInfo.btnConfig[0].icon">
            <img
              class="custom-icon"
              v-if="whiteBoard"
              :src="btnInfo.btnConfig[0].icon"
              alt=""
            />
          </template>
          <template v-else>
            <svg v-if="whiteBoard" class="icon" aria-hidden="true">
              <use xlink:href="#iconyx-baiban"></use>
            </svg>
          </template>
          <template v-if="btnInfo.btnConfig[1].icon">
            <img
              class="custom-icon"
              v-if="!whiteBoard"
              :src="btnInfo.btnConfig[1].icon"
              alt=""
            />
          </template>
          <template v-else>
            <svg v-if="!whiteBoard" class="icon" aria-hidden="true">
              <use xlink:href="#iconyx-baiban"></use>
            </svg>
          </template>
        </template>
        <template v-else>
          <svg class="icon" aria-hidden="true">
            <use xlink:href="#iconyx-baiban"></use>
          </svg>
        </template>
        <div class="custom-text" v-if="btnInfo.btnConfig">
          {{
            screen
              ? `${btnInfo.btnConfig[0].text || $t('closeWhiteBoard')}`
              : `${btnInfo.btnConfig[1].text || $t('whiteBoard')}`
          }}
        </div>
        <div v-else>
          {{ whiteBoard ? $t('closeWhiteBoard') : $t('whiteBoard') }}
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import './button.styl'
import { memberAction, shareMode } from '../../libs/enum'
import { throttle } from '@/utils'

export default Vue.extend({
  name: 'screenShareButton',
  data() {
    return {}
  },
  props: {
    btnInfo: {
      type: Object,
      required: true,
    },
  },
  methods: {
    throttle,
    whiteBoardShare(val = '') {
      // 加val是因为不知道什么原因，vue在不加默认参数的情况，代码校验异常
      if (this.whiteBoard) {
        this.$nextTick(() => {
          this.$neMeeting
            .sendMemberControl(memberAction.closeWhiteShare)
            .then(() => {
              this.whiteBoard = 0
            })
        })
        // this.$EventBus.$emit('whiteboard-logout');
      } else {
        //TODO
        if (this.hasWhiteBoardShare) {
          this.$toast('已经有人在共享，您无法共享')
          return
        }
        if (this.hasScreenShare) {
          this.$toast(this.$t('hasScreenShareShare'))
          return
        }
        if (!this.isSpeaker) {
          this.$store.commit('toggleLayout')
        }
        this.$nextTick(() => {
          this.$neMeeting
            .sendMemberControl(memberAction.openWhiteShare)
            .then(() => {
              this.whiteBoard = 1
            })
          // this.$EventBus.$emit('whiteboard-login');
        })
      }
    },
  },
  computed: {
    whiteBoard: {
      get: function () {
        return this.$store.state.localInfo.whiteBoardShare
      },
      set: function (value) {
        const { state } = this.$store
        state.localInfo.whiteBoardShare = value
      },
    },
    hasWhiteBoardShare(): boolean {
      return this.$store.state.meetingInfo.shareMode === shareMode.whiteboard
    },
    hasScreenShare(): boolean {
      const newResult = { ...this.$store.state.memberMap }
      let result = false
      for (const uid in newResult) {
        if (newResult[uid].screenSharing === 1) {
          result = true
          break
        }
      }
      return result
    },
    wbHasloaded(): boolean {
      return this.$store.state.whiteBoardHasLoaded
    },
    isSpeaker(): boolean {
      return this.$store.state.layout === 'speaker'
    },
  },
})
</script>

<style lang="stylus" scoped></style>
