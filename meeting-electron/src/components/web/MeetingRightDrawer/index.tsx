import { Drawer, DrawerProps } from 'antd'
import classNames from 'classnames'
import React from 'react'
import { useMeetingInfoContext } from '../../../store'
import { ActionType } from '../../../types'
import Chatroom from '../Chatroom/Chatroom'
import MemberList from '../MemberList'
import { useTranslation } from 'react-i18next'
import './index.less'

// interface MeetingRightDrawerProps extends DrawerProps {}

const MeetingRightDrawer: React.FC<DrawerProps> = ({ ...restProps }) => {
  const prefixCls = 'nemeeting-right-drawer'
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()

  const { rightDrawerTabs, rightDrawerTabActiveKey } = meetingInfo

  const getClsWithPrefix = (cls: string) => {
    return `${prefixCls}-${cls}`
  }

  function handleTabChange(key: string) {
    // 点击chatroom tab时，清空未读消息数
    if (key === 'chatroom') {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          unReadChatroomMsgCount: 0,
        },
      })
    }
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        rightDrawerTabActiveKey: key,
      },
    })
  }

  function handleCloseTab(key: string) {
    const newTabs = rightDrawerTabs.filter((item) => item.key !== key)
    let newActiveKey = rightDrawerTabActiveKey
    if (key === rightDrawerTabActiveKey && newTabs.length > 0) {
      newActiveKey = newTabs[newTabs.length - 1].key
    }
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        rightDrawerTabs: newTabs,
        rightDrawerTabActiveKey: newActiveKey,
      },
    })
  }

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
          {rightDrawerTabs.map((item) => {
            if (item.key === 'chatroom') {
              item.label = t('chat')
            }
            if (item.key === 'memberList') {
              item.label = t('memberListTitle')
            }
            return (
              <div
                key={item.key}
                className={classNames(getClsWithPrefix('nav-item-wrapper'), {
                  active: item.key === rightDrawerTabActiveKey,
                  one: rightDrawerTabs.length === 1,
                })}
                onClick={() => handleTabChange(item.key)}
              >
                <div className={getClsWithPrefix('nav-item')}>
                  {item.label}
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
        <div
          className={classNames(getClsWithPrefix('content'), {
            ['content-show']: rightDrawerTabActiveKey === 'memberList',
          })}
        >
          <MemberList />
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
      </div>
    </Drawer>
  )
}

export default MeetingRightDrawer
