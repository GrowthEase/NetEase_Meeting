<template>
  <div class="remaining-time-tip">
    <span>{{ text }}</span>
    <svg class="icon close-icon" aria-hidden="true" @click="onCloseHandler">
      <use xlink:href="#iconyx-pc-closex"></use>
    </svg>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

export default Vue.extend({
  name: 'RemainingTimeTip',
  props: {
    text: {
      default: '',
    },
  },
  methods: {
    onCloseHandler() {
      this.$emit('close')
    },
  },
})
</script>

<style scoped lang="stylus">
.remaining-time-tip
  display flex
  justify-content center
  align-items center
  background-color #fff5a7
  color #000
  font-size 14px
  padding 10px 20px
.close-icon
  margin-left 20px
  width 12px
  height 12px
  cursor pointer
</style>
