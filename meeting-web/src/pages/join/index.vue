<template>
  <div class="join-meeting">
    <section class="join-meeting-content">
      <h3 class="title">加入会议</h3>
      <v-form
        ref="joinMeeting"
        :model="joinInfo"
        :rules="rules"
        class="join-meeting-form"
      >
        <v-form-item prop="meetingId">
          <label for="">
            <input
              ref="meetingId"
              @focus="showMeetingId = false"
              @blur="showMeetingId = true"
              @input="resetMeetingId"
              class="input-box"
              v-model="joinInfo.meetingId"
              placeholder="请输入会议室ID"
              maxlength="13"
            />
            <p
              class="meetingid-by-foramt"
              @click="$refs.meetingId.focus()"
              v-if="showMeetingId && meetingIdByFormat"
            >
              {{ meetingIdByFormat }}
            </p>
            <svg
              v-if="joinInfo.meetingId && joinInfo.meetingId.length > 0"
              @click="() => handleClose('meetingId')"
              class="icon input-close-icon"
              aria-hidden="true"
            >
              <use xlink:href="#iconcross"></use>
            </svg>
          </label>
        </v-form-item>
        <v-form-item prop="nickName">
          <label for="">
            <input
              class="input-box"
              type="text"
              v-model="joinInfo.nickName"
              @input="resetNickName"
              maxlength="20"
              placeholder="请输入昵称"
            />
            <svg
              v-if="joinInfo.nickName && joinInfo.nickName.length > 0"
              @click="() => handleClose('nickName')"
              class="icon input-close-icon"
              aria-hidden="true"
            >
              <use xlink:href="#iconcross"></use>
            </svg>
          </label>
        </v-form-item>
        <v-form-item>
          <v-check-box :value.sync="joinInfo.video"
            >入会时打开摄像头</v-check-box
          >
        </v-form-item>
        <v-form-item>
          <v-check-box :value.sync="joinInfo.audio"
            >入会时打开麦克风</v-check-box
          >
        </v-form-item>
        <v-form-item>
          <input
            :class="`submit-join ${
              joinInfo.meetingId.length < 4 && 'disabled'
            }`"
            type="submit"
            @click="joinMeeting"
            value="加入会议"
          />
          <p class="download-info">
            <span>下载</span>
            <a class="download" href="//yunxin.163.com/meeting" target="_blank"
              >网易会议客户端</a
            >
            <span>，获取更佳体验</span>
          </p>
        </v-form-item>
      </v-form>
    </section>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { formatMeetingId, getLocalInfo } from '../../utils'

export default Vue.extend({
  name: 'join-meeting',
  data() {
    return {
      joinInfo: {
        meetingId: '',
        nickName: '',
        video: false,
        audio: true,
      },
      rules: {
        meetingId: [
          { required: true, message: '请输入会议ID' },
          { min: 4, max: 13, message: '请输入正确的会议ID' },
        ],
        nickName: [
          { required: true, message: '请输入昵称' },
          {
            validator: (rules, value) => {
              const errors: Array<any> = []
              let finalLen = 0
              if (/([\u4E00-\u9FA5]{1,})/.test(value)) {
                finalLen += value.match(/([\u4E00-\u9FA5]{1,})/)[0].length * 2
              }
              if (/([A-Za-z0-9]{1,})/.test(value)) {
                finalLen += value.match(/([A-Za-z0-9]{1,})/)[0].length
              }
              if (finalLen > 20) {
                errors.push(
                  new Error('格式不正确（不支持超过10位中文或20位英文和数字）')
                )
              }
              return errors
            },
          },
          // { pattern: /(^[\u4E00-\u9FA5]{1,10})|(^[A-Za-z0-9]{1,20})/, message: '请输入正确格式昵称' }
        ],
      },
      showMeetingId: false,
    }
  },
  computed: {
    form(): Vue & { validate: (errors?) => any } {
      return this.$refs.joinMeeting as Vue & { validate: (errors?) => boolean }
    },
    meetingIdByFormat(): string {
      return formatMeetingId(
        (this.joinInfo.meetingId && this.joinInfo.meetingId.toString()) || ''
      )
      // const v = this.joinInfo.meetingId.toString() || '';
      // return v ? v.slice(0, 3) + '-' + v.slice(3, 6) + '-' + v.slice(6) : ''
    },
  },
  mounted() {
    this.$nextTick(() => {
      if (this.meetingIdByFormat) {
        this.showMeetingId = true
      }
    })
    const { meetingId, nickName, video, audio } = this.joinInfo
    this.$set(
      this.joinInfo,
      'meetingId',
      getLocalInfo('joinInfo', 'meetingId') || meetingId
    )
    this.$set(
      this.joinInfo,
      'nickName',
      getLocalInfo('joinInfo', 'nickName') || nickName
    )
    this.$set(
      this.joinInfo,
      'video',
      getLocalInfo('joinInfo', 'video') || video
    )
    this.$set(
      this.joinInfo,
      'audio',
      getLocalInfo('joinInfo', 'audio') || audio
    )
  },
  methods: {
    handleClose(name) {
      this.joinInfo[name] = ''
    },
    resetMeetingId({ target }) {
      // (/([^0-9])([^-])/ig, '')
      this.joinInfo.meetingId = target.value.replace(/[\D]/g, '').slice(0, 20)
    },
    resetNickName({ target }) {
      let chLen = this.matchChValueLen(target.value) / 2
      if (chLen > 10) chLen = 10
      this.joinInfo.nickName = target.value.slice(0, 20 - chLen)
    },
    joinMeeting(e) {
      e.preventDefault()
      if (this.joinInfo.meetingId.length < 4) {
        return false
      }
      localStorage.setItem('joinInfo', JSON.stringify(this.joinInfo))
      const { commit } = this.$store
      this.form.validate((errors) => {
        if (errors) {
          return false
        }
        commit('setWebsiteJoinInfo', {
          audio: this.joinInfo.audio ? 1 : 2,
          video: this.joinInfo.video ? 1 : 2,
        })
        this.$router.push({
          name: 'meeting',
          params: {
            meetingId: this.joinInfo.meetingId,
          },
          query: {
            nickName: this.joinInfo.nickName,
          },
        })
      })
    },
    matchChValueLen(value) {
      // 返回字符串长度
      let finalLen = 0
      if (/([\u4E00-\u9FA5]{1,})/.test(value)) {
        finalLen += value.match(/([\u4E00-\u9FA5]{1,})/)[0].length * 2
      }
      return finalLen
    },
  },
})
</script>

<style lang="stylus">
.join-meeting
  height 100%
  display flex
  justify-content center
  align-items center
  .join-meeting-content
    width 320px
    padding 80px 70px
    border-radius 5px
    box-shadow: 0 10px 30px 0 rgba(47,56,111,0.10);
    flex-grow 0
    flex-direction column
    .title
      text-align center
      font-size 24px
      color #333333
    .join-meeting-form
      margin 24px 0 0
      label
        width 100%
        position relative
        .input-close-icon
          background: rgba(60,60,67,0.60);
          width 12px
          height 12px
          padding 3px
          border-radius 50%
          color #ffffff
          cursor pointer
          position absolute
          right 0
          top 30%
        .input-box
          width 100%
          background #ffffff
          border-style none none solid none
          border-width 1px
          border-color #DCDFE5
          padding 11px 11px 11px 0
          font-size 17px
          &:focus
            border-color #337EFF
            color #337EFF
        .meetingid-by-foramt
          position absolute
          top 0
          left 0
          font-size 17px
          padding 9px 11px 9px 0
          background #fff
      .submit-join
        background: #337EFF;
        border-radius: 25px;
        width 100%
        height 50px
        color #ffffff
        cursor pointer
        border none
        &.disabled
          opacity  .7
          cursor not-allowed
        &:active
          opacity  .8
      .download-info
        text-align center
        width 100%
        margin 12px 0 0
        letter-spacing 0
        a.download
          color #337EFF
</style>
