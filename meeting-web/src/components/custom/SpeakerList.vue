<template>
  <div class="speaker-list-wrap" @click="handleClick">
    <div class="speaker-list-mic">
      <svg class="icon speaker-icon" aria-hidden="true">
        <use xlink:href="#iconyx-tv-voice-onx"></use>
      </svg>
    </div>
    <span class="speaker-title">正在说话：</span>
    <span class="speaker-info" :title="speakerStr">{{ speakerStr }}</span>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { Speaker } from '@/types/type'

export default Vue.extend({
  name: 'SpeakerList',
  props: {
    speakerList: {
      default: [],
    },
  },
  methods: {
    handleClick() {
      this.$emit('handleClick')
    },
  },
  computed: {
    speakerStr(): string {
      let str = ''
      ;(this.speakerList as Speaker[]).forEach((speaker, index) => {
        str += (index > 0 ? '、' : '') + speaker.nickName
      })
      return str
    },
  },
})
</script>

<style scoped lang="stylus">
.speaker-list-wrap
  height 35px
  width 216px
  background linear-gradient(180deg, #33333F 0%, #292933 100%)
  color #fff
  position absolute
  right 0
  top: 51px
  z-index: 11
  display flex
  justify-content left
  align-items center
  transition right 0.3s
  cursor pointer
  font-size 14px
.speaker-list-mic
  width 20px
.speaker-list-hide
  right -195px
.speaker-info
  display: inline-block
  white-space nowrap
  text-align left
  text-overflow ellipsis
  overflow hidden
  max-width 120px
.speaker-title
  font-size 14px
</style>
