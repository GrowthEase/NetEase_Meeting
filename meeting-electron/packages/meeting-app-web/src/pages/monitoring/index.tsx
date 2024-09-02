import { Chart } from '@antv/g2';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Radio } from 'antd';
import { useUpdateEffect } from 'ahooks';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';

import {
  MonitoringData,
  MonitoringDataItem,
} from '@meeting-module/services/NEMeeting';

import './index.less';

const MonitoringPage: React.FC = () => {
  const { t } = useTranslation();

  const chartContainerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<Chart>();

  const [type, setType] = useState<'network' | 'audio' | 'video' | 'screen'>();
  const [monitoringData, setMonitoringData] = useState<MonitoringData>();

  const [radioValue, setRadioValue] = useState('overall');

  const [bitrate, setBitrate] = useState<[number, number]>([0, 0]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'monitoringType') {
        setType(payload);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);
  useUpdateEffect(() => {
    if (chartRef.current) {
      chartRef.current?.changeData([]);
    }
  }, [radioValue]);
  // 非码率图表
  useEffect(() => {
    const sourceData: Record<string, number> = {};
    const data: MonitoringDataItem[] = [];

    if (monitoringData && radioValue !== 'bitrate') {
      if (type === 'network') {
        if (radioValue === 'rtt') {
          monitoringData.network.rtt.forEach((item) => {
            sourceData[item.time] = item.value;
          });
        } else {
          monitoringData.network.packetLossRate.forEach((item) => {
            sourceData[item.time] = item.value;
          });
        }
      } else if (type === 'audio') {
        if (radioValue === 'recordVolume') {
          monitoringData.audio.recordVolume.forEach((item) => {
            sourceData[item.time] = item.value;
          });
        } else if (radioValue === 'playVolume') {
          monitoringData.audio.playVolume.forEach((item) => {
            sourceData[item.time] = item.value;
          });
        }
      }

      const nowTime = Math.floor(Date.now() / 1000);

      for (let i = 0; i < 90; i++) {
        const time = nowTime - i * 2;
        const item =
          sourceData[time] || sourceData[time - 1] || sourceData[time + 1];

        data.unshift({
          value: item || 0,
          time,
        });
      }

      chartRef.current?.changeData(data);
    }
  }, [type, radioValue, monitoringData]);

  // 码率图表
  useEffect(() => {
    const txSourceData: Record<string, number> = {};
    const rxSourceData: Record<string, number> = {};
    const data: Array<MonitoringDataItem & { type: 'tx' | 'rx' }> = [];

    if (monitoringData && radioValue === 'bitrate') {
      if (type === 'audio') {
        monitoringData.audio.audioTxBitrate.forEach((item) => {
          txSourceData[item.time] = item.value;
        });
        monitoringData.audio.audioRxBitrate.forEach((item) => {
          rxSourceData[item.time] = item.value;
        });
      } else if (type === 'video') {
        monitoringData.video.videoTxBitrate.forEach((item) => {
          txSourceData[item.time] = item.value;
        });
        monitoringData.video.videoRxBitrate.forEach((item) => {
          rxSourceData[item.time] = item.value;
        });
      } else if (type === 'screen') {
        monitoringData.screen.screenTxBitrate.forEach((item) => {
          txSourceData[item.time] = item.value;
        });
        monitoringData.screen.screenRxBitrate.forEach((item) => {
          rxSourceData[item.time] = item.value;
        });
      }

      const nowTime = Math.floor(Date.now() / 1000);

      for (let i = 0; i < 90; i++) {
        const time = nowTime - i * 2;
        const rxItem =
          rxSourceData[time] ||
          rxSourceData[time - 1] ||
          rxSourceData[time + 1] ||
          0;

        data.unshift({
          type: 'rx',
          value: rxItem,
          time,
        });
        const txItem =
          txSourceData[time] ||
          txSourceData[time - 1] ||
          txSourceData[time + 1] ||
          0;

        data.unshift({
          type: 'tx',
          value: txItem,
          time,
        });
        if (i === 0) {
          setBitrate([txItem, rxItem]);
        }
      }

      chartRef.current?.changeData(data);
    }
  }, [type, radioValue, monitoringData]);

  // 获取标题
  const title = useMemo(() => {
    switch (type) {
      case 'network':
        return t('networkState');
      case 'audio':
        return t('audio');
      case 'video':
        return t('video') + '-' + t('bitrate');
      case 'screen':
        return t('screenShare') + '-' + t('bitrate');
      default:
        return '';
    }
  }, [type, t]);

  const tips = useMemo(() => {
    switch (type) {
      case 'network':
        if (radioValue === 'rtt') {
          return 'ms';
        }

        return '%';
      case 'audio':
        if (radioValue === 'bitrate') {
          return 'kbps';
        }

        return 'dB';
      default:
        return 'kbps';
    }
  }, [type, radioValue]);

  const radioItems = useMemo(() => {
    switch (type) {
      case 'network':
        setRadioValue('rtt');
        return [
          { label: t('delay'), value: 'rtt' },
          { label: t('packageLossRate'), value: 'packetLossRate' },
        ];
      case 'audio':
        setRadioValue('recordVolume');
        return [
          { label: t('microphoneAcquisition'), value: 'recordVolume' },
          { label: t('speakerPlayback'), value: 'playVolume' },
          { label: t('bitrate'), value: 'bitrate' },
        ];
      default:
        setRadioValue('bitrate');
        return [];
    }
  }, [type]);

  // 初始化图表
  useEffect(() => {
    if (chartContainerRef.current) {
      if (!chartRef.current) {
        chartRef.current = new Chart({
          container: chartContainerRef.current,
          autoFit: true,
        });
      }

      const chart = chartRef.current;

      chart.legend(false);
      chart.animate(false);
      chart.data([]);
      chart.axis('x', {
        tick: false,
        label: false,
        title: false,
      });
      chart.axis('y', {
        title: false,
      });
      chart
        .line()
        .encode('x', 'time')
        .encode('y', 'value')
        .encode('color', 'type')
        .scale('color', { range: ['#337EFF', '#5CC871'] })
        .encode('shape', 'smooth')
        .style('strokeWidth', 2)
        .tooltip(false);
      chart.render();
    }
  }, [type]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'monitoring') {
        setMonitoringData(payload);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    // 设置页面标题
    setTimeout(() => {
      document.title = title;
    });
  }, [title]);

  return (
    <>
      <div className="electron-drag-bar">
        <div className="drag-region" />
        <span
          style={{
            fontWeight: 'bold',
          }}
          className="title"
        >
          {title}
        </span>
        <PCTopButtons size="normal" minimizable={false} maximizable={false} />
      </div>
      <div className="monitoring-wrapper">
        {radioItems.length > 0 && (
          <Radio.Group
            defaultValue="overall"
            buttonStyle="solid"
            value={radioValue}
            onChange={(value) => setRadioValue(value.target.value)}
          >
            {radioItems.map((item) => (
              <Radio.Button value={item.value} key={item.value}>
                {item.label}
              </Radio.Button>
            ))}
          </Radio.Group>
        )}
        <div className="chart-tips">
          <span>{tips}</span>
          <span>{t('recently')} 3min</span>
        </div>
        <div ref={chartContainerRef} className="chart" />
        {radioValue === 'bitrate' ? (
          <div className="chat-bitrate">
            <svg className="icon iconfont arrow" aria-hidden="true">
              <use xlinkHref="#icona-Frame341"></use>
            </svg>
            {bitrate[0]} kbps
            <svg className="icon iconfont arrow" aria-hidden="true">
              <use xlinkHref="#icona-Frame340"></use>
            </svg>
            {bitrate[1]} kbps
          </div>
        ) : null}
      </div>
    </>
  );
};

export default MonitoringPage;
