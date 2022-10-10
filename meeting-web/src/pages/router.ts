import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    component: () => import('./main.vue'),
    children: [
      {
        path: '',
        component: () => import('./index/index.vue'),
        redirect: '/join',
        children: [
          {
            path: 'join',
            component: () => import('./join/index.vue'),
          },
        ],
      },
    ],
  },
  {
    path: '/meeting/:meetingId',
    name: 'meeting',
    component: () => import('./meeting/index.vue'),
  },
  {
    path: '/meeting/',
    redirect: '/join',
  },
  {
    path: '*',
    name: '404',
    component: () => import('./404.vue'),
  },
]

const router = new VueRouter({
  mode: 'history',
  base: '/app/',
  routes,
})

router.beforeEach((to, from, next) => {
  document.title = '网易会议'
  next()
})

export default router
