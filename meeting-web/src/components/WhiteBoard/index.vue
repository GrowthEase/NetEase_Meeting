<template>
  <div class="white-board" :style="`height: ${baseHeight}px`" @click="clickBox">
    <div class="iframe-for-whiteboard" ref="whiteBoard"></div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { Logger } from '../../libs/3rd/Logger'

const logger = new Logger('Meeting-Whiteboard', true)

export default Vue.extend({
  name: 'white-board',
  props: {
    baseHeight: {
      type: Number,
    },
    member: {},
    isWhiteBoardShare: {
      type: Boolean,
    },
  },
  async mounted() {
    await this.$neMeeting.whiteboardController.setupWhiteboardCanvas(
      this.$refs.whiteBoard as any
    )
    if (this.enableDraw) {
      this.$neMeeting.whiteboardController.setEnableDraw(true)
    } else {
      this.$neMeeting.whiteboardController.setEnableDraw(false)
    }
  },
  destroyed() {
    logger.debug('白板销毁 %t')
    this.$store.commit('updateWBLoaded', false)
    // this.$neMeeting.whiteboardController.setEnableDraw(false)
    // this.$neMeeting.whiteboardController.stopWhiteboardShare();
  },
  watch: {
    'localInfo.whiteBoardInteract': function (wbDrawable: string) {
      // 白板授权可以绘制
      if (wbDrawable == '1') {
        this.$neMeeting.whiteboardController.setEnableDraw(true)
      } else {
        this.$neMeeting.whiteboardController.setEnableDraw(false)
      }
    },
  },
  computed: {
    enableDraw(): boolean {
      // 当前本端打开共享
      const meetingInfo = this.$store.state.meetingInfo
      console.log(
        'enableDraw222',
        meetingInfo.whiteboardAvRoomUid,
        this.$neMeeting.avRoomUid
      )
      if (
        meetingInfo.whiteboardAvRoomUid &&
        meetingInfo.whiteboardAvRoomUid.length > 0
      ) {
        return meetingInfo.whiteboardAvRoomUid[0] === this.$neMeeting.avRoomUid
      }
      return false
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
  },
  methods: {
    clickBox() {
      this.$store.commit('toggleList', false)
      this.$store.commit('toggleChatroom', false)
    },
  },
})
</script>

<style lang="stylus" scoped>
.white-board
  width 100%
  .iframe-for-whiteboard
    position: relative
    width 100%
    height 100%
  >>> .tc-resize-container .tc-resize-input input
    left 0
</style>
