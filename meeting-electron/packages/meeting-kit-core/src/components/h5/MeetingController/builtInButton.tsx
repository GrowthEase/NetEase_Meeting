import { CommonBar, NEMember, Role } from '../../../types'
import './index.less'
import { useTranslation } from 'react-i18next'
import React from 'react'

// 音频管理组件
type AudioButtonProps = {
  localMember: NEMember
  item: CommonBar
  onClick: (type: 'audio' | 'video', isOpen: boolean) => void
}

const AudioButton: React.FC<AudioButtonProps> = ({
  localMember,
  item,
  onClick,
}) => {
  const { t } = useTranslation()

  return (
    <div
      key={item.id}
      className="controller-item"
      onClick={() => {
        onClick?.('audio', !localMember.isAudioOn)
      }}
    >
      {/* 按钮图标 */}
      <>
        {localMember.isAudioOn ? (
          <>
            {item.btnConfig?.[0].icon ? (
              <img
                className="custom-icon"
                src={item.btnConfig[0].icon}
                alt=""
              />
            ) : (
              <svg className="icon-tool icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconyx-tv-voice-onx"></use>
              </svg>
            )}
          </>
        ) : (
          <>
            {item.btnConfig?.[1].icon ? (
              <img
                className="custom-icon"
                src={item.btnConfig[1].icon}
                alt=""
              />
            ) : (
              <svg
                className="icon-red icon-tool icon iconfont"
                aria-hidden="true"
              >
                <use xlinkHref="#iconyx-tv-voice-offx"></use>
              </svg>
            )}
          </>
        )}
      </>
      {/* 按钮文案 */}
      {
        <div className="custom-text">
          {localMember?.isAudioOn
            ? item.btnConfig?.[0]?.text || t('participantMute')
            : item.btnConfig?.[1]?.text || t('participantUnmute')}
        </div>
      }
    </div>
  )
}

// 视频管理组件
type VideoButtonProps = {
  localMember: NEMember
  item: CommonBar
  onClick: (type: 'audio' | 'video', isOpen: boolean) => void
}

const VideoButton: React.FC<VideoButtonProps> = ({
  localMember,
  item,
  onClick,
}) => {
  const { t } = useTranslation()

  return (
    <div
      key={item.id}
      className="controller-item"
      onClick={() => {
        onClick?.('video', !localMember.isVideoOn)
      }}
    >
      {/* 按钮图标 */}
      <>
        {localMember.isVideoOn ? (
          <>
            {item.btnConfig?.[0].icon ? (
              <img
                className="custom-icon"
                src={item.btnConfig[0].icon}
                alt=""
              />
            ) : (
              <svg className="icon-tool icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconyx-tv-video-onx"></use>
              </svg>
            )}
          </>
        ) : (
          <>
            {item.btnConfig?.[1].icon ? (
              <img
                className="custom-icon"
                src={item.btnConfig[1].icon}
                alt=""
              />
            ) : (
              <svg
                className="icon-red icon-tool  icon iconfont"
                aria-hidden="true"
              >
                <use xlinkHref="#iconyx-tv-video-offx"></use>
              </svg>
            )}
          </>
        )}
      </>
      {/* 按钮文案 */}
      {
        <div className="custom-text">
          {localMember?.isVideoOn
            ? item.btnConfig?.[0]?.text || t('participantStopVideo')
            : item.btnConfig?.[1]?.text || t('participantStartVideo')}
        </div>
      }
    </div>
  )
}

// 成员管理组件
type MemberButtonProps = {
  localMember: NEMember
  memberList: NEMember[]
  item: CommonBar & { btnConfig: { icon?: string; text?: string } }
  onClick: () => void
  onClickHandsUpBtn: (type: boolean) => void
}
const MemberButton: React.FC<MemberButtonProps> = ({
  localMember,
  memberList,
  item,
  onClick,
  onClickHandsUpBtn,
}) => {
  const { t } = useTranslation()

  return (
    <div className="relative controller-item">
      {/*举手图标显示`*/}
      {localMember.isHandsUp && (
        <span
          className="hands-up-tip"
          onClick={() => {
            onClickHandsUpBtn?.(true)
          }}
        >
          <svg className="icon-tool icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconraisehands1x"></use>
          </svg>
          <span className="hands-arrow"></span>
          <span className="hands-arrow-text">{t('inHandsUp')}</span>
        </span>
      )}
      <div
        onClick={() => {
          onClick?.()
        }}
      >
        <div className="absolute member-count">
          {memberList?.length > 99 ? '99+' : memberList?.length}
        </div>
        {/* 按钮图标 */}
        {item.btnConfig?.icon ? (
          <img className="custom-icon" src={item.btnConfig.icon} alt="" />
        ) : (
          <svg className="icon-tool icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconyx-tv-attendeex"></use>
          </svg>
        )}
        {/* 按钮文案 */}
        <div className="custom-text">
          {item.btnConfig?.text ||
            (localMember.role === Role.host || localMember.role === Role.coHost
              ? t('memberListBtnForHost')
              : t('memberListBtnForNormal'))}
        </div>
      </div>
    </div>
  )
}

// 聊天组件
type ChatButtonProps = {
  onClick: () => void
  unReadCount: number
  item: CommonBar & { btnConfig: { icon?: string; text?: string } }
}
const ChatButton: React.FC<ChatButtonProps> = ({
  onClick,
  unReadCount,
  item,
}) => {
  const { t } = useTranslation()

  return (
    <div
      className="relative controller-item"
      onClick={() => {
        onClick?.()
      }}
    >
      {unReadCount ? (
        <div className="unread-count">
          {unReadCount > 99 ? '99+' : unReadCount}
        </div>
      ) : (
        ''
      )}
      {/* 按钮图标 */}
      {item.btnConfig?.icon ? (
        <img className="custom-icon" src={item.btnConfig.icon} alt="" />
      ) : (
        <svg className="icon-tool icon iconfont" aria-hidden="true">
          <use xlinkHref="#iconshipin-liaotian"></use>
        </svg>
      )}
      {/* 按钮文案 */}
      <div className="custom-text">{item.btnConfig?.text || t('chat')}</div>
    </div>
  )
}

export { AudioButton, VideoButton, MemberButton, ChatButton }
