<template>
  <div class="v-checkbox">
    <label for="">
      <i class="v-checkbox-out">
        <svg
          :class="`icon input-check-icon ${value ? 'check' : 'nocheck'}`"
          aria-hidden="true"
        >
          <use xlink:href="#iconcheck-line-regular1x"></use>
        </svg>
      </i>
      <input
        type="checkbox"
        v-model="checkboxValue"
        @change="handleChange"
        name=""
        class="v-checkbox-input"
      />
      <slot></slot>
    </label>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'v-checkbox',
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
    this.checkboxValue = this.value
  },
  data() {
    return {
      checkboxValue: false,
    }
  },
  watch: {
    value: function (newValue) {
      this.checkboxValue = newValue
    },
  },
  methods: {
    handleChange(e) {
      e.preventDefault()
      // console.log(this.checkboxValue)
      this.$emit('update:value', this.checkboxValue)
      this.$emit('toggleChange', this.checkboxValue)
    },
  },
})
</script>

<style lang="stylus">
.v-checkbox
  position relative
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
  label
    display flex
    align-items center
  &-out
    display inline-flex
    width 15px
    height 15px
    position relative
    overflow hidden
    color #fff
    vertical-align revert
    text-align center
    box-sizing border-box
    border 1px solid #dcdfe5
    border-radius 2px
    margin: 0 4px 0 0
    .input-check-icon
      width 14px
      height 14px
      transition all .1s ease-out
    .nocheck
      visibility hidden
    .check
      background #337EFF
</style>
