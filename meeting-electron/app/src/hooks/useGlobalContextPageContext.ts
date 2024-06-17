import EventEmitter from 'eventemitter3';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import NEMeetingService from '../../../src/services/NEMeeting';
import {
  Action,
  ActionType,
  Dispatch,
  GetMeetingConfigResponse,
} from '../../../src/types';
import { NEMeetingInterpretationSettings } from '../../../src/types/type';

const eventEmitter = new EventEmitter();

type GlobalContextPageContextValue = {
  neMeeting?: NEMeetingService;
  eventEmitter?: EventEmitter;
  globalConfig?: GetMeetingConfigResponse;
  interpretationSetting?: NEMeetingInterpretationSettings;
  dispatch: Dispatch;
};

function useGlobalContextPageContext(): GlobalContextPageContextValue {
  const fnReplyCount = useRef(0);
  const [globalConfig, setGlobalConfig] = useState<GetMeetingConfigResponse>();
  const [interpretationSetting, setInterpretationSetting] =
    useState<NEMeetingInterpretationSettings>();
  const dispatch = useCallback((payload: Action<ActionType>) => {
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'globalDispatch',
        payload: payload,
      },
      parentWindow.origin,
    );
  }, []);
  const neMeeting = useMemo(() => {
    function postMessage(
      eventKey: string,
      propKey: string | symbol,
      args: any,
    ) {
      return new Promise((resolve, reject) => {
        fnReplyCount.current += 1;
        const replyKey = `reply-${fnReplyCount.current}`;
        const parentWindow = window.parent;

        parentWindow?.postMessage(
          {
            event: eventKey,
            payload: {
              replyKey,
              fnKey: propKey,
              args: args,
            },
          },
          parentWindow.origin,
        );
        const handleMessage = (e: MessageEvent) => {
          const { event, payload } = e.data;

          if (event === replyKey) {
            const { result, error } = payload;

            if (error) {
              reject(error);
            } else {
              resolve(result);
            }

            window.removeEventListener('message', handleMessage);
          }
        };

        window.addEventListener('message', handleMessage);
      });
    }

    return new Proxy(
      {},
      {
        get: function (_, propKey) {
          if (propKey === 'imInfo') {
            return {};
          }

          if (propKey === 'roomService') {
            return new Proxy(
              {},
              {
                get: function (_, propKey) {
                  if (propKey === 'isSupported') {
                    return true;
                  }

                  return function (...args: any) {
                    return postMessage('roomService', propKey, args);
                  };
                },
              },
            );
          }

          if (propKey === 'previewController') {
            return new Proxy(
              {},
              {
                get: function (_, propKey) {
                  if (propKey === 'isSupported') {
                    return true;
                  }

                  return function (...args: any) {
                    return postMessage('previewController', propKey, args);
                  };
                },
              },
            );
          }

          if (propKey === 'chatController') {
            return new Proxy(
              {},
              {
                get: function (_, propKey) {
                  if (propKey === 'isSupported') {
                    return true;
                  }

                  return function (...args: any) {
                    return postMessage('chatController', propKey, args);
                  };
                },
              },
            );
          }

          if (propKey === 'rtcController') {
            return new Proxy(
              {},
              {
                get: function (_, propKey) {
                  if (propKey === 'isSupported') {
                    return true;
                  }

                  return function (...args: any) {
                    return postMessage('rtcController', propKey, args);
                  };
                },
              },
            );
          }

          return function (...args: any) {
            return postMessage('neMeeting', propKey, args);
          };
        },
      },
    ) as NEMeetingService;
  }, []);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'eventEmitter') {
        eventEmitter.emit.apply(eventEmitter, [payload.key, ...payload.args]);
      } else if (event === 'updateData') {
        const { globalConfig, interpretationSetting } = payload;

        interpretationSetting &&
          setInterpretationSetting(interpretationSetting);
        globalConfig && setGlobalConfig(globalConfig);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return {
    neMeeting,
    eventEmitter,
    globalConfig,
    interpretationSetting,
    dispatch,
  };
}

export default useGlobalContextPageContext;
