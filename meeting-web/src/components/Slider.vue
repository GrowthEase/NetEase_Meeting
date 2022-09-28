<template>
  <div class="slider-box-outter">
    <div class="slider-box" :style="`width: ${width}px;`">
      <div
        class="slider-wrapper"
        :style="
          'width: ' +
          finallWidth +
          'px; transform: translateX(-' +
          translateX +
          'px)'
        "
      >
        <slot></slot>
      </div>
    </div>
    <div v-if="index > 0" class="slider-button-prev" @click="index--"></div>
    <div
      v-if="index < (num - 1 || 0)"
      class="slider-button-next"
      @click="index++"
    ></div>
  </div>
</template>

<script lang="ts">
/**
 * 滑动组件
 * 使用方法
 * <slider :width="800" :num="3">
 *  <div class="slider">滑动页1</div>
 *  <div class="slider">滑动页2</div>
 *  <div class="slider">滑动页3</div>
 * </slider>
 * 其中width是slider视图宽度，num是滑动页的数量
 */
import Vue from 'vue'

export default Vue.extend({
  name: 'Slider',
  props: ['width', 'num'],
  data() {
    return {
      index: 0, // slider的当前位置
    }
  },
  created() {
    this.$on('resetIndex', (i: number) => {
      this.index = i || 0
    })
  },
  watch: {
    num: function (newValue) {
      if (this.index >= newValue) {
        this.index = newValue - 1 || 0
      }
    },
    index: function (newValue) {
      this.$emit('changeIndex', newValue)
    },
  },
  computed: {
    translateX(): number {
      return this.index * this.width
    },
    finallWidth(): number {
      return this.width * this.num
      // return this.width;
    },
  },
})
</script>
<style lang="stylus" scoped>
.slider-box-outter
  position relative
  overflow-y auto
  .slider-button-prev
    left 0
    &:before
      margin: -6px 0 0 -4px
      transform: rotate(-135deg)
  .slider-button-next
    right 0
    &:before
      margin: -6px 0 0 -8px
      transform: rotate(45deg)
.slider-box
  width 100%
  height 100%
  margin 0 auto
  overflow hidden
  .slider-wrapper
    transition: transform 0.6s ease-out 0s
    height 100%
  .slider
    display flex
    justify-content center
    float left
    height 100%
.slider-button-prev, .slider-button-next
  cursor pointer
  height h = 32px
  width h
  line-height h
  text-align center
  position absolute
  top 50%
  margin-top -(h / 2)
  border-radius 50%;
  background-image: linear-gradient(180deg, #5996FF 1%, #2575FF 100%);
  &:before
    content: ''
    position: absolute
    display inline-block
    width beforeW = 10px
    height beforeW
    border: 2px solid #ffffff
    border-style: solid solid none none
    top: 50%
    left: 50%
</style>
