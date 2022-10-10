<template>
  <div ref="chatroom" class="chatroom-wrapper" :style="showStyle"></div>
</template>
<script lang="ts">
import Vue from 'vue'
import { render, unmountComponentAtNode, ChatroomHelper } from '@xkit-yx/kit-chatroom-web'
import '@xkit-yx/kit-chatroom-web/es/Chatroom/style/index.css'
// @ts-ignore
import { Logger } from '@/libs/3rd/Logger'
// @ts-ignore
import { ChatroomConfig, ChatroomMember, NeMember } from "@/types";

const logger = new Logger('Components-Chatroom', true)

export default Vue.extend({
  mounted() {
    logger.debug('mounted')
    const stopPropagationFn = (e) => {
      e.stopPropagation()
    }
    if (this.$neMeeting && this.$neMeeting.imInfo) {
      render(this.$refs.chatroom as any, {
        nim: this.$neMeeting.imInfo.nim,
        chatroomController: this.$neMeeting.chatController as any,
        memberList: this.members as any,
        appKey: this.$neMeeting.imInfo.imAppKey,
        token: this.$neMeeting.imInfo.imToken,
        chatroomId: this.$neMeeting.imInfo.chatRoomId,
        account: this.$neMeeting.imInfo.imAccid,
        nickName: this.nickName,
        imPrivateConf: this.$neMeeting.NIMconf || {},
        ...this.chatroomConfig,
        onFocus: (e) => {
          if(!this.enableUnmuteBySpace) {
            return
          }
          // 获取焦点后阻止长安空格的监听事件
          document.addEventListener('keydown', this.handleFocused, true)
          document.addEventListener('keyup', this.handleFocused, true)
        },
        onBlur: (e) => {
          if(!this.enableUnmuteBySpace) {
            return
          }
          // 移除阻止长安空格的监听事件
          document.removeEventListener('keydown', this.handleFocused, true)
          document.removeEventListener('keyup', this.handleFocused, true)
        },
        onImagePreview: (visible) => {
          console.log('preview', visible)
          if (visible) {
            document.addEventListener('contextmenu', stopPropagationFn, true)
          } else {
            document.removeEventListener('contextmenu', stopPropagationFn, true)
          }
        },
        onMsg: (msgs) => {
          if (!this.$store.state.showChatroom) {
            if(msgs && msgs.length > 0) {
              this.$EventBus.$emit('newMsgs', msgs);
            }
            const filterMsgs = msgs
              .filter((item) => ['text', 'image', 'file'].includes(item.type))
              .filter((item) => Date.now() - item.time < 3000)
            if (filterMsgs.length) {
              this.$store.commit('addUnReadMsgs', filterMsgs)
            }
          }
        },
        isChangeTimePosition: true,
      })
    }
    this.$neMeeting.on('onReceiveChatroomMessages', (messages) => {
      (ChatroomHelper as any).getInstance().emit('onMessage', messages)
    })
  },

  beforeDestroy() {
    logger.debug('beforeDestroy')
    this.$neMeeting.removeAllListeners('onReceiveChatroomMessages');
    (ChatroomHelper as any).getInstance().destroy();
    unmountComponentAtNode(this.$refs.chatroom as any)
    // document.oncontextmenu = function () { return true; };
  },

  watch: {
    nickName: function (newName, oldName) {
      // 更新聊天室内本端昵称
      if((ChatroomHelper as any).getInstance().emit) {
        (ChatroomHelper as any).getInstance().emit('onMyNameChanged', newName)
      }
    },
    members: function(newMembers, oldMembers) {
      // 更新聊天室内成员列表
      if((ChatroomHelper as any).instance) {
        (ChatroomHelper as any).instance.emit('onMembersUpdate', newMembers)
      }
    }
  },
  methods: {
    handleFocused(e) {
      const keyNum = window.event ? e.keyCode :e.which;
      if(keyNum === 32) {
        e.stopPropagation()
      }
    },
  },
  computed: {
    enableUnmuteBySpace(): boolean {
      return this.$store.state.enableUnmuteBySpace
    },
    nickName(): any {
      return this.$store.state.localInfo.nickName
    },
    members(): ChatroomMember[]{
      const memberMap: Record<string, any> = this.$store.state.memberMap
      const memberList: NeMember[] = Object.values(memberMap).filter(item => {
        return item.avRoomUid != this.$store.state.localInfo.avRoomUid
      })
      return memberList.map(member => {
        return {
          tags: [],
          account: member.accountId,
          nick: member.nickName
        }
      })
    },
    chatroomConfig(): ChatroomConfig | null {
      return this.$store.state.chatroomConfig
    },
    showChatroom(): boolean {
      return this.$store.state.showChatroom
    },
    showStyle() {
      if (this.showChatroom) {
        return {
          right: 0,
        }
      } else {
        return {
          // fix 按tab建造成浏览器焦点到聊天室输入框会造成布局错乱。所以不使用right -320px 改为降低层级
          right: 0,
          visibility: 'hidden',
          zIndex: -99999,
        }
      }
    },

  },
})
</script>
<style lang="stylus">
bColor = #387AFF
.chatroom-wrapper
  position absolute
  width 320px
  top 50px
  height calc(100% - 50px)
  background #fff
  color #333333
  transition right 0.2s ease-out
  z-index 13001
.popover .more-popover
    background: #FFFFFF;
    box-shadow: 0 10px 40px 0 rgba(23,23,26,0.20);
    border-radius: 4px;
    padding 8px 0
    margin 0 20px 0 0
    ul
      li
        font-size 14px
        color #333333
        padding 6px 12px
        cursor pointer
        &:hover
          background: #F2F3F5
          color #337EFF
.ant-popover
    z-index 13002 !important
</style>
