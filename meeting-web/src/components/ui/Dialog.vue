<template>
  <div>
    <div
      v-if="visible"
      class="v-dialog"
      ref="vdialog"
      :style="{
        width: `${width}px`,
        top: `${top}%`,
        left: `50%`,
        height: `${typeof height === 'string' ? 'auto' : `${height}px`}`,
        marginLeft: `-${width / 2}px`,
      }"
    >
      <div class="dialog-header" v-if="needHeader">
        {{ title }}
        <svg
          @click="handleClose"
          class="icon dialog-close-icon"
          aria-hidden="true"
        >
          <use xlink:href="#iconyx-pc-closex"></use>
        </svg>
      </div>
      <div class="dialog-content">
        <slot name="dialogContent"></slot>
      </div>
      <div class="dialog-footer" v-if="needBtns">
        <slot name="dialogFooter"></slot>
      </div>
    </div>
    <VMask :visible.sync="visible" msg=""></VMask>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import VMask from './Mask.vue'

export default Vue.extend({
  name: 'VDialog',
  props: {
    visible: {
      type: Boolean,
      default: false,
      required: true,
    },
    title: {
      type: String,
      default: '提示',
    },
    needHeader: {
      type: Boolean,
      default: true,
    },
    needBtns: {
      type: Boolean,
      default: false,
    },
    okBtnMsg: {
      type: String,
      default: '确定',
    },
    cancelBtnMsg: {
      type: String,
      default: '取消',
    },
    width: {
      type: Number,
      default: 400,
    },
    height: {
      type: [Number, String],
      default: 'auto',
    },
    top: {
      type: Number,
      default: 15,
    },
  },
  components: {
    VMask,
  },
  watch: {
    visible(newValue: boolean) {
      // console.warn('newValue: ', newValue)
      this.$nextTick(() => {
        document.body.click()
      })
      if (newValue) {
        window.addEventListener('keyup', this.keyClose)
      } else {
        window.removeEventListener('keyup', this.keyClose)
      }
    },
  },
  methods: {
    handleClose() {
      this.$emit('update:visible', false)
      this.$emit('close')
    },
    keyClose(e: KeyboardEvent) {
      if (e.keyCode === 27) {
        this.handleClose()
      }
    },
  },
})
</script>

<style lang="stylus">
.v-dialog
  position fixed
  background #fff
  z-index 2201
  background: #FFFFFF
  box-shadow: 0 10px 40px 0 rgba(23,23,26,0.20)
  border-radius: 10px
  color #000
  overflow hidden
  .dialog-header
    position relative
    height h=52px
    line-height h
    font-size: 20px
    color: #333333
    text-align: center
    border-bottom 1px solid #EBEDF0
    .dialog-close-icon
      position absolute
      right 18px
      top 40%
      font-size 16px
      cursor pointer
</style>
