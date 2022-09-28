
<template>
  <div class="gallery-btn">
    <div class="button" @click="changeLayout">
      <div class="setting-icon">
        <template v-if="btnInfo.btnConfig">
          <template v-if="btnInfo.btnConfig[0].icon">
            <img
              class="custom-icon"
              v-if="$store.state.layout === 'speaker'"
              :src="btnInfo.btnConfig[0].icon"
              alt=""
            />
          </template>
          <template v-else>
            <svg
              v-if="$store.state.layout === 'speaker'"
              class="icon"
              aria-hidden="true"
            >
              <use xlink:href="#iconyx-tv-layout-bx"></use>
            </svg>
          </template>
          <template v-if="btnInfo.btnConfig[1].icon">
            <img
              class="custom-icon"
              v-if="$store.state.layout === 'gallery'"
              :src="btnInfo.btnConfig[1].icon"
              alt=""
            />
          </template>
          <template v-else>
            <svg
              v-if="$store.state.layout === 'gallery'"
              class="icon"
              aria-hidden="true"
            >
              <use xlink:href="#iconyx-tv-layout-ax"></use>
            </svg>
          </template>
        </template>
        <template v-else>
          <svg
            v-if="$store.state.layout === 'speaker'"
            class="icon"
            aria-hidden="true"
          >
            <use xlink:href="#iconyx-tv-layout-bx"></use>
          </svg>
          <svg
            v-else-if="$store.state.layout === 'gallery'"
            class="icon"
            aria-hidden="true"
          >
            <use xlink:href="#iconyx-tv-layout-ax"></use>
          </svg>
        </template>
        <div v-if="btnInfo.btnConfig" class="custom-text">
          {{
            this.$store.state.layout === 'speaker'
              ? btnInfo.btnConfig[0].text || $t('galleryalBtn')
              : btnInfo.btnConfig[1].text || $t('galleryalBtn')
          }}
        </div>
        <div v-else>{{ $t('galleryalBtn') }}</div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import './button.styl'
import { NEMenuIDs, shareMode } from '../../libs/enum'

export default Vue.extend({
  name: 'galleryBtn',
  data() {
    return {
      NEMenuIDs,
    }
  },
  props: {
    btnInfo: {
      type: Object,
      required: true,
    },
  },
  methods: {
    changeLayout() {
      if (this.hasScreenShare) {
        this.$toast('共享屏幕时暂不支持切换视图')
        return false
      }
      if (this.hasWhiteBoardShare) {
        this.$toast('共享白板时暂不支持切换视图')
        return false
      }
      if (
        this.$store.state.memberIdVideoList &&
        this.$store.state.memberIdVideoList.length > 1
      ) {
        this.$store.commit('toggleLayout')
        console.log('更改视图模式为', this.$store.state.layout)
      }
    },
  },
  computed: {
    hasScreenShare(): boolean {

      return this.$store.state.meetingInfo.shareMode === shareMode.screen
    },
    hasWhiteBoardShare(): boolean {

      return this.$store.state.meetingInfo.shareMode === shareMode.whiteboard
    },
  },
})
</script>

<style lang="stylus" scoped>
// .gallery-btn
</style>
