<template>
  <div
    id="ne-web-meeting"
    :class="`${isDev ? '' : 'normal-meeting'}`"
    :style="`height: ${height && !isWebSite ? height + 'px' : '100%'};width: ${
      width ? width + 'px' : '100%'
    }`"
    ref="neWebMeeting"
  >
    <Meeting
      :width="width"
      :height="height"
      v-if="$store.state.status === 2 || $store.state.beforeLoading"
      :isDev="isDev"
      :isWebSite="isWebSite"
    />
    <Login :isDev="isDev" :isWebSite="isWebSite" ref="login" />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import Login from './components/Login.vue'
import Meeting from './components/Meeting.vue'
// import BeforeEnter from './components/BeforeEnter.vue';
import 'antd/dist/antd.css'
import './reset.css'

export default Vue.extend({
  name: 'ne-web-meeting',
  components: {
    Login,
    Meeting,
    // BeforeEnter,
  },
  computed: {
    isDev(): boolean {
      return process.env.NODE_ENV === 'development'
    },
    isWebSite(): boolean {
      return process.env.VUE_APP_VERSION === 'website'
    },
  },
  data() {
    return {
      width: 0,
      height: 800,
    }
  },
  mounted() {
    if (!this.isDev) {
      this.$EventBus.$on('setWidth', (val) => {
        if (!Number.isNaN(Number(val))) {
          this.width = val
        } else {
          console.error('警告：width 请使用 Number 赋值')
        }
      })
      this.$EventBus.$on('setHeight', (val) => {
        if (!Number.isNaN(Number(val))) {
          this.height = val
        } else {
          console.error('警告：height 请使用 Number 赋值')
        }
      })
    }
  },
})
</script>

<style lang="stylus" scoped>
#ne-web-meeting
  font-family Avenir, Helvetica, Arial, sans-serif
  -webkit-font-smoothing antialiased
  -moz-osx-font-smoothing grayscale
  text-align center
  color #2c3e50
  position absolute
  // height 100%
  // width 100%
  background-color #494949
  //transform translateX(0%)!important
  &.normal-meeting
    position relative
html, body
  margin 0
  padding 0
</style>
