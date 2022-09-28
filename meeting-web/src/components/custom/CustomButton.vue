
<template>
  <div class="custom-button">
    <div
      v-if="customData.type === 'single'"
      :class="`button ${isSmallBtn ? 'small-button' : ''}`"
      @click="customData.injectItemClick(customData)"
    >
      <div class="setting-icon">
        <img
          class="custom-icon"
          :src="customData.btnConfig.icon"
          alt=""
          srcset=""
        />
        <div v-if="!isSmallBtn" class="custom-text">
          {{ customData.btnConfig.text }}
        </div>
      </div>
    </div>
    <div
      v-else-if="customData.type === 'multiple'"
      :class="`button ${isSmallBtn ? 'small-button' : ''}`"
      @click="customData.injectItemClick(customData)"
    >
      <template v-for="(item, index) in customData.btnConfig">
        <div
          class="setting-icon"
          :key="`${item.status}${index}`"
          v-if="item.status === customData.btnStatus"
        >
          <img class="custom-icon" :src="item.icon" alt="" srcset="" />
          <div v-if="!isSmallBtn" class="custom-text">
            {{ item.text }}
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import './button.styl'
import { NEMenuIDs } from '../../libs/enum'

export default Vue.extend({
  name: 'galleryBtn',
  data() {
    return {
      NEMenuIDs,
      status: 0,
      customData: {},
    }
  },
  props: {
    btnInfo: {
      type: Object,
      required: true,
    },
    isSmallBtn: {
      type: Boolean,
      default: false,
    },
  },
  mounted() {
    this.$set(this, 'customData', this.btnInfo)
  },
})
</script>

<style lang="stylus" scoped></style>
