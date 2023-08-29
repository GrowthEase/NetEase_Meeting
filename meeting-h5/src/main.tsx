import React from 'react'
import ReactDOM from 'react-dom'
import AppH5 from './AppH5'
import './index.less'
import { GlobalContextProvider, MeetingInfoContextProvider } from './store'
import NERoom from 'neroom-web-sdk'
import Eventemitter from 'eventemitter3'
import NEMeetingService from './services/NEMeeting'
import Login from './components/login'
import { createMeetingInfoFactory } from './services'
import Auth from './components/Auth'

// 外部用户监听使用
const outEventEmitter = new Eventemitter()
const roomkit = new NERoom()
const eventEmitter = new Eventemitter()
const joinLoading = undefined
const neMeeting = new NEMeetingService({ roomkit, eventEmitter })
neMeeting.init({
  appKey: '4649991c6ab7cc5a4309ccf25d8793e5',
  meetingServerDomain: 'https://roomkit-dev.netease.im',
})

ReactDOM.render(
  <GlobalContextProvider
    outEventEmitter={outEventEmitter}
    eventEmitter={eventEmitter}
    neMeeting={neMeeting}
    joinLoading={joinLoading}
  >
    <MeetingInfoContextProvider
      memberList={[]}
      meetingInfo={createMeetingInfoFactory()}
    >
      <Login />
      <Auth />
      <AppH5 width={0} height={0} />
    </MeetingInfoContextProvider>
  </GlobalContextProvider>,
  document.getElementById('root')!
)
