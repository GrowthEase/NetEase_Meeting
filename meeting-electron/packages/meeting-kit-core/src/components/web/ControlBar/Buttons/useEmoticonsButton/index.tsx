import React, { useMemo, useState } from 'react'
import {
  memberAction,
  NEMenuIDs,
  Role,
  SecurityCtrlEnum,
  Toast,
} from '../../../../../kit'
import { useTranslation } from 'react-i18next'
import { Popover, PopoverProps } from 'antd'
import { useGlobalContext, useMeetingInfoContext } from '../../../../../store'
import { CaretDownOutlined, CaretUpOutlined } from '@ant-design/icons'
import Emoji from '../../../../common/Emoji'
import './index.less'

type EmoticonsBtnPopoverProps = {
  showHandsUpPopoverContent?: boolean
} & PopoverProps

const EmoticonsBtnPopover: React.FC<EmoticonsBtnPopoverProps> = (props) => {
  const { showHandsUpPopoverContent = true } = props
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const { t, i18n } = useTranslation()
  const [emoticonsPopoverOpen, setEmoticonsPopoverOpen] = useState(false)

  const localMember = meetingInfo.localMember
  const language = i18n.language.split('-')[0]
  const isHostOrCoHost =
    localMember.role === Role.coHost || localMember.role === Role.host

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  const emojiKeys = ['[鼓掌]', '[点赞]', '[爱心]', '[笑哭]', '[惊叹]', '[撒花]']

  function renderHandsUpPopoverContent() {
    if (isElectronSharingScreen) return null

    return (
      <Popover
        align={
          isElectronSharingScreen ? { offset: [0, 7] } : { offset: [0, -7] }
        }
        destroyTooltipOnHide
        trigger={[]}
        rootClassName="hands-down-popover"
        open={!emoticonsPopoverOpen && localMember.isHandsUp}
        getTooltipContainer={(node) => node}
        autoAdjustOverflow={false}
        placement={isElectronSharingScreen ? 'bottom' : 'top'}
        arrow={false}
        content={
          <div
            className="hands-down-content"
            onClick={(event) => {
              event.stopPropagation()
              neMeeting?.sendMemberControl(
                memberAction.handsDown,
                localMember.uuid
              )
            }}
          >
            <Emoji type={2} size={32} emojiKey="[举手]" />
            {t('handsUpDown')}
          </div>
        }
      />
    )
  }

  return (
    <Popover
      destroyTooltipOnHide
      align={
        props.align ??
        (isElectronSharingScreen ? { offset: [0, 7] } : { offset: [0, -7] })
      }
      arrow={false}
      trigger={['click']}
      rootClassName="emoticons-popover"
      open={emoticonsPopoverOpen}
      getTooltipContainer={(node) => node}
      onOpenChange={(open) => {
        setEmoticonsPopoverOpen(open)
      }}
      autoAdjustOverflow={props.autoAdjustOverflow ?? false}
      placement={
        props.placement ?? (isElectronSharingScreen ? 'bottom' : 'top')
      }
      content={
        <div>
          <div className="emoticons-list-container">
            {emojiKeys.map((emojiKey) => (
              <Emoji
                disabled={!meetingInfo.emojiRespPermission && !isHostOrCoHost}
                key={emojiKey}
                type={2}
                size={36}
                language={language}
                emojiKey={emojiKey}
                onClick={(emojiKey) => {
                  if (meetingInfo.emojiRespPermission || isHostOrCoHost) {
                    neMeeting?.sendEmoticon(emojiKey)
                  }

                  setEmoticonsPopoverOpen(false)
                }}
              />
            ))}
          </div>
          <div
            className="emoticons-hand-container"
            onClick={async () => {
              if (localMember.isHandsUp) {
                await neMeeting?.sendMemberControl(
                  memberAction.handsDown,
                  localMember.uuid
                )
              } else {
                await neMeeting?.sendMemberControl(
                  memberAction.handsUp,
                  localMember.uuid
                )
              }

              setEmoticonsPopoverOpen(false)
            }}
          >
            <Emoji type={2} size={32} emojiKey="[举手]" />
            {localMember.isHandsUp ? t('handsUpDown') : t('handsUp')}
          </div>
        </div>
      }
    >
      {showHandsUpPopoverContent && renderHandsUpPopoverContent()}
      {props.children}
    </Popover>
  )
}

function useEmoticonsButton(open?: boolean) {
  const { neMeeting } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()
  const { t } = useTranslation()
  const [
    emoticonsPermissionsPopoverOpen,
    setEmoticonsPermissionsPopoverOpen,
  ] = useState(false)

  const localMember = meetingInfo.localMember
  const isHostOrCoHost =
    localMember.role === Role.coHost || localMember.role === Role.host

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  const emoticonsBtn = {
    id: NEMenuIDs.emoticons,
    key: 'emoticons',
    popover: (children) => {
      return (
        <>
          {isHostOrCoHost && renderEmoticonsPermissionsPopoverContent()}
          <EmoticonsBtnPopover showHandsUpPopoverContent={open}>
            {children}
          </EmoticonsBtnPopover>
        </>
      )
    },
    icon: (
      <div>
        <svg className="icon iconfont" aria-hidden="true">
          <use xlinkHref="#iconbiaoqinghuiyingjushou"></use>
        </svg>
      </div>
    ),
    label: t('emoticons'),
    hidden: isElectronSharingScreen,
  }

  function renderEmoticonsPermissionsPopoverContent() {
    if (isElectronSharingScreen) return null

    return (
      <Popover
        destroyTooltipOnHide
        trigger={['click']}
        rootClassName="device-popover"
        open={emoticonsPermissionsPopoverOpen}
        getTooltipContainer={(node) => node}
        autoAdjustOverflow={false}
        placement={isElectronSharingScreen ? 'bottom' : 'top'}
        onOpenChange={setEmoticonsPermissionsPopoverOpen}
        afterOpenChange={setEmoticonsPermissionsPopoverOpen}
        arrow={false}
        zIndex={9999}
        content={
          <>
            <div className="nesetting">
              <div
                className="device-list-title"
                onClick={() => {
                  neMeeting
                    ?.securityControl({
                      [SecurityCtrlEnum.EMOJI_RESP_DISABLE]: !!meetingInfo.emojiRespPermission,
                    })
                    .then(() => {
                      setEmoticonsPermissionsPopoverOpen(false)
                    })
                    .catch((e) => {
                      Toast.fail(e.msg || e.message)
                    })
                }}
              >
                <svg
                  className="icon iconfont emoticons-permissions-icon"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconbiaoqinghuiying"></use>
                </svg>
                {t('allowMembersToReplyWithEmoticons')}
                {meetingInfo.emojiRespPermission ? (
                  <svg
                    className="icon iconfont iconcheck-line-regular1x-blue"
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconcheck-line-regular1x"></use>
                  </svg>
                ) : null}
              </div>
            </div>
          </>
        }
      >
        <div
          className="audio-video-devices-button"
          onClick={() => {
            setEmoticonsPermissionsPopoverOpen(!emoticonsPermissionsPopoverOpen)
          }}
        >
          {isElectronSharingScreen ? (
            <CaretDownOutlined />
          ) : (
            <CaretUpOutlined />
          )}
        </div>
      </Popover>
    )
  }

  return { emoticonsBtn }
}

export { EmoticonsBtnPopover }

export default useEmoticonsButton
