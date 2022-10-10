<template>
  <div class="v-switch">
    <div :class="`v-switch-out ${value ? 'on' : 'off'}`">
      <input
        tabindex="-1"
        type="checkbox"
        v-model="switchValue"
        @change="handleChange"
        name=""
        class="v-switch-input"
      />
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'v-switch',
  props: {
    value: {
      type: Boolean,
      default: false,
    },
    toggleChange: {
      type: Function,
      default: () => {
        return true
      },
    },
  },
  mounted() {
    this.switchValue = this.value
  },
  data() {
    return {
      switchValue: false,
    }
  },
  watch: {
    value: function (newValue) {
      this.switchValue = newValue
    },
  },
  methods: {
    handleChange(e) {
      e.preventDefault()
      console.log(this.switchValue)
      this.$emit('update:value', this.switchValue)
      this.$emit('toggleChange', this.switchValue)
    },
  },
})
</script>

<style lang="stylus">
.v-switch
  position relative
  width 42px
  height 25px
  display inline-block
  vertical-align text-bottom
  input[type='checkbox']
    position absolute
    top 0
    right 0
    bottom 0
    left 0
    background #000
    opacity 0
    width 100%
    height 100%
    cursor pointer
  &-out
    height inherit
    border-radius 20px
    position relative
    &:before
      content ''
      position absolute
      width 21px
      height 21px
      top 2px
      right: 2px
      transition all .3s ease-out
      background: #ffffff
      border-radius 50%
    &.on
      background #337EFF
      &:before
        right 2px
    &.off
      background #999
      &:before
        right: calc(100% - 23px)
</style>
