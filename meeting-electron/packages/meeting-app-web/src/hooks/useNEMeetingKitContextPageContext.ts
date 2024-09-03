import NEMeetingKit from 'nemeeting-web-sdk';
import { useMemo, useRef } from 'react';

type NEMeetingKitPageContextValue = {
  neMeetingKit: NEMeetingKit;
};

function useNEMeetingKitContextPageContext(): NEMeetingKitPageContextValue {
  const fnReplyCount = useRef(0);

  const neMeetingKit = useMemo(() => {
    function postMessage(
      eventKey: string,
      propKey: string | symbol,
      args: unknown,
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
          if (typeof propKey !== 'string') {
            return;
          }

          if (
            [
              'getMeetingService',
              'getMeetingInviteService',
              'getAccountService',
              'getSettingsService',
              'getPreMeetingService',
              'getMeetingMessageChannelService',
              'getContactsService',
            ].includes(propKey)
          ) {
            return function () {
              const serviceKey = propKey;

              return new Proxy(
                {},
                {
                  get: function (_, propKey) {
                    return function (...args) {
                      return postMessage(serviceKey, propKey, args);
                    };
                  },
                },
              );
            };
          } else {
            return function (...args) {
              return postMessage('neMeetingKit', propKey, args);
            };
          }
        },
      },
    ) as NEMeetingKit;
  }, []);

  return { neMeetingKit };
}

export default useNEMeetingKitContextPageContext;
