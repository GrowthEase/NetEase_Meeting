import { css } from '@emotion/css'
import { Drawer, DrawerProps } from 'antd'
import classNames from 'classnames'
import React, { useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import { useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import MeetingNotificationList from '../../common/Notification/List'
import MeetingPlugin from '../../common/PlugIn/MeetingPlugin'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import Chatroom from '../Chatroom/Chatroom'
import MemberList from '../MemberList'
import './index.less'

// interface MeetingRightDrawerProps extends DrawerProps {}

const MeetingRightDrawer: React.FC<DrawerProps> = ({ ...restProps }) => {
  const prefixCls = 'nemeeting-right-drawer'
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { pluginList, onClickPlugin } = useMeetingPlugin()

  const { rightDrawerTabs, rightDrawerTabActiveKey } = meetingInfo

  const navContainerCls =
    rightDrawerTabs.length > 3
      ? css`
          width: ${rightDrawerTabs.length * 106.6}px;
        `
      : css`
          width: 100%;
        `

  const getClsWithPrefix = (cls: string) => {
    return `${prefixCls}-${cls}`
  }

  function handleTabChange(key: string) {
    // 点击chatroom tab时，清空未读消息数

    if (['chatroom', 'memberList', 'notification'].includes(key)) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          unReadChatroomMsgCount: 0,
        },
      })
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          rightDrawerTabActiveKey: key,
        },
      })
    } else {
      const plugin = pluginList.find((item) => item.pluginId === key)
      plugin && onClickPlugin(plugin)
    }
  }

  function handleCloseTab(key: string) {
    const newTabs = rightDrawerTabs.filter((item) => item.key !== key)
    let newActiveKey = rightDrawerTabActiveKey
    if (key === rightDrawerTabActiveKey && newTabs.length > 0) {
      newActiveKey = newTabs[newTabs.length - 1].key
    }
    if (newTabs.length === 0) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          rightDrawerTabs: [],
          rightDrawerTabActiveKey: '',
        },
      })
    } else {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          rightDrawerTabs: newTabs,
          rightDrawerTabActiveKey: newActiveKey,
        },
      })
    }
  }

  useEffect(() => {
    if (rightDrawerTabActiveKey) {
      setTimeout(() => {
        const dom = document.getElementById(rightDrawerTabActiveKey)
        dom &&
          dom.scrollIntoView({
            behavior: 'smooth',
            block: 'nearest',
            inline: 'start',
          })
      }, 100)
    }
  }, [rightDrawerTabActiveKey])

  return (
    <Drawer
      title={null}
      placement="right"
      width={320}
      mask={false}
      maskClosable={false}
      keyboard={false}
      closable={false}
      forceRender
      getContainer={() =>
        document.getElementById('ne-web-meeting') as HTMLElement
      }
      rootStyle={{
        position: 'absolute',
        top: window.isElectronNative ? 28 : 0,
      }}
      rootClassName={classNames(
        getClsWithPrefix('root'),
        'nemeeting-drawer-need-watermark'
      )}
      open={rightDrawerTabs.length > 0}
      {...restProps}
    >
      <div className={getClsWithPrefix('container')}>
        <div className={getClsWithPrefix('nav')}>
          <div
            className={classNames(
              getClsWithPrefix('nav-container'),
              navContainerCls
            )}
          >
            {rightDrawerTabs.map((item) => {
              if (item.key === 'chatroom') {
                item.label = t('chat')
              }
              if (item.key === 'memberList') {
                item.label = t('participants')
              }
              if (item.key === 'notification') {
                item.label = t('notifyCenter')
              }
              return (
                <div
                  id={item.key}
                  key={item.key}
                  className={classNames(getClsWithPrefix('nav-item-wrapper'), {
                    active: item.key === rightDrawerTabActiveKey,
                    one: rightDrawerTabs.length === 1,
                  })}
                  onClick={() => handleTabChange(item.key)}
                >
                  <div className={getClsWithPrefix('nav-item')}>
                    <span
                      className={getClsWithPrefix('nav-item-label')}
                      title={item.label}
                    >
                      {item.label}
                    </span>
                    <svg
                      className={classNames('icon iconfont close-icon')}
                      aria-hidden="true"
                      onClick={(e) => {
                        e.stopPropagation()
                        handleCloseTab(item.key)
                      }}
                    >
                      <use xlinkHref="#iconcross" />
                    </svg>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
        <div
          className={classNames(getClsWithPrefix('content'), {
            ['content-show']: rightDrawerTabActiveKey === 'memberList',
          })}
        >
          <MemberList />
        </div>
        <div
          className={classNames(getClsWithPrefix('content'), {
            ['content-show']: rightDrawerTabActiveKey === 'notification',
          })}
        >
          <MeetingNotificationList
            sessionIds={[]}
            onClick={(action) => {
              if (action?.startsWith('meeting://open_plugin')) {
                onClickPlugin(action)
              }
            }}
          />
        </div>
        <div
          className={classNames(getClsWithPrefix('content'), {
            ['content-show']: rightDrawerTabActiveKey === 'chatroom',
          })}
        >
          <Chatroom
            visible={
              rightDrawerTabs.length > 0 &&
              rightDrawerTabActiveKey === 'chatroom'
            }
          />
        </div>
        {pluginList.map((plugin) => {
          const isOpen = rightDrawerTabs.find(
            (item) => item.key === plugin.pluginId
          )
          return isOpen ? (
            <div
              key={plugin.pluginId}
              className={classNames(getClsWithPrefix('content'), {
                ['content-show']: rightDrawerTabActiveKey === plugin.pluginId,
              })}
            >
              <MeetingPlugin
                url={plugin.homeUrl}
                pluginId={plugin.pluginId}
                isInMeeting={true}
              />
            </div>
          ) : null
        })}
      </div>
    </Drawer>
  )
}

export default MeetingRightDrawer
