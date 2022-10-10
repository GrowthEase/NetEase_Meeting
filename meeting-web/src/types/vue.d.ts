import { Store } from 'vuex/types/index'
import VueRouter, { Route } from 'vue-router/types/index'
import { NeMeeting } from './index'

declare module 'vue/types/vue' {
  interface Vue {
    $neMeeting: NeMeeting
    $roomkit: any
    $store: Store<any>
    $router: VueRouter
    $route: Route
    $toast(msg, duration?, cb?): void
    $toastChat(msg, duration?, cb?): void
    $EventBus: any
  }
}
