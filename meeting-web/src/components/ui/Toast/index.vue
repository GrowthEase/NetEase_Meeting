<template>
  <transition name="toast-fade">
    <div
      :class="`v-toast ${isBottomInfo ? 'v-toast-bottom' : ''}`"
      v-if="showToast"
    >
      {{ message }}
    </div>
  </transition>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'VToast',
  data() {
    return {
      duration: 3000,
      showToast: true,
      message: '',
      isBottomInfo: false,
      seed: 0,
      onClose: () => {
        return true
      },
      toastCb: () => {
        return true
      },
    }
  },
  mounted() {
    this.close()
  },
  methods: {
    close() {
      const container = !this.isBottomInfo
        ? 'div.v-toast-container'
        : 'div.v-toast-container-bottom'
      setTimeout(() => {
        this.onClose()
        this.showToast = false
        this.toastCb()
        this.$nextTick(() => {
          const parentDom: any = document.querySelector(container)
          if (this.$el && parentDom) {
            ;(parentDom as HTMLDivElement).removeChild(this.$el)
          }
          this.$destroy()
        })
      }, this.duration)
    },
  },
  destroyed() {
    this.showToast = false
    this.onClose()
  },
})
</script>

<style lang="stylus">
.v-toast-container
  position fixed
  left 50%
  transform translateX(-50%)
  overflow hidden
  z-index 3001
  &
    max-height 330px
    top 40%
  &-bottom
    position fixed
    left 50%
    transform translateX(-50%)
    max-height 350px
    bottom 70px
    overflow hidden
    z-index 3001
.v-toast
  color #fff
  background: rgba(34,34,34,0.80);
  border-radius: 4px;
  margin 8px 0
  &
    padding: 16px 30px
    font-size 18px
  &-bottom
    padding: 8px 20px
    font-size 14px

.toast-fade-enter-active, .toast-fade-leave-active {
  transition: all .5s
}
.toast-fade-enter, .toast-fade-leave-to{
  opacity: 0
  transform translateX(-100%)
}
.toast-fade-leave, .toast-fade-enter-to{
  opacity: 1
  transform translateX(0%)
}
</style>
