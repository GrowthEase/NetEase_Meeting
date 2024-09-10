import { isPromiseCheck } from '../utils'

interface PostMessageHandle {
  handlePostMessage: (
    childWindow: Window,
    result: unknown,
    replyKey: string
  ) => void
}

export default function usePostMessageHandle(): PostMessageHandle {
  function handlePostMessage(childWindow, result, replyKey) {
    if (isPromiseCheck(result)) {
      result
        .then((res) => {
          postMessage(childWindow, replyKey, {
            result: res,
            error: null,
          })
        })
        .catch((error) => {
          if (error.message) {
            postMessage(childWindow, replyKey, {
              error: { message: error.message, code: error.code },
            })
          } else {
            postMessage(childWindow, replyKey, {
              error,
            })
          }
        })
    } else {
      postMessage(childWindow, replyKey, {
        result,
        error: null,
      })
    }
  }

  function postMessage(childWindow, replyKey, payload) {
    childWindow?.postMessage(
      {
        event: replyKey,
        payload,
      },
      '*'
    )
  }

  return {
    handlePostMessage,
  }
}
