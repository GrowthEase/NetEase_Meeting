import { changeConsole } from '@/utils'

let hasInit = false

function initLog() {
  if (!hasInit) {
    changeConsole()
    hasInit = true
  }
}

initLog()
