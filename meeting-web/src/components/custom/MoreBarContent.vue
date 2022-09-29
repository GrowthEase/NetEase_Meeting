
<template>
  <div class="more-bar-content">
    <div class="button-box">
      <template v-for="item in moreBarList">
        <div :key="item.id" class="button-list">
          <ScreenShareButton
            :btnInfo="item"
            v-if="
              item.id === NEMenuIDs.screenShare && btnVisibile(item.visibility)
            "
          />
          <GalleryButton
            :btnInfo="item"
            v-else-if="
              item.id === NEMenuIDs.gallery && btnVisibile(item.visibility)
            "
          />
          <InviteButton
            :hideAllControlDialog="hideAllControlDialog"
            :btnInfo="item"
            v-else-if="
              item.id === NEMenuIDs.invite && btnVisibile(item.visibility)
            "
            @inviteVisibleChange="inviteVisibleChange"
          />
          <WhiteBoardShareButton
            :btnInfo="item"
            v-else-if="
              item.id === NEMenuIDs.whiteBoard && btnVisibile(item.visibility)
            "
          />
          <SipButton
            :hideAllControlDialog="hideAllControlDialog"
            @sipClick="onSipClick"
            :btnInfo="item"
            v-else-if="
              item.id === NEMenuIDs.sip &&
              btnVisibile(item.visibility) &&
              !noSip &&
              sipCid
            "
          />
          <CustomButton
            :btnInfo="item"
            v-if="
              !Object.values(NEMenuIDs).includes(item.id) &&
              btnVisibile(item.visibility)
            "
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { NEMenuIDs, NEMenuVisibility, RoleType } from '../../libs/enum'
import GalleryButton from './GalleryButton.vue'
import ScreenShareButton from './ScreenShareButton.vue'
import CustomButton from './CustomButton.vue'
import InviteButton from './InviteButton.vue'
import WhiteBoardShareButton from './WhiteBoardShareButton.vue'
import SipButton from '@/components/custom/SipButton.vue'

export default Vue.extend({
  name: 'moreBarContent',
  props: {
    moreBarList: {
      type: Array,
      required: true,
      default: () => [],
    },
    hideAllControlDialog: {
      type: Function,
    },
    inviteVisible: {
      type: Boolean,
    },
  },
  data() {
    return {
      NEMenuIDs,
    }
  },
  components: {
    SipButton,
    GalleryButton,
    ScreenShareButton,
    CustomButton,
    InviteButton,
    WhiteBoardShareButton,
  },
  methods: {
    btnVisibile(visibility = 0) {
      let result = false
      switch (true) {
        case NEMenuVisibility.VISIBLE_ALWAYS === visibility:
          result = true
          break
        case NEMenuVisibility.VISIBLE_EXCLUDE_HOST === visibility &&
          this.isHost:
          result = true
          break
        case NEMenuVisibility.VISIBLE_TO_HOST_ONLY === visibility &&
          !this.isHost:
          result = true
          break
        default:
          break
      }
      return result
    },
    inviteVisibleChange(val) {
      // 暂时兼容一下，后续改造为状态通信
      this.$emit('update:inviteVisible', val)
    },
    onSipClick() {
      this.$emit('moreClick', { type: 'sip' })
    },
  },
  computed: {
    isPresenter(): boolean {
      const result = this.$store.state.localInfo.role
      return result === 'host'
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
    isCoHost(): boolean {
      return this.localInfo.roleType === RoleType.coHost
    },
    isHost(): boolean {
      // 是否为主持人或者联席主持人
      return this.isCoHost || this.isPresenter
    },
    noSip(): boolean {
      return this.$store.state.noSip
    },
    sipCid(): string {
      return this.$store.state.meetingInfo.sipCid
    },
  },
})
</script>

<style lang="stylus" scoped>
.more-bar-content
  font-size 12px
  padding 12px
  .button-box
    // margin 0 auto
    display flex
    justify-content center
    align-items center
    max-width 380px
    flex-wrap wrap
    .button-list
      display flex
      justify-content center
      align-items center
      margin 10px 0
</style>
