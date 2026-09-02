import { requestMeetingInfo } from '@/api'
import { Button, message } from 'antd'
import qs from 'qs'
import React, { useEffect, useMemo, useState } from 'react'
import { filterDate, filterTime } from '../../util/time'
import Styles from './index.less'

export default function IndexPage() {
  const [isDownLoaded, setIsDownLoaded] = useState<boolean>(true)
  const [isInvalidMeeting, setIsInvalidMeeting] = useState<boolean>(false)
  const [startTime, setStartTime] = useState<string>('')
  const [endTime, setEndTime] = useState<string>('')
  const [startDate, setStartDate] = useState<string>('')
  const [endDate, setEndDate] = useState<string>('')
  const [host, setHost] = useState<string>('')
  const [meetingId, setMeetingId] = useState<string>('')
  // const [meetingAppKey, setMeetingAppKey] = useState<string>('')
  // const [guestJoinType, setGuestJoinType] = useState<number>(0) // 0: 表示不允许访客入会，1: 表示支持手机号验证访客入会 2: 支持匿名访客入会
  const [showOpenBrowserTip, setShowOpenBrowser] = useState<boolean>(false)

  async function getMeetingInfo(jump?: boolean) {
    const query = qs.parse(window.location.href.split('?')[1]?.split('#/')[0])
    const { meeting } = query

    // 会议 code 不存在
    if (!meeting) {
      setIsInvalidMeeting(true)
      return
    }

    try {
      const res = await requestMeetingInfo(meeting as string)

      console.log('getMeetingInfo', res)
      setMeetingId(res.meetingNum)
      setHost(res.subject)
      setStartDate(filterDate(res.startTime))
      setStartTime(filterTime(res.startTime, res.type, false))
      setEndTime(filterTime(res.endTime, res.type, true))
      // setMeetingAppKey(res.meetingAppKey)
      // setGuestJoinType(res.guestJoinType)
      //type为3代表预约会议
      if (res.type === 3) {
        setEndDate(filterDate(res.endTime))
      } else {
        setEndDate(filterDate(res.startTime))
      }

      if (res.state === 0 || res.state === 4 || res.state === 5) {
        setIsInvalidMeeting(true)
        setIsDownLoaded(true)
      } else {
        console.log('start open')
        if (jump) {
          window.location.href = `nemeeting://meeting.netease.im/?meetingId=${res.meetingNum}&type=invitation`
        }

        return res
      }
    } catch (error) {
      setIsInvalidMeeting(true)
      setIsDownLoaded(true)
      console.log('error', error)
    }
  }

  useEffect(() => {
    getMeetingInfo(true)
  }, [])

  const copyTextToClipboard = (text: string) => {
    const textarea = document.createElement('textarea')

    textarea.setAttribute('readonly', 'readonly')
    textarea.innerHTML = text
    document.body.appendChild(textarea)
    textarea.setSelectionRange(0, 9999)
    textarea.select()
    if (document.execCommand) {
      document.execCommand('copy')
      console.log('复制成功')
    }

    document.body.removeChild(textarea)
  }

  // 判断是否需要提示通过默认浏览器打开地址，如微信浏览器
  const needOpenBrowser = () => {
    const ua = navigator.userAgent.toLowerCase()
    let needOpen = false

    // 微信
    if (ua.indexOf('micromessenger') !== -1) {
      needOpen = true
    } else if (ua.indexOf('popo') !== -1) {
      needOpen = true
      // qq
    } else if (ua.indexOf('qq') !== -1) {
      needOpen = true
    }

    if (needOpen) {
      setShowOpenBrowser(true)
    }

    return needOpen
  }

  const isH5 = useMemo(() => {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
      navigator.userAgent
    )
  }, [])

  const joinWebMeeting = async () => {
    let jumpUrl = isH5 ? process.env.h5JumpUrl : process.env.webJumpUrl

    if (location.origin === 'https://meeting.163.com') {
      jumpUrl = isH5
        ? 'https://meeting.163.com/app/#/h5/'
        : 'https://meeting.163.com/app/#/'
    }

    const res = await getMeetingInfo()

    if (res) {
      const { meetingNum, meetingAppKey, guestJoinType } = res

      window.location.href = `${jumpUrl}?meetingId=${meetingNum}&meetingAppKey=${meetingAppKey}&guestJoinType=${guestJoinType}&type=invitation`
    }
  }

  const joinMeeting = async () => {
    if (needOpenBrowser()) {
      return
    }

    const res = await getMeetingInfo()

    if (res) {
      window.location.href = `nemeeting://meeting.netease.im/?meetingId=${meetingId}&type=invitation`
      setIsDownLoaded(false)
    }
  }

  const gotoMeetingInfo = () => {
    setIsDownLoaded(true)
  }

  const handleCopy = () => {
    message.success('复制成功')
    copyTextToClipboard(meetingId)
  }

  const download = () => {
    window.location.href = 'https://meeting.163.com/'
  }

  return (
    <div>
      <div className={Styles.wrapper}></div>
      {isDownLoaded ? (
        <div className={Styles.invitePageWrapper}>
          <div className={Styles.card}>
            <div className={Styles.meetingLogo}>
              <p className={Styles.title}>网易会议</p>
              <svg
                width="74"
                height="74"
                viewBox="0 0 74 74"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                style={{
                  margin: '40px 0',
                }}
              >
                <path
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M37 0C34.5521 0 32.1041 0.367142 29.6839 1.10049C24.843 2.56812 20.3364 5.27802 14.5879 11.026L11.0259 14.5885C5.2779 20.3369 2.56753 24.8431 1.10037 29.6836C-0.36679 34.525 -0.36679 39.4753 1.10037 44.3162C2.56753 49.1571 5.2779 53.6638 11.0259 59.4122L14.5879 62.9742C20.3364 68.7222 24.843 71.4326 29.6839 72.8997C34.5248 74.3669 39.4752 74.3669 44.3165 72.8997C49.157 71.4326 53.6636 68.7222 59.4121 62.9742L62.9741 59.4122C68.7221 53.6638 71.432 49.1571 72.8996 44.3162C74.3668 39.4753 74.3668 34.525 72.8996 29.6836C71.432 24.8431 68.7221 20.3369 62.9741 14.5885L59.4121 11.026C53.6636 5.27802 49.157 2.56812 44.3165 1.10049C41.8959 0.367142 39.4479 0 37 0Z"
                  fill="url(#paint0_linear_3992_13905)"
                />
                <path
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M57.0875 49.5582L51.1686 45.415C49.3287 44.1271 48.2324 42.0219 48.2324 39.7759V34.2246C48.2324 31.9781 49.3287 29.8734 51.1686 28.5851L57.0875 24.4418C58.2283 23.6437 59.7955 24.4597 59.7955 25.8517V48.1483C59.7955 49.5408 58.2283 50.3568 57.0875 49.5582"
                  fill="white"
                />
                <path
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M24.4189 24.481H33.3341C40.2483 24.481 45.853 30.0857 45.853 36.9999C45.853 43.9141 40.2483 49.5189 33.3341 49.5189H24.4189C17.5047 49.5189 11.8999 43.9141 11.8999 36.9999C11.8999 30.0857 17.5047 24.481 24.4189 24.481"
                  fill="white"
                />
                <defs>
                  <linearGradient
                    id="paint0_linear_3992_13905"
                    x1="0.406249"
                    y1="0.812501"
                    x2="0.406249"
                    y2="74.0001"
                    gradientUnits="userSpaceOnUse"
                  >
                    <stop stopColor="#5996FF" />
                    <stop offset="1" stopColor="#2575FF" />
                  </linearGradient>
                </defs>
              </svg>
            </div>
            <div
              style={{ display: isInvalidMeeting ? 'none' : 'block' }}
              className={Styles.theme}
            >
              会议主题：{host}
            </div>
            <div
              style={{ display: isInvalidMeeting ? 'none' : 'block' }}
              className={Styles.meetingId}
            >
              会议ID：
              {meetingId}
              <span onClick={handleCopy} className={Styles.copyIcon}>
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 16 16"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <rect opacity="0.01" width="16" height="16" fill="#D8D8D8" />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M6.40611 1H11.2404L14.0081 3.90272V10.625C14.0081 11.5875 13.2206 12.375 12.2581 12.375H6.40611C5.44361 12.375 4.65611 11.5875 4.65611 10.625V2.75C4.65611 1.7875 5.44361 1 6.40611 1ZM4.59551 14.125H9.90611C10.3436 14.125 10.7811 13.6875 10.7811 13.25H11.6561C11.6561 14.2125 10.8686 15 9.90611 15H4.59551C2.51703 15 2.03111 13.7283 2.03111 12.316V5.375C2.03111 4.4125 2.81861 3.625 3.78111 3.625V4.5C3.34361 4.5 2.90611 4.85 2.90611 5.375V12.316C2.90611 13.4911 3.36381 14.125 4.59551 14.125ZM9.70639 10.6239H6.47945C6.21695 10.6239 6.04195 10.4489 6.04195 10.1864C6.04195 9.92386 6.21695 9.74886 6.47945 9.74886H9.70639C9.96889 9.74886 10.1439 9.92386 10.1439 10.1864C10.1439 10.4489 9.96889 10.6239 9.70639 10.6239ZM6.47945 8.87386H12.3314C12.5939 8.87386 12.7689 8.69886 12.7689 8.43636C12.7689 8.17386 12.5939 7.99886 12.3314 7.99886H6.47945C6.21695 7.99886 6.04195 8.17386 6.04195 8.43636C6.04195 8.69886 6.21695 8.87386 6.47945 8.87386ZM12.3314 7.12386H6.47945C6.21695 7.12386 6.04195 6.94886 6.04195 6.68636C6.04195 6.42386 6.21695 6.24886 6.47945 6.24886H12.3314C12.5939 6.24886 12.7689 6.42386 12.7689 6.68636C12.7689 6.94886 12.5939 7.12386 12.3314 7.12386ZM10.8492 2.40079V4.40587H12.8267L10.8492 2.40079Z"
                    fill="#337EFF"
                  />
                </svg>
              </span>
            </div>
            <div className={Styles.timeWrapper}>
              <div>
                <p className={Styles.time}>{startTime}</p>
                <p className={Styles.date}>{startDate}</p>
              </div>
              <div className={Styles.meetingStatusWrapper}>
                <div className={Styles.line}></div>
              </div>
              <div>
                <p className={Styles.time}>{endTime}</p>
                <p className={Styles.date}>{endDate}</p>
              </div>
            </div>
          </div>
          {isInvalidMeeting ? (
            <div className={Styles.invalidMeeting}>
              <svg
                width="80"
                height="105"
                viewBox="0 0 80 105"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                style={{ width: '80px', height: '105px' }}
              >
                <ellipse
                  cx="40"
                  cy="61.979"
                  rx="32.8125"
                  ry="4.375"
                  fill="#F2F2F2"
                />
                <path
                  d="M16.3021 5.10433C16.3021 4.50027 16.7918 4.01058 17.3958 4.01058H53.5895L62.9688 12.7503V60.521C62.9688 61.1251 62.4791 61.6147 61.875 61.6147H17.3958C16.7918 61.6147 16.3021 61.1251 16.3021 60.521V5.10433Z"
                  fill="white"
                  stroke="#D8D8D8"
                  strokeWidth="0.729167"
                />
                <path
                  d="M53.125 4.375H53.9485V11.9798C53.9485 12.5372 54.3786 12.9891 54.9092 12.9891H62.6042V13.8542H54.9092C53.9238 13.8542 53.125 13.015 53.125 11.9798V4.375Z"
                  fill="#DBDBDB"
                />
                <circle
                  opacity="0.5"
                  cx="71.2083"
                  cy="10.4121"
                  r="2.1875"
                  fill="#D8D8D8"
                />
                <circle
                  opacity="0.3"
                  cx="66.9791"
                  cy="5.10433"
                  r="1.45833"
                  fill="#D8D8D8"
                />
                <path
                  opacity="0.3"
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M75 4.73942C75 3.73265 74.1839 2.9165 73.1771 2.9165C72.1703 2.9165 71.3542 3.73265 71.3542 4.73942C71.3542 5.74619 72.1703 6.56234 73.1771 6.56234C74.1839 6.56234 75 5.74619 75 4.73942ZM72.0833 4.73958C72.0833 4.13552 72.573 3.64583 73.1771 3.64583C73.7811 3.64583 74.2708 4.13552 74.2708 4.73958C74.2708 5.34364 73.7811 5.83333 73.1771 5.83333C72.573 5.83333 72.0833 5.34364 72.0833 4.73958Z"
                  fill="#D8D8D8"
                />
                <path
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M53.9973 4.8623V11.8998C53.9973 11.8998 54.0656 12.9889 54.9092 12.9889C55.7528 12.9889 62.6042 12.9889 62.6042 12.9889L53.9973 4.8623Z"
                  fill="#FAFAFA"
                />
                <rect
                  x="37.4479"
                  y="23.6981"
                  width="32.0833"
                  height="23.3333"
                  rx="1.09375"
                  fill="white"
                  stroke="#D8D8D8"
                  strokeWidth="0.729167"
                  strokeDasharray="2.19"
                />
                <rect
                  x="44.375"
                  y="33.5415"
                  width="0.729167"
                  height="8.75"
                  rx="0.364583"
                  fill="#D8D8D8"
                />
                <rect
                  x="50.2083"
                  y="29.1665"
                  width="0.729167"
                  height="12.3958"
                  rx="0.364583"
                  fill="#D8D8D8"
                />
                <rect
                  x="56.0417"
                  y="35"
                  width="0.729167"
                  height="7.29167"
                  rx="0.364583"
                  fill="#D8D8D8"
                />
                <rect
                  x="61.875"
                  y="31.354"
                  width="0.729167"
                  height="10.2083"
                  rx="0.364583"
                  fill="#D8D8D8"
                />
                <path
                  d="M7.584 86.928C5.696 89.088 3.344 90.88 0.528 92.32L1.136 93.424C3.984 91.888 6.272 90.064 8 87.952C9.888 90.192 12.144 92.016 14.8 93.408L15.424 92.304C12.784 90.992 10.448 89.2 8.416 86.928H7.584ZM4.096 91.84V92.928H11.952V91.84H4.096ZM1.584 95.056V96.176H5.6C4.912 97.488 4.048 98.72 3.024 99.904C2.896 100.032 2.704 100.128 2.416 100.208L2.736 101.216C6.56 100.992 9.712 100.672 12.208 100.272C12.528 100.72 12.816 101.152 13.088 101.584L14.048 100.912C13.264 99.712 12.144 98.304 10.688 96.672L9.792 97.248C10.448 97.984 11.04 98.72 11.584 99.424C9.216 99.744 6.736 99.968 4.128 100.128C5.216 98.992 6.144 97.68 6.912 96.176H14.448V95.056H1.584ZM25.088 86.864L24.224 87.488C25.152 88.736 25.92 89.904 26.528 91.024L27.44 90.4C26.896 89.376 26.112 88.208 25.088 86.864ZM29.344 87.664C28.864 91.088 27.904 93.904 26.432 96.144C24.992 94.128 23.872 91.632 23.072 88.656L22.08 89.2C22.976 92.304 24.192 94.928 25.76 97.072C24.528 98.624 22.992 99.824 21.168 100.656L21.792 101.632C23.648 100.784 25.216 99.584 26.496 98.016C27.744 99.52 29.2 100.72 30.864 101.632L31.536 100.624C29.872 99.76 28.416 98.592 27.184 97.104C28.816 94.736 29.904 91.664 30.432 87.888L29.344 87.664ZM18.656 87.088L17.856 87.84C18.992 88.72 19.888 89.552 20.544 90.352L21.328 89.552C20.592 88.736 19.712 87.92 18.656 87.088ZM16.72 91.824V92.928H19.072V99.168C19.072 99.424 18.944 99.648 18.704 99.84L19.152 100.896C20.208 100.16 21.184 99.344 22.096 98.448L21.792 97.216C21.216 97.792 20.688 98.288 20.176 98.736V91.824H16.72ZM35.312 87.504V91.824H44.688V87.504H35.312ZM43.504 90.784H36.496V88.544H43.504V90.784ZM36.464 94.304L35.712 97.216H43.744C43.648 98.656 43.504 99.552 43.312 99.904C43.104 100.256 42.576 100.432 41.712 100.432C41.056 100.432 40.304 100.4 39.456 100.336L39.84 101.392C40.464 101.456 41.168 101.488 41.968 101.488C43.056 101.488 43.792 101.248 44.176 100.768C44.56 100.272 44.816 98.736 44.912 96.176H37.088L37.632 94.304H47.184V93.2H32.8V94.304H36.464ZM51.968 87.264C51.248 89.408 50.176 91.12 48.736 92.4L49.712 93.248C50.4 92.608 51.024 91.808 51.6 90.864H55.424V91.904C55.392 92.672 55.328 93.392 55.2 94.064H49.008V95.168H54.96C54.72 95.984 54.384 96.72 53.968 97.36C52.976 98.688 51.216 99.76 48.72 100.592L49.344 101.568C51.872 100.752 53.68 99.616 54.784 98.16C55.344 97.392 55.776 96.48 56.08 95.424C56.944 98.016 59.12 100.048 62.608 101.552L63.248 100.544C59.904 99.264 57.84 97.472 57.056 95.168H63.008V94.064H56.4C56.512 93.392 56.576 92.672 56.608 91.904V90.864H61.968V89.744H56.608V86.944H55.424V89.744H52.192C52.496 89.104 52.784 88.416 53.04 87.68L51.968 87.264ZM66.96 90.464C66.304 91.888 65.52 93.104 64.624 94.112L65.552 94.784C66.464 93.696 67.264 92.432 67.952 90.96L66.96 90.464ZM71.168 93.44L71.92 92.672C71.072 91.648 70.336 90.88 69.696 90.368L68.992 91.056C69.712 91.728 70.432 92.512 71.168 93.44ZM66.896 94.4L66.176 95.216C66.848 95.76 67.536 96.368 68.208 97.04C67.264 98.496 66.048 99.632 64.56 100.448L65.264 101.472C66.8 100.592 68.048 99.392 69.04 97.888C69.584 98.464 70.16 99.088 70.736 99.776L71.552 98.864C70.944 98.16 70.304 97.488 69.632 96.832C70.064 96 70.432 95.072 70.72 94.08L69.728 93.664C69.472 94.496 69.152 95.28 68.784 96.016C68.176 95.456 67.552 94.912 66.896 94.4ZM68.544 86.816L67.344 87.008C67.632 87.504 67.904 88.048 68.144 88.624H64.864V89.728H72.272V88.624H69.264C69.024 87.952 68.784 87.36 68.544 86.816ZM74.384 90.64H76.768C76.704 92.672 76.272 94.464 75.504 96.032C74.896 94.816 74.4 93.392 74.016 91.76C74.144 91.408 74.256 91.024 74.384 90.64ZM74.88 97.12C73.936 98.544 72.608 99.696 70.912 100.592L71.568 101.632C73.168 100.72 74.48 99.568 75.488 98.192C76.384 99.632 77.472 100.768 78.752 101.584L79.424 100.576C78.144 99.792 77.04 98.656 76.128 97.184C77.168 95.36 77.728 93.184 77.824 90.64H79.184V89.52H74.688C74.864 88.752 75.024 87.936 75.152 87.04L74 86.848C73.616 89.84 72.848 92.208 71.728 93.968L72.464 94.848C72.784 94.368 73.104 93.856 73.392 93.28C73.792 94.688 74.288 95.968 74.88 97.12Z"
                  fill="#999999"
                />
              </svg>
            </div>
          ) : (
            <div className={Styles.footer}>
              {isH5 ? (
                <>
                  <Button
                    onClick={joinMeeting}
                    icon={
                      <svg
                        style={{ marginRight: '10px' }}
                        xmlns="http://www.w3.org/2000/svg"
                        width="20"
                        height="20"
                        viewBox="0 0 20 20"
                        fill="none"
                      >
                        <path
                          d="M7.24626 1.85519C7.5812 1.85519 7.86783 1.97113 8.10615 2.20301C8.34447 2.43489 8.46363 2.7183 8.46363 3.05324V7.88407C8.46363 8.21901 8.34447 8.50564 8.10615 8.74396C7.86783 8.98228 7.5812 9.10144 7.24626 9.10144H2.41542C2.08049 9.10144 1.79708 8.98228 1.5652 8.74396C1.33332 8.50564 1.21738 8.21901 1.21738 7.88407V3.05324C1.21738 2.7183 1.33332 2.43489 1.5652 2.20301C1.79708 1.97113 2.08049 1.85519 2.41542 1.85519H7.24626ZM7.24626 11.5169C7.5812 11.5169 7.86783 11.6328 8.10615 11.8647C8.34447 12.0966 8.46363 12.38 8.46363 12.7149V17.5651C8.46363 17.9 8.34447 18.1834 8.10615 18.4153C7.86783 18.6472 7.5812 18.7631 7.24626 18.7631H2.41542C2.08049 18.7631 1.79708 18.6472 1.5652 18.4153C1.33332 18.1834 1.21738 17.9 1.21738 17.5651V12.7149C1.21738 12.38 1.33332 12.0966 1.5652 11.8647C1.79708 11.6328 2.08049 11.5169 2.41542 11.5169H7.24626ZM16.9273 11.5169C17.2622 11.5169 17.5456 11.6328 17.7775 11.8647C18.0094 12.0966 18.1253 12.38 18.1253 12.7149V17.5651C18.1253 17.9 18.0094 18.1834 17.7775 18.4153C17.5456 18.6472 17.2622 18.7631 16.9273 18.7631H12.0964C11.7615 18.7631 11.4749 18.6472 11.2365 18.4153C10.9982 18.1834 10.879 17.9 10.879 17.5651V12.7149C10.879 12.38 10.9982 12.0966 11.2365 11.8647C11.4749 11.6328 11.7615 11.5169 12.0964 11.5169H16.9273ZM19.6132 3.98076C19.8708 4.2384 19.9997 4.54113 19.9997 4.88895C19.9997 5.23677 19.8708 5.53306 19.6132 5.77783L16.0191 9.37197C15.7614 9.62961 15.4619 9.75844 15.1205 9.75844C14.7791 9.75844 14.4796 9.62961 14.222 9.37197L10.6278 5.77783C10.3831 5.53306 10.2607 5.23677 10.2607 4.88895C10.2607 4.54113 10.3831 4.2384 10.6278 3.98076L14.222 0.386614C14.4796 0.141851 14.7791 0.0194702 15.1205 0.0194702C15.4619 0.0194702 15.7614 0.141851 16.0191 0.386614L19.6132 3.98076Z"
                          fill="white"
                        />
                      </svg>
                    }
                    type="primary"
                    className={`${Styles.joinMeetingBtn} ${Styles.appJoinBtn}`}
                  >
                    APP入会
                  </Button>
                  <Button
                    onClick={joinWebMeeting}
                    icon={
                      <svg
                        style={{ marginRight: '10px' }}
                        xmlns="http://www.w3.org/2000/svg"
                        width="20"
                        height="20"
                        viewBox="0 0 21 20"
                        fill="none"
                      >
                        <g>
                          <path
                            d="M14.84 11.6553H19.4506C19.4862 11.3353 19.5006 11.0091 19.5006 10.6747C19.5006 9.10782 19.0799 7.63845 18.3456 6.37283C19.1049 4.35534 19.0781 2.64285 18.0612 1.6191C17.0943 0.656605 14.5006 0.812855 11.5687 2.11097C11.3518 2.09472 11.1331 2.08597 10.9118 2.08597C6.88749 2.08597 3.51126 4.85534 2.57751 8.58719C3.84 6.97095 5.16812 5.79908 6.94187 4.94596C6.78062 5.09721 5.83937 6.03283 5.68062 6.19158C1.00252 10.8684 -0.4731 16.9784 1.11502 18.5665C2.32189 19.7728 4.50875 19.569 7.02062 18.339C8.18873 18.934 9.5106 19.269 10.9118 19.269C14.6837 19.269 17.8806 16.8409 19.0387 13.4597H14.3925C13.7531 14.639 12.5031 15.4415 11.0681 15.4415C9.6331 15.4415 8.38311 14.639 7.74374 13.4597C7.45936 12.9272 7.29624 12.3159 7.29624 11.6697V11.6553H14.84ZM7.30249 9.38907C7.40936 7.4922 8.98623 5.97908 10.9112 5.97908C12.8362 5.97908 14.4137 7.4922 14.52 9.38907H7.30249ZM18.0187 2.57285C18.6737 3.23472 18.6574 4.45221 18.0968 5.97158C17.1368 4.50846 15.7431 3.35534 14.0968 2.69722C15.8574 1.94285 17.2887 1.84285 18.0187 2.57285ZM2.32564 18.2653C1.49002 17.4297 1.74189 15.6753 2.81813 13.5615C3.48813 15.4415 4.79375 17.0203 6.47687 18.0372C4.61375 18.8828 3.08813 19.0265 2.32564 18.2653Z"
                            fill="#8C8F9A"
                          />
                        </g>
                        <defs>
                          <clipPath id="clip0_13115_18990">
                            <rect
                              width="20"
                              height="20"
                              fill="white"
                              transform="translate(0.5)"
                            />
                          </clipPath>
                        </defs>
                      </svg>
                    }
                    className={`${Styles.joinMeetingBtn} ${Styles.webJoinBtn}`}
                  >
                    网页版入会
                  </Button>
                </>
              ) : (
                <Button
                  onClick={joinWebMeeting}
                  type="primary"
                  className={`${Styles.joinMeetingBtn} ${Styles.webJoinBtn}`}
                  icon={
                    <img
                      className={Styles.webJoinBtnIcon}
                      src={require('../../assets/Frame.png')}
                      alt="logo"
                    />
                  }
                >
                  加入会议
                </Button>
              )}
            </div>
          )}
        </div>
      ) : (
        <div className={Styles.downloadPageWrapper}>
          <div className={Styles.downloadPage}>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                flexDirection: 'column',
              }}
            >
              <div>
                <svg
                  width="74"
                  height="74"
                  viewBox="0 0 74 74"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  style={{
                    width: '70px',
                    height: '70px',
                    marginTop: '70px',
                    marginBottom: '40px',
                  }}
                >
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M37 0C34.5521 0 32.1041 0.367142 29.6839 1.10049C24.843 2.56812 20.3364 5.27802 14.5879 11.026L11.0259 14.5885C5.2779 20.3369 2.56753 24.8431 1.10037 29.6836C-0.36679 34.525 -0.36679 39.4753 1.10037 44.3162C2.56753 49.1571 5.2779 53.6638 11.0259 59.4122L14.5879 62.9742C20.3364 68.7222 24.843 71.4326 29.6839 72.8997C34.5248 74.3669 39.4752 74.3669 44.3165 72.8997C49.157 71.4326 53.6636 68.7222 59.4121 62.9742L62.9741 59.4122C68.7221 53.6638 71.432 49.1571 72.8996 44.3162C74.3668 39.4753 74.3668 34.525 72.8996 29.6836C71.432 24.8431 68.7221 20.3369 62.9741 14.5885L59.4121 11.026C53.6636 5.27802 49.157 2.56812 44.3165 1.10049C41.8959 0.367142 39.4479 0 37 0Z"
                    fill="url(#paint0_linear_3992_13905)"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M57.0875 49.5582L51.1686 45.415C49.3287 44.1271 48.2324 42.0219 48.2324 39.7759V34.2246C48.2324 31.9781 49.3287 29.8734 51.1686 28.5851L57.0875 24.4418C58.2283 23.6437 59.7955 24.4597 59.7955 25.8517V48.1483C59.7955 49.5408 58.2283 50.3568 57.0875 49.5582"
                    fill="white"
                  />
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M24.4189 24.481H33.3341C40.2483 24.481 45.853 30.0857 45.853 36.9999C45.853 43.9141 40.2483 49.5189 33.3341 49.5189H24.4189C17.5047 49.5189 11.8999 43.9141 11.8999 36.9999C11.8999 30.0857 17.5047 24.481 24.4189 24.481"
                    fill="white"
                  />
                  <defs>
                    <linearGradient
                      id="paint0_linear_3992_13905"
                      x1="0.406249"
                      y1="0.812501"
                      x2="0.406249"
                      y2="74.0001"
                      gradientUnits="userSpaceOnUse"
                    >
                      <stop stopColor="#5996FF" />
                      <stop offset="1" stopColor="#2575FF" />
                    </linearGradient>
                  </defs>
                </svg>
              </div>
              <div style={{ fontSize: '16px', color: '#2d3033' }}>
                该页面会唤起网易会议
              </div>
              <div className={Styles.downloadDesc}>
                <p>若无法正常跳转，请先点击【立即下载】按钮</p>
                <p>
                  或
                  <span
                    onClick={gotoMeetingInfo}
                    style={{ color: '#006fff', cursor: 'pointer' }}
                  >
                    返回会议详情
                  </span>
                  ， 通过其他方式加入当前会议。
                </p>
                <p>
                  若您已安装了网易会议，请
                  <span
                    onClick={joinMeeting}
                    style={{ color: '#006fff', cursor: 'pointer' }}
                  >
                    点击此处。
                  </span>
                </p>
                <p>
                  如果浏览器对话框弹出，请您点击【网易会议】按钮，加入会议。
                </p>
              </div>
            </div>
            <Button
              onClick={download}
              type="primary"
              shape="round"
              className={Styles.joinMeetingBtn}
            >
              立即下载
            </Button>
          </div>
        </div>
      )}
      {showOpenBrowserTip && (
        <div className={Styles.openBrowserTip}>
          <img
            className={Styles.openBrowserTipImg}
            src={require('../../assets/openBrowserTip.png')}
            alt="logo"
          />
        </div>
      )}
    </div>
  )
}
