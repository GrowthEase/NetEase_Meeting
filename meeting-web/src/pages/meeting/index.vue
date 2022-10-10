<!--
 * @Description: 会议对外站点外层容器
-->
<template>
  <div class="meeting-content">
    <Meeting ref="meeting" v-show="showMeeting" />
    <Dialog
      :width="320"
      :top="35"
      :visible.sync="visible"
      :needBtns="true"
      @close="
        () => {
          visible = false
        }
      "
    >
      <div slot="dialogContent" class="goback-content">你确定离开会议吗？</div>
      <div slot="dialogFooter" class="goback-content-btns">
        <button class="confirm" @click="gobackOk">确定</button>
        <button class="endall" @click="visible = false">取消</button>
      </div>
    </Dialog>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import Meeting from '../../App.vue'
import Dialog from '../../components/ui/Dialog.vue'
import { getErrCode } from '../../utils'
export default Vue.extend({
  name: 'meeting-content',
  components: {
    Meeting,
    Dialog,
  },
  data() {
    return {
      showMeeting: false,
      allowBack: false,
      visible: false,
    }
  },
  mounted() {
    const {
      state: {
        websiteState: { joinInfo },
      },
    } = this.$store

    if (this.$route.params.meetingId && this.$route.query.nickName) {
      const meeting = (this.$refs.meeting as any).$refs.login as any
      meeting.joinObj = {
        obj: {
          meetingId: this.$route.params.meetingId,
          nickName: decodeURI(`${this.$route.query.nickName}`),
          ...joinInfo,
          noCloudRecord: false,
        },
        callback: (e) => {
          if (e) {
            const code = Number(getErrCode(e.message))
            if (code === 2014 || code === 2018) {
              this.showMeeting = true
              return false
            }
            this.$EventBus.$emit('beforeDestroy')
            this.allowBack = true
            setTimeout(() => {
              this.$router.push('/join')
            }, 500)
            return false
          }
          this.showMeeting = true
          return false
        },
      }
      meeting.joinMeeting()
      // this.$EventBus.$emit('join', {
      //   obj: {
      //     meetingId: this.$route.params.meetingId,
      //     nickName: this.$route.query.nickName,
      //     appKey: appkey,
      //     ...joinInfo,
      //   },
      //   callback: (e) => {
      //     if (e) {
      //       const code = Number(getErrCode(e.message));
      //       if (code === 2014 || code === 2018) {
      //         this.showMeeting = true;
      //         return false;
      //       }
      //       this.$EventBus.$emit('beforeDestroy');
      //       this.allowBack = true;
      //       setTimeout(() => {
      //         this.$router.push('/join');
      //       }, 500)
      //       return false;
      //     }
      //     this.showMeeting = true;
      //     return false;
      //   },
      // })
    } else {
      this.$toast('参数缺失')
      this.gobackOk()
      return
    }
    this.$EventBus.$emit('afterLeave', () => {
      // this.$EventBus.$emit('beforeDestroy');
      this.allowBack = true
      setTimeout(() => {
        this.$router.push('/join')
      }, 500)
    })
  },
  methods: {
    gobackOk() {
      this.allowBack = true
      this.$EventBus.$emit('beforeDestroy')
      this.$router.push('/join')
    },
  },
  beforeRouteLeave(to, from, next) {
    if (!this.allowBack) {
      this.visible = true
      next(false)
    } else {
      next()
    }
  },
})
</script>

<style lang="stylus">
.meeting-content
  height 100%
.goback-content
  padding 24px 0
  font-size 16px
  text-align center
  h3
    font-size: 18px
    margin-bottom 12px
  &-info
    padding 0 24px
    font-size 14px
.goback-content-btns
  display flex
  border-top: 1px solid #EBEDF0
  font-size 15px
  button
    flex 1
    border none
    background #fff
    border-right 1px solid #EBEDF0
    padding: 10px 0
    cursor pointer
    &:active
      opacity 0.8
    &:last-child
      border none
    &.confirm
      color #337EFF
    &.endall
      color #f00
</style>
