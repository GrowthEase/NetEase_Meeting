import { css } from '@emotion/css'
import { Popup, PopupProps } from 'antd-mobile/es'
import React, { useMemo } from 'react'
import { useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import MeetingPlugin from '../../common/PlugIn/MeetingPlugin'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import { useTranslation } from 'react-i18next'

const popupBodyCls = css`
  height: 100%;
  z-index: 9999;
`

const pluginHeaderCls = css`
  height: 40px;
  text-align: center;
  color: #333;
  line-height: 40px;
  font-size: 16px;
`

const pluginHeaderCloseCls = css`
  position: absolute;
  left: 10px;
  font-size: 16px;
  color: #337eff;
  height: 40px;
  line-height: 40px;
`

const pluginContainerCls = css`
  height: calc(100% - 40px);
`

const MeetingPluginPopup: React.FC<PopupProps> = () => {
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { pluginList } = useMeetingPlugin()
  const { t } = useTranslation()
  const i18n = {
    globalClose: t('globalClose'),
  }

  // 复用 web 的右侧抽屉的逻辑
  const { rightDrawerTabActiveKey } = meetingInfo

  const plugin = pluginList.find(
    (item) => item.pluginId === rightDrawerTabActiveKey
  )

  const popupVisible = useMemo(() => {
    if (rightDrawerTabActiveKey && plugin) {
      return true
    }

    return false
  }, [rightDrawerTabActiveKey, plugin])

  const pluginUrl = useMemo(() => {
    let url = plugin?.homeUrl ?? ''

    if (meetingInfo.pluginUrlSearch) {
      if (url.includes('?')) {
        url += `&${meetingInfo.pluginUrlSearch}`
      } else {
        url += `?${meetingInfo.pluginUrlSearch}`
      }
    }

    return url
  }, [plugin, meetingInfo.pluginUrlSearch])

  const onClose = () => {
    // 关闭插件
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        rightDrawerTabActiveKey: '',
      },
    })
  }

  return (
    <Popup
      bodyClassName={popupBodyCls}
      visible={popupVisible}
      onMaskClick={onClose}
      onClose={onClose}
      destroyOnClose
    >
      {plugin ? (
        <>
          <div className={pluginHeaderCls}>
            <div className={pluginHeaderCloseCls} onClick={onClose}>
              {i18n.globalClose}
            </div>
            {plugin.name}
          </div>
          <div className={pluginContainerCls}>
            <MeetingPlugin
              url={pluginUrl}
              pluginId={plugin.pluginId}
              isInMeeting={true}
            />
          </div>
        </>
      ) : null}
    </Popup>
  )
}

export default MeetingPluginPopup
