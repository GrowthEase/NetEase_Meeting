<template>
  <div
    class="control-bar"
    ref="controlBar"
    :style="{
      background: theme.controlBarBgColor || '',
    }"
  >
    <div class="button-box">
      <!-- <div class="button" @click="isHandsUp = !isHandsUp">展示</div> -->
      <template v-for="item in toolBarList">
        <div
          :key="item.id"
          class="button-list"
          :style="{
            color: theme.controlBarColor || '',
          }"
        >
          <div
            class="button"
            v-if="item.id === NEMenuIDs.mic && btnVisibile(item.visibility)"
            :name="`${
              audio === 1 ? 'mute-audio-byself' : 'unmute-audio-byself'
            }`"
            @click="debounce(toggleMuteAudio)"
          >
            <div
              :class="`setting-icon ${audio === 1 ? '' : 'setting-icon-close'}`"
            >
              <template v-if="item.btnConfig">
                <template v-if="item.btnConfig[0].icon">
                  <img
                    class="custom-icon"
                    v-if="audio === 1"
                    :src="item.btnConfig[0].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg v-if="audio === 1" class="icon" aria-hidden="true">
                    <use xlink:href="#iconyx-tv-voice-onx"></use>
                  </svg>
                </template>
                <template v-if="item.btnConfig[1].icon">
                  <img
                    class="custom-icon"
                    v-if="audio !== 1"
                    :src="item.btnConfig[1].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg v-if="audio !== 1" class="icon" aria-hidden="true">
                    <use xlink:href="#iconyx-tv-voice-offx"></use>
                  </svg>
                </template>
              </template>
              <template v-else>
                <svg v-if="audio === 1" class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-voice-onx"></use>
                </svg>
                <svg v-else class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-voice-offx"></use>
                </svg>
              </template>
              <div class="white custom-text" v-if="item.btnConfig">
                {{
                  audio === 1
                    ? `${item.btnConfig[0].text || $t('unMuteAudio')}`
                    : `${item.btnConfig[1].text || $t('muteAudio')}`
                }}
              </div>
              <div class="white" v-else>
                {{ audio === 1 ? $t('muteAudio') : $t('unMuteAudio') }}
              </div>
            </div>
          </div>
          <div
            class="button button-for-setting"
            v-if="item.id === NEMenuIDs.mic && btnVisibile(item.visibility)"
          >
            <v-popover
              :delay="300"
              popoverWrapperClass="setting-popover-out"
              style="display: inline-block"
              placement="top"
              @apply-hide="toggleSettingOnBar(1, false)"
            >
              <template slot="popover">
                <div class="setting-outer">
                  <SettingInBar
                    v-if="hasJoined"
                    v-show="showSoundSetting"
                    :devicesType="1"
                  />
                  <!-- <ul class="setting-enter">
                    <li @click="showDialog">音频设置</li>
                  </ul> -->
                </div>
              </template>
              <span
                @click="toggleSettingOnBar(1, true)"
                :class="`bar-setting mute-setting ${isDev ? '' : 'need-top'} ${
                  showSoundSetting && 'setting-select'
                }`"
              ></span>
            </v-popover>
          </div>
          <div
            class="button"
            :name="`${
              video === 1 ? 'mute-video-byself' : 'unmute-video-byself'
            }`"
            @click="debounce(toggleMuteVideo)"
            v-if="item.id === NEMenuIDs.camera && btnVisibile(item.visibility)"
          >
            <div
              :class="`setting-icon ${video === 1 ? '' : 'setting-icon-close'}`"
            >
              <template v-if="item.btnConfig">
                <template v-if="item.btnConfig[0].icon">
                  <img
                    class="custom-icon"
                    v-if="video === 1"
                    :src="item.btnConfig[0].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg v-if="video === 1" class="icon" aria-hidden="true">
                    <use xlink:href="#iconyx-tv-video-onx"></use>
                  </svg>
                </template>
                <template v-if="item.btnConfig[1].icon">
                  <img
                    class="custom-icon"
                    v-if="video !== 1"
                    :src="item.btnConfig[1].icon"
                    alt=""
                  />
                </template>
                <template v-else>
                  <svg v-if="video !== 1" class="icon" aria-hidden="true">
                    <use xlink:href="#iconyx-tv-video-offx"></use>
                  </svg>
                </template>
              </template>
              <template v-else>
                <svg v-if="video === 1" class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-video-onx"></use>
                </svg>
                <svg v-else class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-video-offx"></use>
                </svg>
              </template>
              <div class="white custom-text" v-if="item.btnConfig">
                {{
                  video === 1
                    ? `${item.btnConfig[0].text || $t('muteVideo')}`
                    : `${item.btnConfig[1].text || $t('unMuteVideo')}`
                }}
              </div>
              <div class="white custom-text" v-else>
                {{ video === 1 ? $t('muteVideo') : $t('unMuteVideo') }}
              </div>
            </div>
          </div>
          <div
            class="button button-for-setting"
            v-if="item.id === NEMenuIDs.camera && btnVisibile(item.visibility)"
          >
            <v-popover
              :delay="300"
              popoverWrapperClass="setting-popover-out"
              style="display: inline-block"
              placement="top"
              @apply-hide="toggleSettingOnBar(2, false)"
            >
              <template slot="popover">
                <div class="setting-outer">
                  <SettingInBar
                    v-if="hasJoined"
                    v-show="showVideoSetting"
                    :devicesType="2"
                  />
                  <ul class="setting-enter">
                    <li @click="showDialog">视频设置</li>
                  </ul>
                </div>
              </template>
              <span
                @click="toggleSettingOnBar(2, true)"
                :class="`bar-setting mute-setting ${
                  showVideoSetting && 'setting-select'
                }`"
              ></span>
            </v-popover>
          </div>
          <!-- <div
            class="button"
            @click="share"
            v-if="item.id === NEMenuIDs.screenShare">
            <div class="setting-icon">
              <template v-if="item.btnConfig">
                <img v-if="screen" :src="item.btnConfig[0].icon" alt="">
                <img v-else :src="item.btnConfig[1].icon" alt="">
              </template>
              <template v-else>
                <svg class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-sharescreen1x"></use>
                </svg>
              </template>
              <div v-if="item.btnConfig">
                {{screen ? `${item.btnConfig[0].text || '结束共享'}` : `${item.btnConfig[0].text || '共享屏幕'}`}}
              </div>
              <div v-else>{{screen ? '结束共享' : '共享屏幕'}}</div>
            </div>
          </div> -->
          <ScreenShareButton
            :btnInfo="item"
            v-if="
              item.id === NEMenuIDs.screenShare && btnVisibile(item.visibility)
            "
          />
          <WhiteBoardShareButton
            :btnInfo="item"
            v-if="
              item.id === NEMenuIDs.whiteBoard && btnVisibile(item.visibility)
            "
          />
          <InviteButton
            :btnInfo="item"
            v-if="item.id === NEMenuIDs.invite && btnVisibile(item.visibility)"
            :hideAllControlDialog="
              () => {
                hideAllControlDialog(false)
              }
            "
            @inviteVisibleChange="inviteVisible = true"
          />
          <!-- <div
            class="button"
            @click="() => {hideAllControlDialog(false);invite();}"
            v-if="item.id === NEMenuIDs.invite && btnVisibile(item.visibility)">
            <div class="setting-icon">
              <template v-if="item.btnConfig && item.btnConfig.icon">
                <img class="custom-icon" :src="item.btnConfig.icon" alt="">
              </template>
              <template v-else>
                <svg class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-invitex"></use>
                </svg>
              </template>
              <div class="custom-text" v-if="item.btnConfig">{{item.btnConfig.text || '邀请'}}</div>
              <div v-else>邀请</div>
            </div>
          </div> -->
          <v-popover
            :delay="500"
            :open="
              isHandsUp && showControlBar && !isHost && !isScreen && !isLoading
            "
            :auto-hide="false"
            trigger="manual"
            style="display: flex"
            placement="top"
            :container="false"
            popoverWrapperClass="hands-popover"
            v-if="
              !isHost &&
              (item.id === NEMenuIDs.participants ||
                item.id === NEMenuIDs.manageParticipants) &&
              btnVisibile(item.visibility)
            "
          >
            <template slot="popover">
              <div class="hands-action" @click="showCancelAudioHandsUp = true">
                <span class="hands-up-tip">
                  <svg class="icon hands-icon" aria-hidden="true">
                    <use xlink:href="#iconraisehands1x"></use>
                  </svg>
                  <span>{{ $t('inHandsUp') }}</span>
                </span>
                <span class="hands-down-tip">
                  <svg class="icon hands-icon" aria-hidden="true">
                    <use xlink:href="#iconraisehands1x"></use>
                  </svg>
                  <span>{{ $t('handsUpDown') }}</span>
                </span>
              </div>
            </template>
            <div class="button" @click="toggleList">
              <span class="member-num" v-if="memberNum > 0">{{
                memberNum
              }}</span>
              <div class="setting-icon">
                <template v-if="item.btnConfig && item.btnConfig.icon">
                  <img
                    class="custom-icon"
                    :src="item.btnConfig.icon"
                    alt=""
                    srcset=""
                  />
                </template>
                <template v-else>
                  <svg class="icon" aria-hidden="true">
                    <use xlink:href="#iconyx-tv-attendeex"></use>
                  </svg>
                </template>
                <div class="custom-text" v-if="item.btnConfig">
                  {{
                    item.btnConfig.text ||
                    (isHost
                      ? $t('memberListBtnForHost')
                      : $t('memberListBtnForNormal'))
                  }}
                </div>
                <div v-else>
                  {{
                    isHost
                      ? $t('memberListBtnForHost')
                      : $t('memberListBtnForNormal')
                  }}
                </div>
              </div>
            </div>
          </v-popover>
          <v-popover
            :delay="500"
            :open="
              audiohandsUpsNum > 0 && showControlBar && isHost && !isLoading
            "
            :auto-hide="false"
            trigger="manual"
            style="display: flex"
            placement="top"
            :container="false"
            popoverWrapperClass="hands-popover"
            v-if="
              isHost &&
              (item.id === NEMenuIDs.participants ||
                item.id === NEMenuIDs.manageParticipants) &&
              btnVisibile(item.visibility)
            "
          >
            <template slot="popover">
              <div class="hands-action no-hover">
                <span class="hands-up-tip">
                  <svg class="icon hands-icon" aria-hidden="true">
                    <use xlink:href="#iconraisehands1x"></use>
                  </svg>
                  <span>{{ audiohandsUpsNum }}</span>
                </span>
              </div>
            </template>
            <div class="button" @click="toggleList">
              <span class="member-num" v-if="memberNum > 0">{{
                memberNum
              }}</span>
              <div class="setting-icon">
                <template v-if="item.btnConfig && item.btnConfig.icon">
                  <img
                    class="custom-icon"
                    :src="item.btnConfig.icon"
                    alt=""
                    srcset=""
                  />
                </template>
                <template v-else>
                  <svg class="icon" aria-hidden="true">
                    <use xlink:href="#iconyx-tv-attendeex"></use>
                  </svg>
                </template>
                <div class="custom-text" v-if="item.btnConfig">
                  {{
                    item.btnConfig.text ||
                    (isHost
                      ? $t('memberListBtnForHost')
                      : $t('memberListBtnForNormal'))
                  }}
                </div>
                <div v-else>
                  {{
                    isHost
                      ? $t('memberListBtnForHost')
                      : $t('memberListBtnForNormal')
                  }}
                </div>
              </div>
            </div>
          </v-popover>
          <!-- <div
            class="button"
            @click="changeLayout"
            v-if="item.id === NEMenuIDs.gallery">
            <div class="setting-icon">
              <template v-if="item.btnConfig">
                <img v-if="$store.state.layout === 'speaker'" :src="item.btnConfig[0].icon" alt="">
                <img v-else-if="$store.state.layout === 'gallery'" :src="item.btnConfig[1].icon" alt="">
              </template>
              <template v-else>
                <svg v-if="$store.state.layout === 'speaker'" class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-layout-bx"></use>
                </svg>
                <svg v-else-if="$store.state.layout === 'gallery'" class="icon" aria-hidden="true">
                  <use xlink:href="#iconyx-tv-layout-ax"></use>
                </svg>
              </template>
              <div v-if="item.btnConfig">
                {{this.$store.state.layout === 'speaker' ? item.btnConfig[0].text : item.btnConfig[1].text}}
              </div>
              <div v-else>视图布局</div>
            </div>
          </div> -->
          <GalleryButton
            :btnInfo="item"
            v-if="item.id === NEMenuIDs.gallery && btnVisibile(item.visibility)"
          />
          <v-popover
            :delay="500"
            :open="showControlBar && !isLoading"
            :auto-hide="false"
            trigger="manual"
            style="display: flex"
            placement="top"
            popoverWrapperClass="hands-popover"
            :container="false"
            v-if="item.id === NEMenuIDs.chat && btnVisibile(item.visibility)"
          >
            <div class="button" @click="toggleChatroom">
              <!--    聊天室消息提醒          -->
              <div class="msg-tip" v-show="showMsgTip && !showChatroom">
                <div class="msg-avatar">
                  {{receiveMsg.nickname && receiveMsg.nickname.charAt(0) }}
                </div>
                <div class="msg-wrap">
                  <p class="msg-nick">{{receiveMsg.nickname}} 说：</p>
                  <p class="msg-content">{{receiveMsg.content}}</p>
                </div>
              </div>

              <template v-if="unReadMsgsNum > 0">
                <span class="chatmsg-num">{{
                  unReadMsgsNum > 99 ? '99+' : unReadMsgsNum
                }}</span>
              </template>
              <div class="setting-icon">
                <template v-if="item.btnConfig && item.btnConfig.icon">
                  <img
                    class="custom-icon"
                    :src="item.btnConfig.icon"
                    alt=""
                    srcset=""
                  />
                </template>
                <template v-else>
                  <svg class="icon" aria-hidden="true">
                    <use xlink:href="#iconshipin-liaotian"></use>
                  </svg>
                </template>
                <div class="custom-text" v-if="item.btnConfig">
                  {{ item.btnConfig.text || '聊天' }}
                </div>
                <div v-else>聊天</div>
              </div>
            </div>
          </v-popover>
          <CustomButton
            :btnInfo="item"
            v-if="
              !Object.values(NEMenuIDs).includes(item.id) &&
              btnVisibile(item.visibility)
            "
          />
        </div>
      </template>
      <!-- <div class="button">
        <div class="setting-icon">
          <svg class="icon" aria-hidden="true">
            <use xlink:href="#iconyx-tv-voice-offx"></use>
          </svg>
          <div>聊天</div>
        </div>
      </div> -->
      <v-popover
        placement="top"
        :container="false"
        popoverWrapperClass="setting-popover-out"
      >
        <template slot="popover">
          <div
            class="setting-outer"
            :style="{
              background: theme.controlBarBgColor || '',
              color: theme.controlBarColor || '#fff',
            }"
          >
            <MoreBarContent
              @moreClick="onMoreBtnClick"
              :moreBarList="moreBarList"
              :hideAllControlDialog="() => this.hideAllControlDialog(false)"
              :inviteVisible.sync="inviteVisible"
            />
          </div>
        </template>
        <div class="button" v-if="moreBarList.length || dynamicList.length">
          <div class="setting-icon">
            <svg class="icon" aria-hidden="true">
              <use xlink:href="#iconyx-tv-more1x"></use>
            </svg>
            <div>{{ $t('moreBtn') }}</div>
          </div>
        </div>
      </v-popover>
    </div>
    <div
      v-if="!hideLeave"
      class="leave-button"
      :style="{
        background: theme.controlBarBgColor || '',
      }"
      name="end-dialog"
      @click="
        () => {
          this.hideAllControlDialog(false)
          this.leaveVisible = true
        }
      "
    >
      {{ isHost ? $t('finish') : $t('leave') }}
    </div>
    <VDialog :width="800" :height="500" title="设置" :visible.sync="visible">
      <SettingContent slot="dialogContent" />
    </VDialog>
    <VDialog
      :width="400"
      :title="$t('inviteBtn')"
      :top="35"
      :visible.sync="inviteVisible"
    >
      <div slot="dialogContent" class="invite-content" ref="inviteContent">
        <p>{{ $t('defaultMeetingInfoTitle') }}</p>
        <p class="mt22">{{ $t('inviteSubject') }}：{{ meetingInfo.subject }}</p>
        <p v-if="meetingInfo.type === 3">
          {{ $t('inviteTime') }}：{{ formatDate(meetingInfo.startTime) }} -
          {{ formatDate(meetingInfo.endTime) }}
        </p>
        <p class="mt22">{{ $t('meetingId') }}：{{ meetingId }}</p>
        <p
          v-if="
            meetingInfo.type === 2 &&
            meetingInfo.shortId &&
            meetingIdDisplayOptions === NEMeetingIdDisplayOptions.displayAll
          "
          class="short-id"
        >
          {{ meetingInfo.shortId }}(仅对内)
        </p>
        <p class="mt22" v-if="meetingInfo.sipCid && !noSip">
          {{ $t('sip') }}：{{ meetingInfo.sipCid }}
        </p>
        <p class="mt22" v-if="meetingInfo.password">
          {{ $t('meetingPassword') }}：{{ meetingInfo.password }}
        </p>
        <div class="invite-btn-out">
          <button @click="handleCopy">{{ $t('copy') }}</button>
        </div>
      </div>
    </VDialog>
    <VDialog
      :width="320"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="leaveVisible"
    >
      <div slot="dialogContent" v-if="!isHost" class="leave-content">
        <h3>{{ $t('leave') }}</h3>
        <p class="leave-content-info">{{ $t('leaveTips') }}</p>
      </div>
      <div slot="dialogContent" v-else-if="isHost" class="leave-content">
        <h3>{{ $t('finish') }}</h3>
        <p class="leave-content-info">{{ $t('hostExitTips') }}</p>
      </div>
      <div class="leave-content-btns" v-if="!isHost" slot="dialogFooter">
        <button class="confirm" @click="leave">{{ $t('sure') }}</button>
        <button class="cacel" @click="leaveVisible = !leaveVisible">
          {{ $t('cancel') }}
        </button>
      </div>
      <div class="leave-content-btns" v-else-if="isHost" slot="dialogFooter">
        <button @click="() => this.hideAllControlDialog(false)">
          {{ $t('cancel') }}
        </button>
        <button class="confirm" @click="showChangePresenter">
          {{ $t('leaveMeeting') }}
        </button>
        <button class="endall" name="endall" @click="endMeeting">
          {{ $t('quitMeeting') }}
        </button>
      </div>
    </VDialog>
    <VDialog
      :width="320"
      :top="35"
      :title="$t('commonTitle')"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="presenterChangeVisible"
    >
      <div slot="dialogContent" class="leave-content">
        <h3>{{ $t('leave') }}</h3>
        <p class="leave-content-info">{{ $t('changePresenterTips') }}</p>
      </div>
      <div class="leave-content-btns" slot="dialogFooter">
        <button class="confirm" @click="changePresenter">
          {{ $t('yes') }}
        </button>
        <button class="cacel" @click="leave">{{ $t('no') }}</button>
      </div>
    </VDialog>
    <VDialog
      :width="320"
      :top="35"
      title="全体静音"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="handsUpAudioVisible"
    >
      <div slot="dialogContent" class="leave-content">
        <p class="leave-content-info">{{ $t('muteAllAudioHandsUpTips') }}</p>
      </div>
      <div class="leave-content-btns" slot="dialogFooter">
        <button @click="() => this.hideAllControlDialog(false)">
          {{ $t('cancelHandsUp') }}
        </button>
        <button
          class="confirm"
          @click="handleHandsUpAction(memberAction.handsUp)"
        >
          {{ $t('handsUpApply') }}
        </button>
      </div>
    </VDialog>
    <VDialog
      :width="320"
      :top="35"
      title="全体关闭视频"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="handsUpVideoVisible"
    >
      <div slot="dialogContent" class="leave-content">
        <p class="leave-content-info">{{ $t('muteAllVideoHandsUpTips') }}</p>
      </div>
      <div class="leave-content-btns" slot="dialogFooter">
        <button @click="() => this.hideAllControlDialog(false)">
          {{ $t('cancelHandsUp') }}
        </button>
        <button
          class="confirm"
          @click="handleHandsUpAction(memberAction.handsUp)"
        >
          {{ $t('handsUpApply') }}
        </button>
      </div>
    </VDialog>
    <VDialog
      :width="320"
      :top="35"
      title="全体静音"
      :needHeader="false"
      :needBtns="true"
      :visible.sync="showCancelAudioHandsUp"
    >
      <div slot="dialogContent" class="leave-content">
        <p class="leave-content-info">{{ $t('cancelHandUpTips') }}</p>
      </div>
      <div class="leave-content-btns" slot="dialogFooter">
        <button @click="() => this.hideAllControlDialog(false)">
          {{ $t('cancel') }}
        </button>
        <button
          class="confirm"
          @click="handleHandsUpAction(memberAction.handsDown)"
        >
          {{ $t('sure') }}
        </button>
      </div>
    </VDialog>
    <VDialog
      :width="360"
      :top="30"
      :title="$t('addSipMember') + `(${sipMemberList.length})`"
      :needBtns="true"
      :visible.sync="showAddSipMember"
      class="confirm-sip-add"
    >
      <template v-slot:dialogContent>
        <div class="input-content">
          <input
            class="sip-input"
            type="text"
            v-model="sipNumber"
            :placeholder="$t('placeholderSipMember')"
            maxlength="20"
          />
          <input
            class="sip-input"
            type="text"
            v-model="sipAddress"
            :placeholder="$t('placeholderSipAddr')"
            maxlength="20"
          />
          <span
            :class="`join-meeting ${
              sipNumber.length >= 3 && sipAddress.length >= 3 ? '' : 'disable'
            }`"
            @click="debounce(onAddSipMember)"
            >{{ $t('addSipMember') }}</span
          >
        </div>
      </template>
      <template v-slot:dialogFooter>
        <div class="sip-invite-wrap" v-if="sipMemberList.length > 0">
          <p class="title">邀请列表：</p>
          <div class="list">
            <div v-for="member in sipMemberList">
              {{ member.sipNum }}
            </div>
          </div>
        </div>
      </template>
    </VDialog>
  </div>
</template>
<script lang="ts">
import Vue from "vue";
import SettingInBar from "./SettingInBar.vue";
import VDialog from "./ui/Dialog.vue";
import SettingContent from "./SettingContent.vue";
import MoreBarContent from "./custom/MoreBarContent.vue";
import { debounce, formatDate, formatMeetingId, getErrCode, handsUpsNum, localIns } from "../utils";
import {
  AttendeeOffType,
  errorCodes,
  memberAction,
  memberLeaveTypes,
  NEMeetingIdDisplayOptions,
  NEMenuIDs,
  NEMenuVisibility,
  RoleType,
  shareMode
} from "../libs/enum";
import GalleryButton from "./custom/GalleryButton.vue";
import ScreenShareButton from "./custom/ScreenShareButton.vue";
import CustomButton from "./custom/CustomButton.vue";
import WhiteBoardShareButton from "./custom/WhiteBoardShareButton.vue";
import InviteButton from "./custom/InviteButton.vue";
import { SipMember, Theme, VideoProfile } from "@/types/index";


export default Vue.extend({
  name: 'ControlBar',
  props: ['showControlBar'],
  data() {
    return {
      memberAction,
      NEMeetingIdDisplayOptions,
      showSoundSetting: false,
      showVideoSetting: false,
      visible: false,
      inviteVisible: false,
      leaveVisible: false,
      handsUpAudioVisible: false,
      handsUpVideoVisible: false,
      presenterChangeVisible: false, // 是否移交主持人
      showMemberHansUpNumTip: false,
      showCancelAudioHandsUp: false,
      copyId: 0,
      // leaveCallBack: (LeaveTypes: memberLeaveTypes) => true,
      dynamicList: [],
      canClickAudio: true,
      canClickVideo: true,
      NEMenuIDs,
      NEMenuVisibility,
      sipNumber: '', // 添加的sip号码
      sipAddress: '', // 添加的sip地址
      sipMemberList: [] as SipMember[], // 邀请列表
      showAddSipMember: false,
      showMsgTip: false, // 是否显示新l
      receiveMsg: {
        nickname: '',
        content: ''
      },
      showMsgTimer: null as any
    }
  },
  components: {
    SettingInBar,
    VDialog,
    SettingContent,
    MoreBarContent,
    GalleryButton,
    ScreenShareButton,
    CustomButton,
    WhiteBoardShareButton,
    InviteButton,
  },
  mounted() {
    // setTimeout(() => {
    //   console.warn(123456, (this.$refs.controlBar as any).offsetWidth);
    // }, 3000);
    // this.leaveCallBack = this.$store.state.localInfo.
    // this.$EventBus.$on('afterLeave', (val: any) => {
    //   this.leaveCallBack = val;
    // });

    this.$EventBus.$on('newMsgs', (msgs) => {
      console.log('newmsgs', msgs)
      const msg = msgs[0]
      if(msg.type === "notification" || this.showChatroom) {
        return
      }
      const content = {
        'image': '[图片]',
        'file': '[文件]'
      }
      this.receiveMsg = {
        nickname: msg.fromNick,
        content: msg.type === 'text' ? msg.text : (content[msg.type] || '[不支持类型]')
      }
      this.showMsgTip = true
      this.showMsgTimer && clearTimeout(this.showMsgTimer)
      this.showMsgTimer = setTimeout(() => {
        this.showMsgTip = false
        this.showMsgTimer = null
      }, 3000)
    })
    this.$EventBus.$on('needAudioHandsUp', (val) => {
      this.handsUpAudioVisible = val
    })
    this.$EventBus.$on('needVideoHandsUp', (val) => {
      this.handsUpVideoVisible = val
    })
  },
  watch: {
    showChatroom: function(isShow) {
      if(isShow) {
        this.showMsgTip = false
        this.showMsgTimer && clearTimeout(this.showMsgTimer)
        this.showMsgTimer = null
      }
    },
    '$store.state.status': function (newValue) {
      if (newValue === 2) {
        window.addEventListener('unload', this.listenUnload)
      } else {
        this.hideAllControlDialog(false)
        window.removeEventListener('unload', this.listenUnload)
      }
      // if (newValue !== 2) {
      //   this.hideAllControlDialog();
      //   if (this.screen === 1) {
      //     this.share();
      //   }
      // }
    },
  },
  methods: {
    debounce,
    listenUnload() {
      if (this.$store.state.status === 2) {
        this.leave()
      }
    },
    changeLayout() {
      if (this.hasScreenShare) {
        this.$toast('正在进行屏幕分享，无法操作布局')
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
    showChangePresenter() {
      // 当主持人离开会议室时候，确定是否移交主持人
      if (this.memberNum > 1 && this.isPresenter) {
        this.leaveVisible = false
        this.presenterChangeVisible = true
      } else {
        // 如果只有一个人则直接离开会议室
        this.leave()
      }
    },
    changePresenter() {
      // 移交主持人
      this.presenterChangeVisible = false
      this.toggleList()
    },
    onMoreBtnClick(data: { type: 'sip'; data: any }) {
      console.log('onMoreBtnClick', data)
      if (data.type === 'sip') {
        this.showAddSipMember = true
        this.getSipMemberList()
      }
    },
    onAddSipMember() {
      console.log(
        'onAddSipMember',
        this.sipNumber,
        this.sipAddress,
        this.localInfo
      )
      this.$neMeeting
        .addSipMember(this.sipNumber, this.sipAddress)
        .then((res) => {
          this.getSipMemberList()
        })
    },
    getSipMemberList() {
      this.$neMeeting.getSipMemberList().then((res) => {
        this.sipMemberList = res.list
      })
    },
    leave() {
      console.log('离开会议')
      // if (this.$store.state.meetingInfo.whiteboardAvRoomUid.length) {
      // this.$EventBus.$emit('whiteboard-logout');
      // }
      if (this.$store.state.online === 0) {
        this.resetMeeting(memberLeaveTypes.leaveBySelf, true)
        return
      }
      this.setHistoryMeetingItem()
      this.$neMeeting
        .leave(this.$store.state.localInfo.role)
        .then(() => {
          console.log('离开会议成功')
          this.resetMeeting(memberLeaveTypes.leaveBySelf)
        })
        .catch((e) => {
          console.error('离开会议失败: ', e)
          this.$toast(this.errorCodes[getErrCode(e.message)] || '离开会议失败')
          this.$store.dispatch('resetInfo')
          this.$store.commit('changeMeetingStatus', 1000)
          this.$neMeeting.destroyRoomContext()
        })
      this.leaveVisible = false
    },
    endMeeting() {
      console.log('结束会议')
      this.leaveVisible = false
      if (this.$store.state.online === 0) {
        this.$toast(this.$t('networkUnavailableCloseFail'))
        return
      }
      this.setHistoryMeetingItem()
      this.$neMeeting
        .end()
        .then(() => {
          console.log('结束会议成功')
          this.resetMeeting(memberLeaveTypes.endBySelf, false)
        })
        .catch((e) => {
          console.error('结束会议失败: ', e)
          // const reason = e.message.match(/[\u4e00-\u9fa5]+/) && e.message.match(/[\u4e00-\u9fa5]+/).length && e.message.match(/[\u4e00-\u9fa5]+/)[0] || '结束会议失败'
          this.$toast(this.errorCodes[getErrCode(e.message)] || '结束会议失败')
          this.$neMeeting.destroyRoomContext()
          setTimeout(() => {
            this.$store.dispatch('resetInfo')
            this.$store.commit('changeMeetingStatus', 1000)
          })
        })
    },
    resetMeeting(leaveType: memberLeaveTypes, needCallback = false) {
      const {
        localInfo: { leaveCallBack },
      } = this.$store.state
      this.$EventBus.$emit('whiteboard-clean-cache')
      this.$EventBus.$emit('whiteboard-logout')
      this.$store.dispatch('resetInfo')
      this.$store.commit('changeMeetingStatus', 1)
      this.$EventBus.$emit('NEMeetingInfo', null)
      this.$EventBus.$emit('memberInfo', {})
      this.$EventBus.$emit('joinMemberInfo', {})
      if (needCallback) {
        this.$EventBus.$emit('peerLeave', 'LEAVE_BY_SELF')
        this.$nextTick(() => {
          leaveCallBack && leaveCallBack(leaveType)
        })
      }
    },
    toggleSettingOnBar(type, value) {
      // 1 音频 2 视频
      switch (type) {
        case 1:
          this.showSoundSetting = value

          this.$store.commit('setSettingSelect', 'audio')
          break
        case 2:
          this.showVideoSetting = value
          this.$store.commit('setSettingSelect', 'video')
          break
        default:
          this.showSoundSetting = value
          this.showVideoSetting = value
          break
      }
    },
    share() {
      if (this.screen) {
        console.warn('关闭屏幕共享')
        this.$neMeeting
          .muteLocalScreenShare()
          .then(() => {
            console.log('关闭共享屏幕成功')
            this.screen = 0
            this.$store.dispatch('sortMemberList')
            if (this.$store.state.localInfo.video === 1) {
              this.unmuteLocalVideo()
              // this.$neMeeting.unmuteLocalVideo();
            }
          })
          .catch((e) => {
            this.$toast(
              this.errorCodes[getErrCode(e.code)] || e.msg || '关闭共享屏幕失败'
            )
            console.error('关闭共享屏幕失败: ', e)
          })
      } else {
        console.warn('开启屏幕共享')
        if (this.hasScreenShare) {
          this.$toast('共享屏幕数量已达上限')
          return false
        }
        if (this.isHandsUp) {
          this.handleHandsUpAction(memberAction.handsDown, false)
        }
        if (
          this.$store.state.localInfo.video === 1 ||
          this.$store.state.localInfo.video === 4
        ) {
          this.$neMeeting.muteLocalVideo(false)
        }
        this.$neMeeting
          .unmuteLocalScreenShare()
          .then(() => {
            console.log('共享屏幕成功')
            this.screen = 1
            this.$store.dispatch('sortMemberList')
          })
          .catch((e) => {
            console.error('共享屏幕失败: ', e)
            switch (true) {
              case e.message.includes(
                'possibly because the user denied permission'
              ):
                this.$toast(
                  '无法开启屏幕共享：进入浏览器偏好设置，屏幕共享设置调整为’请求‘，并在开启共享时允许观察屏幕'
                )
                break
              case e.message.includes('Permission denied by system'):
                this.$toast(
                  '无法开启屏幕共享：打开系统偏好设置-安全与隐私-隐私-屏幕录制，允许该浏览器使用录制功能'
                )
                break
              case e.message.includes('Permission denied'):
                this.$toast('取消开启屏幕共享')
                break
              default:
                this.$toast('共享屏幕失败')
                break
            }
            this.screen = 1
            this.share()
            /*this.screen = 0
          this.$store.dispatch('sortMemberList');
          if (this.$store.state.localInfo.video) {
            this.$neMeeting.unmuteLocalVideo()
          }*/
          })
      }
    },
    // invite () {
    //   this.inviteVisible = true;
    // },
    toggleList() {
      if (!this.$store.state.showList) {
        this.$store.commit('toggleChatroom', false)
      }
      this.$store.commit('toggleList')
    },
    toggleChatroom() {
      if (!this.$store.state.showChatroom) {
        this.$store.commit('toggleList', false)
      }
      this.$store.commit('toggleChatroom')
    },
    async toggleMuteAudio() {
      if (!this.canClickAudio) {
        return
      }
      this.canClickAudio = false
      const { microphoneId, allowUnMuteAudioBySelf } = this.$store.state
      console.log(
        'microphoneId',
        microphoneId,
        allowUnMuteAudioBySelf,
        this.isHost,
        this.isScreen
      )
      const status = this.audio
      let p: any, callback: any
      if (status === 1) {
        p = this.$neMeeting.muteLocalAudio()
        // callback = () => {
        //   this.$store.commit('setLocalInfo', {
        //     audio: 0,
        //     isAudioOn: false
        //   })
        //   this.audio = 0
        // }
        // this.$store.state.localInfo.audio = 2
      } else if (!allowUnMuteAudioBySelf && !this.isHost && !this.isScreen) {
        if (this.isHandsUp) {
          this.$toast(`${this.$t('handsUpSuccessAlready')}`)
        } else {
          this.handsUpAudioVisible = true
        }
      } else {
        p = this.$neMeeting.unmuteLocalAudio(microphoneId)
        // callback = () => {
        //   this.$store.commit('setLocalInfo', {
        //     audio: 1,
        //     isAudioOn: true
        //   })
        //   this.audio = 1
        // }
        // this.$store.state.localInfo.audio = 1
      }
      if (p) {
        p.then(() => {
          callback && callback()
        })
          .catch((e) => {
            this.$toast(
              this.errorCodes[getErrCode(e.code)] || e.msg || '设置音频失败'
            )
            console.error(
              'toggleMuteAudio',
              status ? 'mute' : 'unmute',
              'error',
              e
            )
          })
          .finally(() => {
            this.canClickAudio = true
          })
      } else {
        this.canClickAudio = true
      }
    },
    unmuteLocalVideo(deviceId?: string) {
      let videoProfile = this.videoProfile
      if (this.isFocus) {
        // 如果当前是焦点画面则设置焦点画面分辨率配置
        videoProfile = this.focusVideoProfile
      }
      return this.$neMeeting.unmuteLocalVideo(deviceId, true, videoProfile)
    },
    toggleMuteVideo() {
      // if (this.screen) {
      //   this.$toast(this.$t('screenShareModeForbiddenOp'))
      //   return
      // }
      if (!this.canClickVideo) {
        return
      }
      this.canClickVideo = false
      const { cameraId, allowUnMuteVideoBySelf } = this.$store.state
      const status = this.video
      let p, callback: () => void
      if (status === 1) {
        p = this.$neMeeting.muteLocalVideo()
        // callback = () => {
        //   this.$store.commit('setLocalInfo', {
        //     video: 0,
        //     isVideoOn: false
        //   })
        // }
        // this.$store.state.localInfo.video = 2
        this.video = 2
      } else if (!allowUnMuteVideoBySelf && !this.isHost && !this.isScreen) {
        if (this.isHandsUp) {
          this.$toast(`${this.$t('handsUpSuccessAlready')}`)
        } else {
          this.handsUpVideoVisible = true
        }
      } else {
        // this.$neMeeting.rtcController.setupLocalVideoCanvas(`.video-${this.$neMeeting.avRoomUid}`)
        p = this.unmuteLocalVideo(cameraId)
        // callback = () => {
        //   this.$store.commit('setLocalInfo', {
        //     video: 1,
        //     isVideoOn: true
        //   })
        //   // this.$store.state.localInfo.video = 1
        //   this.video = 1
        // }
      }
      if (p) {
        p.then(() => {
          callback && callback()
        })
          .catch((e) => {
            this.$toast(
              this.errorCodes[getErrCode(e.code)] || e.msg || '设置视频失败'
            )
            console.error(
              'toggleMuteVideo',
              status ? 'mute' : 'unmute',
              'error',
              e
            )
          })
          .finally(() => {
            this.canClickVideo = true
          })
      } else {
        this.canClickVideo = true
      }
    },
    showDialog() {
      this.hideAllControlDialog(false)
      this.visible = !this.visible
      // this.toggleSettingOnBar(-1, false)
    },
    handleCopy() {
      const textarea = document.createElement('textarea')
      let msg = ''
      for (const child of (this.$refs.inviteContent as HTMLElement).children) {
        const item = child as HTMLElement
        if (item.tagName === 'P') {
          msg = msg.concat(item.innerText + '\r\n\n')
        }
      }
      textarea.setAttribute('readonly', 'readonly')
      // textarea.setAttribute('value', msg);
      msg = msg.slice(0, -3)
      textarea.innerHTML = msg
      document.body.appendChild(textarea)
      textarea.setSelectionRange(0, 9999)
      textarea.select()
      if (document.execCommand) {
        document.execCommand('copy')
        console.log('复制成功')
        this.$toast(this.$t('copySuccess'))
        this.hideAllControlDialog(false)
      }
      document.body.removeChild(textarea)
    },
    handleHandsUpAction(val, needToast = true) {
      // 举手 val 58 发言申请举手发言
      // 取消举手 val 59 发言申请举手放下
      this.$neMeeting
        .sendMemberControl(val)
        .then(() => {
          switch (val) {
            case memberAction.handsUp:
              needToast && this.$toast(`${this.$t('handsUpSuccess')}`)
              this.hideAllControlDialog(false)
              break
            case memberAction.handsDown:
              needToast && this.$toast(this.$t('cancelHandUpSuccess'))
              this.hideAllControlDialog()
              break
            default:
              break
          }
        })
        .catch((e) => {
          if (e && e.code) {
            switch (e.code) {
              case 2110:
                this.toggleMuteAudio()
                this.$toast(
                  this.errorCodes[getErrCode(e.code)] || e.msg || '解除静音'
                )
                break
              default:
                this.$toast(
                  this.errorCodes[getErrCode(e.code)] || e.msg || '操作失败'
                )
                break
            }
          }
          this.hideAllControlDialog()
          throw new Error(e)
        })
    },
    hideAllControlDialog(needCloseHands = true) {
      this.visible = false
      this.inviteVisible = false
      this.leaveVisible = false
      this.handsUpAudioVisible = false
      this.handsUpVideoVisible = false
      this.showMemberHansUpNumTip = false
      this.showCancelAudioHandsUp = false
      this.$store.commit('toggleList', false)
      this.$store.commit('toggleChatroom', false)
      if (needCloseHands) {
        this.isHandsUp = false
      }
    },
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
    // 离会同时记录上一次会议信息记录对象
    setHistoryMeetingItem() {
      const data = {
        meetingUniqueId: this.meetingInfo?.meetingUniqueId,
        meetingId: this.meetingInfo?.meetingId,
        shortMeetingId: this.meetingInfo?.shortId,
        subject: this.meetingInfo?.subject,
        password: this.meetingInfo?.password,
        nickname: this.localInfo?.nickName,
        sipId: this.meetingInfo.sipCid,
      }
      // console.log('上次会议信息', data);
      this.$EventBus.$emit('setHistoryMeetingItem', {
        ...data,
      })
      localIns.set('historyMeeting', data)
    },
    formatDate,
  },
  beforeDestroy() {
    this.hideAllControlDialog()

    this.$neMeeting.removeAllListeners('stopScreenSharing')
  },
  computed: {
    showChatroom(): boolean {
      return this.$store.state.showChatroom
    },
    enableUnmuteBySpace(): boolean {
      return this.$store.state.enableUnmuteBySpace
    },
    errorCodes(): any {
      return errorCodes(this.$i18n)
    },
    isCoHost(): boolean {
      // 是否是联席主持人
      return this.localInfo.roleType === RoleType.coHost
    },
    isFocus(): boolean {
      // 本端是否是焦点
      if (!this.$store.state.meetingInfo.focusAvRoomUid) {
        return false
      }
      return (
        this.$store.state.meetingInfo.focusAvRoomUid ===
        this.$store.state.localInfo.avRoomUid
      )
    },
    videoProfile(): VideoProfile {
      return this.$store.state.videoProfile
    },
    focusVideoProfile(): VideoProfile {
      return this.$store.state.focusVideoProfile
    },
    audio: {
      get: function () {
        return this.$store.state.localInfo.audio
      },
      set: function (value) {
        const { state, commit } = this.$store
        state.localInfo.audio = value
        const uid = state.localInfo.avRoomUid
        // console.error('uid: %s, value: %s', uid, value)
        let m = state.memberMap[uid]
        m = m ? Object.assign({}, m) : {}
        m['audio'] = value
        commit('updateMember', m)
      },
    },
    video: {
      get: function () {
        return this.$store.state.localInfo.video
      },
      set: function (value) {
        const { state, commit } = this.$store
        state.localInfo.video = value
        const uid = state.localInfo.avRoomUid
        // console.error('uid: %s, value: %s', uid, value)
        let m = state.memberMap[uid]
        m = m ? Object.assign({}, m) : {}
        m['video'] = value
        // const test  = m
        // console.log('m: ', test)
        commit('updateMember', m)
      },
    },
    screen: {
      get: function () {
        return this.$store.state.localInfo.screen
      },
      set: function (value) {
        const { state, commit } = this.$store
        state.localInfo.screen = value
        const uid = state.localInfo.avRoomUid
        // console.error('uid: %s, value: %s', uid, value)
        let m = state.memberMap[uid]
        m = m ? Object.assign({}, m) : {}
        m['screenSharing'] = value
        commit('updateMember', m)
      },
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
    meetingInfo(): any {
      return this.$store.state.meetingInfo
    },
    noSip(): boolean {
      return this.$store.state.noSip
    },
    localInfo(): any {
      return this.$store.state.localInfo
    },
    isHost(): boolean {
      // 是否为主持人或者联席主持人
      return this.isCoHost || this.isPresenter
    },
    isPresenter(): boolean {
      const result = this.$store.state.localInfo.role
      return result === 'host'
    },
    isScreen(): boolean {
      const {
        state: { meetingInfo },
      } = this.$store
      return (
        meetingInfo.shareMode === shareMode.screen &&
        meetingInfo.screenSharersAvRoomUid &&
        meetingInfo.screenSharersAvRoomUid.includes(
          this.$neMeeting.avRoomUid.toString()
        )
      )
    },
    isDev() {
      return process.env.NODE_ENV === 'development'
    },
    isLoading(): boolean {
      return this.$store.state.beforeLoading
    },
    hasScreenShare(): boolean {
      const newResult = { ...this.$store.state.memberMap }
      let result = false
      for (const uid in newResult) {
        if (newResult[uid].screenSharing === 1) {
          result = true
          break
        }
      }
      return result
    },
    audiohandsUpsNum(): number {
      return handsUpsNum(1, this.$store.state.memberMap)
    },
    isHandsUp: {
      get: function () {
        return this.$store.state.localInfo.isHandsUp
      },
      set: function (value) {
        this.$store.commit('setLocalInfo', {
          isHandsUp: value,
        })
      },
    },
    memberNum(): number {
      return this.$store.state.memberIdList.length || 0
    },
    meetingIdDisplayOptions(): number {
      return this.$store.state.localInfo.meetingIdDisplayOptions
    },
    toolBarList() {
      return this.$store.state.localInfo.toolBarList
    },
    moreBarList() {
      return this.$store.state.localInfo.moreBarList
    },
    hideLeave(): boolean {
      return this.$store.state.localInfo.hideLeave
    },
    theme(): Theme {
      return this.$store.state.theme
    },
    hasJoined(): boolean {
      return this.$neMeeting?.meetingStatus === 'joined'
    },
    unReadMsgsNum(): number {
      return this.$store.state.unReadMsgs.length
    },
  },
})
</script>

<style lang="stylus" scoped>
h = 68px
.hands-popover
  .hands-action
    position relative
    text-align center
    width 36px
    height 40px
    background #337EFF
    color #fff
    box-shadow: 0 2px 6px 0 rgba(23,23,26,0.10);
    cursor pointer
    .hands-icon
      display block
      margin 3px auto 0
      font-size 20px
    &:after
      content ''
      display inline-block
      position absolute
      left 15px
      bottom -12px
      border-color #337EFF transparent transparent transparent
      border-width 6px 4px 6px 4px
      border-style solid
    .hands-up-tip
      display inline-block
    .hands-down-tip
      display none
      // margin-left -30px
      background #337EFF
    &:hover .hands-down-tip, & .hands-down-tip:hover, &.no-hover:hover .hands-up-tip, &.no-hover:hover .hands-up-tip:hover
      display inline-block
    &:hover .hands-up-tip, & .hands-up-tip:hover, &.no-hover:hover .hands-down-tip, &.no-hover:hover .hands-down-tip:hover
      display none
    .hands-up-tip,.hands-down-tip
      span
        display block
        font-size 12px
        transform scale(.8)
.setting-popover-out
  .setting-outer
    background-image: linear-gradient(180deg, #33333F 0%, #292933 100%);
    border-radius: 4px;
    color: #fff;
    box-shadow: 0 5px 30px rgba(0, 0, 0, 0.1);
  .setting-enter
    padding 0 14px 14px
    li:hover
      cursor pointer
      background: rgba(0, 0, 0, 0.2);
.control-bar
  height h
  width 100%
  background-image: linear-gradient(180deg, #33333F 0%, #292933 100%)
  font-size: 12px
  color: #ffffff
  position relative
  // bottom 0
  .button-box
    // margin 0 auto
    display flex
    justify-content center
    align-items center
    .button-list
      display flex
      justify-content center
      align-items center
      color: #fff
  .button
    position relative
    display flex
    width 60px
    margin 0 16px
    height h
    // line-height h
    text-align center
    cursor pointer
    align-items center
    justify-content center
    .member-num
      position absolute
      top 5px
      left 40px
      font-size 9px
    .chatmsg-num
      position absolute
      top 5px
      left 40px
      font-size 9px
      background-color: red
      padding: 0 5px
      border-radius: 50%
    &:hover
      background: rgba(0, 0, 0, 0.3)
    .setting-icon
      vertical-align: middle
      display: inline-block
      .custom-icon
        display block
        width 26px
        margin 0 auto 2px
        user-select none
      .custom-text
        text-overflow ellipsis
        overflow hidden
        white-space pre
        max-width 78px
        user-select none
    .setting-icon-close
      color: #FE3B30
    .white
      // color #fff
    .icon
      font-size 26px
    .bar-setting
      height: h
      line-height: 54px
      width: 12px
      display: inline-block
      position: relative
      // margin: 0 0 0 10px
      // &.need-top:before
      //   margin-top 38%
    .bar-setting:before
      content: ''
      position relative
      // display: inline-block
      border-width 4px
      border-style solid
      border-top-color transparent
      border-right-color transparent
      border-bottom-color inherit
      border-left-color transparent
    .setting-select
      opacity: 0.3;
      background: #000000;
  .button-for-setting
    width 12px
    margin: 0
  .leave-button
    color red
    position absolute
    right 50px
    top 30%
    background-image: linear-gradient(179deg, #25252E 7%, #15151A 100%);
    border-radius: 4px
    padding: 6px 14px
    cursor: pointer
  .invite-content, .leave-content
    padding 24px 0
    font-size 16px
    h3
      font-size: 18px
      margin-bottom 12px
  .invite-content
    p
      font-size: 18px;
      color: #222222;
      text-align left
      font-size 14px
      padding 0 35px
      &.mt22
        margin 22px 0 0
      &.short-id
        text-indent 55px
    button
      margin 10px 0 0
      background: #337EFF;
      border: 1px solid #337EFF;
      border-radius: 20px;
      padding 10px 30px
      text-align center
      cursor pointer
      color #fff
      &:active
        opacity 0.8
    div.invite-btn-out
      margin 32px 0 0
      border-top 1px solid #EBEDF0
  .leave-content
    &-info
      padding 0 24px
      font-size 14px
  .leave-content-btns
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
  .confirm-sip-add
    div.input-content
      position relative
      padding 10px 20px 20px
      .sip-input
        margin 10px 0
        width 100%
        padding: 10px 0
        border 1px solid #E1E3E6
        border-radius 2px
        text-indent 12px
        font-size 14px
        height 32px
        line-height 32px
        &.error
          border 1px solid #F24957;
      & .close-btn
        position absolute
        display flex
        right 5px
        top 9px
        width 16px
        height 16px
        color #fff
        background rgba(60,60,67,0.60)
        border-radius 50%
        font-size 10px
        // line-height 15px
        justify-content center
        align-items center
        color #fff
        cursor pointer
        .icon-close
          display inline-block

    span.join-meeting
      margin-top 14px
      border none
      display inline-block
      width 120px
      height 36px
      line-height 36px
      background #337EFF
      border-radius 18px
      color #fff
      padding 0
      cursor pointer
      user-select none
      &:active
        opacity 0.8
      &.disable
        opacity 0.5
        cursor not-allowed
  .sip-invite-wrap
    text-align left
    padding 0 20px
    margin-bottom 10px
    .title
      font-size 14px
    .list
      max-height 160px
      overflow auto
  .msg-tip
    position absolute
    display flex
    top -80px
    left 50%
    transform translateX(-50%)
    width 240px
    height 60px
    padding 12px
    font-size 12px
    background linear-gradient(180deg, rgba(41, 41, 51, 0.95) 6.82%, rgba(33, 33, 41, 0.95) 99.71%);
    border-radius: 8px
  .msg-avatar
    width 36px
    height 36px
    border-radius 50%
    background #337eff
    font-weight bold
    text-align center
    color #fff
    margin-right 8px
    line-height 36px
  .msg-wrap
    text-align left
  .msg-nick
    color #cccccc
  .msg-content
    color #fff
    white-space nowrap
    text-overflow ellipsis
    overflow hidden
    max-width 170px

</style>
