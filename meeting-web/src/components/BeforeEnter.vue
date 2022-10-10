<template>
  <div class="before-enter">
    <div class="enter-loading">
      <img :src="require('@/assets/beforeloading.png')" alt="" srcset="" />
      <p>
        <span>{{ $t('joiningTips') }}</span>
        <!-- <span v-if="isWebsite">网易</span> -->
      </p>
    </div>
    <!-- <div class="before-loading-hangup">
      <img @click="leave" :src="require('assets/hangup.png')" alt="" srcset="">
    </div> -->
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'BeforeEnter',
  props: {
    isWebsite: {
      type: Boolean,
    },
  },
  data() {
    return {
      timeOut: 0,
    }
  },
  methods: {
    leave() {
      console.log('离开会议', this.status)
      if (this.status === 2) {
        this.$neMeeting
          .leave(this.$store.state.localInfo.role)
          .then(() => {
            console.log('离开会议成功')
            this.$store.dispatch('resetInfo')
            if (this.$neMeeting.meetingStatus === 'login') {
              this.$store.commit('changeMeetingStatus', 1)
            } else {
              this.$store.commit('changeMeetingStatus', 0)
            }
            clearTimeout(this.timeOut)
          })
          .catch((e) => {
            console.error('离开会议失败: ', e)
          })
      } else {
        this.timeOut = setTimeout(() => {
          this.leave()
        }, 500) as any
      }
    },
  },
  computed: {
    status(): number {
      return this.$store.state.status
    },
  },
})
</script>

<style lang="stylus">
.before-enter
  height 100%
  width 100%
  padding-bottom 60px
  background-image: linear-gradient(180deg, #292933 0%, #1E1E25 100%);
  .enter-loading
    top 40%
    position relative
    text-align center
    img
      width 100px
      height 100px
    p
      margin 16px auto
      text-align center
      font-size 14px
      color #ffffff
  .before-loading-hangup
    top 66%
    position relative
    img
      width 60px
      height 60px
      cursor pointer
      &:active
        opacity 0.8
</style>
