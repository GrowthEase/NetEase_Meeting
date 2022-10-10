<template>
  <div class="v-mask" v-if="visible">
    <p v-if="msg">
      <i ref="loading" class="loading"></i>
      {{ msg }}
    </p>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import lottie from 'lottie-web'
import loadingJSON from '../../assets/loading.json'

export default Vue.extend({
  name: 'VMask',
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    msg: {
      type: String,
      default: '请稍候···',
    },
  },
  mounted() {
    lottie.loadAnimation({
      container: this.$refs.loading as Element,
      renderer: 'svg',
      loop: true,
      autoplay: true,
      animationData: loadingJSON,
    })
    lottie.play()
  },
})
</script>

<style lang="stylus">
.v-mask
  position fixed
  top 0
  right 0
  bottom 0
  left 0
  background rgba(0, 0, 0, .2)
  z-index 2101
  display flex
  flex-direction column
  justify-content center
  align-items center
  p
    width 360px
    height 80px
    line-height 80px
    text-align center
    font-size: 14px;
    color: #337EFF;
    background #fff
    border-radius 8px
    box-shadow 0 10px 40px 0 rgba(23,23,26,0.20);
    display flex
    align-items center
    justify-content center
    i.loading
      display inline-block
      height 22px
      width 22px
      margin 0 2px 0 0
      svg
        display block
</style>
