<template>
  <div class="meeting-info">
    <v-popover :auto-hide="true" placement="bottom" container=".meeting-info">
      <template slot="popover">
        <div
          v-show="isShowMeetingInfo"
          class="meeting-info-wrap"
          :style="{
            background: theme.controlBarBgColor || '#fff',
          }"
        >
          <div class="info-subject-wrap">
            <p class="info-subject">{{ meetingInfo.subject }}</p>
            <div class="info-security-info">
              <img
                class="info-security-icon"
                :src="require('../assets/security.png')"
              />
              <span class="info-security-title">{{ $t('securityInfo') }}</span>
            </div>
          </div>
          <div class="info-content-wrap">
            <p v-if="meetingInfo.type === 3" class="info-content">
              <span class="info-content-title">{{ $t('inviteTime') }}</span>
              <span
                >{{ formatDate(meetingInfo.startTime) }} -
                {{ formatDate(meetingInfo.endTime) }}</span
              >
            </p>
            <p class="info-content">
              <span class="info-content-title">{{ $t('meetingId') }}</span>
              <span>{{ meetingId }}</span>
              <img
                class="copy-icon"
                @click="handleCopy(meetingId)"
                :src="require('../assets/copy.png')"
              />
            </p>
            <p class="info-content">
              <span class="info-content-title">{{ $t('host') }}</span>
              <span class="info-content-host">{{ hostName }}</span>
            </p>
            <p class="info-content" v-if="meetingInfo.password">
              <span class="info-content-title">{{
                $t('meetingPassword')
              }}</span>
              <span>{{ meetingInfo.password }}</span>
              <img
                class="copy-icon"
                @click="handleCopy(meetingInfo.password)"
                :src="require('../assets/copy.png')"
              />
            </p>
            <p
              v-if="
                meetingInfo.type === 2 &&
                meetingInfo.shortId &&
                meetingIdDisplayOptions === NEMeetingIdDisplayOptions.displayAll
              "
              class="short-id info-content"
            >
              <span class="info-content-title">{{ $t('shortMeetingId') }}</span>
              <span>{{ meetingInfo.shortId }}</span>
              <img
                class="copy-icon"
                @click="handleCopy(meetingInfo.shortId)"
                :src="require('../assets/copy.png')"
              />
            </p>
            <p class="info-content" v-if="meetingInfo.sipCid && !noSip">
              <span class="info-content-title">{{ $t('sip') }}</span>
              <span>{{ meetingInfo.sipCid }}</span>
              <img
                class="copy-icon"
                @click="handleCopy(meetingInfo.sipCid)"
                :src="require('../assets/copy.png')"
              />
            </p>
          </div>
        </div>
      </template>
      <div class="meeting-info-icon">
        <svg class="icon" @click="showMeetingInfo" aria-hidden="true">
          <use xlink:href="#icona-45"></use>
        </svg>
      </div>
    </v-popover>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { Theme } from '@/types/index'
import { formatDate, formatMeetingId, copyElementValue } from '../utils'
import { NEMeetingIdDisplayOptions } from '../libs/enum'
export default Vue.extend({
  props: {},
  data() {
    return {
      NEMeetingIdDisplayOptions,
      isShowMeetingInfo: false, // 是否显示会议信息
    }
  },
  computed: {
    meetingInfo(): any {
      return this.$store.state.meetingInfo
    },
    meetingIdDisplayOptions(): number {
      return this.$store.state.localInfo.meetingIdDisplayOptions
    },
    theme(): Theme {
      return this.$store.state.theme
    },
    noSip(): boolean {
      return this.$store.state.noSip
    },
    hostName(): string {
      const memberMap = this.$store.state.memberMap
      const hostId: number = this.meetingInfo.hostAvRoomUid
      if (memberMap[hostId]) {
        return memberMap[hostId].nickName || '-'
      } else {
        return ''
      }
    },
    meetingId(): string {
      let result = ''
      const {
        state: { localInfo, meetingId, meetingInfo },
      } = this.$store
      switch (localInfo.meetingIdDisplayOptions) {
        case NEMeetingIdDisplayOptions.displayAll:
          result = meetingId.toString()
          break
        case NEMeetingIdDisplayOptions.displayLongId:
          result = meetingId.toString()
          break
        case NEMeetingIdDisplayOptions.displayShortId:
          result =
            meetingInfo?.shortId && meetingInfo.shortId !== 0
              ? meetingInfo.shortId.toString()
              : meetingId.toString()
          break
        default:
          break
      }
      return formatMeetingId(result || '')
    },
  },
  methods: {
    formatDate,
    handleCopy(value) {
      copyElementValue(value, () => {
        this.$toast(this.$t('copySuccess'))
      })
    },
    showMeetingInfo() {
      // 显示会议信息
      this.isShowMeetingInfo = true
    },
  },
})
</script>

<style lang="stylus" scoped>
.meeting-info
  z-index 14000
  >>> .tooltip
    left 20px!important
    color: #000
    .wrapper
      min-width 350px!important
.meeting-info-wrap
  border-radius: 8px;
  text-align: left;
  padding: 25px 25px;
  max-width: 550px;
.info-subject-wrap
  border-bottom: 1px solid #b3b4b53d
  padding-bottom: 10px
.info-subject
  font-size: 18px
  font-weight: bold
  display: inline-block
  max-width 500px
.info-security-info
  display: flex;
  align-items: center;
.info-security-icon
  transform: scale(0.5)
  margin-left: -3px
.info-security-title
  font-size: 12px
  color: #B3B4B5
.info-content-wrap
  padding-top: 10px
.info-content
  display: flex
  align-items: center
  font-size: 14px
  padding: 8px 0
.info-content-title
  color: #B3B4B5
  min-width 112px
  margin-right: 10px
.copy-icon
  width: 14px
  height: 14px
  cursor: pointer
  margin-left: 5px
.meeting-info-icon
  margin-left: 5px
  color: #fff
  cursor: pointer
.info-content-host
  display: inline-block
  white-space nowrap
  text-overflow ellipsis
  overflow hidden
  max-width 500px
</style>
