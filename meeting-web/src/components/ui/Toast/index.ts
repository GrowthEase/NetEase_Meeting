import VToast from './index.vue'
const isWebSite = process.env.VUE_APP_VERSION === 'website'
const toast = {
  install: (Vue) => {
    const toastList: any = []
    const toastBottomList: any = []
    let seed = 1
    const container = document.createElement('div')
    container.className = 'v-toast-container'
    const containerBottom = document.createElement('div')
    containerBottom.className = 'v-toast-container-bottom'
    Vue.nextTick(() => {
      if (!isWebSite) {
        if (document.querySelector('#ne-web-meeting')) {
          ;(document.querySelector('#ne-web-meeting') as any).appendChild(
            container
          )
          ;(document.querySelector('#ne-web-meeting') as any).appendChild(
            containerBottom
          )
        }
      } else {
        if (document.querySelector('.nemeeting-main')) {
          ;(document.querySelector('.nemeeting-main') as any).appendChild(
            container
          )
          ;(document.querySelector('.nemeeting-main') as any).appendChild(
            containerBottom
          )
        }
      }
    })
    const onClose = (ele, type) => {
      const arr = type === 1 ? toastList : toastBottomList
      for (let i = 0; i < arr.length; i++) {
        const item: any = arr[i]
        if (ele.seed === item.seed) {
          arr.splice(i, 1)
        }
      }
    }
    const appendContainer = () => {
      // 理论只有组件会这样，web站点不会去执行
      if (!isWebSite) {
        if (document.querySelector('#ne-web-meeting')) {
          if (!document.querySelector('div.v-toast-container')) {
            ;(document.querySelector('#ne-web-meeting') as any).appendChild(
              container
            )
          }
          if (!document.querySelector('div.v-toast-container-bottom')) {
            ;(document.querySelector('#ne-web-meeting') as any).appendChild(
              containerBottom
            )
          }
        }
      }
    }

    Vue.prototype.$toast = (msg, duration = 2000, cb = () => true) => {
      appendContainer()
      const ToastCon = VToast
      const ins: any = new ToastCon()
      ins.message = msg
      ins.duration = duration
      ins.showToast = true
      ins.seed = seed++
      ins.onClose = () => onClose(ins, 1)
      ins.toastCb = () => cb()
      ins.$mount()
      container.appendChild(ins.$el)
      // if (toastList.length >= 5) {
      //   toastList[0].onClose();
      //   // toastList[0].$destroy()
      //   // toastList.shift()
      // } else {
      toastList.push(ins)
      // }
    }
    Vue.prototype.$toastChat = (msg, duration = 2000, cb = () => true) => {
      appendContainer()
      const ToastCon = VToast
      const ins: any = new ToastCon()
      ins.message = msg
      ins.duration = duration
      ins.showToast = true
      ins.isBottomInfo = true
      ins.seed = seed++
      ins.onClose = () => onClose(ins, 2)
      ins.toastCb = () => cb()
      ins.$mount()
      // if (toastBottomList.length >= 5) {
      //   // removeEL.$destroy()
      //   toastBottomList[0].onClose();
      //   // toastBottomList.pop()
      // } else {
      toastBottomList.unshift(ins)
      // }
      if (toastBottomList.length === 1) {
        containerBottom.appendChild(ins.$el)
      } else if (toastBottomList.length >= 2) {
        containerBottom.insertBefore(ins.$el, null)
      }
    }
  },
}

export default toast
