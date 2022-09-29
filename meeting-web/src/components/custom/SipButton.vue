<template>
  <div class="invite">
    <div
      class="button"
      @click="
        () => {
          hideAllControlDialog()
          handleClick()
        }
      "
    >
      <div class="setting-icon">
        <template v-if="btnInfo.btnConfig && btnInfo.btnConfig.icon">
          <img class="custom-icon" :src="btnInfo.btnConfig.icon" alt="" />
        </template>
        <template v-else>
          <svg class="icon" aria-hidden="true">
            <use xlink:href="#iconSIP"></use>
          </svg>
        </template>
        <div class="custom-text" v-if="btnInfo.btnConfig">
          {{ btnInfo.btnConfig.text || $t('sipBtn') }}
        </div>
        <div v-else>{{ $t('sipBtn') }}</div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import './button.styl'
import { NEMenuIDs } from '../../libs/enum'

export default Vue.extend({
  name: 'sip-button',
  data() {
    return {
      NEMenuIDs,
    }
  },
  props: {
    inviteVisible: {
      type: Boolean,
      default: false,
    },
    btnInfo: {
      type: Object,
      required: true,
    },
    hideAllControlDialog: {
      type: Function,
    },
  },
  methods: {
    handleClick() {
      this.$emit('sipClick', true)
    },
  },
})
</script>

<style lang="stylus"></style>
