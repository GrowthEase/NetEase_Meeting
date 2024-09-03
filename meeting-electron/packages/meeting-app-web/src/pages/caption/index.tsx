import React, { useEffect, useRef, useState } from 'react';
import { Caption } from '@meeting-module/components/web/Caption';
import { useGlobalContext, useMeetingInfoContext } from '@meeting-module/store';
import { ActionType, NEMeetingCaptionMessage } from '@meeting-module/types';
import { IPCEvent } from '@meeting-module/app/src/types';
import './index.less';
import { createDefaultCaptionSetting } from '@meeting-module/services';
import { NERoomCaptionTranslationLanguage } from 'neroom-types';
import { setLocalStorageSetting } from '@meeting-module/utils';

const CaptionPage: React.FC = () => {
  const { neMeeting } = useGlobalContext();
  const { meetingInfo, dispatch } = useMeetingInfoContext();
  const captionElementRef = useRef<HTMLDivElement>(null);
  const isMouseOverCaptionRef = useRef(false);

  const [captionMessageList, setCaptionMessageList] = useState<
    NEMeetingCaptionMessage[]
  >([]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const { captionMessageList } = payload;

        console.log('update>>>', captionMessageList);
        captionMessageList && setCaptionMessageList(captionMessageList);
      } else if (event === 'closeCaptionWindow') {
        if (!isMouseOverCaptionRef.current) {
          window.close();
        }
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  function onAllowParticipantsEnableCaption(allow: boolean) {
    neMeeting?.liveTranscriptionController?.allowParticipantsEnableCaption(
      allow,
    );
  }

  const handleMouseOut = () => {
    isMouseOverCaptionRef.current = false;
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        isMouseOverCaption: false,
      },
    });
    if (!meetingInfo.canShowCaption) {
      window.close();
    }
  };

  useEffect(() => {
    const heightMap = {
      12: 92,
      15: 108,
      18: 132,
      21: 140,
      24: 240,
    };

    // 添加header 32
    window.ipcRenderer?.send(IPCEvent.captionWindowChange, {
      height:
        heightMap[meetingInfo.setting?.captionSetting?.fontSize || 15] + 32,
    });
  }, [meetingInfo.setting?.captionSetting?.fontSize]);

  function onCaptionSizeChange(size: number) {
    const setting = meetingInfo.setting;

    if (!setting.captionSetting) {
      setting.captionSetting = createDefaultCaptionSetting();
    } else {
      setting.captionSetting.fontSize = size;
    }

    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }

  function onClickCloseCaption() {
    neMeeting?.enableCaption(false);
  }

  function onCaptionShowBilingual(enable: boolean): void {
    const setting = meetingInfo.setting;

    if (!setting.captionSetting) {
      setting.captionSetting = createDefaultCaptionSetting();
    } else {
      setting.captionSetting.showCaptionBilingual = enable;
    }

    setLocalStorageSetting(JSON.stringify(setting));
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }

  function onTargetLanguageChange(
    lang: NERoomCaptionTranslationLanguage,
  ): void {
    const setting = meetingInfo.setting;

    if (!setting.captionSetting) {
      setting.captionSetting = createDefaultCaptionSetting();
    } else {
      setting.captionSetting.targetLanguage = lang;
    }

    setLocalStorageSetting(JSON.stringify(setting));
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }

  return (
    <div className="caption-window-page">
      <div
        className="nemeeting-web-caption nemeeting-web-caption-electron"
        ref={captionElementRef}
      >
        <Caption
          onMouseOut={handleMouseOut}
          onMouseOver={() => {
            isMouseOverCaptionRef.current = true;
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                isMouseOverCaption: true,
              },
            });
          }}
          fontSize={meetingInfo.setting?.captionSetting?.fontSize || 15}
          onAllowParticipantsEnableCaption={onAllowParticipantsEnableCaption}
          onCaptionShowBilingual={onCaptionShowBilingual}
          onTargetLanguageChange={onTargetLanguageChange}
          targetLanguage={meetingInfo.setting.captionSetting?.targetLanguage}
          showCaptionBilingual={
            !!meetingInfo.setting.captionSetting?.showCaptionBilingual
          }
          onSizeChange={onCaptionSizeChange}
          onClose={onClickCloseCaption}
          captionMessageList={captionMessageList}
          isAllowParticipantsEnableCaption={
            meetingInfo.isAllowParticipantsEnableCaption
          }
          isElectronWindow={true}
          enableCaptionLoading={!!meetingInfo.enableCaptionLoading}
        />
      </div>
    </div>
  );
};

export default CaptionPage;
