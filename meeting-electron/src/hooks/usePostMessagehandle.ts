import { isPromiseCheck } from '../utils'

export default function usePostMessageHandle() {
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
          postMessage(childWindow, replyKey, {
            error,
          })
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
