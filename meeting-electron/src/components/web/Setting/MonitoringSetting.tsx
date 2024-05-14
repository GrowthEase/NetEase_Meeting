import { Progress, Radio } from 'antd'
import React, { useEffect } from 'react'
import './index.less'

import { useTranslation } from 'react-i18next'

const MonitoringSetting: React.FC = () => {
  const { t } = useTranslation()

  const onLocalAudioStatsTimerRef = React.useRef<NodeJS.Timeout>()
  const onLocalVideoStatsTimerRef = React.useRef<NodeJS.Timeout>()
  const onRemoteAudioStats = React.useRef<NodeJS.Timeout>()
  const onRemoteVideoStats = React.useRef<NodeJS.Timeout>()
  const [tab, setTab] = React.useState<'overall' | 'av'>('overall')
  const [sysInfo, setSysInfo] = React.useState({
    cpu: {
      speed: 0,
      core: 0,
      appPercent: 0,
      otherPercent: 0,
    },
    memory: {
      total: 16,
      used: 8,
      app: 0,
    },
    network: {
      desc: '',
      type: '',
      rtt: 0,
      txKBitRate: 0, // 上行码率
      rxKBitRate: 0, // 下行码率
      txPacketLossRate: 0, // 上行丢包率
      rxPacketLossRate: 0, // 下行丢包率
    },
    audio: {
      txKBitRate: 0, // 上行码率
      rxKBitRate: 0, // 下行码率
      recordVolume: 0, // 录音
      playVolume: 0, // 播放
    },
    video: {
      txKBitRate: 0, // 上行码率
      rxKBitRate: 0, // 下行码率
      txHz: 0, // 上行帧率
      rxHz: 0, // 下行帧率
      txResolution: '--', // 上行分辨率
      rxResolution: '--', // 下行分辨率
    },
    screen: {
      txKBitRate: 0, // 上行码率
      rxKBitRate: 0, // 下行码率
      txHz: 0, // 上行帧率
      rxHz: 0, // 下行帧率
      txResolution: '--', // 上行分辨率
      rxResolution: '--', // 下行分辨率
    },
  })

  const cpuLabel = `${sysInfo.cpu.speed.toFixed(2)} GHz ${
    sysInfo.cpu.core
  }-Core`

  const networkRttLabel = `${t('delay')} ${sysInfo.network.rtt} ms`

  function openMonitoringWindow(type: string) {
    const parentWindow = window.parent
    parentWindow?.postMessage(
      {
        event: 'openWindow',
        payload: {
          name: 'monitoringWindow',
          postMessageData: {
            event: 'monitoringType',
            payload: type,
          },
        },
      },
      parentWindow.origin
    )
  }

  /**
   * 根据 sdk 返回信息，更新网络信息和视频信息
   * @param event
   * @param data
   */
  function handlePostMessage(e: MessageEvent) {
    const { event, payload } = e.data
    if (event === 'onRtcStats') {
      setSysInfo((prev) => {
        return {
          ...prev,
          network: {
            ...prev.network,
            rtt: payload.downRtt + payload.upRtt,
            txKBitRate: payload.txAudioKBitRate + payload.txVideoKBitRate,
            rxKBitRate: payload.rxAudioKBitRate + payload.rxVideoKBitRate,
            txPacketLossRate:
              payload.txAudioPacketLossRate + payload.txVideoPacketLossRate,
            rxPacketLossRate:
              payload.rxAudioPacketLossRate + payload.rxVideoPacketLossRate,
          },
          audio: {
            ...prev.audio,
            txKBitRate: payload.txAudioKBitRate,
            rxKBitRate: payload.rxAudioKBitRate,
          },
          video: {
            ...prev.video,
            txKBitRate: payload.txVideoKBitRate,
            rxKBitRate: payload.rxVideoKBitRate,
          },
        }
      })
    } else if (event === 'onLocalAudioStats') {
      const maxRecordVolume = payload.reduce((prev, current) => {
        return prev > current.capVolume ? prev : current.capVolume
      }, 0)
      setSysInfo((prev) => {
        return {
          ...prev,
          audio: {
            ...prev.audio,
            recordVolume: maxRecordVolume,
          },
        }
      })
      onLocalAudioStatsTimerRef.current &&
        clearTimeout(onLocalAudioStatsTimerRef.current)
      onLocalAudioStatsTimerRef.current = setTimeout(() => {
        setSysInfo((prev) => {
          return {
            ...prev,
            audio: {
              ...prev.audio,
              recordVolume: 0,
            },
          }
        })
        onLocalAudioStatsTimerRef.current = undefined
      }, 3000)
    } else if (event === 'onRemoteAudioStats') {
      const arr = Object.values(payload).flat() as Array<{ volume: number }>
      console.log('onRemoteAudioStats', arr)
      const maxPlayVolume = arr.reduce((prev, current) => {
        return prev > current.volume ? prev : current.volume
      }, 0)
      setSysInfo((prev) => {
        return {
          ...prev,
          audio: {
            ...prev.audio,
            playVolume: maxPlayVolume,
          },
        }
      })
      onRemoteAudioStats.current && clearTimeout(onRemoteAudioStats.current)
      onRemoteAudioStats.current = setTimeout(() => {
        setSysInfo((prev) => {
          return {
            ...prev,
            audio: {
              ...prev.audio,
              playVolume: 0,
            },
          }
        })
        onRemoteAudioStats.current = undefined
      }, 3000)
    } else if (event === 'onLocalVideoStats') {
      const video = payload.find((item) => item.layerType === 1)
      const screen = payload.find((item) => item.layerType === 2)
      if (video) {
        setSysInfo((prev) => {
          return {
            ...prev,
            video: {
              ...prev.video,
              txHz: video.captureFrameRate,
              txResolution: video.width + 'x' + video.height,
            },
          }
        })
      }
      if (screen) {
        setSysInfo((prev) => {
          return {
            ...prev,
            screen: {
              ...prev.screen,
              txHz: screen.captureFrameRate,
              txResolution: screen.width + 'x' + screen.height,
              txKBitRate: screen.sentBitRate,
            },
          }
        })
      }
      onLocalVideoStatsTimerRef.current &&
        clearTimeout(onLocalVideoStatsTimerRef.current)
      onLocalVideoStatsTimerRef.current = setTimeout(() => {
        setSysInfo((prev) => {
          return {
            ...prev,
            video: {
              ...prev.video,
              txHz: 0,
              txResolution: '--',
            },
            screen: {
              ...prev.screen,
              txHz: 0,
              txResolution: '--',
              txKBitRate: 0,
            },
          }
        })
        onLocalAudioStatsTimerRef.current = undefined
      }, 3000)
    } else if (event === 'onRemoteVideoStats') {
      const videos = Object.values(payload).flat() as Array<{
        width: number
        height: number
        layerType: number
        receivedFrameRate: number
        receivedBitRate: number
      }>
      let maxVideo
      if (videos.length > 0) {
        videos.forEach((video) => {
          if (video.layerType !== 1) return
          if (!maxVideo) {
            maxVideo = video
          } else {
            if (maxVideo.width * maxVideo.height < video.width * video.height) {
              maxVideo = video
            }
          }
        })
      }
      const screen = videos.find((item) => item.layerType === 2)
      if (maxVideo) {
        setSysInfo((prev) => {
          return {
            ...prev,
            video: {
              ...prev.video,
              rxHz: maxVideo.receivedFrameRate,
              rxResolution: maxVideo.width + 'x' + maxVideo.height,
            },
          }
        })
      }
      if (screen) {
        setSysInfo((prev) => {
          return {
            ...prev,
            screen: {
              ...prev.screen,
              rxHz: screen.receivedFrameRate,
              rxResolution: screen.width + 'x' + screen.height,
              rxKBitRate: screen.receivedBitRate,
            },
          }
        })
      }
      onRemoteVideoStats.current && clearTimeout(onRemoteVideoStats.current)
      onRemoteVideoStats.current = setTimeout(() => {
        setSysInfo((prev) => {
          return {
            ...prev,
            video: {
              ...prev.video,
              rxHz: 0,
              rxResolution: '--',
            },
            screen: {
              ...prev.screen,
              rxHz: 0,
              rxResolution: '--',
              rxKBitRate: 0,
            },
          }
        })
        onRemoteVideoStats.current = undefined
      }, 3000)
    }
  }

  /**
   * 根据 node 返回信息，更新系统信息
   * @param event
   * @param data
   */
  function handleSysInfo(event, data) {
    console.log('handleSysInfo', event, data)
    const memoryTotal = data.memory.total / 1024 / 1024 / 1024
    const memoryUsed = data.memory.used / 1024 / 1024 / 1024

    const memoryApp =
      data.appMetrics.reduce((prev, curr) => {
        return prev + curr.memory.workingSetSize
      }, 0) /
      1000 /
      2

    const cpuAppPercent = data.appMetrics.reduce((prev, curr) => {
      return prev + curr.cpu.percentCPUUsage
    }, 0)

    const cpuOtherPercent =
      data.cpuUse.currentLoadUser + data.cpuUse.currentLoadSystem

    setSysInfo((prev) => {
      return {
        ...prev,
        cpu: {
          speed: data.cpu.speed,
          core: data.cpu.physicalCores,
          appPercent: cpuAppPercent,
          otherPercent: cpuOtherPercent,
        },
        memory: {
          total: memoryTotal,
          used: memoryUsed,
          app: memoryApp,
        },
        network: {
          ...prev.network,
          desc: data.network.desc,
          type: data.network.type,
        },
      }
    })
  }

  useEffect(() => {
    window.addEventListener('message', handlePostMessage)
    return () => {
      window.removeEventListener('message', handlePostMessage)
    }
  }, [])

  useEffect(() => {
    if (tab === 'overall') {
      let timer
      function getMonitoringInfo() {
        window.ipcRenderer?.invoke('getMonitoringInfo').then((data) => {
          handleSysInfo('monitoring', data)
          timer = setTimeout(getMonitoringInfo, 2000)
        })
      }
      getMonitoringInfo()
      return () => {
        timer && clearTimeout(timer)
      }
    }
  }, [tab])

  /**
   *
   * @returns CPU 监控
   */
  const MonitoringContentBoxCpu = () => {
    return (
      <div className="monitoring-content-box-cpu">
        <div className="header">
          <div className="title">
            <svg className={'icon iconfont'} aria-hidden="true">
              <use xlinkHref="#iconCPU"></use>
            </svg>
            <span>{t('cpu')}</span>
          </div>
          <div className="value">{cpuLabel}</div>
        </div>
        <div className="content">
          <div className="content-item">
            <span className="blue title">{t('appTitle')}</span>
            <span>{sysInfo.cpu.appPercent.toFixed(2)}%</span>
          </div>
          <div className="content-item">
            <span className="gray title">{t('other')}</span>
            <span>{sysInfo.cpu.otherPercent.toFixed(2)}%</span>
          </div>
          <Progress
            percent={sysInfo.cpu.otherPercent}
            strokeColor="#CCCCCC"
            success={{
              percent: sysInfo.cpu.appPercent,
              strokeColor: '#337eff',
            }}
            showInfo={false}
            strokeLinecap="butt"
          />
        </div>
      </div>
    )
  }

  /**
   *
   * @returns 内存监控
   */
  const MonitoringContentBoxMemory = () => {
    return (
      <div className="monitoring-content-box-memory">
        <div className="header">
          <div className="title">
            <svg className={'icon iconfont'} aria-hidden="true">
              <use xlinkHref="#iconneicun"></use>
            </svg>
            <span>{t('memory')}</span>
          </div>
          <div className="value">{sysInfo.memory.total.toFixed(0)} GB</div>
        </div>
        <div className="content">
          <div className="content-item">
            <span className="blue title">{t('appTitle')}</span>
            <span>{sysInfo.memory.app.toFixed(0)} MB</span>
          </div>
          <div className="content-item">
            <span className="gray title">{t('other')}</span>
            <span>{sysInfo.memory.used.toFixed(0)} GB</span>
          </div>
          <Progress
            percent={
              sysInfo.memory.total === 0
                ? 0
                : (sysInfo.memory.used / sysInfo.memory.total) * 100
            }
            strokeColor="#CCCCCC"
            success={{
              percent:
                sysInfo.memory.total === 0
                  ? 0
                  : (sysInfo.memory.app / 1024 / sysInfo.memory.total) * 100,
              strokeColor: '#337eff',
            }}
            showInfo={false}
            strokeLinecap="butt"
          />
        </div>
      </div>
    )
  }

  /**
   *
   * @returns 网络监控
   */
  const MonitoringContentBoxNetwork = () => {
    return (
      <div className="monitoring-content-box-network">
        <div className="header">
          <div className="title">
            <svg className={'icon iconfont'} aria-hidden="true">
              <use xlinkHref="#iconwangluo"></use>
            </svg>
            <span>{t('network')}</span>
          </div>
          <div className="value">
            {networkRttLabel}
            <svg
              className={'icon iconfont icon-status'}
              aria-hidden="true"
              onClick={() => openMonitoringWindow('network')}
            >
              <use xlinkHref="#iconzhuangtai"></use>
            </svg>
          </div>
        </div>
        <div className="network-content">
          <div className="content-item">
            <span className="title">{t('bandwidth')}</span>
            <span>
              <span>
                <svg className="icon iconfont arrow" aria-hidden="true">
                  <use xlinkHref="#icona-Frame341"></use>
                </svg>
                {sysInfo.network.txKBitRate}kbps
              </span>
              <span>
                <svg className="icon iconfont arrow" aria-hidden="true">
                  <use xlinkHref="#icona-Frame340"></use>
                </svg>
                {sysInfo.network.rxKBitRate}kbps
              </span>
            </span>
          </div>
          <div className="content-item">
            <span className="title">{t('packageLossRate')}</span>
            <span>
              <span>
                <svg className="icon iconfont arrow" aria-hidden="true">
                  <use xlinkHref="#icona-Frame341"></use>
                </svg>
                {sysInfo.network.txPacketLossRate}%
              </span>
              <span>
                <svg className="icon iconfont arrow" aria-hidden="true">
                  <use xlinkHref="#icona-Frame340"></use>
                </svg>
                {sysInfo.network.rxPacketLossRate}%
              </span>
            </span>
          </div>
          <div className="content-item">
            <span className="title">{t('network')}</span>
            <span>{sysInfo.network.desc}</span>
          </div>
          <div className="content-item">
            <span className="title">{t('networkType')}</span>
            <span>{sysInfo.network.type}</span>
          </div>
        </div>
      </div>
    )
  }

  /**
   * @returns 音视频监控
   */
  const MonitoringContentBoxAudio = () => {
    return (
      <div className="monitoring-content-box-audio">
        <div className="header">
          <div className="title">
            <svg className={'icon iconfont'} aria-hidden="true">
              <use xlinkHref="#iconyinpin1"></use>
            </svg>
            <span>{t('audio')}</span>
          </div>
          <div className="value">
            <svg
              className={'icon iconfont icon-status'}
              aria-hidden="true"
              onClick={() => openMonitoringWindow('audio')}
            >
              <use xlinkHref="#iconzhuangtai"></use>
            </svg>
          </div>
        </div>
        <div className="content">
          <div className="content-item">
            <span className="title">{t('bitrate')}</span>
            <span>
              <div>
                <svg className="icon iconfont " aria-hidden="true">
                  <use xlinkHref="#icona-Frame341"></use>
                </svg>
                {sysInfo.audio.txKBitRate} kbps
              </div>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame340"></use>
                </svg>
                {sysInfo.audio.rxKBitRate} kbps
              </div>
            </span>
          </div>
          <div className="content-item">
            <span className="title">{t('microphone')}</span>
            <span>{sysInfo.audio.recordVolume} dB</span>
          </div>
          <div className="content-item">
            <span className="title">{t('speaker')}</span>
            <span>{sysInfo.audio.playVolume} dB</span>
          </div>
        </div>
      </div>
    )
  }

  const MonitoringContentBoxVideo = (type: 'video' | 'screen') => {
    const title =
      type === 'video' ? (
        <div className="title">
          <svg className={'icon iconfont'} aria-hidden="true">
            <use xlinkHref="#iconshipin1"></use>
          </svg>
          <span>{t('video')}</span>
        </div>
      ) : (
        <div className="title">
          <svg className={'icon iconfont'} aria-hidden="true">
            <use xlinkHref="#iconzhiliangjiance"></use>
          </svg>
          <span>{t('screenShare')}</span>
        </div>
      )

    const txResolutionLabel = `${sysInfo[type].txResolution}`

    const txHzLabel = `${sysInfo[type].txHz} fps`

    const txKBitRateLabel = `${sysInfo[type].txKBitRate} kbps`

    const rxResolutionLabel = `${sysInfo[type].rxResolution}`

    const rxHzLabel = `${sysInfo[type].rxHz} fps`

    const rxKBitRateLabel = `${sysInfo[type].rxKBitRate} kbps`

    return (
      <div className="monitoring-content-box-video">
        <div className="header">
          {title}
          <div className="value">
            <svg
              className={'icon iconfont icon-status'}
              aria-hidden="true"
              onClick={() => openMonitoringWindow(type)}
            >
              <use xlinkHref="#iconzhuangtai"></use>
            </svg>
          </div>
        </div>
        <div className="content">
          <div className="content-item">
            <span className="title">{t('resolution')}</span>
            <span>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame341"></use>
                </svg>
                {txResolutionLabel}
              </div>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame340"></use>
                </svg>
                {rxResolutionLabel}
              </div>
            </span>
          </div>
          <div className="content-item">
            <span className="title">{t('frameRate')}</span>
            <span>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame341"></use>
                </svg>
                {txHzLabel}
              </div>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame340"></use>
                </svg>
                {rxHzLabel}
              </div>
            </span>
          </div>
          <div className="content-item">
            <span className="title">{t('bitrate')}</span>
            <span>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame341"></use>
                </svg>
                {txKBitRateLabel}
              </div>
              <div>
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icona-Frame340"></use>
                </svg>
                {rxKBitRateLabel}
              </div>
            </span>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="nemeeting-setting-monitoring">
      <Radio.Group
        defaultValue="overall"
        buttonStyle="solid"
        value={tab}
        onChange={(value) => setTab(value.target.value)}
      >
        <Radio.Button value="overall">{t('overall')}</Radio.Button>
        <Radio.Button value="av">{t('soundAndVideo')}</Radio.Button>
      </Radio.Group>
      <div className="monitoring-content">
        {tab === 'overall' ? (
          <>
            {MonitoringContentBoxCpu()}
            {MonitoringContentBoxMemory()}
            {MonitoringContentBoxNetwork()}
          </>
        ) : (
          <>
            {MonitoringContentBoxAudio()}
            {MonitoringContentBoxVideo('video')}
            {MonitoringContentBoxVideo('screen')}
          </>
        )}
      </div>
    </div>
  )
}

export default MonitoringSetting
