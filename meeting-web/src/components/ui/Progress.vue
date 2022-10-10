<template>
  <div class="v-progress">
    <div class="v-progress-outer" :style="setProgressBgStyle" ref="progress">
      <div class="v-progress-inner" :style="setProgressStyle"></div>
      <div
        v-if="showSlider"
        class="v-progress-slider"
        ref="slider"
        :style="setSliderStyle"
      ></div>
    </div>
    <span v-if="showPerText">{{ tempPercent }}%</span>
  </div>
</template>

<script>
// 使用了element的颜色
const colorTable = {
  success: '#13ce66',
  fail: '#ff4949',
  warning: '#e6a23c',
  default: '#409EFF',
}
export default {
  name: 'VProgress',
  props: {
    percent: {
      type: Number,
      default: 60,
    },
    showSlider: {
      type: Boolean,
      default: true,
    },
    showPerText: {
      type: Boolean,
      default: false,
    },
    // 进度条的宽度
    width: {
      type: Number,
      default: 300,
    },
    bgColor: {
      type: String,
      default: '#ebeef5',
    },
    progressColor: {
      type: String,
      default: '#409EFF',
    },
    // 滑块的宽度
    sliderWidth: {
      type: Number,
      default: 14,
    },
    // 颜色的类型
    type: {
      type: String,
      default: colorTable.default,
    },
  },
  data() {
    return {
      sliderLeft: 0, // 滑块相对父元素发x坐标
      progressWidth: 0, // 进度条当前的的宽度
      tempPercent: 0,
      timeOut: null,
    }
  },
  computed: {
    // 设置进度条的背景样式
    setProgressBgStyle() {
      return {
        // 加上滑块的宽度
        width: `${this.width + this.sliderWidth}px`,
        height: `${this.showSlider ? 4 : 8}px`,
      }
    },
    // 设置进度条的样式
    setProgressStyle() {
      const color = colorTable[this.type] || this.progressColor
      return {
        height: `${this.showSlider ? 4 : 8}px`,
        width: `${this.progressWidth}px`,
        background: color,
      }
    },
    // 设置滑块的样式
    setSliderStyle() {
      const color = colorTable[this.type] || this.progressColor
      return {
        border: `1px solid ${color}`,
        width: `${this.sliderWidth}px`,
        height: `${this.sliderWidth}px`,
        left: `${this.sliderLeft}px`,
      }
    },
  },
  mounted() {
    this.sliderLeft = (this.width / 100) * this.percent
    this.progressWidth = this.sliderLeft + this.sliderWidth // 滑块的x坐标加上滑块的宽度
    this.tempPercent = this.percent
    this.addListener()
  },
  methods: {
    addListener() {
      const slider = this.$refs.slider
      const progress = this.$refs.progress
      let isClickSlider = false
      let distance = 0 // 滑块与点击坐标的绝对距离
      if (!slider || !progress) {
        return
      }
      progress.onclick = (e) => {
        // 阻止事件冒泡
        if (e.target == slider) {
          return
        }
        const curX = progress.offsetLeft
        this.sliderLeft = e.pageX - curX
        if (this.sliderLeft <= 0) {
          this.sliderLeft = 0
        }
        if (this.sliderLeft >= this.width) {
          this.sliderLeft = this.width
        }
        this._countCurPercent()
      }
      slider.onmousedown = (e) => {
        isClickSlider = true
        const curX = slider.offsetLeft
        distance = e.pageX - curX // 得出绝对距离
      }

      slider.onmousemove = (e) => {
        document.onmousemove = (e) => {
          if (isClickSlider) {
            // 判断是否已经超出进度条的长度
            if (
              e.pageX - distance >= 0 &&
              e.pageX - distance <= this.width - 0
            ) {
              this.sliderLeft = e.pageX - distance
              this._countCurPercent()
            }
          }
        }
      }
      slider.onmouseup = () => {
        isClickSlider = false
      }
      document.onmouseup = () => {
        isClickSlider = false
        document.onmousemove = null
      }
    },
    // 算出百分比
    _countCurPercent() {
      this.tempPercent = Math.ceil(
        parseInt((this.sliderLeft / this.width) * 100)
      )
      this.progressWidth = this.sliderLeft
      // 取整的时候宽度可能不为0，所以在0和100的时候也将宽度取整
      if (this.tempPercent <= 0) {
        this.progressWidth = 0
        this.sliderLeft = 0
      }
      if (this.tempPercent >= 100) {
        this.progressWidth = this.width
        this.sliderLeft = this.width
      }
      if (this.timeOut) {
        clearTimeout(this.timeOut)
      }
      this.timeOut = setTimeout(() => {
        this.$emit('percentChange', this.tempPercent)
      }, 300)
    },
  },
}
</script>

<style lang="stylus">
.v-progress
  $width = 300px
  $radius = 5px
  display: flex
  align-items: center

  span
    margin-left: 5px
    font-size: 14px
    color: #666


  .v-progress-outer
    width: $width
    height: 10px
    border-radius: $radius
    background: #ebeef5
    position: relative
    display: flex
    align-items: center

    .v-progress-inner
      width: 100px
      height: 10px
      background: #409EFF
      border-radius: $radius


    .v-progress-slider
      width: 14px
      height: 14px
      border-radius: 50%
      background: #fff
      border: 1px solid #409EFF
      position: absolute
      z-index: 10
      left: 10px
      cursor pointer
</style>
