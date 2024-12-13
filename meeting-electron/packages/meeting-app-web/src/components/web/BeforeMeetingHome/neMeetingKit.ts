import { NEAccountServiceListener } from '@meeting-module/kit/interface/service/meeting_account_service';
import { NEMeetingInviteStatusListener } from '@meeting-module/kit/interface/service/meeting_invite_service';
import { NEMeetingMessageChannelListener } from '@meeting-module/kit/interface/service/meeting_message_channel_service';
import { NEMeetingOnInjectedMenuItemClickListener } from '@meeting-module/kit/interface/service/meeting_service';
import { NEPreMeetingListener } from '@meeting-module/kit/interface/service/pre_meeting_service';
import NEMeetingKit, { NEMeetingStatusListener } from 'nemeeting-web-sdk';

let fnReplyCount = 0;

let meetingStatusListeners: NEMeetingStatusListener[] = [];
let accountServiceListeners: NEAccountServiceListener[] = [];
let preMeetingListeners: NEPreMeetingListener[] = [];
let meetingInviteStatusListeners: NEMeetingInviteStatusListener[] = [];
let meetingMessageChannelListeners: NEMeetingMessageChannelListener[] = [];
let meetingOnInjectedMenuItemClickListeners: NEMeetingOnInjectedMenuItemClickListener[] =
  [];

let isInitialized = false;

function postMessage(
  eventKey: string,
  propKey: string | symbol,
  args: unknown,
) {
  return new Promise((resolve, reject) => {
    fnReplyCount += 1;
    const replyKey = `NEMeetingKitElectron-reply-${fnReplyCount}`;

    try {
      window.ipcRenderer?.send('NEMeetingKitElectron', {
        event: eventKey,
        payload: {
          replyKey,
          fnKey: propKey,
          args: args,
        },
      });

      window.ipcRenderer?.once(replyKey, (_, data) => {
        const { result, error } = data;

        if (error) {
          reject(error);
        } else {
          resolve(result);
          if (propKey === 'unInitialize') {
            isInitialized = false;
            meetingStatusListeners = [];
            accountServiceListeners = [];
            preMeetingListeners = [];
            meetingInviteStatusListeners = [];
            meetingMessageChannelListeners = [];
            meetingOnInjectedMenuItemClickListeners = [];
          }

          if (propKey === 'initialize') {
            isInitialized = true;
            window.ipcRenderer?.removeAllListeners(
              'NEMeetingKitElectron-Listener',
            );
            window.ipcRenderer?.on(
              'NEMeetingKitElectron-Listener',
              (_, data) => {
                const { module, fnKey, args } = data;

                const listeners = {
                  meetingStatusListeners: meetingStatusListeners,
                  accountServiceListeners: accountServiceListeners,
                  preMeetingListeners: preMeetingListeners,
                  meetingInviteStatusListeners: meetingInviteStatusListeners,
                  meetingMessageChannelListeners:
                    meetingMessageChannelListeners,
                  meetingOnInjectedMenuItemClickListeners:
                    meetingOnInjectedMenuItemClickListeners,
                }[module];

                listeners?.forEach((listener) => {
                  listener[fnKey]?.(...args);
                });
              },
            );
          }
        }
      });
    } catch {
      // 处理监听
      if (eventKey === 'getMeetingService') {
        if (propKey === 'addMeetingStatusListener') {
          const listener = (args as NEMeetingStatusListener[])[0];

          meetingStatusListeners.push(listener);
        } else if (propKey === 'removeMeetingStatusListener') {
          const listener = (args as NEMeetingStatusListener[])[0];
          const index = meetingStatusListeners.indexOf(listener);

          if (index > -1) {
            meetingStatusListeners.splice(index, 1);
          }
        } else if (propKey === 'setOnInjectedMenuItemClickListener') {
          const listener = (
            args as NEMeetingOnInjectedMenuItemClickListener[]
          )[0];

          meetingOnInjectedMenuItemClickListeners.push(listener);
        }
      } else if (eventKey === 'getAccountService') {
        if (propKey === 'addListener') {
          const listener = (args as NEAccountServiceListener[])[0];

          accountServiceListeners.push(listener);
        } else if (propKey === 'removeListener') {
          const listener = (args as NEAccountServiceListener[])[0];
          const index = accountServiceListeners.indexOf(listener);

          if (index > -1) {
            accountServiceListeners.splice(index, 1);
          }
        }
      } else if (eventKey === 'getPreMeetingService') {
        if (propKey === 'addListener') {
          const listener = (args as NEPreMeetingListener[])[0];

          preMeetingListeners.push(listener);
        } else if (propKey === 'removeListener') {
          const listener = (args as NEPreMeetingListener[])[0];
          const index = preMeetingListeners.indexOf(listener);

          if (index > -1) {
            preMeetingListeners.splice(index, 1);
          }
        }
      } else if (eventKey === 'getMeetingInviteService') {
        if (propKey === 'addMeetingInviteStatusListener') {
          const listener = (args as NEMeetingInviteStatusListener[])[0];

          meetingInviteStatusListeners.push(listener);
        } else if (propKey === 'removeMeetingInviteStatusListener') {
          const listener = (args as NEMeetingInviteStatusListener[])[0];
          const index = meetingInviteStatusListeners.indexOf(listener);

          if (index > -1) {
            meetingInviteStatusListeners.splice(index, 1);
          }
        }
      } else if (eventKey === 'getMeetingMessageChannelService') {
        if (propKey === 'addMeetingMessageChannelListener') {
          const listener = (args as NEMeetingMessageChannelListener[])[0];

          meetingMessageChannelListeners.push(listener);
        } else if (propKey === 'removeMeetingMessageChannelListener') {
          const listener = (args as NEMeetingMessageChannelListener[])[0];
          const index = meetingMessageChannelListeners.indexOf(listener);

          if (index > -1) {
            meetingMessageChannelListeners.splice(index, 1);
          }
        }
      }
    }
  });
}

function getMeetingKitInstance(): NEMeetingKit {
  if (window.isElectronNative) {
    return new Proxy(
      {},
      {
        get: function (_, propKey) {
          if (typeof propKey !== 'string') {
            return;
          }

          if (propKey === 'isInitialized') {
            return isInitialized;
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
              'getFeedbackService',
              'getGuestService',
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
  } else {
    return NEMeetingKit.getInstance();
  }
}

export function checkSystemRequirements(): boolean | undefined {
  return NEMeetingKit.checkSystemRequirements();
}

export default getMeetingKitInstance;
