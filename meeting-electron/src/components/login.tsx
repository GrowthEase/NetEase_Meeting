import React, { useContext, useState } from 'react'
import {
  ActionType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
} from '../types'
import { GlobalContext, MeetingInfoContext } from '../store'
import { UserEventType } from '../types/innerType'

interface LoginProps {
  className?: string
}
const Login: React.FC<LoginProps> = (props) => {
  const [username, setUsername] = useState<string>('')
  const [accountId, setAccountId] = useState('')
  const [token, setToken] = useState<string>('')
  const [isOpenVideo, setIsOpenVideo] = useState(false)
  const [isOpenAudio, setIsOpenAudio] = useState(false)
  const [nickname, setNickname] = useState('')
  const [password, setPassword] = useState('')
  const [meetingId, setMeetingId] = useState<string>('')
  const [systemSupportFlag, setSystemSupportFlag] = useState<boolean | null>(
    null
  )
  const { neMeeting } = useContext<GlobalContextInterface>(GlobalContext)
  const { outEventEmitter } = useContext<GlobalContextInterface>(GlobalContext)
  const { dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const handleUsernameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setUsername(e.target.value)
  }

  const handleTokenChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setToken(e.target.value)
  }

  const handleMeetingIdChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setMeetingId(e.target.value)
  }

  const handleAudioChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log('handleAudioChange', e)
    e.persist()
    setIsOpenAudio(e.target.checked)
  }

  const handleVideoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    e.persist()
    console.log('handleVideoChange', e)
    setIsOpenVideo(e.target.checked)
  }

  const handleNicknameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setNickname(e.target.value)
  }

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value)
  }

  const handleAccountIdChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setAccountId(e.target.value)
  }

  const login = () => {
    const options = {
      accountId,
      accountToken: token,
    }
    const callback = () => {
      console.log('登录')
    }

    outEventEmitter?.emit(UserEventType.Login, { options, callback })
  }

  const logout = () => {
    const callback = () => {
      console.log('登出')
    }

    outEventEmitter?.emit(UserEventType.Logout, { callback })
  }

  const loginWithPassWord = () => {
    const options = {
      username,
      password,
    }
    const callback = () => {
      console.log('密码登录')
    }

    outEventEmitter?.emit(UserEventType.LoginWithPassword, {
      options,
      callback,
    })
  }

  const joinMeeting = () => {
    const options = {
      meetingNum: meetingId,
      nickName: nickname,
      video: isOpenVideo ? 1 : 2,
      audio: isOpenAudio ? 1 : 2,
    }
    const callback = (e: any) => {
      if (e) {
        console.log(e, 'joinMeeting')
        return
      }

      console.log('加入会议成功')
      const meeting = neMeeting?.getMeetingInfo()

      if (meeting) {
        dispatch &&
          dispatch({
            type: ActionType.SET_MEETING,
            data: meeting,
          })
      }
    }

    outEventEmitter?.emit(UserEventType.JoinMeeting, { options, callback })
  }

  const anonymousJoin = () => {
    const options = {
      meetingNum: meetingId,
      nickName: nickname,
      video: isOpenVideo ? 1 : 2,
      audio: isOpenAudio ? 1 : 2,
    }
    const callback = (e: any) => {
      if (e) {
        console.log(e, 'anonymousJoin')
        return
      }

      console.log('加入会议成功')
      const meeting = neMeeting?.getMeetingInfo()

      if (meeting) {
        dispatch &&
          dispatch({
            type: ActionType.SET_MEETING,
            data: meeting,
          })
      }
    }

    outEventEmitter?.emit(UserEventType.AnonymousJoinMeeting, {
      options,
      callback,
    })
  }

  const checkStystem = async () => {
    const result = await neMeeting?.checkSystemRequirements()

    setSystemSupportFlag(result || false)
  }

  return (
    <div className={props.className}>
      <div>
        <button onClick={checkStystem}>检查浏览器兼容性</button>
        <span>
          结果：
          {typeof systemSupportFlag === 'boolean'
            ? systemSupportFlag
              ? '支持'
              : '不支持'
            : '--'}
        </span>
      </div>
      <div>
        <input
          value={username}
          placeholder={'用户名'}
          style={{ width: 110 }}
          onChange={handleUsernameChange}
        />
        <input
          value={password}
          placeholder={'密码'}
          style={{ width: 110 }}
          onChange={handlePasswordChange}
        />
        <button onClick={loginWithPassWord}>密码登录</button>
      </div>
      <div>
        <input
          value={accountId}
          placeholder={'accountId'}
          style={{ width: 110 }}
          onChange={handleAccountIdChange}
        />
        <input
          value={token}
          placeholder={'accountToken'}
          style={{ width: 110 }}
          onChange={handleTokenChange}
        />
        <button onClick={login}>登录</button>
      </div>
      <div>
        <button onClick={logout}>登出</button>
      </div>
      <div>
        <input
          value={meetingId}
          placeholder={'会议号'}
          style={{ width: 110 }}
          onChange={handleMeetingIdChange}
        />
        <input
          value={nickname}
          placeholder={'昵称'}
          style={{ width: 110 }}
          onChange={handleNicknameChange}
        />
      </div>
      <div>
        <label>
          <input
            type="checkbox"
            name=""
            id=""
            className="audio"
            onChange={handleAudioChange}
          />
          开启音频
        </label>
        <label>
          <input
            type="checkbox"
            name=""
            id=""
            className="video"
            onChange={handleVideoChange}
          />
          开启视频
        </label>
        {/*<button onClick={createMeeting}>创建会议</button>*/}
        <button onClick={joinMeeting}>加入会议</button>
        <button onClick={anonymousJoin}>匿名入会</button>
      </div>
    </div>
  )
}

export default Login
